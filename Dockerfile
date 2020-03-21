# I: Runtime Stage: ============================================================
# This is the stage where we build the runtime base image, which is used as the
# common ancestor by the rest of the stages, and contains the minimal runtime
# dependencies required for the application to run:

# Step 1: Use the official Ruby 2.6.3 Slim Strech image as base:
FROM ruby:2.6.3-slim-stretch AS runtime

# Step 2: We'll set the MALLOC_ARENA_MAX for optimization purposes & prevent memory bloat
# https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html
ENV MALLOC_ARENA_MAX="2"

# Step 3: We'll set the LANG encoding to be UTF-8 for special characters support
ENV LANG C.UTF-8

# Step 4: We'll set '/usr/src' path as the working directory:
# NOTE: This is a Linux "standard" practice - see:
# - http://www.pathname.com/fhs/2.2/
# - http://www.pathname.com/fhs/2.2/fhs-4.1.html
# - http://www.pathname.com/fhs/2.2/fhs-4.12.html
WORKDIR /usr/src

# Step 5: We'll set the working dir as HOME and add the app's binaries path to
# $PATH:
ENV HOME=/usr/src PATH=/usr/src/bin:$PATH DEBIAN_FRONTEND=noninteractive

# Step 6: We'll install curl for later dependencies installations
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

# Step 7: Add nodejs source
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Step 8: Add yarn packages repository
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Step 9: Install the common runtime dependencies:
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https software-properties-common \
    ca-certificates \
    graphicsmagick \
    libpq5 \
    openssl \
    graphviz \
    nodejs \
    tzdata \
    yarn && \
    rm -rf /var/lib/apt/lists/*

# II: Development Stage: =======================================================
# In this stage we'll build the image used for development, including compilers,
# and development libraries. This is also a first step for building a releasable
# Docker image:

# Step 10: Start off from the "runtime" stage:
FROM runtime AS development

# Step 11: Set the default command:
CMD [ "rails", "server", "-b", "0.0.0.0" ]

# Step 12: Add Dockerize image
RUN export DOCKERIZE_VERSION=v0.6.1 \
 && curl --progress-bar --location \
    https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 | tar -C /usr/local/bin -xz

# Step 13: Install the development dependency packages with alpine package
# manager:
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    # Build dependency of the pg gem:
    libpq-dev \
    # Required by vscode-remote to figure out the container's ip address:
    net-tools \
    socat \
    # Required by VSCode to properly install vscode-remote as non-root user:
    sudo \
    unzip \
 && rm -rf /var/lib/apt/lists/*

# Step 14: Fetch the pre-built specific version of Chromium & Chromedriver:
# See https://omahaproxy.appspot.com for build / version lookup.
# NOTE: In case your'e using "puppeteer", check the "puppeteer.chrome_revision"
# key at puppeteer's package.json to check which chromium build number is
# compatible with your project's puppeteer version:
RUN export CHROMIUM_BUILD_NUMBER=722269 \
 && mkdir -p /tmp/chromium \
 && cd /tmp/chromium \
 && for FILE in chrome-linux.zip chromedriver_linux64.zip; do \
      # Use wget -O ${FILE} on alpine!
      curl --progress-bar --location --output $FILE \
      "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROMIUM_BUILD_NUMBER}/${FILE}" \
      && unzip ${FILE} -d /opt ; \
    done \
 && ln -s /opt/chrome-linux/chrome /usr/bin/chromium \
 && ln -s /opt/chromedriver_linux64/chromedriver /usr/bin/chromedriver \
 && cd ${HOME} \
 && rm -rf /tmp/chromium

# Step 15: Install the Chromium dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y apt-file \
  && apt-file update \
  && apt-get install --no-install-recommends -y $( \
    ldd /usr/bin/chromium \
    | grep not \
    | sed -E 's/\s+(.+) =.+/\1/' \
    | uniq \
    | apt-file search --from-file - \
    | sed -E 's/(.+):.+/\1/' \
    | uniq \
    | sed -n '/^lib/p' \
  ) \
  && rm -rf /var/lib/apt/lists/*

# Step 16: Install the CodeClimate Reporter
RUN curl --progress-bar --location --output /usr/local/bin/cc-test-reporter \
 -L https://codeclimate.com/downloads/test-reporter/test-reporter-0.6.3-linux-amd64 \
 && chown root:root /usr/local/bin/cc-test-reporter \
 && chmod 0755 /usr/local/bin/cc-test-reporter

# Step 17: Fix npm uid-number error
# - see https://github.com/npm/uid-number/issues/7
RUN npm config set unsafe-perm true

# Step 18: Install the 'check-dependencies' node package:
RUN npm install -g check-dependencies

# Step 19: Copy the project's Gemfile + lock:
COPY Gemfile* /usr/src/

# Step 20: Install the current project gems - they can be safely changed later
# during development via `bundle install` or `bundle update`:
RUN bundle install --jobs=4 --retry=3

# Step 21: Copy the project's node package dependency lists:
COPY package.json yarn.lock /usr/src/

# Step 22: Install the project's node packages:
RUN yarn install

# Step 23: Receive the developer user's UID:
ARG DEVELOPER_UID=1000

# Step 24: Receive the developer user's username:
ARG DEVELOPER_USERNAME=you

# Step 25: Set the developer's UID as an environment variable:
ENV DEVELOPER_UID=${DEVELOPER_UID}

# Step 26: Create the developer user:
RUN useradd -r -M -u ${DEVELOPER_UID} -d /usr/src -c "Developer User,,," ${DEVELOPER_USERNAME} \
 && echo ${DEVELOPER_USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${DEVELOPER_USERNAME} \
 && chmod 0440 /etc/sudoers.d/${DEVELOPER_USERNAME}

# III: Testing stage: ==========================================================
# In this stage we'll add the current code from the project's source, so we can
# run tests with the code.

# Step 27: Start off from the development stage image:
FROM development AS testing

# Step 28: Copy the rest of the application code
COPY . /usr/src

# IV: Builder stage: ===========================================================
# In this stage we'll compile assets coming from the project's source, do some
# tests and cleanup. If the CI/CD that builds this image allows it, we should
# also run the app test suites here:

# Step 29: Start off from the development stage image:
FROM testing AS builder

# Step 30: Precompile assets:
RUN export DATABASE_URL=postgres://postgres@example.com:5432/fakedb \
    SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece \
    RAILS_ENV=production && \
    rails assets:precompile && \
    rails secret > /dev/null

# Step 31: Remove installed gems that belong to the development & test groups -
# we'll copy the remaining system gems into the deployable image on the next
# stage:
RUN bundle config without development:test && bundle clean

# Step 32: Remove files not used on release image:
RUN rm -rf \
    .rspec \
    Guardfile \
    bin/rspec \
    bin/checkdb \
    bin/dumpdb \
    bin/restoredb \
    bin/setup \
    bin/spring \
    bin/update \
    bin/dev-entrypoint.sh \
    config/spring.rb \
    node_modules \
    spec \
    config/initializers/listen_patch.rb \
    tmp/*

# V: Release stage: ============================================================
# In this stage, we build the final, deployable Docker image, which will be
# smaller than the images generated on previous stages:

# Step 33: Start off from the runtime stage image:
FROM runtime AS release

# Step 34: Copy the remaining installed gems from the "builder" stage:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Step 35: Copy the app code from the "builder" stage, which at this point
# should have the assets from the asset pipeline already compiled:
COPY --from=builder --chown=nobody:nogroup /usr/src /usr/src

# Step 36: Set the RAILS/RACK_ENV and PORT default values:
ENV RAILS_ENV=production RACK_ENV=production PORT=3000 DEBIAN_FRONTEND=dialog

# Step 37: Generate the temporary directories in case they don't already exist:
RUN mkdir -p /usr/src/tmp/cache /usr/src/tmp/pids /usr/src/tmp/sockets \
 && chown -R nobody:nogroup /usr/src/tmp

# Step 38: Set the container user to 'nobody':
USER nobody

# Step 39: Set the default command:
CMD [ "puma" ]

# Step 40 thru 44: Add label-schema.org labels to identify the build info:
ARG SOURCE_BRANCH="master"
ARG SOURCE_COMMIT="000000"
ARG BUILD_DATE="2017-09-26T16:13:26Z"
ARG IMAGE_NAME="consume-local:latest"

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="consume-local" \
      org.label-schema.description="consume-local" \
      org.label-schema.vcs-url="https://github.com/Consume-Local/platform" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      build-target="release" \
      build-branch=$SOURCE_BRANCH
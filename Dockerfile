############################
# Final container
############################
FROM registry.cto.ai/official_images/bash:2-bullseye-slim

# Install the build dependencies and clean up the install in the same layer.
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    # Install python build dependencies
    apt-get install -y build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl git \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pipx to install poetry to manage our Python dependencies.
RUN python3 -m pip install --user pipx && \
    /root/.local/bin/pipx install --global pipx poetry

##############################################################################
# As a security best practice the container will always run as non-root user.
##############################################################################
USER ops
WORKDIR /ops

# Set the `ASDF_VERSION_TAG` and `ASDF_DIR` environment variables manually to
# ensure that the correct version of the tool is installed in `/ops/.asdf`.
ENV ASDF_VERSION_TAG=v0.14.1 \
    ASDF_DIR=/ops/.asdf \
    ASDF_DATA_DIR=/ops/.asdf \
    ASDF_FORCE_PREPEND=yes \
    ASDF_CONFIG_FILE=/ops/.asdfrc \
    HOME=/ops \
    PATH=/ops/.asdf/shims:/ops/.asdf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Copy the contents of the `lib/` directory into the root of the image. This
# means, for example, that the `./lib/build/` directory will be at `/build/`.
COPY --chown=ops:9999 lib/build/ /build/

# Run the script that will install the `asdf` tool, the plugins necessary to
# install the tools specified in the `.tool-versions` file, and then install
# the tools themselves. This is how a more recent version of Node.js will be
# installed and managed in our image.
RUN bash /build/install-asdf-tools.sh

# Copy the dependencies files to the working directory and then install those
# dependencies with the appropriate package manager.
COPY --chown=ops:9999 pyproject.toml poetry.lock ./

# The pyproject.toml file sets the `package-mode = false` option, meaning that
# the `poetry install` command will only install the dependencies and not
# attempt to install the root package itself.
RUN poetry env use $(asdf which python) && \
    poetry install
COPY --chown=ops:9999 . /ops/

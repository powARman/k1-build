ARG VARIANT="jammy"
FROM buildpack-deps:${VARIANT}-curl

# Local fix for issue with timezone data at 'buildpack-deps'. Ref# https://github.com/devcontainers/images/issues/1709
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y reinstall --no-install-recommends tzdata \
    && echo "Etc/UTC" > /etc/timezone

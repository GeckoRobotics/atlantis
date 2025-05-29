FROM ghcr.io/runatlantis/atlantis:v0.34.0

# COPY secret-entrypoint.sh /usr/local/bin/secret-entrypoint.sh

USER root

ARG CLOUD_SDK_VERSION=503.0.0

RUN apk --no-cache upgrade && apk --no-cache add \
  curl \
  python3 \
  py3-crcmod \
  py3-openssl \
  bash \
  libc6-compat \
  openssh-client \
  git \
  gnupg \
  && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && tar xzf google-cloud-cli-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && rm google-cloud-cli-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && rm -rf /var/cache/apk/* \
  && /google-cloud-sdk/bin/gcloud config set core/disable_usage_reporting true \
  && /google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true \
  && /google-cloud-sdk/bin/gcloud config set metrics/environment github_docker_image

ARG TERRAGRUNT_ATLANTIS_CONFIG_VERSION=1.20.0

RUN curl -LO https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 \
  && mv terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 terragrunt-atlantis-config \
  && install terragrunt-atlantis-config /usr/local/bin

ARG TG_VERSION=v0.80.4

RUN curl -sS -L \
  "https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}/terragrunt_linux_amd64" \
  -o /usr/local/bin/terragrunt \
  && chmod +x /usr/local/bin/terragrunt

USER atlantis


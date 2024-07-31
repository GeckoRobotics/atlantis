FROM ghcr.io/runatlantis/atlantis:v0.28.5-debian@sha256:1363cd727cd0a22627d15ce6bf3c6fe7cb7a2aaff64b03d231814966656865a3

COPY secret-entrypoint.sh /usr/local/bin/secret-entrypoint.sh

USER root

RUN apt-get update && \
  apt-get install -y --no-install-recommends python3=3.11.2-1+b1 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG TG_VERSION=v0.64.2

RUN curl -sS -L \
  "https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}/terragrunt_linux_amd64" \
  -o /usr/local/bin/terragrunt \
  && chmod +x /usr/local/bin/terragrunt

USER atlantis

ENTRYPOINT ["secret-entrypoint.sh"]
CMD ["server"]

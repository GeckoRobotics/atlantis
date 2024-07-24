FROM ghcr.io/runatlantis/atlantis:v0.28.5-debian@sha256:1363cd727cd0a22627d15ce6bf3c6fe7cb7a2aaff64b03d231814966656865a3

COPY secret-entrypoint.sh /usr/local/bin/secret-entrypoint.sh

ENTRYPOINT ["secret-entrypoint.sh"]

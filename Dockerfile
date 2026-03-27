FROM python:3.11-slim

ARG RETICULUM_REF=master
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/local/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libssl-dev \
      libffi-dev \
      git \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install the rns package from the Reticulum repo at the requested ref
RUN pip install --no-cache-dir "git+https://github.com/markqvist/Reticulum.git@${RETICULUM_REF}#egg=rns"

# Create system group and user (similar to NomadNet pattern)
RUN groupadd -r rnsuser && useradd -r -m -g rnsuser -s /bin/bash rnsuser
WORKDIR /home/rnsuser

# Persist Reticulum configuration
VOLUME /home/rnsuser/.reticulum

# Keep running as root so entrypoint can fix mount permissions, then drop to rnsuser
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--service"]

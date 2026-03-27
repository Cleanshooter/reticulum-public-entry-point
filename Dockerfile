## Build stage: create a virtualenv and install Reticulum into it
FROM python:3.11-slim AS build

ARG RETICULUM_REF=master
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libssl-dev \
      libffi-dev \
      git \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create a venv and install into it to avoid pip-as-root warnings
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install the rns package from the Reticulum repo at the requested ref
RUN pip install --no-cache-dir "git+https://github.com/markqvist/Reticulum.git@${RETICULUM_REF}#egg=rns"

## Final stage: copy the venv and produce a small runtime image
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:${PATH}"

# Copy venv from build stage
COPY --from=build /opt/venv /opt/venv

# Create system group and user (similar to NomadNet pattern)
RUN groupadd -r rnsuser && useradd -r -m -g rnsuser -s /bin/bash rnsuser
WORKDIR /home/rnsuser

# Persist Reticulum configuration
VOLUME /home/rnsuser/.reticulum

COPY reticulum-config.template /home/rnsuser/reticulum-config.template
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

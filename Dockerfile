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


WORKDIR /rns-pep

# Persist unified config/data directory
VOLUME /rns-pep

# Create config/data directory and copy templates
RUN mkdir -p /rns-pep
COPY reticulum-config.template /rns-pep/reticulum-config.template
COPY lxmd-config.template /rns-pep/lxmd-config.template
COPY rns-page-node-config.template /rns-pep/rns-page-node-config.template
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Install system dependencies for Reticulum, rns-page-node, and supervisor
RUN apt-get update && \
  apt-get install -y --no-install-recommends wget unzip supervisor bsdmainutils && \
  rm -rf /var/lib/apt/lists/*

# Install LXMF
RUN pip install --no-cache-dir lxmf

# Install rns-page-node from Gitea registry
RUN pip install --index-url https://git.quad4.io/api/packages/RNS-Things/pypi/simple/ --extra-index-url https://pypi.org/simple rns-page-node

# Expose default ports
# TODO Verify ports: looks like AI halucination to me... 
EXPOSE 4242 8080 8081

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Use supervisord as entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

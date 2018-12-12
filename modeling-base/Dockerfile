FROM python:3.6-slim

ENV PYTHONUNBUFFERED=1

ARG CWD=/opt
ARG REPO_URL
ARG GITHUB_TOKEN
ARG CPLEX="cplex_128.tar.gz"

RUN set -eux \
    && apt-get update \
    && apt-get install --yes --only-upgrade openssl ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR "${CWD}"

COPY requirements.in ./

RUN set -eux \
    && pip install --upgrade pip setuptools wheel pip-tools \
    && pip-compile --generate-hashes \
        --output-file requirements.txt requirements.in \
    && pip-sync requirements.txt \
    && rm -rf /root/.cache \
    && rm -rf /tmp/* /var/tmp/*

# Install CPLEX afterwards when pip was already upgraded.

COPY cplex_128.tar.gz ./

RUN set -eux \
    && tar -xzf "${CPLEX}" \
    && pip --no-cache-dir install cplex_128/python/3.6/x86-64_linux \
    && rm -rf cplex_128*

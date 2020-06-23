# Copyright (c) 2020 Novo Nordisk Foundation Center for Biosustainability,
# Technical University of Denmark.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM python:3.6-slim

LABEL dk.dtu.biosustain.iam.alpine.vendor="Novo Nordisk Foundation \
Center for Biosustainability, Technical University of Denmark"
LABEL maintainer="niso@biosustain.dtu.dk"

WORKDIR "/opt"

RUN set -eux \
    && apt-get update \
    && apt-get install --yes --only-upgrade openssl ca-certificates \
    && apt-get install --yes build-essential libpq-dev libpq5 \
    && pip install --upgrade pip setuptools wheel \
    && pip install pip-tools pip-licenses

COPY --from=dddecaf/wsgi-base:alpine /opt/base-requirements.txt ./

COPY --from=dddecaf/postgres-base:alpine /opt/sql-requirements.txt ./

COPY --from=gcr.io/dd-decaf-cfbf6/modeling-base:cameo /opt/modeling-requirements.txt ./

COPY requirements/ ./

COPY install.sh ./

RUN set -eux \
    && ./install.sh

CMD ["pip-licenses", \
    "--from", "mixed", \
    "--with-urls", \
    "--order", "name", \
    "--format", "csv"]

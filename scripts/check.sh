#!/usr/bin/env bash

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

set -u

FAILURE=0

check() {
    /usr/bin/env bash -c "which $1 > /dev/null"
    ret=$?
    if (( $ret > $FAILURE )); then
        FAILURE=$ret
    fi
    if (( $ret == 0 )); then
        echo "$1: ok"
    else
        echo "$1: no"
    fi
}

check "bash"
check "git"
check "docker"
check "docker-compose"

# Check for the presence of a CPLEX compressed archive.
if [[ -f "$(find cplex -iname 'cplex*.tar.gz')" ]]; then
    echo "CPLEX: ok"
else
    echo "CPLEX: no"
    if (( 1 > $FAILURE )); then
        FAILURE=1
    fi
fi

# Check for the presence of the POSTGRES_PASSWORD variable.

exit ${FAILURE}

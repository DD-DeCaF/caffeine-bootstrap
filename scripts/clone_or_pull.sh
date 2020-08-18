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

set -eu

get_default_branch() {
    basename $(cat .git/refs/remotes/origin/HEAD | awk '{ print $2 }')
}

if [ -d "${1}" ]; then
    pushd "${1}"
    branch=$(get_default_branch)
    git stash
    git checkout ${branch}
    git pull origin ${branch}
    popd
else
    git clone --depth 3 https://github.com/dd-decaf/${1}
fi

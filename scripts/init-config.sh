#!/usr/bin/env bash
# Copyright © 2023 OpenIM. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script automatically initializes the various configuration files
# Read: https://github.com/OpenIMSDK/Open-IM-Server/blob/main/docs/contrib/init_config.md

set -o errexit
set -o nounset
set -o pipefail

OPENIM_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

source "${OPENIM_ROOT}/scripts/lib/init.sh"

# 定义一个配置文件数组，其中包含需要生成的配置文件的名称路径 
# (en: Define a profile array that contains the name path of the profile to be generated.)
readonly ENV_FILE=${ENV_FILE:-"${OPENIM_ROOT}/scripts/install/environment.sh"}

# 定义关联数组，其中键是模板文件，值是对应的输出文件 
# (en: Defines an associative array where the keys are the template files and the values are the corresponding output files.)
declare -A TEMPLATES=(
  ["${OPENIM_ROOT}/templates/env_template.yaml"]="${OPENIM_ROOT}/.env;${OPENIM_ROOT}/example/.env"
  ["${OPENIM_ROOT}/templates/openim.yaml"]="${OPENIM_ROOT}/openim-server/main/config/config.yaml;${OPENIM_ROOT}/openim-server/release-v3.2/config/config.yaml;"
)

for template in "${!TEMPLATES[@]}"; do
  if [[ ! -f "${template}" ]]; then
    openim::log::error_exit "template file ${template} does not exist..."
  fi

  IFS=';' read -ra OUTPUT_FILES <<< "${TEMPLATES[$template]}"
  for output_file in "${OUTPUT_FILES[@]}"; do
    openim::log::info "⌚  Working with template file: ${template} to ${output_file}..."
    "${OPENIM_ROOT}/scripts/genconfig.sh" "${ENV_FILE}" "${template}" > "${output_file}" || {
      openim::log::error "Error processing template file ${template}"
      exit 1
    }
  done
done

openim::log::success "✨  All configuration files have been successfully generated!"

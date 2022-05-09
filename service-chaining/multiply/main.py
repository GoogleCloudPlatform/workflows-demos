# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START workflows_functions_multiply]
import functions_framework
from flask import jsonify


@functions_framework.http
def multiply(request):
    request_json = request.get_json()
    output = {"multiplied": 2 * request_json['input']}
    return jsonify(output)
# [END workflows_functions_multiply]

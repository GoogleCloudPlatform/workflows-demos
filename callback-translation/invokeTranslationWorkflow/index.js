// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [START workflows_invoke_translation]
const cors = require('cors')({origin: true});
const {ExecutionsClient} = require('@google-cloud/workflows');
const client = new ExecutionsClient();

exports.invokeTranslationWorkflow = async (req, res) => {
  cors(req, res, async () => {
    const text = req.body.text;
    console.log(`Translation request for "${text}"`);

    const PROJECT_ID = process.env.PROJECT_ID;
    const CLOUD_REGION = process.env.CLOUD_REGION;
    const WORKFLOW_NAME = process.env.WORKFLOW_NAME;

    const execResponse = await client.createExecution({
      parent: client.workflowPath(PROJECT_ID, CLOUD_REGION, WORKFLOW_NAME),
      execution: {
        argument: JSON.stringify({text})
      }
    });
    console.log(`Translation workflow execution request: ${JSON.stringify(execResponse)}`);

    const execName = execResponse[0].name;
    console.log(`Created translation workflow execution: ${execName}`);

    res.set('Access-Control-Allow-Origin', '*');
    res.status(200).json({executionId: execName});
  });
};
// [END workflows_invoke_translation]

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
// [START workflows_callback_translation]
const cors = require('cors')({origin: true});
const fetch = require('node-fetch');

function isValidCallbackUrl(urlString) {
  try {
    const parsed = new URL(urlString);
    if (parsed.protocol !== 'https:') {
      return false;
    }
    if (parsed.username || parsed.password) {
      return false;
    }
    const isGoogleWorkflowsHost =
      parsed.hostname === 'workflowexecutions.googleapis.com' ||
      /^[a-z0-9-]+-workflowexecutions\.googleapis\.com$/.test(parsed.hostname);
    if (!isGoogleWorkflowsHost) {
      return false;
    }
    const callbackPathRegex = /^\/v1\/projects\/[a-zA-Z0-9_-]+\/locations\/[a-zA-Z0-9_-]+\/workflows\/[a-zA-Z0-9_-]+\/executions\/[a-zA-Z0-9_-]+\/callbacks\/[a-zA-Z0-9_-]+$/;
    return callbackPathRegex.test(parsed.pathname);
  } catch {
    return false;
  }
}

exports.isValidCallbackUrl = isValidCallbackUrl;
exports.translationCallbackCall = async (req, res) => {
  cors(req, res, async () => {
    res.set('Access-Control-Allow-Origin', '*');
    
    const {url, approved} = req.body || {};
    if (!url || !isValidCallbackUrl(url)) {
      res.status(400).json({error: 'Invalid or unauthorized callback URL'});
      return;
    }

    console.log("Approved? ", approved);
    console.log("URL = ", url);
    // [START workflows_oauth_token]
    const {GoogleAuth} = require('google-auth-library');
    const auth = new GoogleAuth();
    const token = await auth.getAccessToken();

    try {
      const resp = await fetch(url, {
          method: 'POST',
          headers: {
              'accept': 'application/json',
              'content-type': 'application/json',
              'authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ approved: Boolean(approved) })
      });
      console.log("Response = ", JSON.stringify(resp));
      
      const result = await resp.json();
      console.log("Outcome = ", JSON.stringify(result));
      // [END workflows_oauth_token]

      res.status(200).json({status: 'OK'});
    } catch(e) {
      console.error(e);

      res.status(500).json({status: 'error'});
    }
  });
};
// [END workflows_callback_translation]

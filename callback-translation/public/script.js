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
// limitations under the License.const cors = require('cors')({origin: true});
// [START workflows_callback_script]
document.addEventListener("DOMContentLoaded", async function (event) {
    const textArea = document.getElementById("text");
    textArea.focus();

    const newBtn = document.getElementById("newBtn");
    newBtn.addEventListener("sl-focus", event => {
        event.target.blur();
        window.location.reload();
    });

    const translationAlert = document.getElementById("translation");
    const buttonRow = document.getElementById("buttonRow");

    var callbackUrl = "";

    const validationAlert = document.getElementById("validationAlert");
    const rejectionAlert = document.getElementById("rejectionAlert");
    const validateBtn = document.getElementById("validateBtn");
    const rejectBtn = document.getElementById("rejectBtn");

    const translateBtn = document.getElementById("translateBtn");
    translateBtn.addEventListener("sl-focus", async event => {
        event.target.disabled = true;
        event.target.loading = true;
        textArea.disabled = true;

        console.log("Text to translate = ", textArea.value);

        const fnUrl = UPDATE_ME;

        try {
            console.log("Calling workflow executor function...");
            const resp = await fetch(fnUrl, {
                method: "POST",
                headers: {
                    "accept": "application/json",
                    "content-type": "application/json"
                },
                body: JSON.stringify({ text: textArea.value })
            });
            const executionResp = await resp.json();
            const executionId = executionResp.executionId.slice(-36);
            console.log("Execution ID = ", executionId);

            const db = firebase.firestore();
            const translationDoc = db.collection("translations").doc(executionId);
        
            var translationReceived = false;
            var callbackReceived =  false;
            var approvalReceived = false;
            translationDoc.onSnapshot((doc) => {
                console.log("Firestore update", doc.data());
                if (doc.data()) {
                    if ("translation" in doc.data()) {
                        if (!translationReceived) {
                            console.log("Translation = ", doc.data().translation);
                            translationReceived = true;
                            translationAlert.innerText = doc.data().translation;
                            translationAlert.open = true;
                        }
                    }
                    if ("callback" in doc.data()) {
                        if (!callbackReceived) {
                            console.log("Callback URL = ", doc.data().callback);
                            callbackReceived = true;
                            callbackUrl = doc.data().callback;
                            buttonRow.style.display = "block";
                        }
                    }
                    if ("approved" in doc.data()) {
                        if (!approvalReceived) {
                            const approved = doc.data().approved;
                            console.log("Approval received = ", approved);
                            if (approved) {
                                validationAlert.open = true;
                                buttonRow.style.display = "none";
                                newBtn.style.display = "inline-block";   
                            } else {
                                rejectionAlert.open = true;
                                buttonRow.style.display = "none";
                                newBtn.style.display = "inline-block";
                            }
                            approvalReceived = true;
                        }
                    }
                }
            });
        } catch (e) {
            console.log(e);
        }
        event.target.loading = false;
    });

    validateBtn.addEventListener("sl-focus", async event => {
        validateBtn.disabled = true;
        rejectBtn.disabled = true;
        validateBtn.loading = true;
        validateBtn.blur();

        // call callback
        await callCallbackUrl(callbackUrl, true);
    });

    rejectBtn.addEventListener("sl-focus", async event => {
        rejectBtn.disabled = true;
        validateBtn.disabled = true;
        rejectBtn.loading = true;
        rejectBtn.blur();
    
        // call callback
        await callCallbackUrl(callbackUrl, false);
    });

});

async function callCallbackUrl(url, approved) {
    console.log("Calling callback URL with status = ", approved);

    const fnUrl = UPDATE_ME;
    try {
        const resp = await fetch(fnUrl, {
            method: "POST",
            headers: {
                "accept": "application/json",
                "content-type": "application/json"
            },
            body: JSON.stringify({ url, approved })
        });
        const result = await resp.json();
        console.log("Callback answer = ", result);
    } catch(e) {
        console.log(e);
    }
}
// [END workflows_callback_script]

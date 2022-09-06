const PROJECT_ID = "your-project-id";
const REGION = "us-central1";
const WORKFLOW = "create-vm-from-form";

function handleEdit(e) {
  var range = e.range.getA1Notation();
  var sheet = e.source;

  if (range.length > 1 && range[0] === 'H') {
    if (e.value == "TRUE") {
      Logger.log("Approved checkbox: true");

      var row = range.slice(1)
      var email = sheet.getRange('B' + row).getCell(1, 1).getValue()
      var vmName = sheet.getRange('c' + row).getCell(1, 1).getValue()
      var zone = sheet.getRange('D' + row).getCell(1, 1).getValue()
      var machineType = sheet.getRange('E' + row).getCell(1, 1).getValue()
      var diskSize = sheet.getRange('F' + row).getCell(1, 1).getValue()
      var imageFamily = sheet.getRange('G' + row).getCell(1, 1).getValue()
      var imageProject = imageFamily.substring(0, imageFamily.indexOf('-')) + "-cloud"

      const executionPayload = {
        "argument": "{\"diskSize\": \"" + diskSize + "\", \"email\": \"" + email + "\", \"imageFamily\": \"" + imageFamily + "\", \"imageProject\": \"" + imageProject + "\", \"machineType\": \"" + machineType + "\", \"vmName\": \"" + vmName + "\", \"zone\": \"" + zone +  "\"}"
      };

      approve(executionPayload);
    }
    else {
      Logger.log("Approved checkbox: false");
    }
  }
}

function approve(executionPayload) {
  const headers = {
    "Authorization": "Bearer " + ScriptApp.getOAuthToken()
  };

  const params = {
    "method": 'post',
    "contentType": 'application/json',
    "headers": headers,
    "payload": JSON.stringify(executionPayload)
  };

  const url = "https://workflowexecutions.googleapis.com/v1/projects/" + PROJECT_ID + "/locations/" + REGION + "/workflows/" + WORKFLOW + "/executions";

  Logger.log("Workflow execution request to " + url);
  var response = UrlFetchApp.fetch(url, params);
  Logger.log(response);
}
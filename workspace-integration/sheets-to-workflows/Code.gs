const PROJECT_ID = "your-project-id";
const REGION = "us-central1";
const WORKFLOW = "create-vm-from-form";

function handleEdit(e) {
  if (!e || !e.range) {
    return;
  }

  var sheet = e.source;
  var col = e.range.getColumn();
  var row = e.range.getRow();

  if (col === 8 && row > 1) {
    if (e.value == "TRUE") {
      Logger.log("Approved checkbox: true");

      var email = String(sheet.getRange('B' + row).getCell(1, 1).getValue());
      var vmName = String(sheet.getRange('C' + row).getCell(1, 1).getValue());
      var zone = String(sheet.getRange('D' + row).getCell(1, 1).getValue());
      var machineType = String(sheet.getRange('E' + row).getCell(1, 1).getValue());
      var diskSize = sheet.getRange('F' + row).getCell(1, 1).getValue();
      var imageFamily = String(sheet.getRange('G' + row).getCell(1, 1).getValue());
      var dashIndex = imageFamily.indexOf('-');
      var imageProject = dashIndex > 0 ? imageFamily.substring(0, dashIndex) + "-cloud" : "";

      const argument = {
        diskSize: diskSize,
        email: email,
        imageFamily: imageFamily,
        imageProject: imageProject,
        machineType: machineType,
        vmName: vmName,
        zone: zone
      };

      const executionPayload = {
        "argument": JSON.stringify(argument)
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
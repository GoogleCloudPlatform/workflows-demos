const CALLBACK_URL_PATTERN = /^https:\/\/workflowexecutions\.googleapis\.com\/v1\/projects\/[a-z0-9-]+\/locations\/[a-z0-9-]+\/workflows\/[A-Za-z0-9_-]+\/executions\/[A-Za-z0-9_-]+\/callbacks\/[A-Za-z0-9_-]+$/;

function handleEdit(e) {
  if (!e || !e.range) {
    return;
  }

  var sheet = e.source;
  var col = e.range.getColumn();
  var row = e.range.getRow();

  if (col === 7 && row > 1) {
    if (e.value == "TRUE") {
      Logger.log("Approved: TRUE");

      var url = String(sheet.getRange('E' + row).getCell(1, 1).getValue()).trim();
      var approver = String(sheet.getRange('F' + row).getCell(1, 1).getValue());

      callback(url, approver);
    }
    else {
      Logger.log("Approved: FALSE");
    }
  }
}

function callback(url, approver) {
  if (!CALLBACK_URL_PATTERN.test(url)) {
    throw new Error("Invalid workflow callback URL: " + url);
  }

  const headers = {
    "Authorization": "Bearer " + ScriptApp.getOAuthToken()
  };

  var payload = {
    'approver': approver
  };

  const params = {
    "method": 'POST',
    "contentType": 'application/json',
    "headers": headers,
    "payload": JSON.stringify(payload)
  };


  Logger.log("Workflow callback request to " + url);
  var response = UrlFetchApp.fetch(url, params);
  Logger.log(response);
}
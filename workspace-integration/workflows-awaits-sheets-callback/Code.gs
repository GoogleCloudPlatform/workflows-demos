function handleEdit(e) {
  var range = e.range.getA1Notation();
  var sheet = e.source;

  if (range.length > 1 && range[0] === 'G') {
    if (e.value == "TRUE") {
      Logger.log("Approved: TRUE");

      var row = range.slice(1);
      var url = sheet.getRange('E' + row).getCell(1, 1).getValue();
      var approver = sheet.getRange('F' + row).getCell(1, 1).getValue();

      callback(url, approver);
    }
    else {
      Logger.log("Approved: FALSE");
    }
  }
}

function callback(url, approver) {
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
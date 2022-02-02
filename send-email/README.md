Sending an email with SendGrid from a workflow
===

For notification purposes, a workflow can have steps that send emails.
The [workflow](send-email/send-email-workflow.yaml) in this directory uses the 
[SendGrid](https://sendgrid.com/) third-party API for this task.

Once you've signed-up with SendGrid, created a sender, retrieved an API key, you're ready to go.

First, you should have a step that retrieves your API key, for example using Secret Manager.
Here, the API key is just hard-coded into this assignment step:

```
- retrieve_api_key:
    assign:
        - SENDGRID_API_KEY: "YOUR_SENDGRID_API_KEY"
```

Next, you're going to make an HTTP POST to the SendGrid endpoint,
specifying sender & receipient, subject & body.
In the headers, you'll specify the SendGrid API key as the authorization bearer token.

```
- send_email:
    call: http.post
    args:
        url: https://api.sendgrid.com/v3/mail/send
        headers:
            Content-Type: "application/json"
            Authorization: ${"Bearer " + SENDGRID_API_KEY}
        body:
            personalizations:
                - to:
                    - email: to@example.com
            from:
                email: from@example.com
            subject: Sending an email from Workflows
            content:
                - type: text/plain
                  value: Here's the body of my email
    result: email_result
```

As a final step, we just return the body of the call to the SendGrid API,
but you could just return the status of the email sending for example.

```
- return_result:
    return: ${email_result.body}
```

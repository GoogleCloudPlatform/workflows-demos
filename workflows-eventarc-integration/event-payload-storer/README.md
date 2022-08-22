# Event payload storer

This workflow receives events from Eventarc and stores their payload (the data
field of the event) to a Cloud Storage bucket.

## Setup

Run [setup.sh](setup.sh) to enable required services, deploy the
event-payload-storer workflow defined in
[event-payload-storer.yaml](workevent-payload-storerflow.yaml) and create a
bucket for the workflow to save event payloads to.

## Test events from Pub/Sub

Run [test_pubsub.sh](test_pubsub.sh) to create a Pub/Sub trigger and publish a message to the
Pub/Sub topic. After the script runs, you should see the event payload of the
Pub/Sub event saved to the bucket.

## Test events from Cloud Storage

Run [test_storage.sh](test_storage.sh) to create a Cloud Storage bucket and trigger and save a
file to the bucket. After the script runs, you should see the event payload of the
Cloud Storage event saved to the bucket.

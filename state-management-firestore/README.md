# Workflows state management with Firestore

Sometimes, you need to store some state (typically a key/value pair) in a
workflow step and later read that state in another step. There's no intrinsic
key/value store in Workflows. However, you can use Firestore to store and read
key/value pairs from Workflows.

In the [workflow.yaml](workflow.yaml), you can see how to store different types
of key/value pairs to Firestore. It uses execution ID as the document name in
Firestore and stores each key/value pair in a single document for the execution.

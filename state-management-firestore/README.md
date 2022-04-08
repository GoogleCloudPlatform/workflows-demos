# Workflows state management with Firestore

Sometimes, you need to store some state (typically a key/value pair) in a
step from one workflow execution and later read that state in another step from
another workflow execution. There's no intrinsic key/value store in Workflows.
However, you can use Firestore to store and read key/value pairs from Workflows.

In the [workflow.yaml](workflow.yaml), you can see how to store different types
of key/value pairs to Firestore. It uses the workflow name as the collection
name and stores each key/value pair in a single document.
# Calling VertexAI text models from Workflows

Some samples to show how to call VertexAI text models from Workflows.

## Find capital cities

See [capitals.yaml](./capitals.yaml). This workflow shows how to find capitals
of a list of countries by calling Vertex AI's text-bison model in parallel for
each country.

Deploy:

```sh
gcloud workflows deploy capitals --source=capitals.yaml
```

Run:

```sh
gcloud workflows run capitals
```

You should see an output similar to the following:

```sh
...
result: '{"Argentina":"Buenos Aires","Brazil":"Brasília","Cyprus":"Nicosia","Denmark":"Copenhagen","England":"London","Finland":"Helsinki","Germany":"Berlin","Honduras":"Tegucigalpa","Italy":"Rome","Japan":"Tokyo","Korea":"Seoul","Latvia":"Riga","Morocco":"Rabat","Nepal":"Kathmandu","Oman":"Muscat"}'
```

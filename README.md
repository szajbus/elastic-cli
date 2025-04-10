# The Missing Elasticsearch CLI

![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/szajbus/elastic-cli?label=version&sort=semver) ![GitHub Workflow Status (branch)](https://img.shields.io/github/actions/workflow/status/szajbus/elastic-cli/build.yaml?branch=main)

`elastic` is a command line utility for Elasticsearch.

It simplifies common operations by wrapping obscure `curl` commands with a friendly API.

## Features

- Index management
- Alias management
- Document management
- Search and arbitrary requests
- Multi-cluster support
- Shell completions for commands, subcommands, index names, aliases, etc.

## Installation

Make sure you have [curl](https://curl.se) installed and available in `$PATH`.

Clone this repository:

```shell
git clone https://github.com/szajbus/elastic-cli.git ~/.elastic-cli
```

Add to your shell by adding the following to `~/.bashrc` or `~/.zshrc`:

```shell
. $HOME/.elastic-cli/elastic.sh
```

To enable completions in ZSH add the following to `~/.zshrc`:

```shell
# append completions to fpath
fpath=(${ELASTIC_DIR/completions} $fpath)
# initialize completions
autoload -Uz compinit
compinit
```

Restart your shell and voilà! 🎉

## Usage

Here are some basic examples, see the bottom of this file for the `elastic --help` printout.

Create an index:

```shell
elastic index create my-index '{"mappings": {...}, "settings": {...}}'
```

Update mapping of an existing index (add new fields):

```shell
elastic index update_mapping my-index '{"properties": {...}}'
```

Retrieve a document from an index:

```shell
elastic document get my-index doc-id
```

### Multi-cluster support

By default, all the requests are sent to `http://localhost:9200`, but you can specify an alternative cluster URL with `--cluster` option:

```shell
elastic --cluster https://username:password@my-cluster.eu-west-1.aws.found.io:9243 ...
elastic --cluster $PROD_ELASTICSEARCH_URL ...
```

Shell completions take the value of this option into account, so index and alias names suggestions will come from the specified cluster.

### Sending data sourced from a file

Under the hood, `curl` is used, so whenever request body is required, it may be provided inline or sourced from a file.

```shell
elastic document index my-index '{"field": "value", ...}'
elastic document index my-index "@data.json"
```

### Arbitrary requests

For use cases not directly supported by the tool's API, you can fall back to `elastic curl` command which automatically sets the cluster URL, HTTP method and `Content-Type: application/json` header for your requests.

See `elastic help curl` for more information.

## The Full API

```
Usage:
  elastic [--cluster <url>] [--verbose] [--dry-run] [--version] [--help]
          <command> [<subcommand>] [<args>]

Available commands:

Index management
  index list                              Lists all indices
  index get <index>                       Returns information about one or more indices
  index create <index> [<body>]           Creates a new index
  index delete <index>                    Deletes an existing index
  index open <index>                      Opens a closed index
  index close <index>                     Closes an index

Mapping management
  index get_mapping [<index>]             Retrieves mapping definitions for one or more fields
  index update_mapping <index> <body>     Adds new fields to an existing index

Index settings
  index get_settings <index> [<setting>]  Returns setting information for one or more indices
  index update_settings <index> <body>    Changes a dynamic index settings in real time

Index status management
  index clear_cache [<index>]             Clears the caches of one or more indices
  index refresh [<index>]                 Refreshes one or more indices
  index flush [<index>]                   Flushes one or more indices
  index forcemerge [<index>]              Forces a merge on the shards of one or more indices

Alias management
  alias list                              Lists all index aliases
  alias get [<alias>]                     Returns information about one or more index aliases
  alias add <alias> <index> [<body>]      Creates or updates an index alias
  alias delete <alias> <index>            Deletes an existing index alias
  alias switch <alias> <from> <to>        Moves an alias from one index to another

Single document APIs
  document get <index> <id>               Retrieves the specified JSON document from an index
  document delete <index> <id>            Removes a JSON document from the specified index
  document delete_by_query <index> <body> Deletes documents matching the query from the specified index
  document index <index> <body>           Creates new document in an index with auto-generated id
  document insert <index> <id> <body>     Creates new document in an index
  document upsert <index> <id> <body>     Creates new or replaces exising document in an index
  document update <index> <id> <body>     Updates existing document in an index

Multi-document APIs
  document mget <index> <id> [<ids>...]   Retrieves multiple JSON documents by ID
  document reindex <source> <dest>        Copies documents from a source to a destination in the same cluster

Search API
  search <index> [<body>]                 Returns search hits that match the query defined in the request

Count API
  count <index> [<body>]                  Counts the documents matching the query defined in the request

Arbitrary HTTP requests
  curl get <path> [<curl args>]           Makes arbitrary GET request
  curl post <path> [<curl args>]          Makes arbitrary POST request
  curl put <path> [<curl args>]           Makes arbitrary PUT request
  curl delete <path> [<curl args>]        Makes arbitrary DELETE request

Application options:
  -c, --cluster   Specify Elasticsearch cluster URL, http://localhost:9200 is default
  -v, --verbose   Prints out all curl commands to stderr
  -n, --dry-run   Only prints out all curl commands to stderr, without running them

Help options:
  -h, --help      Shows this message
  -V, --version   Shows version number

See 'elastic help <command>' for command usage examples.
```

## Roadmap

Apart from functionality extensions (new APIs), there are some extras that would be nice to have.

- Distribution via Homebrew
- Installation instructions for other shells (fish, ksh)
- Shell completions for bash
- Support for older Elasticsearch versions (< 7)
- AWS Elasticsearch support

## Development

In order to run tests locally, install [bats](https://github.com/sstephenson/bats) and [jq](https://stedolan.github.io/jq/) and run:

```shell
bats test
```

## Contributing

You are very welcome to help!

- Report a bug or raise a feature request via [Github Issues](https://github.com/szajbus/elastic-cli/issues)
- Fork this repository and submit your changes via [Github Pull Requests](https://github.com/szajbus/elastic-cli/pulls)

## License

Copyright (c) 2021 Michał Szajbe

Licensed under [The MIT License](LICENSE).

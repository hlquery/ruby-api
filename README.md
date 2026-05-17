<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>

<div align="center">

**A modular Ruby client library for hlquery, designed with a familiar and intuitive API structure.**

[![Follow hlquery](https://img.shields.io/badge/Follow-%40hlquery-blue?logo=x&logoColor=white)](https://x.com/hlquery)
[![Commit Activity](https://img.shields.io/github/commit-activity/m/hlquery/ruby-api)](https://github.com/hlquery/ruby-api/pulse)
[![GitHub](https://img.shields.io/badge/GitHub-ruby--api-purple?logo=github&logoColor=white)](https://github.com/hlquery/ruby-api/stargazers)
[![hlquery](https://img.shields.io/badge/GitHub-hlquery-blue?logo=github&logoColor=white)](https://github.com/hlquery/hlquery/stargazers)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

</div>

### What is the hlquery Ruby API?

The hlquery Ruby API is the official Ruby client for [hlquery](https://github.com/hlquery/hlquery). It mirrors the practical endpoint coverage of the other hlquery clients while exposing Ruby-style method names and service objects.

It is intended for scripts, services, internal tools, and apps that want a small Ruby wrapper over hlquery's HTTP interface.

### Why use it?

- Cleaner Ruby API than hand-written Net::HTTP calls.
- Consistent auth, params, and parsed response handling.
- Coverage for collections, documents, search, and custom route access.

### Why choose it over raw HTTP?

Choose the Ruby client over raw HTTP when you want less request boilerplate, application code that stays easier to read, and a structure similar to the other official clients.

### Install

Local usage:

```ruby
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "hlquery"
```

Client initialization:

```ruby
client = Hlquery::Client.new(ENV["HLQ_BASE_URL"] || ENV["HLQUERY_BASE_URL"] || "http://localhost:9200")
```

### Quick Start

```ruby
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")

health = client.health
puts "status: #{health.body["status"] || "ok"}" if health.success?

collections = client.list_collections(0, 10)
puts collections.body.inspect
```

### Auth

```ruby
client = Hlquery::Client.new("http://localhost:9200", {
  token: "your_token_here",
  auth_method: "bearer"
})

client.set_auth_token("your_token_here", "bearer")
client.set_auth_token("your_api_key_here", "api-key")
```

### SAM

If your current Ruby client build includes the SAM helper, use it directly. Otherwise use the raw request helper against the SAM endpoints:

SAM is separate from vector search. It performs term and intent-style lookup, not vector similarity search.

```ruby
status = client.execute_request("GET", "/sam/status", nil, {
  collection: "music"
})

history = client.execute_request("GET", "/sam/history", nil, {
  collection: "music",
  limit: 5
})

results = client.execute_request("GET", "/sam/search", nil, {
  collection: "music",
  q: "queen of pop",
  limit: 10
})
```

### Search

```ruby
results = client.search("products", {
  "q" => "waterproof jacket",
  "limit" => 10
})
```

If `q` is set and `query_by` is omitted, the client tries to infer `query_by` from the collection's `searchable_fields`.

### Contributing

We welcome contributions from the community! All contributions must be released under the BSD 3-Clause license.

### How to Contribute

- Check existing [issues](https://github.com/hlquery/hlquery/issues) or create new ones
- Contribute to client libraries (Node.js, Go, Java, Python, PHP, Ruby, Rust, Perl, C++)
- Test and report bugs
- Improve documentation

### Community

- 📖 [Documentation](https://docs.hlquery.com)
- 🐦 [X (Twitter)](https://x.com/hlquery)
- 📦 [GitHub](https://github.com/hlquery/hlquery)

### License

hlquery is licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause).

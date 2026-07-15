<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>

<div align="center">

**A modular Ruby client library for hlquery, designed with a familiar and intuitive API structure.**

[![Follow hlquery](https://img.shields.io/badge/Follow-%40hlquery-blue?logo=x&logoColor=white&labelColor=000000)](https://x.com/hlquery)
[![Ruby build](https://img.shields.io/badge/Ruby%20build-passing-brightgreen?logo=ruby&logoColor=white&labelColor=000000)](https://github.com/hlquery/ruby-api/actions/workflows/ruby-api.yml)
[![GitHub](https://img.shields.io/badge/GitHub-ruby--api-purple?logo=github&logoColor=white&labelColor=000000)](https://github.com/hlquery/ruby-api/)
[![hlquery](https://img.shields.io/badge/GitHub-hlquery-blue?logo=github&logoColor=white&labelColor=000000)](https://github.com/hlquery/hlquery/)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-a35a0f?logo=open-source-initiative&logoColor=white&labelColor=000000)](https://opensource.org/licenses/BSD-3-Clause)

</div>

### What is the hlquery Ruby API?

The hlquery Ruby API is the official Ruby client for [hlquery](https://github.com/hlquery/hlquery). It mirrors the practical endpoint coverage of the other hlquery clients while exposing Ruby-style method names and service objects.

It is intended for scripts, services, internal tools, and apps that want a small Ruby wrapper over hlquery's HTTP interface.

### Why use it?

Use it when you want a cleaner Ruby interface than hand-written Net::HTTP calls, with consistent auth, params, parsed response handling, and coverage for collections, documents, search, and custom route access.

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

- Check existing [Ruby API issues](https://github.com/hlquery/ruby-api/issues) or create new ones
- Contribute Ruby client changes to [hlquery/ruby-api](https://github.com/hlquery/ruby-api)
- Contribute shared server/API changes to [hlquery/hlquery](https://github.com/hlquery/hlquery)
- Test and report bugs against the Ruby client
- Improve Ruby-specific documentation and examples

### Community

- 📖 [Documentation](https://docs.hlquery.com)
- 🐦 [X (Twitter)](https://x.com/hlquery)
- 💎 [Ruby API GitHub](https://github.com/hlquery/ruby-api)
- 📦 [hlquery GitHub](https://github.com/hlquery/hlquery)

### License

The hlquery Ruby API is licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause).

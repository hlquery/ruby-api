<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>

<div align="center">

**A modular Ruby client library for hlquery, based on the PHP client layout and endpoint coverage.**

[![Follow hlquery](https://img.shields.io/badge/Follow-%40hlquery-blue?logo=x&logoColor=white)](https://x.com/hlquery)
[![Commit Activity](https://img.shields.io/github/commit-activity/m/hlquery/ruby-api)](https://github.com/hlquery/ruby-api/pulse)
[![hlquery](https://img.shields.io/badge/GitHub-hlquery-181717?logo=github&logoColor=white)](https://github.com/hlquery/ruby-api)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

</div>

# hlquery Ruby API Client

Compact Ruby client for hlquery. It mirrors the PHP client structure closely, but exposes idiomatic Ruby method names.

Included in the current client:

- Collections
- Documents
- Search
- Keys
- Aliases
- Overrides
- Synonyms
- Stopwords
- System helpers, including `etc`

## Install

Local usage:

```ruby
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")
```

Gem metadata in this directory targets:

- `https://github.com/hlquery/ruby-api`

## Quick Start

```ruby
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")

health = client.health
puts "status: #{health.body["status"] || "ok"}" if health.success?

collections = client.list_collections(0, 10)
puts collections.body.inspect
```

## Auth

```ruby
client = Hlquery::Client.new("http://localhost:9200", {
  token: "your_token_here",
  auth_method: "bearer"
})

client.set_auth_token("your_token_here", "api-key")
```

## Common Examples

### Create a collection

```ruby
schema = {
  "searchable_fields" => ["title", "description"],
  "filterable_fields" => ["category", "in_stock"],
  "sortable_fields" => ["price", "rating"]
}

response = client.collections.create("products", schema)
puts response.body.inspect
```

### Add documents

```ruby
client.documents.add("products", {
  "id" => "sku-1",
  "title" => "Trail Running Shoes",
  "description" => "Lightweight shoes for mixed terrain",
  "category" => "footwear",
  "price" => 129,
  "rating" => 4.7,
  "in_stock" => true
})

client.documents.import("products", [
  {
    "id" => "sku-2",
    "title" => "Waterproof Jacket",
    "description" => "Breathable shell for wet weather"
  }
])
```

### Search

```ruby
results = client.search("products", {
  "q" => "waterproof jacket",
  "limit" => 10
})
```

If `q` is set and `query_by` is omitted, the client tries to infer `query_by` from the collection's `searchable_fields`, matching the PHP client behavior.

### Vector Search Notes

For vector search, the knobs around the embedding usually matter more than the literal example values:

- `field_name` must match the stored vector field
- `topk` controls result count
- `threshold` can cut weak matches
- `nprobe` is the main recall/speed tradeoff on IVF-style indexes

Start with a small `nprobe`, then raise it only if obvious neighbors are being missed.

### Reduce Text Example

You can call custom module routes directly:

```ruby
module_response = client.execute_request(
  "GET",
  "/modules/<name>/<route>",
  nil,
  {
    q: "example query"
  }
)

puts module_response.body.inspect
```

## Files

- `lib/hlquery.rb`: main require entrypoint
- `lib/hlquery/client.rb`: top-level client and convenience wrappers
- `lib/hlquery/request.rb`: HTTP transport
- `lib/hlquery/*.rb`: modular endpoint APIs
- `examples/`: small usage scripts

## Quick Local Run

```bash
ruby example.rb
ruby examples/basic_usage.rb
```

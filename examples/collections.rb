#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")

response = client.collections.list(0, 10)
puts "List collections: #{response.body.inspect}"

schema = {
  "fields" => [
    { "name" => "title", "type" => "string" },
    { "name" => "content", "type" => "string" }
  ]
}

puts "Create collection: #{client.collections.create("ruby_example", schema).body.inspect}"

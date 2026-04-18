#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")

response = client.vector_search("ruby_example", {
  "field_name" => "embedding",
  "vector_query" => [0.12, 0.34, 0.56, 0.78],
  "topk" => 5,
  "nprobe" => 8
})

puts "Vector status: #{response.status_code}"
puts "Vector body: #{response.body.inspect}"

#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")

response = client.search("ruby_example", {
  "q" => "ruby client",
  "query_by" => %w[title content],
  "limit" => 10
})

puts "Search status: #{response.status_code}"
puts "Search body: #{response.body.inspect}"

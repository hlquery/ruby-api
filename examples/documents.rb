#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")
collection = "ruby_example"

document = {
  "id" => "doc_1",
  "title" => "Ruby API Document",
  "content" => "Created from the Ruby hlquery client"
}

puts "Add document: #{client.documents.add(collection, document).body.inspect}"
puts "Get document: #{client.documents.get(collection, "doc_1").body.inspect}"

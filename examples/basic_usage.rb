#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "hlquery"

client = Hlquery::Client.new("http://localhost:9200")

health = client.health
puts "Health status: #{health.status_code}"
puts "Health body: #{health.body.inspect}"

collections = client.list_collections(0, 10)
puts "Collections status: #{collections.status_code}"
puts "Collections body: #{collections.body.inspect}"

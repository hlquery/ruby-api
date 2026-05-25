#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require "webrick"

root = Pathname.new(__dir__).join("..")
$LOAD_PATH.unshift(root.join("lib").to_s)
require "hlquery"

def assert(message)
  raise "Assertion failed: #{message}" unless yield
end

server = WEBrick::HTTPServer.new(
  BindAddress: "127.0.0.1",
  Port: 0,
  Logger: WEBrick::Log.new(File::NULL),
  AccessLog: []
)

json = lambda do |res, body|
  res["Content-Type"] = "application/json"
  res.body = JSON.generate(body)
end

server.mount_proc("/") do |req, res|
  case [req.request_method, req.path]
  when ["GET", "/"]
    json.call(res, { info: "hlquery" })
  when ["GET", "/health"]
    json.call(res, { status: "ok" })
  when ["GET", "/status"]
    json.call(res, { status: "ready" })
  when ["GET", "/etc"]
    json.call(res, { protocol: "http" })
  when ["POST", "/flush"]
    json.call(res, { flushed: true })
  when ["GET", "/links"]
    json.call(res, { links: [] })
  when ["POST", "/links/connect"]
    json.call(res, { connected: true, body: JSON.parse(req.body) })
  when ["GET", "/keys/key%2Fwith%20space"], ["GET", "/keys/key/with space"]
    json.call(res, { id: "key/with space" })
  else
    res.status = 404
    json.call(res, { error: "not found", path: req.path })
  end
end

thread = Thread.new { server.start }

begin
  client = Hlquery::Client.new("http://127.0.0.1:#{server.config[:Port]}")

  assert("health response") { client.health.body["status"] == "ok" }
  assert("status response") { client.status.body["status"] == "ready" }
  assert("etc response") { client.etc.body["protocol"] == "http" }
  assert("flush response") { client.flush.body["flushed"] == true }
  assert("links service") { client.links.body["links"] == [] }
  assert("links connect") { client.links_connect("http://node-b:9200").body["connected"] == true }
  assert("escaped key id") { client.keys.get("key/with space").body["id"] == "key/with space" }

  assert("system service") { client.system.respond_to?(:metrics_json) }
  assert("documents import") { client.documents.respond_to?(:import) }
  assert("search API") { client.search_api.respond_to?(:vector_search) && client.respond_to?(:sql_search) }
  assert("SAM API") { client.sam.respond_to?(:search_all) && client.respond_to?(:sam_open_document) }
  assert("resources") { client.aliases.respond_to?(:upsert) && client.synonyms.respond_to?(:list_global) && client.stopwords.respond_to?(:create_global) }
  assert("compat aliases") { client.respond_to?(:searchApi) && client.respond_to?(:execSql) && client.respond_to?(:globalSearch) }

  puts "Ruby offline smoke tests passed."
ensure
  server.shutdown
  thread.join
end

# frozen_string_literal: true

module Hlquery
  class Client
    attr_reader :request

    def initialize(base_url = nil, options = {})
      opts = stringify_keys(options || {})
      base =
        base_url ||
        opts["base_url"] ||
        opts["baseUrl"] ||
        opts["url"] ||
        ENV["HLQ_BASE_URL"] ||
        ENV["HLQUERY_BASE_URL"] ||
        "http://localhost:9200"
      timeout = opts.fetch("timeout", 10)
      token = opts["token"]
      auth_method = opts.fetch("auth_method", opts.fetch("authMethod", "bearer"))

      @request = Hlquery::Request.new(base, timeout: timeout, token: token, auth_method: auth_method)
      @collections = Hlquery::Collections.new(@request)
      @documents = Hlquery::Documents.new(@request)
      @search = Hlquery::Search.new(@request, @collections)
    end

    def set_auth_token(token, method = "bearer")
      @request.set_auth_token(token, method)
      self
    end

    def clear_auth
      @request.clear_auth
      self
    end

    def execute_request(method, path, body = nil, query = {})
      @request.execute(method, path, body, query)
    end

    def health = @request.execute("GET", "/health")
    def stats = @request.execute("GET", "/stats")
    def etc = @request.execute("GET", "/etc")
    def info = @request.execute("GET", "/")

    def collections = @collections
    def documents = @documents

    def list_collections(offset = 0, limit = 10) = @collections.list(offset, limit)
    def get_collection(name) = @collections.get(name)
    def create_collection(name, schema) = @collections.create(name, schema)
    def delete_collection(name) = @collections.delete(name)

    def search(collection_name, params = {}) = @search.search(collection_name, params)
    def vector_search(collection_name, params = {}) = @search.vector_search(collection_name, params)

    private

    def stringify_keys(obj)
      return obj unless obj.is_a?(Hash)

      obj.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end
  end
end

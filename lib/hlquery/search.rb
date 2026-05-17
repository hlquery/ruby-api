# frozen_string_literal: true

require "json"

module Hlquery
  class Search
    def initialize(request, collections)
      @request = request
      @collections = collections
    end

    def search(collection_name, params = {})
      query = normalize_search_params(collection_name, params || {})
      @request.execute("GET", "/collections/#{escape(collection_name)}/search", nil, query)
    end

    def vector_search(collection_name, params = {})
      p = (params || {}).dup
      vector = p["vector_query"] || p[:vector_query] || p["vector"] || p[:vector] || p["embedding"] || p[:embedding]
      field_name = p["field_name"] || p[:field_name] || p["field"] || p[:field] || p["fieldName"] || p[:fieldName]
      limit = p["limit"] || p[:limit] || p["topk"] || p[:topk] || p["top_k"] || p[:top_k] || p["k"] || p[:k]

      query = {}
      query["field_name"] = field_name if field_name
      query["limit"] = limit if limit
      query["vector_query"] = vector.is_a?(String) ? vector : JSON.generate(vector) if vector != nil

      @request.execute("GET", "/collections/#{escape(collection_name)}/vector_search", nil, query)
    end

    private

    def normalize_search_params(collection_name, params)
      query = stringify_keys(params)

      if query.key?("q") && !query.key?("query_by")
        collection = @collections.get(collection_name)
        if collection.success? && collection.body.is_a?(Hash) && collection.body["searchable_fields"].is_a?(Array) && !collection.body["searchable_fields"].empty?
          query["query_by"] = collection.body["searchable_fields"].join(",")
        end
      end

      query
    end

    def stringify_keys(obj)
      return {} unless obj.is_a?(Hash)

      obj.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end

    def escape(value)
      require "cgi"
      CGI.escape(value.to_s)
    end
  end
end


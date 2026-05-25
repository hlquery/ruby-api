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
      body = query.delete("body")
      method = body ? "POST" : "GET"
      @request.execute(method, "/collections/#{escape(collection_name)}/search", body, query)
    end

    def search_legacy(collection_name, params = {})
      query = normalize_search_params(collection_name, params || {})
      body = query.delete("body")
      method = body ? "POST" : "GET"
      @request.execute(method, "/collections/#{escape(collection_name)}/documents/search", body, query)
    end

    def sql(collection_name, sql, params = {})
      raise ArgumentError, "SQL query is required" if sql.to_s.strip.empty?

      @request.execute("GET", "/collections/#{escape(collection_name)}/documents/search", nil, stringify_keys(params || {}).merge("sql" => sql))
    end

    def multi_search(searches)
      @request.execute("POST", "/multi_search", { searches: searches })
    end

    def global_search(params = {})
      query = stringify_keys(params || {})
      body = query.delete("body")
      method = body ? "POST" : "GET"
      @request.execute(method, "/search", body, query)
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
      assign_if_present(query, "threshold", p, "threshold")
      assign_if_present(query, "radius", p, "radius")
      assign_if_present(query, "max_distance", p, "max_distance", "maxDistance")
      assign_if_present(query, "min_distance", p, "min_distance", "minDistance")
      assign_if_present(query, "range_filter", p, "range_filter", "rangeFilter")
      assign_if_present(query, "filter_by", p, "filter_by", "filterBy", "filter")
      query["normalize"] = boolean_string(value_for(p, "normalize")) unless value_for(p, "normalize").nil?
      query["include_vector"] = boolean_string(value_for(p, "include_vector", "includeVector")) unless value_for(p, "include_vector", "includeVector").nil?
      query["include_distance"] = boolean_string(value_for(p, "include_distance", "includeDistance")) unless value_for(p, "include_distance", "includeDistance").nil?
      output_fields = value_for(p, "output_fields", "outputFields")
      query["output_fields"] = csv(output_fields) unless output_fields.nil?

      force_post = %w[query_params queryParams params vector_queries vectorQueries].any? { |key| p.key?(key) || p.key?(key.to_sym) }
      body = p["body"] || p[:body] || (force_post ? params : nil)
      method = body ? "POST" : "GET"

      @request.execute(method, "/collections/#{escape(collection_name)}/vector_search", body, query)
    end

    private

    def normalize_search_params(collection_name, params)
      query = stringify_keys(params)

      if query.key?("query") && query["query"].is_a?(Hash)
        nested = stringify_keys(query["query"])
        query["q"] ||= nested["q"]
        query["query_by"] ||= csv(nested["query_by"]) if nested.key?("query_by")
      end

      if query.key?("q") && !query.key?("query_by") && query.fetch("auto_detect_query_by", true)
        collection = @collections.get(collection_name)
        if collection.success? && collection.body.is_a?(Hash) && collection.body["searchable_fields"].is_a?(Array) && !collection.body["searchable_fields"].empty?
          query["query_by"] = collection.body["searchable_fields"].join(",")
        end
      end

      query["query_by"] = csv(query["query_by"]) if query.key?("query_by")
      query["filter_by"] ||= query["filter"].is_a?(Hash) ? JSON.generate(query["filter"]) : query["filter"]
      query["sort_by"] ||= normalize_sort(query["sort"]) if query.key?("sort")
      query["facet_by"] ||= csv(query["facets"]) if query.key?("facets")
      %w[sort_by facet_by highlight_fields highlight_full_fields].each { |key| query[key] = csv(query[key]) if query.key?(key) }
      query["limit"] ||= query.delete("size") if query.key?("size")
      query["offset"] ||= query.delete("from") if query.key?("from")
      query.delete("query")
      query.delete("filter")
      query.delete("sort")
      query.delete("facets")
      query.delete("auto_detect_query_by")
      query
    end

    def normalize_sort(sort)
      return sort unless sort.is_a?(Array)

      sort.map do |item|
        next item unless item.is_a?(Hash)

        item.map { |field, order| order.to_s == "desc" ? "-#{field}" : field.to_s }.join(",")
      end.join(",")
    end

    def assign_if_present(query, output_key, source, *input_keys)
      value = value_for(source, *input_keys)
      query[output_key] = value unless value.nil?
    end

    def value_for(hash, *keys)
      keys.each do |key|
        return hash[key] if hash.key?(key)
        sym = key.to_sym
        return hash[sym] if hash.key?(sym)
      end
      nil
    end

    def csv(value)
      value.is_a?(Array) ? value.join(",") : value
    end

    def boolean_string(value)
      value ? "true" : "false"
    end

    def stringify_keys(obj)
      return {} unless obj.is_a?(Hash)

      obj.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end

    def escape(value)
      require "cgi"
      CGI.escape(value.to_s).gsub("+", "%20")
    end
  end
end

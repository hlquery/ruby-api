require "cgi"
require "json"

module Hlquery
  class Search
    def initialize(request, collections)
      @request = request
      @collections = collections
    end

    def search(collection_name, params = {})
      search_collection(collection_name, params, false)
    end

    def search_legacy(collection_name, params = {})
      search_collection(collection_name, params, true)
    end

    def multi_search(searches)
      @request.execute("POST", "/multi_search", { searches: searches })
    end

    def global_search(params = {})
      Utils::Validator.validate_search_params(params || {})
      method = fetch_key(params, :body) ? "POST" : "GET"
      body = fetch_key(params, :body)
      query = method == "GET" ? params : {}
      @request.execute(method, "/search", body, query)
    end

    def vector_search(collection_name, params = {})
      Utils::Validator.validate_collection_name(collection_name)
      params ||= {}
      query = {}
      force_post = false

      %i[vector_query vectorQuery vector embedding].each do |vector_key|
        value = fetch_key(params, vector_key)
        next if value.nil?

        query[:vector_query] = value.is_a?(Array) ? JSON.generate(value) : value
        break
      end

      field_name = fetch_key(params, :field_name) || fetch_key(params, :field) || fetch_key(params, :fieldName)
      query[:field_name] = field_name if field_name

      %i[limit topk top_k topK k per_page].each do |limit_key|
        value = fetch_key(params, limit_key)
        next if value.nil?

        query[:limit] = value
        break
      end

      %i[threshold radius max_distance maxDistance range_filter rangeFilter min_distance minDistance].each do |key|
        value = fetch_key(params, key)
        next if value.nil?

        query[underscore(key)] = value
      end

      %i[output_fields outputFields].each do |key|
        value = fetch_key(params, key)
        next if value.nil?

        query[:output_fields] = value.is_a?(Array) ? value.join(",") : value
        break
      end

      %i[include_vector includeVector include_distance includeDistance normalize].each do |key|
        value = fetch_key(params, key)
        next if value.nil?

        query[underscore(key)] = value ? "true" : "false"
      end

      filter_value = fetch_key(params, :filter_by) || fetch_key(params, :filterBy)
      filter_value = fetch_key(params, :filter) if filter_value.nil?
      query[:filter_by] = filter_value.is_a?(Hash) || filter_value.is_a?(Array) ? JSON.generate(filter_value) : filter_value if filter_value

      %i[query_params queryParams params vector_queries vectorQueries vectorQuery].each do |key|
        if params.key?(key) || params.key?(key.to_s)
          force_post = true
          break
        end
      end

      body = fetch_key(params, :body)
      method = body || force_post ? "POST" : "GET"
      body = params if body.nil? && force_post

      @request.execute(method, "/collections/#{CGI.escape(collection_name)}/vector_search", body, query)
    end

    alias searchLegacy search_legacy
    alias multiSearch multi_search
    alias globalSearch global_search
    alias vectorSearch vector_search

    private

    def search_collection(collection_name, params, legacy)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_search_params(params || {})
      params ||= {}
      query = {}

      nested_query = fetch_key(params, :query)
      if nested_query.is_a?(Hash)
        nested_q = fetch_key(nested_query, :q)
        nested_query_by = fetch_key(nested_query, :query_by)
        query[:q] = nested_q if nested_q
        query[:query_by] = nested_query_by.is_a?(Array) ? nested_query_by.join(",") : nested_query_by if nested_query_by
      end

      q = fetch_key(params, :q)
      query[:q] = q if q

      query_by = fetch_key(params, :query_by)
      if query_by
        query[:query_by] = query_by.is_a?(Array) ? query_by.join(",") : query_by
      elsif q && !q.to_s.empty?
        collection = @collections.get(collection_name)
        if collection.status_code == 200 && collection.body.is_a?(Hash)
          searchable_fields = collection.body["searchable_fields"]
          query[:query_by] = searchable_fields.join(",") if searchable_fields.is_a?(Array) && !searchable_fields.empty?
        end
      end

      offset = fetch_key(params, :from)
      offset = fetch_key(params, :offset) if offset.nil?
      query[:offset] = offset unless offset.nil?

      limit = fetch_key(params, :size)
      limit = fetch_key(params, :limit) if limit.nil?
      query[:limit] = limit unless limit.nil?

      %i[page per_page typo_tolerance num_typos].each do |key|
        value = fetch_key(params, key)
        query[key] = value unless value.nil?
      end

      { facet_by: :facet_by, facets: :facet_by, highlight_fields: :highlight_fields, highlight_full_fields: :highlight_full_fields }.each do |source, target|
        value = fetch_key(params, source)
        next if value.nil?

        query[target] = value.is_a?(Array) ? value.join(",") : value
      end

      highlight = fetch_key(params, :highlight)
      query[:highlight] = highlight ? "true" : "false" unless highlight.nil?

      filter_value = fetch_key(params, :filter_by)
      filter_value = fetch_key(params, :filter) if filter_value.nil?
      query[:filter_by] = filter_value.is_a?(Hash) || filter_value.is_a?(Array) ? JSON.generate(filter_value) : filter_value if filter_value

      sort_value = fetch_key(params, :sort)
      if sort_value
        query[:sort_by] = normalize_sort(sort_value)
      else
        sort_by = fetch_key(params, :sort_by)
        query[:sort_by] = sort_by.is_a?(Array) ? sort_by.join(",") : sort_by if sort_by
      end

      body = fetch_key(params, :body)
      method = body ? "POST" : "GET"
      path =
        if legacy
          "/collections/#{CGI.escape(collection_name)}/documents/search"
        else
          "/collections/#{CGI.escape(collection_name)}/search"
        end

      @request.execute(method, path, body, query)
    end

    def normalize_sort(sort_value)
      return sort_value unless sort_value.is_a?(Array)

      sort_value.map do |item|
        if item.is_a?(Hash)
          item.map { |field, order| "#{field}:#{normalize_sort_order(order)}" }
        else
          item
        end
      end.flatten.join(",")
    end

    def normalize_sort_order(order)
      order.to_s.strip.downcase == "desc" ? "desc" : "asc"
    end

    def fetch_key(hash, key)
      hash[key] || hash[key.to_s]
    end

    def underscore(key)
      key.to_s.gsub(/([A-Z])/, '_\1').downcase.to_sym
    end
  end
end

# frozen_string_literal: true

module Hlquery
  class Documents
    def initialize(request)
      @request = request
    end

    def list(collection_name, params = {})
      params = { offset: params, limit: 10 } unless params.is_a?(Hash)
      offset = params[:offset] || params["offset"] || params[:from] || params["from"] || 0
      limit = params[:limit] || params["limit"] || params[:size] || params["size"] || 10
      @request.execute("GET", "/collections/#{escape(collection_name)}/documents", nil, { offset: offset, limit: limit })
    end

    def get(collection_name, document_id)
      @request.execute("GET", "/collections/#{escape(collection_name)}/documents/#{escape(document_id)}")
    end

    def add(collection_name, document)
      @request.execute("POST", "/collections/#{escape(collection_name)}/documents", document)
    end

    def update(collection_name, document_id, document)
      @request.execute("PUT", "/collections/#{escape(collection_name)}/documents/#{escape(document_id)}", document)
    end

    def delete(collection_name, document_id)
      @request.execute("DELETE", "/collections/#{escape(collection_name)}/documents/#{escape(document_id)}")
    end

    def import(collection_name, documents)
      raise ArgumentError, "Documents must be an array" unless documents.is_a?(Array)

      @request.execute("POST", "/collections/#{escape(collection_name)}/documents/import", { documents: documents })
    end

    def facet_counts(collection_name, params = {})
      collection_document_query(collection_name, "facet_counts", params)
    end

    def maybe(collection_name, params = {})
      collection_document_query(collection_name, "maybe", params)
    end

    def context(collection_name, document_id, params = {})
      @request.execute("GET", "/collections/#{escape(collection_name)}/documents/#{escape(document_id)}/context", nil, params || {})
    end

    def export(collection_name, params = {})
      collection_document_query(collection_name, "export", params)
    end

    def delete_by_filter(collection_name, filter)
      @request.execute("DELETE", "/collections/#{escape(collection_name)}/documents", nil, { filter_by: filter })
    end

    private

    def collection_document_query(collection_name, route, params)
      params ||= {}
      body = params[:body] || params["body"]
      method = body ? "POST" : "GET"
      query = method == "GET" ? params : {}
      @request.execute(method, "/collections/#{escape(collection_name)}/documents/#{route}", body, query)
    end

    def escape(value)
      require "cgi"
      CGI.escape(value.to_s).gsub("+", "%20")
    end
  end
end

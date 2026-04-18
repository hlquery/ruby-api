require "cgi"

module Hlquery
  class Documents
    def initialize(request)
      @request = request
    end

    def list(collection_name, params = {})
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_search_params(params || {})

      offset = fetch_param(params, :offset, :from, default: 0)
      limit = fetch_param(params, :limit, :size, default: 10)

      @request.execute(
        "GET",
        "/collections/#{CGI.escape(collection_name)}/documents",
        nil,
        { offset: offset, limit: limit }
      )
    end

    def get(collection_name, document_id)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(document_id)
      @request.execute("GET", "/collections/#{CGI.escape(collection_name)}/documents/#{CGI.escape(document_id)}")
    end

    def add(collection_name, document)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_fields(document)
      @request.execute("POST", "/collections/#{CGI.escape(collection_name)}/documents", document)
    end

    def update(collection_name, document_id, document)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(document_id)
      Utils::Validator.validate_document_fields(document)
      @request.execute("PUT", "/collections/#{CGI.escape(collection_name)}/documents/#{CGI.escape(document_id)}", document)
    end

    def delete(collection_name, document_id)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(document_id)
      @request.execute("DELETE", "/collections/#{CGI.escape(collection_name)}/documents/#{CGI.escape(document_id)}")
    end

    def import(collection_name, documents)
      Utils::Validator.validate_collection_name(collection_name)
      Array(documents).each { |document| Utils::Validator.validate_document_fields(document) }
      @request.execute("POST", "/collections/#{CGI.escape(collection_name)}/documents/import", { documents: documents })
    end

    def import_documents(collection_name, documents)
      import(collection_name, documents)
    end

    def delete_by_filter(collection_name, filter)
      Utils::Validator.validate_collection_name(collection_name)
      @request.execute("DELETE", "/collections/#{CGI.escape(collection_name)}/documents", nil, { filter_by: filter })
    end

    def facet_counts(collection_name, params = {})
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_search_params(params || {})
      method = params.key?(:body) || params.key?("body") ? "POST" : "GET"
      body = fetch_key(params, :body)
      query = method == "GET" ? params : {}
      @request.execute(method, "/collections/#{CGI.escape(collection_name)}/documents/facet_counts", body, query)
    end

    def export(collection_name, params = {})
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_search_params(params || {})
      method = params.key?(:body) || params.key?("body") ? "POST" : "GET"
      body = fetch_key(params, :body)
      query = method == "GET" ? params : {}
      @request.execute(method, "/collections/#{CGI.escape(collection_name)}/documents/export", body, query)
    end

    alias importDocuments import_documents
    alias deleteByFilter delete_by_filter
    alias facetCounts facet_counts

    private

    def fetch_param(params, primary, secondary, default:)
      fetch_key(params, primary) || fetch_key(params, secondary) || default
    end

    def fetch_key(params, key)
      params[key] || params[key.to_s]
    end
  end
end

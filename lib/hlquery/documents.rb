# frozen_string_literal: true

module Hlquery
  class Documents
    def initialize(request)
      @request = request
    end

    def list(collection_name, offset = 0, limit = 10)
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

    private

    def escape(value)
      require "cgi"
      CGI.escape(value.to_s)
    end
  end
end


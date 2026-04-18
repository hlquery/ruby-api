require "cgi"

module Hlquery
  class Overrides
    def initialize(request)
      @request = request
    end

    def list(collection_name)
      Utils::Validator.validate_collection_name(collection_name)
      @request.execute("GET", "/collections/#{CGI.escape(collection_name)}/overrides")
    end

    def get(collection_name, id)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("GET", "/collections/#{CGI.escape(collection_name)}/overrides/#{CGI.escape(id)}")
    end

    def create(collection_name, id, override_body)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("POST", "/collections/#{CGI.escape(collection_name)}/overrides/#{CGI.escape(id)}", override_body || {})
    end

    def update(collection_name, id, override_body)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("PUT", "/collections/#{CGI.escape(collection_name)}/overrides/#{CGI.escape(id)}", override_body || {})
    end

    def upsert(collection_name, id, override_body)
      create(collection_name, id, override_body)
    end

    def delete(collection_name, id)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("DELETE", "/collections/#{CGI.escape(collection_name)}/overrides/#{CGI.escape(id)}")
    end
  end
end

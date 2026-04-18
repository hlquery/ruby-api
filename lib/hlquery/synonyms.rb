require "cgi"

module Hlquery
  class Synonyms
    def initialize(request)
      @request = request
    end

    def list(collection_name)
      Utils::Validator.validate_collection_name(collection_name)
      @request.execute("GET", "/collections/#{CGI.escape(collection_name)}/synonyms")
    end

    def get(collection_name, id)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("GET", "/collections/#{CGI.escape(collection_name)}/synonyms/#{CGI.escape(id)}")
    end

    def create(collection_name, id, synonym)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("POST", "/collections/#{CGI.escape(collection_name)}/synonyms/#{CGI.escape(id)}", synonym || {})
    end

    def update(collection_name, id, synonym)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("PUT", "/collections/#{CGI.escape(collection_name)}/synonyms/#{CGI.escape(id)}", synonym || {})
    end

    def upsert(collection_name, id, synonym)
      create(collection_name, id, synonym)
    end

    def delete(collection_name, id)
      Utils::Validator.validate_collection_name(collection_name)
      Utils::Validator.validate_document_id(id)
      @request.execute("DELETE", "/collections/#{CGI.escape(collection_name)}/synonyms/#{CGI.escape(id)}")
    end

    def list_all
      @request.execute("GET", "/synonyms")
    end

    def list_global
      @request.execute("GET", "/synonyms/global")
    end

    def get_global(id)
      Utils::Validator.validate_document_id(id)
      @request.execute("GET", "/synonyms/global/#{CGI.escape(id)}")
    end

    def create_global(id, synonym)
      Utils::Validator.validate_document_id(id)
      @request.execute("POST", "/synonyms/global/#{CGI.escape(id)}", synonym || {})
    end

    def update_global(id, synonym)
      Utils::Validator.validate_document_id(id)
      @request.execute("PUT", "/synonyms/global/#{CGI.escape(id)}", synonym || {})
    end

    def upsert_global(id, synonym)
      create_global(id, synonym)
    end

    def delete_global(id)
      Utils::Validator.validate_document_id(id)
      @request.execute("DELETE", "/synonyms/global/#{CGI.escape(id)}")
    end
  end
end

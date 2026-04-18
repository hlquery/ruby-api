require "cgi"

module Hlquery
  class Stopwords
    def initialize(request)
      @request = request
    end

    def list(collection_name)
      Utils::Validator.validate_collection_name(collection_name)
      @request.execute("GET", "/collections/#{CGI.escape(collection_name)}/stopwords")
    end

    def create(collection_name, params)
      Utils::Validator.validate_collection_name(collection_name)
      @request.execute("POST", "/collections/#{CGI.escape(collection_name)}/stopwords", params || {})
    end

    def delete(collection_name, word)
      Utils::Validator.validate_collection_name(collection_name)
      validate_word(word)
      @request.execute("DELETE", "/collections/#{CGI.escape(collection_name)}/stopwords/#{CGI.escape(word)}")
    end

    def list_all
      @request.execute("GET", "/stopwords")
    end

    def list_global
      @request.execute("GET", "/stopwords/global")
    end

    def create_global(params)
      @request.execute("POST", "/stopwords/global", params || {})
    end

    def delete_global(word)
      validate_word(word)
      @request.execute("DELETE", "/stopwords/global/#{CGI.escape(word)}")
    end

    private

    def validate_word(word)
      unless word.is_a?(String) && !word.strip.empty?
        raise ValidationException, "word must be a non-empty string"
      end
    end
  end
end

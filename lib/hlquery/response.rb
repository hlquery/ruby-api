module Hlquery
  class Response
    attr_reader :status_code, :body, :headers, :raw_body, :error

    def initialize(status_code = 0, body = nil, headers = {}, raw_body = "", error = nil)
      @status_code = status_code.to_i
      @body = body
      @headers = headers || {}
      @raw_body = raw_body || ""
      @error = error
    end

    def get_status_code
      status_code
    end

    def get_body
      body
    end

    def get_headers
      headers
    end

    def get_raw_body
      raw_body
    end

    def get_error
      return error if error
      return nil unless error?

      if body.is_a?(Hash)
        body["error"] || body["message"] || body[:error] || body[:message]
      elsif body.is_a?(String) && !body.empty?
        body
      end
    end

    def success?
      status_code >= 200 && status_code < 300
    end

    def is_success?
      success?
    end

    def error?
      status_code >= 400 || status_code.zero?
    end

    def is_error?
      error?
    end

    def to_h
      {
        status_code: status_code,
        body: body,
        headers: headers,
        raw_body: raw_body,
        error: get_error
      }
    end
  end
end

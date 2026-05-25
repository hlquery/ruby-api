# frozen_string_literal: true

require "json"

module Hlquery
  class Response
    attr_reader :status_code, :headers, :raw_body, :body

    def initialize(status_code, headers = {}, raw_body = nil, request: nil, status_message: nil)
      @status_code = status_code.to_i
      @headers = headers || {}
      @raw_body = raw_body
      @request = request
      @status_message = status_message
      @body = parse_body(raw_body)
    end

    def success?
      status_code >= 200 && status_code < 300
    end

    def error?
      status_code >= 400
    end

    def parsed?
      !raw_body.is_a?(String) || body != raw_body
    end

    def error
      return nil unless error?
      return body["error"] || body["message"] || "Unknown error" if body.is_a?(Hash)

      body.to_s
    end

    def to_h
      { status: status_code, body: body }
    end

    def get_status_code = status_code
    def get_body = body
    def get_headers = headers
    def is_success = success?
    def is_error = error?
    def get_error = error
    def get_raw_body = raw_body
    def get_request = @request
    def get_status_message = @status_message

    def content_type
      headers["content-type"] || headers["Content-Type"]
    end

    def get_content_type = content_type

    private

    def parse_body(raw)
      return nil if raw.nil?
      return raw if raw == ""

      JSON.parse(raw)
    rescue JSON::ParserError
      raw
    end
  end
end

# frozen_string_literal: true

require "json"

module Hlquery
  class Response
    attr_reader :status_code, :headers, :raw_body, :body

    def initialize(status_code, headers, raw_body)
      @status_code = status_code.to_i
      @headers = headers || {}
      @raw_body = raw_body
      @body = parse_body(raw_body)
    end

    def success?
      status_code >= 200 && status_code < 300
    end

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


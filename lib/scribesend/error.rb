module Scribesend
  class Error < StandardError
    attr_reader :message, :http_status, :http_body, :json_body

    def initialize(message=nil, http_status=nil, http_body=nil, json_body=nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @json_body = json_body
    end

    def to_s
      s = @http_status.nil? ? "" : "(Status #{@http_status}): "
      "#{s}#{@message}"
    end
  end
end
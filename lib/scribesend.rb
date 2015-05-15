# Scribesend Ruby bindings (https://scribesend.com/docs)

# Third-party libraries
require 'cgi'
require 'set'
require 'rest-client'
require 'json'

# API Resources
require 'scribesend/version'
require 'scribesend/util'
require 'scribesend/scribesend_object'
require 'scribesend/api_resource'
require 'scribesend/list_object'
require 'scribesend/account'
require 'scribesend/entry'
require 'scribesend/entry_line'

# Errors
require 'scribesend/error'

module Scribesend
  @api_key = nil
  @api_base = "https://api.scribesend.com/v0"

  def self.api_url(url='', api_base_url=nil)
    (api_base_url || @api_base) + url
  end

  def self.api_key=(api_key)
    @api_key = api_key
  end

  def self.api_key
    @api_key
  end

  def self.api_base
    @api_base
  end

  def self.request(method, url, api_key, params={}, headers={}, api_base_url=nil)
    api_base_url = api_base_url || @api_base

    unless api_key ||= @api_key
      raise Error.new("No API key provided. " \
        "Set your API key using 'Scribesend.api_key = <API-KEY>'.")
    end

    params = Util.objects_to_ids(params)
    url = api_url(url, api_base_url)

    case method.to_s.downcase.to_sym
    when :get, :head, :delete
      # Make params into GET parameters
      url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
      payload = nil
    else
      if headers[:content_type] && (headers[:content_type] == "multipart/form-data" || headers[:content_type] == "application/json")
        payload = params
      else
        payload = uri_encode(params)
      end
    end

    if headers[:content_type] && headers[:content_type] == "application/json"
      content_type = headers[:content_type]
    else
      content_type = "application/x-www-form-urlencoded"
    end

    headers = {
      :user_agent => "Scribesend/v0 RubyClient/#{Scribesend::VERSION}",
      :authorization => "Bearer #{api_key}",
      :content_type => content_type
    }.update(headers)

    request_opts = {
      :method => method,
      :headers => headers,
      :url => url,
      :payload => payload,
      :verify_ssl => false,
      :open_timeout => 30,
      :timeout => 80, 
    }

    begin
      response = execute_request(request_opts)
    rescue SocketError => e
      handle_restclient_error(e, api_base_url)
    rescue NoMethodError => e
      # Work around RestClient bug
      if e.message =~ /\WRequestFailed\W/
        e = Error.new('Unexpected HTTP response code')
        handle_restclient_error(e, api_base_url)
      else
        raise
      end
    rescue RestClient::ExceptionWithResponse => e
      if rcode = e.http_code and rbody = e.http_body
        handle_api_error(rcode, rbody)
      else
        handle_restclient_error(e, api_base_url)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      handle_restclient_error(e, api_base_url)
    end

    [parse(response), api_key]
  end

  protected

  def self.uri_encode(params)
    Util.flatten_params(params).
      map { |k,v| "#{k}=#{Util.url_encode(v)}" }.join('&')
  end

  def self.execute_request(opts)
    RestClient::Request.execute(opts)
  end

  def self.parse(response)
    begin
      response = JSON.parse(response.body)
    rescue JSON::ParserError
      raise Error.new('Unexpected API response', response.code, response.body)
    end

    Util.symbolize_names(response)
  end

  def self.handle_api_error(rcode, rbody)
    begin
      error_obj = JSON.parse(rbody)
      error_obj = Util.symbolize_names(error_obj)
      error = error_obj[:error][:message] or raise Error.new # escape from parsing
    rescue JSON::ParserError, Error
      raise Error.new("Invalid response object from API: #{rbody.inspect} " +
                      "(HTTP response code was #{rcode})", rcode, rbody)
    end

    raise Error.new(error, rcode, rbody, error_obj)
  end

  def self.handle_restclient_error(e, api_base_url=nil)
    api_base_url = @api_base unless api_base_url
    connection_message = "Please check your internet connection and try again. " \
        "If this problem persists, let us know at team@scribesend.com."

    case e
    when RestClient::RequestTimeout
      message = "Could not connect to Scribesend (#{api_base_url}). #{connection_message}"

    when RestClient::ServerBrokeConnection
      message = "The connection to the server (#{api_base_url}) broke before the " \
        "request completed. #{connection_message}"

    when SocketError
      message = "Unexpected error communicating when trying to connect to Scribesend. " \
        "You may be seeing this message because your DNS is not working. " \
        "To check, try running 'host scribesend.com' from the command line."

    else
      message = "Unexpected error communicating with Scribesend. " \
        "If this problem persists, let us know at team@scribesend.com."

    end

    raise Error.new(message + "\n\n(Network error: #{e.message})")
  end
end
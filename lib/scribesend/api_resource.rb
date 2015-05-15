module Scribesend
  class APIResource < ScribesendObject
    def self.class_name
      self.name.split('::')[-1]
    end

    def self.url
      if self == APIResource
        raise NotImplementedError.new("APIResource is an abstract class. You should perform actions on its subclasses (Account, Entry, etc.)")
      end
      if (self.class_name[-1..-1] == 's' || self.class_name[-1..-1] == 'h')
        return "/#{CGI.escape(self.class_name.downcase)}es"
      elsif (self.class_name[-1..-1] == 'y')
        return "/#{CGI.escape(self.class_name.downcase[0..-2])}ies"
      else
        return "/#{CGI.escape(class_name.downcase)}s"
      end
    end

    def url
      unless id = self['id']
        raise Error.new("Could not determine which URL to request: #{self.class} instance has invalid ID: #{id.inspect}", "id")
      end
      "#{self.class.url}/#{CGI.escape(id)}"
    end

    # API Methods

    def self.request(method, url, params={}, opts={})
      headers = opts.clone
      api_key = headers.delete(:api_key)
      api_base = headers.delete(:api_base)

      response, opts = Scribesend.request(method, url, api_key, params, headers, api_base)
      [response, opts]
    end

    def refresh
      response, opts = self.class.request(:get, url, @retrieve_params)
      refresh_from(response, opts)
    end

    def self.retrieve(id, opts={})
      instance = self.new(id, opts)
      instance.refresh
      instance
    end

    def self.all(filters={}, opts={})
      response, opts = self.request(:get, url, filters, opts)
      Util.convert_to_scribesend_object(response, opts)
    end

    def self.create(params={}, opts={})
      response, opts = self.request(:post, url, params, opts)
      Util.convert_to_scribesend_object(response, opts)
    end

    # def delete(params={}, opts={})
    #   response, opts = self.class.request(:delete, url, params, opts)
    #   refresh_from(response, opts)
    #   self
    # end

    def save(params={})
      values = self.class.serialize_params(self).merge(params)

      if values.length > 0
        values.delete(:id)

        response, opts = self.class.request(:post, url, values)
        refresh_from(response, opts)
      end
      self
    end
  end
end
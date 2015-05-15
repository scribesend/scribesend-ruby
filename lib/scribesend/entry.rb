module Scribesend
  class Entry < APIResource
    def self.create(params={}, opts={})
      opts = {
        :content_type => 'application/json'
      }.merge(opts)

      response, opts = self.request(:post, url, params.to_json, opts)
      Util.convert_to_scribesend_object(response, opts)
    end

    def self.create_charge_entry(params, opts={})
      response, opts = self.request(:post, url + "/charge", params, opts)
      Util.convert_to_scribesend_object(response, opts)
    end

    def self.create_capture_entry(params, opts={})
      response, opts = self.request(:post, url + "/capture", params, opts)
      Util.convert_to_scribesend_object(response, opts)
    end

    def self.create_charge_and_capture_entry(params, opts={})
      response, opts = self.request(:post, url + "/charge_and_capture", params, opts)
      Util.convert_to_scribesend_object(response, opts)
    end
  end
end
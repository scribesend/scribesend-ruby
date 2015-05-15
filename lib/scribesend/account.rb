module Scribesend
  class Account < APIResource
    def self.retrieve_entry_lines(id, opts={})
      instance = self.new(id, opts)
      response, opts = instance.class.request(:get, instance.url + "/entry_lines", opts)
      Util.convert_to_scribesend_object(response, opts)
    end
  end
end
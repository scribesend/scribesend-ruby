module Scribesend
  class EntryLine < APIResource
    def self.url
      return nil
    end

    def url
      return nil
    end

    def self.retrieve(id, opts=nil)
      raise NotImplementedError.new("Entry_lines cannot be retrieved individually. Retrieve an entry instead.")
    end

    def self.all
      raise NotImplementedError.new("Entry_lines cannot be retrieved individually. Retrieve an entry instead.")
    end

    def self.create
      raise NotImplementedError.new("Entry_lines cannot be created outside of an entry.")
    end

    def save
      raise NotImplementedError.new("Entry_lines cannot be updated within an entry. " \
                                    "If you want to make changes to an entry_line, you will need to create " \
                                    "a new entry that adjusts the corresponding accounts and values. " \
                                    "See https://scribesend.com/docs for more details.")
    end
  end
end
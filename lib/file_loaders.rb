require "file_loaders/version"
require 'file_loaders/adapters/base'
require 'file_loaders/adapters/file'
require 'file_loaders/adapters/sftp'

module FileLoaders
  class Base
    def process
      current_adapter.each do |filename, original_filename|
        process_file(File.open(filename), File.basename(original_filename))
        true
      end
    end

    private

    def current_adapter
      name = "FileLoaders::Adapters::#{adapter_name.camelize}"
      name.constantize.new(patterns, adapter_settings)
    end

    def process_file(_file, _basename)
      raise NotImplemented
    end

    def adapter_name
      raise NotImplemented
    end

    def adapter_settings
      raise NotImplemented
    end

    def patterns
      raise NotImplemented
    end
  end
end

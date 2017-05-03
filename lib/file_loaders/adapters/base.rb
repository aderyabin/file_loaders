module FileLoaders
  module Adapters
    class Base
      def initialize(patterns, settings)
        @patterns = patterns
        @settings = settings
      end

      attr_reader :patterns, :settings

      def each(&_block)
        raise NotImplementedError
      end
    end
  end
end

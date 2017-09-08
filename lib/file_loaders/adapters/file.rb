module FileLoaders
  module Adapters
    class File < FileLoaders::Adapters::Base
      def initialize(extensions, settings)
        super

        @processed_dir = settings.processed_dir
        @source_dir = settings.source_dir

        raise(
          ArgumentError, "Source reports directory #{@source_dir} does not exists"
        ) unless Dir.exist?(@source_dir)

        raise(
          ArgumentError,
          "Processed reports directory #{@processed_dir} does not exists"
        ) if @processed_dir && !Dir.exist?(@processed_dir)
      end

      def each
        Dir[*paths].entries.each do |entry|
          basename = ::File.basename(entry)

          if yield(entry, entry) && @processed_dir
            processed_path = "#{@processed_dir}/#{basename}"
            FileUtils.mv entry, processed_path
          end
        end
      end

      private

      def paths
        patterns.map { |pattern| ::File.join(@source_dir, pattern) }
      end
    end
  end
end

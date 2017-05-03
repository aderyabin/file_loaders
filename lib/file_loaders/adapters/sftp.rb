require 'net/sftp'

module FileLoaders
  module Adapters
    class Sftp < FileLoaders::Adapters::Base
      def each
        tempdir = make_tempdir
        Net::SFTP.start settings.host, settings.user do |sftp|
          entries(sftp).each do |entry|
            filename = download!(sftp, entry, tempdir)
            move_to_processed(sftp, entry) if yield(filename, entry)
          end
        end
      ensure
        FileUtils.remove_dir(tempdir, true)
      end

      private

      def entries(sftp)
        dir = sftp.dir

        patterns.flat_map do |mask|
          dir.entries(settings.source_dir)
             .select { |e| match? e, mask }
             .map { |e| ::File.join(settings.source_dir, e.name) }
        end
      end

      def match?(entry, mask)
        !entry.directory? && ::File.fnmatch?(mask, entry.name, ::File::FNM_PATHNAME)
      end

      def download!(sftp, entry, tempdir)
        ::File.join(tempdir, ::File.basename(entry)).tap do |filename|
          sftp.download!(entry, filename)
        end
      end

      def move_to_processed(sftp, entry)
        processed_path = ::File.join(settings.processed_dir, ::File.basename(entry))
        sftp.remove(processed_path)
        sftp.rename!(entry, processed_path)
      end

      def make_tempdir
        "/tmp/#{Dir::Tmpname.make_tmpname('sftp', nil)}".tap do |name|
          FileUtils.mkdir_p name
        end
      end
    end
  end
end

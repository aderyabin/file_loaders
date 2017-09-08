require "spec_helper"

RSpec.describe FileLoaders::Adapters::Sftp do
  let(:settings) do
    Settings.new("tmp/purchase_reports_test",
                 "tmp/purchase_reports_test_processed")
  end
  let(:source_dir) { settings.source_dir }
  let(:processed_dir) { settings.processed_dir }
  let(:extensions) { %w(*.csv *.json) }

  let(:sftp) { instance_double(Net::SFTP::Session, dir: sftp_dir) }
  let(:sftp_dir) { instance_double(Net::SFTP::Operations::Dir) }

  let(:files) { extensions.map { |e| e.gsub("*", "file") } }
  let(:rails_root) { File.dirname(__FILE__) + '/../..' }
  let(:entries) do
    entry_class = Net::SFTP::Protocol::V01::Name
    files.map { |f| instance_double(entry_class, name: f, directory?: false) }
  end

  subject { described_class.new(extensions, settings) }

  before do
    allow(Net::SFTP).to \
      receive(:start).with(settings.host, settings.user) { |&b| b.call(sftp) }

    allow(sftp).to receive(:download!) do |src, dst|
      path = rails_root + dst
      dir = File.dirname(path)

      unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end

      File.write(path, "Content of #{src}")
    end

    allow(sftp_dir).to receive(:entries).with(source_dir).and_return(entries)
    allow(sftp).to receive(:remove)
    allow(sftp).to receive(:rename!).and_return(true)
  end

  it "iterates through files from src dir matched with pattern" do
    entries = []
    subject.each do |file, entry|
      entries << [File.read(rails_root + file), entry]
    end

    expect(entries).to eq(
      files.map { |f| ["Content of #{source_dir}/#{f}", "#{source_dir}/#{f}"] }
    )
  end

  it "moves sucessfully processed files to processed" do
    subject.each { true }
    files.each do |file|
      expect(sftp).to have_received(:rename!)
        .with("#{source_dir}/#{file}", "#{processed_dir}/#{file}")
    end
  end

  it "rewrites files in processed dir" do
    subject.each { true }
    files.each do |file|
      expect(sftp).to have_received(:remove).with("#{processed_dir}/#{file}")
    end
  end

  context "when processed directory is unspecified" do
    let(:settings) { Settings.new("tmp/purchase_reports_test", nil) }

    it "doesn't move entries to processed directory" do
      subject.each { true }

      expect(sftp).not_to have_received(:remove)
    end
  end
end

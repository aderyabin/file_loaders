require "spec_helper"

RSpec.describe FileLoaders::Adapters::File do
  let(:settings) do
    Settings.new("tmp/purchase_reports_test",
                 "tmp/purchase_reports_test_processed")
  end

  let(:source_dir) { settings.source_dir }
  let(:processed_dir) { settings.processed_dir }

  let(:files) { FILES.map { |name| File.join(source_dir, name) } }

  subject { described_class.new(%w(*.csv *.json), settings) }

  before do
    FileUtils.mkdir_p(source_dir)
    FileUtils.mkdir_p(processed_dir)

    files.each { |path| File.write(path, "Content of #{path}") }
  end

  after do
    FileUtils.rm_rf(processed_dir)
    FileUtils.rm_rf(source_dir)
  end

  it "iterates through files from src dir matched with pattern" do
    entries = []
    subject.each { |file, entry| entries << [File.read(file), entry] }
    expect(entries).to eq files.map { |f| ["Content of #{f}", f] }
  end

  # rubocop: disable RSpec/MultipleExpectations
  it "moves entries to processed directory" do
    subject.each { true }

    expect(Dir[File.join(source_dir, "*")]).to eq([])
    expect(Dir[File.join(processed_dir, "*")]).to match_array(
      FILES.map { |name| File.join(processed_dir, name) }
    )
  end
  # rubocop: enable RSpec/MultipleExpectations

  FILES = %w(example.csv example.json).freeze
end

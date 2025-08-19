require 'json'

RSpec.describe 'Van Gogh Paintings Extraction' do
  let(:extracted_data) { JSON.parse(File.read('./van-gogh-paintings-extracted.json'))['artworks'] }

  it 'matches the expected array' do
    expected_data = JSON.parse(File.read('./files/expected-array.json'))['artworks']
    expect(extracted_data).to eq(expected_data)
  end

  it 'ensures each artwork has required keys in correct order' do
    extracted_data.each do |artwork|
      keys = artwork.keys
      expect(keys.first).to eq('name')
      expect(keys.last).to eq('image')
      expect(keys).to include('link')
    end
  end

  it 'ensures extensions key is omitted when empty' do
    extracted_data.each do |artwork|
      if artwork['extensions'].nil? || artwork['extensions'].empty?
        expect(artwork.key?('extensions')).to be false
      end
    end
  end

  it 'ensures extensions is an array if present' do
    extracted_data.each do |artwork|
      if artwork.key?('extensions')
        expect(artwork['extensions']).to be_an(Array)
      end
    end
  end

  it 'ensures all Google links start with https://www.google.com' do
    extracted_data.each do |artwork|
      expect(artwork['link']).to start_with('https://www.google.com')
    end
  end

  it 'ensures images are present for each artwork' do
    extracted_data.each do |artwork|
      expect(artwork['image']).not_to be_nil
      expect(artwork['image']).not_to be_empty
    end
  end

  it 'ensures name is always present' do
    extracted_data.each do |artwork|
      expect(artwork['name']).not_to be_nil
      expect(artwork['name']).not_to be_empty
    end
  end

  it 'ensures image is either a URL or a base64 data string' do
    extracted_data.each do |artwork|
      expect(artwork['image']).to match(/^https?:\/\/|^data:/)
    end
  end

  it 'does not include unexpected keys' do
    allowed_keys = %w[name extensions link image]
    extracted_data.each do |artwork|
      expect(artwork.keys - allowed_keys).to be_empty
    end
  end
end

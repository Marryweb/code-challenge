require 'json'
require 'ferrum'
require 'byebug'

def extract_paintings(file_path)
  browser = Ferrum::Browser.new(headless: true)
  browser.goto("file://#{File.expand_path(file_path)}")

  paintings = []

  browser.css('div.iELo6').each do |painting_div|
    link_tag = painting_div.at_css('a')
    google_link = link_tag&.attribute('href')&.strip
    google_link = "https://www.google.com#{google_link}" if google_link && !google_link.start_with?("http")

    thumbnail_tag = link_tag.at_css('img.taFZJe')
    image = thumbnail_tag&.attribute('data-src')&.strip || thumbnail_tag&.attribute('src')&.strip

    painting_parent_div = painting_div.at_css('div.KHK6lb')
    painting_name = painting_parent_div.at_css('div.pgNMRc')&.text&.strip
    extensions_text = painting_parent_div.at_css('div.cxzHyb')&.text&.strip

    painting_hash = { name: painting_name }
    painting_hash[:extensions] = [extensions_text] unless extensions_text.nil? || extensions_text.empty?
    painting_hash[:link] = google_link
    painting_hash[:image] = image

    paintings << painting_hash
  end

  browser.quit
  { artworks: paintings }
end

File.write(
  'van-gogh-paintings-extracted.json',
  JSON.pretty_generate(extract_paintings('files/van-gogh-paintings.html'))
)

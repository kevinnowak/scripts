require 'httparty'
require 'nokogiri'
require 'json'

class Scraper
  URL = 'https://www.humblebundle.com/books'

  def initialize
    @headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
  end

  def fetch_books
    puts "Fetching current book bundles from humblebundle.com... \n\n"

    response = HTTParty.get(
      URL,
      headers: @headers
    )

    if response.code == 200
      parse_bundles(response.body)
    else
      puts "Failed to fetch data. Status code: #{response.code}"
    end
  end

  def parse_bundles(html)
    doc = Nokogiri::HTML(html)
    script = doc.at('script#landingPage-json-data')

    unless script
      puts 'Could not find the JSON data in the page'
      return
    end

    data = JSON.parse(script.content)
    books_data = data.dig('data', 'books', 'mosaic')

    unless books_data
      puts 'Could not find books data in JSON'
      return
    end

    books_data.each do |section|
      products = section['products'] || []
      puts "Found #{products.length} book bundle(s):"
      puts '=' * 70
      products.each_with_index do |product, index|
        print_product(product, index + 1)
      end
    end
  end

  def print_product(product, number)
    puts "\n#{number}. #{product['tile_name']}"
    puts "   Short Name: #{product['tile_short_name']}"
    puts "   Author/Publisher: #{product['author']}" if product['author']
    puts "   URL: #{URL}#{product['product_url']}"
    puts "   Number of Books: #{product['hover_highlights']&.first}" if product['hover_highlights']
    puts "   Total Value: #{product['hover_highlights']&.last}" if product['hover_highlights']
    puts "   Marketing: #{product['short_marketing_blurb']}" if product['short_marketing_blurb']
    puts '-' * 70
  end
end

scraper = Scraper.new
scraper.fetch_books

require "open3"


# make root-shell
# sudo npx playwright install-deps chromium

# npm install
# npx playwright install chromium
# node lib/scrapers/openai_pricing_scraper.js | head -50

class OpenAiPriceDownloaderAgent
  URL    = "https://developers.openai.com/api/docs/pricing"
  SCRIPT = Rails.root.join("lib/scrapers/openai_pricing_scraper.js").to_s

  def self.call(url: URL)
    new(url:).call
  end

  def initialize(url: URL)
    @url = url
  end

  def call
    out, err, status = Open3.capture3(
      "node #{SCRIPT} #{@url}",
      chdir: Rails.root.to_s
    )

    raise "Scraper error: #{err}" unless status.success?

    @html = out
    self
  end

  def html
    @html
  end

  def text
    @html
      &.gsub(/<script[^>]*>.*?<\/script>/mi, "")
      &.gsub(/<style[^>]*>.*?<\/style>/mi, "")
      &.gsub(/<[^>]+>/, " ")
      &.gsub(/\s+/, " ")
      &.strip
  end
end

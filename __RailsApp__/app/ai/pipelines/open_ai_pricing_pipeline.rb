class OpenAiPricingPipeline < ActiveHarness::Pipeline
  FETCH_STEP = lambda do |_payload|
    t0    = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    agent = OpenAiPriceDownloaderAgent.call
    elapsed = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0).round(3)

    ActiveHarness::Result.new(
      input:          _payload,
      output:         agent.text,
      processed:      { "html_length" => agent.html&.length, "text_length" => agent.text&.length },
      execution_time: elapsed
    )
  end

  # Step 1 — scrape the OpenAI pricing page via Playwright
  step :fetch_page, FETCH_STEP

  # Step 2 — extract structured JSON pricing via LLM
  step :extract_pricing, OpenAiPricingExtractAgent

  before :step do |step_name, _payload|
    Rails.logger.info "[OpenAiPricingPipeline] ▶ :#{step_name}"
  end

  after :step do |step_name, result|
    Rails.logger.info "[OpenAiPricingPipeline] ✓ :#{step_name} (#{result.execution_time}s)"
  end

  callback :complete do |_last_result|
    Rails.logger.info "[OpenAiPricingPipeline] ✓ complete"
  end
end

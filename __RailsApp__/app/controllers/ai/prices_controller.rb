module Ai
  class PricesController < ApplicationController
    SPECIAL_CATS = %w[imggen embed speech transcription video rerank].freeze

    def modelsdev
      all_models = ActiveHarness::Pricing.all

      @providers = all_models
        .group_by(&:provider)
        .transform_values { |models|
          models.sort_by { |m| m.output_per_million || Float::INFINITY }
        }
        .sort_by { |provider, _| provider }
        .to_h

      @cheapest = all_models
        .select { |m| m.output_per_million&.positive? }
        .sort_by { |m| m.output_per_million }
        .first(30)

      @free_models = all_models
        .select { |m| m.output_per_million.nil? || m.output_per_million == 0 }
        .sort_by { |m| [m.provider, m.id] }
    end

    def openrouter
      or_all = ActiveHarness::Pricing::OpenRouter.all

      @or_image_models = or_all
        .select { |m| m.categories.include?("imggen") }
        .sort_by { |m| m.output_per_million || Float::INFINITY }

      @or_special_models = or_all
        .reject { |m| m.categories.include?("imggen") }
        .select { |m| (m.categories & SPECIAL_CATS).any? }
        .sort_by { |m| [m.categories.first || "z", m.id] }

      @or_text_models = or_all
        .reject { |m| (m.categories & SPECIAL_CATS).any? }
        .sort_by { |m| m.output_per_million || Float::INFINITY }
    end
  end
end

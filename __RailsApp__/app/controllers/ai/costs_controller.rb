module Ai
  class CostsController < ApplicationController
    def index
      all_models = ActiveHarness::Costs.all

      # Group by provider, sort each group by output_per_million ascending (nil last)
      @providers = all_models
        .group_by(&:provider)
        .transform_values { |models|
          models.sort_by { |m| m.output_per_million || Float::INFINITY }
        }
        .sort_by { |provider, _| provider }
        .to_h

      # 30 cheapest paid models (output > 0), sorted by output price
      @cheapest = all_models
        .select { |m| m.output_per_million&.positive? }
        .sort_by { |m| m.output_per_million }
        .first(30)

      # Free models (output == 0 or no pricing data)
      @free_models = all_models
        .select { |m| m.output_per_million.nil? || m.output_per_million == 0 }
        .sort_by { |m| [m.provider, m.id] }
    end
  end
end

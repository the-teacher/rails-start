module Ai
  module PricesHelper
    BADGE_ABBR = {
      "imggen"        => "IG",
      "vision"        => "V",
      "audio"         => "Au",
      "video"         => "VD",
      "embed"         => "E",
      "speech"        => "SP",
      "transcription" => "TR",
      "rerank"        => "RR",
      "pdf"           => "PDF",
    }.freeze

    def cat_badge(cat)
      abbr = BADGE_ABBR[cat] || cat[0, 2].upcase
      content_tag(:span, abbr,
        class: "ah-cat-badge ah-cat-badge--#{cat}",
        title: cat
      )
    end

    def cat_badges(model)
      safe_join(model.categories.map { |cat| cat_badge(cat) })
    end
  end
end

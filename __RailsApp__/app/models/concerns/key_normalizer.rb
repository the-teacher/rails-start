# Converts input strings into normalized machine-friendly identifiers
# Example: "Forum Posts!" -> "forum_posts"
module TheRole2
  module KeyNormalizer
    def self.call(value)
      value.presence&.parameterize&.underscore
    end
  end
end

module ThreeStars
  # helper methods shared around clases
  module Helpers
    def blank?(string)
      string.nil? || !string.is_a?(String) || string.strip.empty?
    end

    def present?(string)
      !blank?(string)
    end
  end
end

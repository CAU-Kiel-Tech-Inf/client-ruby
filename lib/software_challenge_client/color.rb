# frozen_string_literal: true

require 'typesafe_enum'

# Die Spielsteinfarben. BLUE, YELLOW, RED und GREEN
class Color < TypesafeEnum::Base
  new :BLUE, 'B'
  new :YELLOW, 'Y'
  new :RED, 'R'
  new :GREEN, 'G'

  class << self
    def [](digit)
      constants.find { |const| const_get(const) == digit }
    end
  end
end

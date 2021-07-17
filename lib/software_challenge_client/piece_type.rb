# frozen_string_literal: true

require 'typesafe_enum'

# Die Spielsteintypen. Herzmuschel, Möwe, Seestern und Robbe
class PieceType < TypesafeEnum::Base
  new :Herzmuschel, 'C'
  new :Moewe, 'G'
  new :Seestern, 'S'
  new :Robbe, 'R'

  # @return [String] Gibt den color namen zurück
  def to_s
    self.key.to_s
  end
end

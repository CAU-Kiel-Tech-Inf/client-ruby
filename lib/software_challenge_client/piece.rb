# frozen_string_literal: true

# Ein Spielstein mit Ausrichtung, Koordinaten und Farbe
class Piece
  # @!attribute [rw] Color
  # @return [Color]
  attr_accessor :color

  # @!attribute [r] Typ des Spielsteins
  # @return [PieceType]
  attr_reader :type

  # @!attribute [rw] Koordinaten
  # @return [Coordinates]
  attr_accessor :position

  # @!attribute [r] tower_height
  # @return [Integer] Die Anzahl Spielsteine übereinander inklusive des obersten
  attr_reader :height

  # Erstellt einen neuen Spielstein.
  def initialize(color, type, position = Coordinates.origin, height = 0)
    @color = color
    @type = type
    @position = position
    @height = height
  end

  # Berechnet die Koordinaten zu denen sich dieser Spielstein bewegen könnte.
  #
  # @return [Array<Coordinates>] Die Zielkoordinaten 
  def target_coords
    xdir = 0
    if color == Color::RED
      xdir = 1
    else
      xdir = -1
    end

    case type
    when PieceType::Herzmuschel
      coords = [Coordinates.new(xdir,-1), Coordinates.new(xdir,1)]
    when PieceType::Moewe
      coords = [Coordinates.new(1,0), Coordinates.new(-1,0), Coordinates.new(0,1), 
        Coordinates.new(0,-1)]
    when PieceType::Seestern
      coords = [Coordinates.new(xdir,0), Coordinates.new(1,1), Coordinates.new(-1,1), 
        Coordinates.new(1,-1), Coordinates.new(-1,-1)]
    when PieceType::Robbe
      coords = [Coordinates.new(-1,2), Coordinates.new(1,2), Coordinates.new(-2,1), 
        Coordinates.new(2,1), Coordinates.new(-1,-2), Coordinates.new(1,-2), 
        Coordinates.new(-2,-1), Coordinates.new(2,-1)]
    end

    coords.map{ |x| x + position }.to_a
  end

  def ==(other)
    !other.nil? &&
      color == other.color &&
      position == other.position &&
      type == other.type
  end

  # @return [String] Gibt die String-Repräsentation zurück
  def to_s
    "#{color.key} #{type.key} at #{position}"
  end

  # @return [String] Gibt eine Kurzfassung der String-Repräsentation zurück
  def to_ss
    "#{color.key.to_s[0]}#{type.key.to_s[0]}"
  end

  def inspect
    to_s
  end
end

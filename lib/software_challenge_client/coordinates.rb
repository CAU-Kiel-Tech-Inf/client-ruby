# frozen_string_literal: true

# Einfache kartesische Koordinaten
class Coordinates
  include Comparable
  attr_reader :x, :y

  # Erstellt neue leere Koordinaten.
  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    x == other.x && y == other.y
  end

  # Gibt die Koordinaten (0, 0) zurück.
  def self.origin
    Coordinates.new(0, 0)
  end

  def <=>(other)
    xComp = x <=> other.x
    yComp = y <=> other.y
    if xComp == 0
      yComp
    else
      xComp
    end
  end

  def +(other)
    Coordinates.new(x + other.x, y + other.y)
  end

  # Gibt eine textuelle Repräsentation der Koordinaten aus.
  def to_s
    "(#{x}, #{y})"
  end

  def inspect
    to_s
  end
end

# encoding: UTF-8
# frozen_string_literal: true

# Ein Spieler
class Player
  # @!attribute [r] name
  # @return [String] der Name des Spielers, hat keine Auswirkungen auf das Spiel
  attr_reader :name

  # @!attribute [r] color
  # @return [Color] erster (Color::RED) oder zweiter (Color::BLUE) Spieler
  attr_reader :color

  # @!attribute [rw] amber
  # @return [Integer] Anzahl Bernsteine die dieser Spieler gesammelt hat
  attr_accessor :amber

  # Konstruktor
  # @param type [Color] Rot oder blau
  # @param name [String] Name
  # @param amber [Integer] Menge des Bernsteins die der Spieler hat
  def initialize(color, name, amber = 0)
    @color = color
    @name = name
    @amber = amber
  end

  def ==(other)
    color == other.color
  end
end

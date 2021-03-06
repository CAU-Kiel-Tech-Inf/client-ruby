# encoding: utf-8
# frozen_string_literal: true

# Exception, die geworfen wird, wenn ein ungültiger Zug ausgeführt wird.
# @see GameRuleLogic#perform_move
class InvalidMoveException < StandardError
  def initialize(msg, move)
    @move = move
    super(msg)
  end

  def to_s
    "#{super}: #{@move}"
  end
end

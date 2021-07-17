# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

require 'benchmark'

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

# matcher to make game rule specs nicer to read
RSpec::Matchers.define :be_valid_to do |what, *args|
  match do |actual|
    actual.send('is_valid_to_' + what.to_s, *args)[0]
  end
end
RSpec::Matchers.define_negated_matcher :not_be_valid_to, :be_valid_to

include GameStateHelpers
include Constants

RSpec.describe GameRuleLogic do
  subject { GameRuleLogic }
  let(:gamestate) { GameState.new }

  context 'on game start' do
    before do
      board =
        <<~BOARD
          RC RS RR RC RG RG RR RS 
          __ __ __ __ __ __ __ __ 
          __ __ __ __ __ __ __ __ 
          __ __ __ __ __ __ __ __ 
          __ __ __ __ __ __ __ __ 
          __ __ __ __ __ __ __ __ 
          __ __ __ __ __ __ __ __ 
          BS BR BG BC BR BG BC BS 
      BOARD
      state_from_string!(board, gamestate)
    end
  end

  context 'in third round' do
    before do
      board =
        <<~BOARD
        __ RS RR RC __ RG RR RS 
        __ RC __ __ RG __ __ __ 
        __ __ __ __ __ __ __ __ 
        __ __ __ __ __ __ __ __ 
        __ __ __ __ __ __ __ __ 
        __ __ BR __ __ __ __ __ 
        __ __ __ __ __ __ __ __ 
        BS __ BG BC BR BG BC BS 
      BOARD
      state_from_string!(board, gamestate)
    end

    it 'calculates all possible moves in under two seconds' do
      n = 25
      time = Benchmark.realtime do
        n.times do
          GameRuleLogic.possible_moves(gamestate)
        end
      end
      time /= n
      puts time
      expect(time).to be < 2.0
    end

    # context 'a whole game' do
    #   it 'calculates all possible moves in under two seconds' do
    #     state = GameState.new
    #     n = 1
    #     times = []
    #
    #     until state.ordered_colors.empty? do
    #       GameRuleLogic.perform_move(state, GameRuleLogic.possible_moves(state).sample)
    #       times << Benchmark.realtime do
    #         n.times do
    #           GameRuleLogic.possible_moves(state)
    #         end
    #       end
    #       puts state.board
    #     end
    #     times.each do |e|
    #       expect(e / n).to be < 2.0
    #     end
    #   end
    # end
  end
end

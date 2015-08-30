class Player
	attr_accessor :board, :color

	def initialize(color)
		@color = color 
		@board = nil
	end

	def give_board(board)
		@board = board
	end

	def get_input
		raise "get_input not implemented"
	end
end
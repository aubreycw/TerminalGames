class EmptyPiece
	def empty?
		true
	end

	def king?
		false
	end

	def to_s
		"   "
	end

	def color
		:none
	end

	def perform_move(dest)
		raise EmptyPieceError
	end

	def dup(board)
		EmptyPiece.new
	end

	def moves
		raise EmptyPieceError
	end

	def has_no_moves(xcolor)
		true
	end
end
require_relative 'board'
require_relative 'human_player'
require_relative 'computer_player'
require 'yaml'

class Game
	def initialize(player1, player2)
		@board = Board.new
		@board.populate_board
		player1.give_board(@board)
		player2.give_board(@board)
		@players = [player1, player2]
	end

	def play
		begin 
			@board.render
			until over?(current_player.color) || turns_with_no_takes > 100
				begin
					@board.render
					play_turn
				rescue SaveGame
					save_game
					retry
				end
			end
		if turns_with_no_takes <= 100
			puts "Game is over, #{@players.last.color} has won." 
		else
			puts "game is probably at a stalemate"
		end
		
		rescue QuitGame
			system("clear")
			puts "Quitting now"
			save_game_auto
			sleep(1)
		end
	end

	def play_turn
		moves = current_player.get_input
		if moves == :lose
			puts "player #{current_player.color} loses"
			quit
		end
		if @board.valid_move_set?(moves)
			@board.do_moves!(moves)
			@players << @players.shift
			return nil
		end
		sleep(1)
		puts "invalid move sequence "
	end

	def current_player
		@players.first
	end

	def over?(color)
		@board.over? || @board.stalemate?(color)
	end

	def turns_with_no_takes
		@board.turns_with_no_takes
	end

	def test
		@board.render
	end

	def self.load_game(file_name)
		save = File.read(file_name+".yml")
     	YAML::load(save).play
	end

	def save_game
    	print "Enter the name you want your savefile to have (q to cancel): "
    	savename = "#{gets.chomp}.yml"
    	return if savename.downcase == "q.yml"
   	 	File.open(savename, 'w') do |f|
    	  f.puts self.to_yaml
    	end

    	puts "Game has been saved."
    	sleep(1)
    	return
 	 end

 	 def save_game_auto
 	 	File.open("last_quit.yml", 'w') do |f|
    	  f.puts self.to_yaml
    	end
 	 end

end

white = HumanPlayer.new(:white)
black = ComputerPlayer.new(:black, 3)

game = Game.new(white, black)

game.play

#AI can double jump
#alpha-beta pruning
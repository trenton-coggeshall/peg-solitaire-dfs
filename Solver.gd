extends Node

@onready var board = $"../Board"
@onready var moves_label = $"../MovesLabel"

var search_delay = 0
var solution_delay = 50

func depth_first_search():
	var frontier = []
	var solution = []
	
	var moves_made = 0
	
	frontier.push_front(board.move_list.duplicate())
	
	while len(frontier) > 0:
		for i in range(search_delay):
			await get_tree().process_frame
		
		if len(frontier[0]) == 0:
			if board.peg_count() == 1:
				board.reset_board(board.start_peg)
				break
			
			var last_move = solution.pop_back()
			board.undo_move(last_move)
			frontier.pop_front()
			
		else:
			var node = frontier[0].pop_front()
			board.select_peg(node[0])
			board.select_peg(node[2])
			solution.append(node)
			frontier.push_front(board.move_list.duplicate())
			moves_made += 1
			moves_label.text = "Moves Searched: " + str(moves_made)
	
	play_solution(solution)


func play_solution(solution):
	for move in solution:
		
		for i in range(solution_delay):
			await get_tree().process_frame
		board.select_peg(move[0])
		board.select_peg(move[2])
		

func _on_button_pressed():
	if board.peg_count() == len(board.peg_list):
		board.select_peg(randi_range(0, len(board.peg_list) - 1))
	depth_first_search()


func _on_speed_slider_value_changed(value):
	solution_delay = 100 - value


func _on_search_speed_slider_value_changed(value):
	search_delay = 100 - value

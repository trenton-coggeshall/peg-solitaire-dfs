extends Node2D

@onready var board_sprite = $BoardSprite
@onready var peg_location = preload("res://peg_location.tscn")
@onready var solver = $"../Solver"
@onready var rows_label = $"../RowsLabel"

var board_height = 0
var board_width = 0

var peg_list = []
var selected_peg = -1
var rows = 5
var start_peg = null

var move_list = []

var game_start = false

# Called when the node enters the scene tree for the first time.
func _ready():
	board_width = board_sprite.texture.get_width()
	board_height = board_sprite.texture.get_height()
	initialize(rows)

func initialize(num_rows):
	var horizontal_offset = board_width / num_rows
	var vertical_offset = board_height / num_rows
	var vertical_position = -(board_height / 2) + (vertical_offset / 2)
	var index = 0
	rows = num_rows
	
	for i in num_rows:
		var horizontal_position = (i * -(horizontal_offset)) / 2
		for j in i + 1:
			var peg = peg_location.instantiate()
			peg.initialize(horizontal_position, vertical_position, index, i)
			index += 1
			horizontal_position += horizontal_offset
			peg_list.append(peg)
			add_child(peg)
		vertical_position += vertical_offset

func select_peg(index):
	if not game_start:
		start_peg = index
		peg_list[index].set_peg(false)
		game_start = true
		check_game()
		return
	
	if peg_list[index].has_peg:
		selected_peg = index
	else:
		check_move(index)

func check_move(index):
	var selected_row = peg_list[selected_peg].row
	var index_row = peg_list[index].row
	var jump_peg = null
	
	for i in range(len(move_list)):
		if move_list[i][0] == selected_peg and move_list[i][2] == index:
			jump_peg = peg_list[move_list[i][1]]
		
	jump(jump_peg, index)

func jump(jump_peg, index):
	if jump_peg != null and jump_peg.has_peg:
		jump_peg.set_peg(false)
		peg_list[selected_peg].set_peg(false)
		peg_list[index].set_peg(true)
	else:
		print("invalid move")
	
	move_list.clear()
	check_game()

func horizontal_check(index, row):
	if row > 1:
		if peg_list[index - 1].row == row and peg_list[index - 2].row == row:
			if peg_list[index - 1].has_peg and not peg_list[index - 2].has_peg:
				move_list.append(Vector3i(index, index - 1, index - 2))
		if index < len(peg_list) - 2 and peg_list[index + 1].row == row and peg_list[index + 2].row == row:
			if peg_list[index + 1].has_peg and not peg_list[index + 2].has_peg:
				move_list.append(Vector3i(index, index + 1, index + 2))

func vertical_check(index, row):
	if row > 1:
		var up_right = index - row
		var up_up_right = up_right - (row - 1)
		if peg_list[up_right].has_peg and not peg_list[up_up_right].has_peg:
			if peg_list[index].row - peg_list[up_up_right].row == 2:
				move_list.append(Vector3i(index, up_right, up_up_right))
		if  peg_list[up_right - 1].has_peg and not peg_list[up_up_right - 2].has_peg:
			if peg_list[index].row - peg_list[up_up_right - 2].row == 2:
				move_list.append(Vector3i(index, up_right - 1, up_up_right - 2))
	
	if row < rows - 2:
		var down_right = index + (row + 2)
		var down_down_right = down_right + (row + 3)
		if peg_list[down_right].has_peg and not peg_list[down_down_right].has_peg:
			move_list.append(Vector3i(index, down_right, down_down_right))
		if peg_list[down_right - 1].has_peg and not peg_list[down_down_right - 2].has_peg:
			move_list.append(Vector3i(index, down_right - 1, down_down_right - 2))

func check_game():
	for i in len(peg_list):
		if peg_list[i].has_peg:
			vertical_check(i, peg_list[i].row)
			horizontal_check(i, peg_list[i].row)
	
	if len(move_list) == 0:
		pass

func undo_move(move):
	peg_list[move[0]].set_peg(true)
	peg_list[move[1]].set_peg(true)
	peg_list[move[2]].set_peg(false)
	check_game()

func peg_count():
	var count = 0
	for peg in peg_list:
		if peg.has_peg:
			count += 1
	return count

func reset_board(s_peg = -1):
	for peg in peg_list:
		peg.set_peg(true)
	
	if s_peg > -1:
		peg_list[s_peg].set_peg(false)
	else:
		game_start = false
		start_peg = null
	check_game()


func _on_button_2_pressed():
	reset_board()


func _on_minus_row_button_pressed():
	rows -= 1
	reinitialize()


func _on_plus_row_button_pressed():
	rows += 1
	reinitialize()

func reinitialize():
	rows_label.text = "Rows: " + str(rows)
	for peg in peg_list:
		peg.queue_free()
	peg_list.clear()
	initialize(rows)
	selected_peg = null
	game_start = false
	check_game()

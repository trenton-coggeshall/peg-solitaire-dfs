extends Node2D
@onready var peg_hole = $PegHole
@onready var clickable = $Clickable
@onready var board = $".."


var peg_texture = load("res://Sprites/Peg.png")
var hole_texture = load("res://Sprites/Peg_Hole.png")

var has_peg = true
var index = 0
var row = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_peg:
		peg_hole.texture = peg_texture
	else:
		peg_hole.texture = hole_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize(x, y, i, r):
	position.x = x
	position.y = y
	index = i
	row = r

func clicked():
	board.select_peg(index)

func set_peg(p):
	has_peg = p
	if has_peg:
		peg_hole.texture = peg_texture
	else:
		peg_hole.texture = hole_texture

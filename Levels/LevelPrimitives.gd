extends Node

onready var melee_template = preload("res://Enemies/MeleeEnemy/MeleeEnemy.tscn")
onready var basic_template = preload("res://Enemies/BasicEnemy/BasicEnemy.tscn")
onready var advanced_tmplt = preload("res://Enemies/AdvancedEnemy/AdvancedEnemy.tscn")

var player
var level
var nextLevel = "res://Levels/Level 1.tscn"

var retry   = false
var playing = true

func initialize(p, l):
	player = p
	level  = l
	var label = Label.new()
	label.set_text("Orange enemies grow stronger each time you die. Watch out!")
	label.set_position(Vector2(430,160))
	if retry:
		level.add_child(label)
		yield(get_tree().create_timer(2), "timeout")
		label.hide()

func spawnMelee(n):
	for _i in range(n):
		var enemy:Area2D = melee_template.instance()
		enemy.initialize(player, randi()%3)
		enemy.set_position(RandomPos()) 
		level.add_child(enemy)

func spawnBasic(n):
	for _i in range(n):
		var enemy:Area2D = basic_template.instance()
		enemy.initialize(player, randi()%3)
		enemy.set_position(Vector2(RandomPos())) 
		level.add_child(enemy)
	
func spawnAdvanced(n):
	for _i in range(n):
		var enemy:Area2D = advanced_tmplt.instance()
		enemy.initialize(player, randi()%3)
		enemy.set_position(Vector2(RandomPos())) 
		level.add_child(enemy)

func RandomPos():
	return(Vector2(random_x(), random_y()))
	
func random_x():
	var ret
	if randi() % 2 == 1:
		ret = 0
	else:
		ret = 1223
	return ret

func random_y():
	var ret
	if randi() % 2 == 1:
		ret = 0
	else:
		ret = 600
	return ret
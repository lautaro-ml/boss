extends Panel

export (Resource) var background

onready var upgradeMainWindow:Node2D = get_parent()
var new_style = StyleBoxTexture.new()

func _ready():
	new_style.texture = background
	set("custom_styles/panel", new_style)

func _on_button_up(fill_mode:int, next_pos:Vector2)->void:
	# fill_mode debe ser 0-8. Ver en documentacion de TextureProgress.
	upgradeMainWindow.change_panel_to(fill_mode, next_pos)

func _on_Play_again_button_up():
	FogBackground.change_bg_color_by_position(0)
	upgradeMainWindow.get_tree().change_scene("res://proof of concept.tscn")
	TrapManager._ready()

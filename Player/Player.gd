extends Area2D

var Bullet = preload("res://Player/Bullet.tscn")
var disparo_explosivo = preload("res://Disparo/ExplosionDisparo.tscn")
const DMG_TEXT = preload("res://Fonts/FloatingText.tscn")
var label
var coins  

var speed         = GlobalVariables.Pspeed     		#Naranja, velocidad de movimiento
var atk_speed     = GlobalVariables.Patk_speed 		#Azul, velocidad de ataque
var health        = GlobalVariables.Phealth    		#Azul, vida
var dmg           = GlobalVariables.Pdmg       		#Rojo, daño
var magnet_radius = GlobalVariables.magnet_radius 	#De todos los colores
var brn_dmg       = GlobalVariables.brn_dmg  		#Rojo, quemado de fuego
var heal_speed    = GlobalVariables.heal_speed 		#Azul, velocidad de curacion
var shield_speed  = GlobalVariables.shield_speed 	#Azul, escudo

var invencibility         = false
var uso_dash              = false
var uso_disparo_explosivo = false
var uso_Attack_speed      = false
var speed_bullet          = 2

var shootT  = Timer.new()
var healT   = Timer.new()
var shieldT = Timer.new()
var isShielded = false

var poisonT   = Timer.new()
var freezeT   = Timer.new()
var habilityT = Timer.new()
var dash_use  = Timer.new()
#Blue, Orange and Red
var colores     = [Color(.0627, .1255, .702), Color(.702, .3216, .1216), Color(.702, .0823, .0706)]
var states
var pointer     = 0

onready var R = get_node("States/Red")
onready var O = get_node("States/Orange")
onready var B = get_node("States/Blue")

func initialize(l,c):
	label = l
	coins = c
	label.on_update(health)
	states = [B, O, R]

func _ready():
	R.initialize(self)
	O.initialize(self)
	B.initialize(self)
	$Sprite.modulate = colores[pointer]
	shootT.set_one_shot(true)
	shootT.set_wait_time(atk_speed)
	add_child(shootT)
	healT.set_one_shot(true)
	healT.set_wait_time(heal_speed)
	add_child(healT)
	shieldT.set_one_shot(true)
	shieldT.set_wait_time(shield_speed)
	add_child(shieldT)
	poisonT.set_one_shot(true)
	poisonT.set_wait_time(5)
	add_child(poisonT)
	freezeT.set_one_shot(true)
	freezeT.set_wait_time(2.5)
	add_child(freezeT)
	habilityT.set_one_shot(true)
	habilityT.set_wait_time(15)
	add_child(habilityT)

func color_actual():
	var sprite_modulate = $Sprite.modulate
	if sprite_modulate == Color(.702, .0823, .0706):
		return "Red"
	elif sprite_modulate == Color(.0627, .1255, .702):
		return "Blue"
	elif sprite_modulate == Color(.702, .3216, .1216):
		return "Orange"

func _physics_process(_delta):

	look_at(get_global_mouse_position())
	#if Input.is_action_just_pressed("ui_accept"):
	#	speed *= 3
	#if Input.is_action_just_released("ui_accept"):
	#	speed /= 3
	if Input.is_action_just_pressed("ui_accept") and habilityT.is_stopped():
		habilityT.start()
		states[pointer].power()
	if Input.is_action_just_pressed("next_color"):
		next_color()
		if not states[pointer].shield:
			remove_shield()
	if Input.is_action_just_pressed("previous_color"):
		previous_color()
		if not states[pointer].shield:
			remove_shield()
	if(states[pointer].shield and shieldT.is_stopped()):
		isShielded = true
		$Shield.show()
	if(states[pointer].heal and healT.is_stopped()):
		healT.start()
		heal(1)
	if(shootT.is_stopped()):
		shoot()

	if Input.is_action_pressed('right'):
		if freezeT.is_stopped():
			position.x += speed
		else:
			position.x += speed * .75
	if Input.is_action_pressed('left'):
		if freezeT.is_stopped():
			position.x -= speed
		else:
			position.x -= speed * .75
	if Input.is_action_pressed('down'):
		if freezeT.is_stopped():
			position.y += speed
		else:
			position.y += speed * .75
	if Input.is_action_pressed('up'):
		if freezeT.is_stopped():
			position.y -= speed
		else:
			position.y -= speed * .75
	if not poisonT.is_stopped():
		takeDamage(1)
	if Input.is_action_just_pressed("Activate_dash") && skill_condition("Dash",uso_dash,"Orange"):
		dash()	
		uso_dash = true
	if Input.is_action_just_pressed("Disparo_especial") && skill_condition("Disparo explosivo",uso_disparo_explosivo,"Red"):
		disparo_explosivo()	
		uso_disparo_explosivo = true
	if Input.is_action_just_pressed("Attack_speed") && skill_condition("Attack_speed",uso_Attack_speed,"Blue"):
		attack_speed()
		uso_Attack_speed = true
		
		
		
		
		
func attack_speed():
	speed_bullet = 5 
	$Timer_attack_speed.set_wait_time(3)
	$Timer_attack_speed.start()
		
		
func skill_condition(name_habilidad,use_skill,color):
	return 	posee_habilidad(name_habilidad) && !use_skill && color_actual() == color
	
	
func posee_habilidad(name_habilidad):
	var boolean = false
	for habilidad in GlobalVariables.habilidades:
		boolean = boolean || habilidad == name_habilidad
	return boolean			

func heal(x):
	if(health + x > GlobalVariables.Phealth):
		health =  GlobalVariables.Phealth
	else:
		health += x
		_create_floating_text(x, "Heal")
	label.on_update(health)

func takeDamage(x):
	if not invencibility:
		if not isShielded:
			health -= x
			_create_floating_text(x, "Damage")
			label.on_update(health)
			shieldT.stop()
			shieldT.start()
			if health <= 0:
				GlobalVariables.retry = true
				get_tree().change_scene("res://UpgradeScreen/UpgradeWindow.tscn")
		else:
			remove_shield()
			shieldT.start()

func remove_shield():
	isShielded = false
	$Shield.hide()

func shoot():
	var b = Bullet.instance()
	b.set_speed(speed_bullet)
	b.modulate = colores[pointer]
	b.start($Muzzle.global_position, rotation, dmg, pointer, states[pointer])
	get_parent().add_child(b)
	shootT.start(atk_speed)

func disparo_explosivo():
	var d = disparo_explosivo.instance()
	d.position = $Muzzle.global_position
	d.rotation = rotation
	d.set_values()
	get_parent().add_child(d)
	$Timer_Disparo_explosivo.set_wait_time(5)
	$Timer_Disparo_explosivo.start()
	
	
func dash():
	speed = 20
	$Timer_restar_Dash.set_wait_time(5)
	$Timer_restar_Dash.start()
	$Timer_dash.set_wait_time(0.1)
	$Timer_dash.start()

func next_color():
	pointer = (pointer + 1)%3
	_change_with_color(pointer)

func previous_color():
	pointer = (pointer + 2)%3
	_change_with_color(pointer)

func stop_shooting(n):
	shootT.start(n)

func _on_grab_coin(area):
	area.grab()
	coins.on_update()

func _change_with_color(n:int)->void:
	$Sprite.modulate = colores[n]
	FogBackground.change_bg_color(colores[n])
	TrapManager.change_trap_type(colores[n])

func _create_floating_text(amount:int, type:String)->void:
	var text = DMG_TEXT.instance()
	text.amount = amount
	text.type = type
	text.rotation_degrees = 90
	add_child(text)


func _on_Timer_dash_timeout():
	speed = GlobalVariables.Pspeed
	
func _on_Timer_restar_Dash_timeout():
	uso_dash = false


func _on_Timer_Disparo_explosivo_timeout():
	 uso_disparo_explosivo  = false


func _on_Timer_attack_speed_timeout():
	speed_bullet = 2
	uso_Attack_speed = false

func on_enemy_entered(area):
	if area.is_in_group("Enemy"):
		takeDamage(area.dmg)


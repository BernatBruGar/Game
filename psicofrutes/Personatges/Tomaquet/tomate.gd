extends CharacterBody2D

var speed = 100.0
var jump_power = 800.0
var jump_power_wall = 4000.0
var stopping_friction = 0.6
var running_friction = 0.95
var gravity = 30

var vel = Vector2()

var jumps_left = 2
var dash_direction = Vector2(1,0)
var can_dash = false
var dashing = false

@onready var animationPlayer=$AnimationPlayer
@onready var sprite2D=$Sprite2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	Run(delta)
	Jump()
	Dash()
	Friction()
	Gravity()
	Animations()
	velocity = vel
	move_and_slide()

func Run(delta):
	if Input.is_action_pressed("right"):
		vel.x += speed
		sprite2D.flip_h = true
	if Input.is_action_pressed("left"):
		vel.x -= speed
		sprite2D.flip_h = false

func Jump():
	if is_on_floor() or next_to_wall():
		jumps_left = 2
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		if vel.y > 0: vel.y = 0
		vel.y -= jump_power
		jumps_left -= 1
		if not is_on_floor() and next_to_left_wall():
			vel.x +=jump_power_wall
		if not is_on_floor() and next_to_right_wall():
			vel.x -=jump_power_wall
	if Input.is_action_just_released("jump") and vel.y < 0:
		vel.y = 0

func Friction():
	var running = Input.is_action_pressed("left") or Input.is_action_pressed("right")
	if not running and is_on_floor():
		vel.x *= stopping_friction
	else:
		vel.x *= running_friction
		
func Gravity():
	if not dashing:
		vel.y += gravity
	if vel.y > 800: vel.y = 800
	if next_to_wall() and vel.y > 100: vel.y = 100
	
func Dash():
	if is_on_floor():
		can_dash = true
	if Input.is_action_pressed("right"):
		dash_direction = Vector2(1,0)
	if Input.is_action_pressed("left"):
		dash_direction = Vector2(-1,0)
	
	if Input.is_action_just_pressed("dash") and can_dash:
		vel = dash_direction.normalized() * 2000
		dashing = true
		await get_tree().create_timer(0.5).timeout
		dashing = false

func next_to_wall():
	return next_to_left_wall() or next_to_right_wall()

func next_to_left_wall():
	return $LeftWall1.is_colliding() or $LeftWall2.is_colliding()

func next_to_right_wall():
	return $RightWall1.is_colliding() or $RightWall2.is_colliding()

		
func Animations():
	var running = Input.is_action_pressed("left") or Input.is_action_pressed("right")
	if not is_on_floor() and next_to_left_wall():
		animationPlayer.play("Wall")
		sprite2D.flip_h = false
	elif not is_on_floor() and next_to_right_wall():
		animationPlayer.play("Wall")
		sprite2D.flip_h = true
	elif running and is_on_floor():
		animationPlayer.play("Run")
	elif Input.is_action_pressed("jump"):
		animationPlayer.play("Jump")
	else:
		animationPlayer.play("Idle")

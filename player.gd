extends KinematicBody2D

export var JUMP_FORCE : int = -150;
export var JUMP_RELEASED_FORCE : int = -70;
export var MAX_SPEED : int = 50;
export var FRICTION : int = 20;
export var ACCELERATION : int = 20;
export var GRAVITY:int = 4;
export var ADDITIONAL_FALL_GRAVITY:int = 4;

var velocity = Vector2.ZERO

func _physics_process(delta):
	apply_gravity();
	apply_jump_moviments();
	apply_horizontal_moviments();
	velocity = move_and_slide(velocity, Vector2.UP)

func apply_gravity():
	velocity.y += GRAVITY;
	
func apply_horizontal_moviments(): 
	var input = Vector2.ZERO;
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input.x == 0:
		apply_friction();
	else:
		apply_acceleration(input.x);	
	pass;

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	pass;

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)
	pass;

func apply_jump_moviments(): 
	if  is_on_floor():
		if Input.is_action_pressed("ui_up"):
			print('entrou 1')
			velocity.y = JUMP_FORCE;
	else: 
		if Input.is_action_just_released("ui_up") && velocity.y < JUMP_RELEASED_FORCE:
			velocity.y = JUMP_RELEASED_FORCE;
		if velocity.y > 10:
			velocity.y += ADDITIONAL_FALL_GRAVITY;
	pass;	

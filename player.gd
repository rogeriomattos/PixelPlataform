extends KinematicBody2D
class_name Player

enum {MOVE, CLIMB}

export(Resource) var moveData

var velocity = Vector2.ZERO
var state = MOVE;

onready var animateSprite = $AnimatedSprite;
onready var ledderCheck = $LedderCheck;


func _ready():
	animateSprite.frames = load("res://PlayerGreenSkin.tres")

func powerup():
	moveData = load("res://FastPlayerMovementData.tres")

func _physics_process(delta):
	
	var input = Vector2.ZERO;
	input.x = Input.get_axis('ui_left', "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	if state == MOVE: 
		move_state(input)
	elif state == CLIMB: 
		climb_state(input)
	
func climb_state(input):
	if !is_on_ledder():
		state = MOVE
	velocity = input * 50;
	velocity = move_and_slide(velocity, Vector2.UP)
	pass
func move_state(input):
	if is_on_ledder() && Input.is_action_just_pressed("ui_up"):
		state = CLIMB
	apply_gravity();
	apply_horizontal_moviments(input);
	apply_jump_moviments();
	var was_in_air = !is_on_floor();
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() && was_in_air;
	if just_landed:
		animateSprite.animation = "Run"
		animateSprite.frame = 1
	pass

func is_on_ledder():
	var collider = ledderCheck.get_collider()
	return ledderCheck.is_colliding() && collider != Ledder;

func apply_gravity():
	velocity.y += moveData.GRAVITY;
	velocity.y = min(velocity.y, 200);
	
func apply_horizontal_moviments(input): 
	if input.x == 0:
		apply_friction();
		animateSprite.animation = "Idle";
	else:
		apply_acceleration(input.x);	
		animateSprite.animation = "Run";
		if input.x > 0:
			animateSprite.flip_h = true;
		else: 
			animateSprite.flip_h = false;
	pass;

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)
	pass;

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
	pass;

func apply_jump_moviments(): 
	if  is_on_floor():
		if Input.is_action_pressed("ui_up"):
			velocity.y = moveData.JUMP_FORCE;
	else: 
		animateSprite.animation = "Jump";
		if Input.is_action_just_released("ui_up") && velocity.y < moveData.JUMP_RELEASED_FORCE:
			velocity.y = moveData.JUMP_RELEASED_FORCE;
		if velocity.y > 10:
			velocity.y += moveData.ADDITIONAL_FALL_GRAVITY;
	pass;	

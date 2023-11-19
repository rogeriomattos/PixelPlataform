extends KinematicBody2D
class_name Player

enum {MOVE, CLIMB}

export(Resource) var moveData = preload("res://DefaultPlayerMovementData.tres") as PlayerMovementData;

var velocity = Vector2.ZERO
var state = MOVE;
var double_jump = 1;
var buffered_jump = false;
var coyote_jump = false;

onready var animateSprite: = $AnimatedSprite;
onready var ledderCheck: = $LedderCheck;
onready var jumpBufferTimer: = $JumpBufferTimer;
onready var coyoteJumpTimer: = $CoyoteJumpTimer;

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
	velocity = input * moveData.CLIMB_SPEED;
	velocity = move_and_slide(velocity, Vector2.UP)
	pass
func move_state(input):
	if is_on_ledder() && Input.is_action_just_pressed("ui_up"):
		state = CLIMB
	apply_gravity();
	apply_horizontal_moviments(input);
	apply_jump_moviments();
	
	pass

func is_on_ledder():
	var collider = ledderCheck.get_collider()
	return ledderCheck.is_colliding() && collider != Ledder;

func apply_gravity():
	velocity.y += moveData.GRAVITY;
	velocity.y = min(velocity.y, 200);
	
func apply_horizontal_moviments(input): 
	if !horizontal_move(input):
		apply_friction();
		animateSprite.animation = "Idle";
	if horizontal_move(input):
		apply_acceleration(input.x);	
		animateSprite.animation = "Run";
		flip_player_sprite(input);
	pass;

func flip_player_sprite(input): 
	animateSprite.flip_h = input.x > 0;

func horizontal_move(input):
	return input.x != 0;

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)
	pass;

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
	pass;

func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMP_COUNT;

func input_jump():
	if Input.is_action_pressed("ui_up") or buffered_jump:
		velocity.y = moveData.JUMP_FORCE;
		buffered_jump = false;

func can_jump():
	return is_on_floor() or coyote_jump;

func apply_jump_moviments(): 	
	if is_on_floor():
		reset_double_jump();
	else :
		animateSprite.animation = "Jump";
	
	if  can_jump():
		input_jump();
	else: 
		input_jump_released();
		input_double_jump();
		fast_fall();
		buffer_jump();
		
	var was_in_air = !is_on_floor();
	var was_on_flor = is_on_floor();
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var just_landed = is_on_floor() && was_in_air;
	if just_landed:
		animateSprite.animation = "Run"
		animateSprite.frame = 1
		
	var just_left_ground = !is_on_floor() and was_on_flor;
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true;
		coyoteJumpTimer.start()
	pass;	

func input_jump_released():
	if Input.is_action_just_released("ui_up") && velocity.y < moveData.JUMP_RELEASED_FORCE:
		velocity.y = moveData.JUMP_RELEASED_FORCE;

func input_double_jump():
	if Input.is_action_just_pressed("ui_up") && double_jump > 0:
		velocity.y = moveData.JUMP_FORCE;
		double_jump = 0;
	pass
	
func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true;
		jumpBufferTimer.start();
	pass

func fast_fall():
	if velocity.y > 10:
		velocity.y += moveData.ADDITIONAL_FALL_GRAVITY;
	pass

func _on_JumpBufferTime_timeout():
	buffered_jump = false;
	pass # Replace with function body.


func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false;
	pass # Replace with function body.

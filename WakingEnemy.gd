extends KinematicBody2D

var direction = Vector2.LEFT;
var velocity = Vector2.ZERO;
onready var animateSprite = $AnimatedSprite;
onready var ledgeCheck = $LedgeCheck;

func _ready():
	animateSprite.play('Walking')
	pass

func _physics_process(delta):
	var found_wall = is_on_wall()
	var found_ledge = !ledgeCheck.is_colliding();
	if found_wall or found_ledge:
		direction *= -1
		animateSprite.flip_h = !animateSprite.flip_h
#
	velocity = direction * 25;
	move_and_slide(velocity, Vector2.UP);
	

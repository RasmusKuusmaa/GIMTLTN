extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var player: CharacterBody2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
var is_attacking  = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_attacking:
		velocity.y = JUMP_VELOCITY


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction and !is_attacking:
		velocity.x = direction * SPEED
	elif !is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	#animation
	if direction != 0 and !is_attacking:
		animated_sprite_2d.play("Run")
		animated_sprite_2d.flip_h = direction < 0
	elif !is_attacking:
		animated_sprite_2d.play("Idle")


	if Input.is_action_just_pressed("attack"):
		animated_sprite_2d.play("Attack")
		is_attacking = true
		attack_area.monitoring = true	
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "Attack":
		is_attacking = false
		attack_area.monitoring = false
			


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(2)

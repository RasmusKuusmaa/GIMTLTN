extends CharacterBody2D

@export_group("Movement")
@export var speed: float = 220.0
@export var acceleration: float = 2000.0
@export var air_acceleration: float = 1600.0
@export var friction: float = 1800.0

@export_group("Jump")
@export var jump_velocity: float = -320.0
@export var gravity_scale: float = 1.0

@export_group("Jump Feel")
@export var max_jump_hold_time: float = 0.18
@export var fall_gravity_multiplier: float = 1.6

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

var is_attacking := false
var coyote_timer := 0.0

var jump_time := 0.0
var is_jumping := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * gravity_scale * (fall_gravity_multiplier if velocity.y > 0 else 1.0) * delta

	if is_on_floor():
		coyote_timer = 0.1
	else:
		coyote_timer -= delta

	var direction := Input.get_axis("left", "right")
	var target_speed := direction * speed
	var accel := acceleration if is_on_floor() else air_acceleration

	if direction != 0 and !is_attacking:
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0) and !is_attacking:
		velocity.y = jump_velocity
		is_jumping = true
		jump_time = 0.0

	if Input.is_action_pressed("jump") and is_jumping:
		jump_time += delta
		if jump_time < max_jump_hold_time:
			velocity.y = jump_velocity
	else:
		is_jumping = false

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	if Input.is_action_just_pressed("attack") and !is_attacking:
		is_attacking = true
		animated_sprite_2d.play("Attack")
		attack_area.monitoring = true

	move_and_slide()

	if is_attacking:
		return

	if not is_on_floor():
		animated_sprite_2d.play("Idle")
	elif abs(velocity.x) > 10:
		animated_sprite_2d.play("Run")
		animated_sprite_2d.flip_h = velocity.x < 0
	else:
		animated_sprite_2d.play("Idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "Attack":
		is_attacking = false
		attack_area.monitoring = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(2)

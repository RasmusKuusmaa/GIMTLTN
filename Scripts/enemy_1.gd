extends CharacterBody2D

var health = 3

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
		
func die():	
	queue_free()

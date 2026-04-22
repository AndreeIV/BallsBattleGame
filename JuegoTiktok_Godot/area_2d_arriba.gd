extends Area2D

func _ready():
	pass

func _on_body_entered(body):
	if body is RigidBody2D:
		get_tree().call_group("bordes_arena", "reaccionar_choque")

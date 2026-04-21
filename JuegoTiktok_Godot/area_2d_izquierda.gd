extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que entró es una pelota
	if body:
		# ENVIAMOS EL MENSAJE: 
		# "A todos los del grupo 'bordes_arena', ejecuten 'reaccionar_choque'"
		get_tree().call_group("bordes_arena", "reaccionar_choque")

extends Area2D

func _ready():
	pass

func _on_body_entered(body):
	# Verificamos si lo que entró es una pelota
	if body:
		# ENVIAMOS EL MENSAJE: 
		# "A todos los del grupo 'bordes_arena', ejecuten 'reaccionar_choque'"
		get_tree().call_group("bordes_arena", "reaccionar_choque")

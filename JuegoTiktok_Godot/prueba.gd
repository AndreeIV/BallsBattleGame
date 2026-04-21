extends Line2D

@onready var onda_ext = $Ondas_Externas
@onready var onda_int = $Ondas_Internas

var escena_sonidos = preload("res://efectos_de_sonido.tscn")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bordes_arena")
	
	points = []
	
	position = Vector2(30, 30)
	add_point(Vector2(-960, -540))
	add_point(Vector2(900, -540))
	add_point(Vector2(900, 480))
	add_point(Vector2(-960, 480))
	
	onda_int.position = Vector2(0, 0)
	onda_int.add_point(Vector2(-960, -540))
	onda_int.add_point(Vector2(900, -540))
	onda_int.add_point(Vector2(900, 480))
	onda_int.add_point(Vector2(-960, 480))

	onda_ext.position = Vector2(0, 0)
	onda_ext.add_point(Vector2(-960, -540))
	onda_ext.add_point(Vector2(900, -540))
	onda_ext.add_point(Vector2(900, 480))
	onda_ext.add_point(Vector2(-960, 480))
	
	iniciar_pulso_total()
	
func reaccionar_choque():
	
	var sonido_temporal = escena_sonidos.instantiate().get_node("Audio_Rebote").duplicate()
	get_parent().add_child(sonido_temporal)
	sonido_temporal.play()
	# 1. Creamos el objeto de animación
	var tween = create_tween()
	
	# 2. Le decimos: "Cambia el 'width' a 25 en 0.1 segundos"
	tween.tween_property(self, "width", 10.0, 0.1)
	
	# 3. Luego: "Regresa el 'width' a 8 (o tu tamaño original) en 0.2 segundos"
	tween.tween_property(self, "width", 5.0, 0.2)



func iniciar_pulso_total():
	# Creamos un loop infinito para el pulso
	var tween = create_tween().set_loops()
	
	# --- Animación de las Ondas ---
	# 1. Escala: La onda externa crece, la interna se achica
	tween.parallel().tween_property(onda_ext, "scale", Vector2(1.04, 1.04), 1.2).from(Vector2(1.0, 1.0))
	tween.parallel().tween_property(onda_int, "scale", Vector2(0.96, 0.96), 1.2).from(Vector2(1.0, 1.0))
	
	# 2. Desvanecimiento: Ambas se vuelven transparentes
	tween.parallel().tween_property(onda_ext, "modulate:a", 0.0, 1.2).from(0.6)
	tween.parallel().tween_property(onda_int, "modulate:a", 0.0, 1.2).from(0.6)
	
	# 3. Pequeño intervalo para el siguiente latido
	#tween.tween_interval(0.05)

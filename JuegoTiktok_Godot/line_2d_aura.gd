extends Line2D

@onready var onda_ext = $Line2D_Exterior
@onready var onda_int = $Line2D_Interior

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var radio = 28.0
	var puntos = 64 # Cuantos más puntos, más redondo se verá
	
	
	for i in range(puntos + 1):
		var angulo = TAU * i / puntos
		var x = cos(angulo) * radio
		var y = sin(angulo) * radio
		add_point(Vector2(x, y))
		onda_ext.add_point(Vector2(x,y))
		onda_int.add_point(Vector2(x,y))
		
	iniciar_pulso_total()


func iniciar_pulso_total():

	# Creamos un loop infinito para el pulso
	var tween = create_tween().set_loops()
	
	# --- Animación de las Ondas ---
	# 1. Escala: La onda externa crece, la interna se achica
	tween.parallel().tween_property(onda_ext, "scale", Vector2(1.5, 1.5), 1.2).from(Vector2(1.0, 1.0))
	tween.parallel().tween_property(onda_int, "scale", Vector2(0.5, 0.5), 1.2).from(Vector2(1.0, 1.0))
	
	# 2. Desvanecimiento: Ambas se vuelven transparentes
	tween.parallel().tween_property(onda_ext, "modulate:a", 0.0, 1.2).from(0.6)
	tween.parallel().tween_property(onda_int, "modulate:a", 0.0, 1.2).from(0.6)

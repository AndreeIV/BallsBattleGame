extends Line2D

func _ready():
	var radio = 25.0
	var puntos = 64 # Cuantos más puntos, más redondo se verá
	
	for i in range(puntos + 1):
		var angulo = TAU * i / puntos
		var x = cos(angulo) * radio
		var y = sin(angulo) * radio
		add_point(Vector2(x, y))
	
	# Opcional: Para que no haya un hueco donde termina la línea
	closed = true

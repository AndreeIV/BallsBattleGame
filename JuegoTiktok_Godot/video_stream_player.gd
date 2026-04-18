extends VideoStreamPlayer






# Called when the node enters the scene tree for the first time.
func _ready():
	var ancho_pantalla = get_viewport_rect().size.x
	var largo_pantalla = get_viewport_rect().size.y
	
	size.x = ancho_pantalla
	size.y = largo_pantalla
	
	
	

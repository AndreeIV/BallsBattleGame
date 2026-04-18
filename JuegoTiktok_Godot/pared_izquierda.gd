extends StaticBody2D

@onready var colision = $CollisionShape2D
@onready var visual = $ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	#var ancho_pantalla = get_viewport_rect().size.x
	var largo_pantalla = get_viewport_rect().size.y
	
	if colision.shape is RectangleShape2D:
		
		# Visual tamaño
		visual.size.x = 5
		visual.size.y = largo_pantalla - 60
		
		# Visual posicion
		visual.position.x = 30
		visual.position.y = 30
		


		
		# Colision tamaño
		#colision.shape.size.x = visual.size.x
		#colision.shape.size.y = visual.size.y
		
		# Colision posicion
		#colision.position.x = 25
		#colision.position.y = largo_pantalla / 2

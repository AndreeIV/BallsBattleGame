
		
		
		
		
		
		
extends StaticBody2D

@onready var colision = $CollisionShape2D
@onready var visual = $ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var ancho_pantalla = get_viewport_rect().size.x
	var largo_pantalla = get_viewport_rect().size.y
	
	if colision.shape is RectangleShape2D:
		
		# Visual tamaño
		visual.size.x = ancho_pantalla - 65
		visual.size.y = 5
		
		# Visual posicion
		visual.position.x = 30
		visual.position.y = largo_pantalla - 35
		
		print(ancho_pantalla)
		print(largo_pantalla)
		
		# Colision tamaños
		#colision.shape.size.x = ancho_pantalla
		#colision.shape.size.y = 30
		
		# Colision posicion
		#colision.position.x = ancho_pantalla / 2
		#colision.position.y = largo_pantalla - (visual.size.y / 2)

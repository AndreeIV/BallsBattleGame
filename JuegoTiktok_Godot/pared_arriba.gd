
		
		
extends StaticBody2D

@onready var colision = $CollisionShape2D
@onready var visual = $ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var ancho_pantalla = get_viewport_rect().size.x
	var largo_pantalla = get_viewport_rect().size.y
	
	if colision.shape is RectangleShape2D:
		
		# Visual tamaño
		visual.size.x = ancho_pantalla
		visual.size.y = 30
		
		# Visual posicion
		visual.position.x = 0
		visual.position.y = 0
		
		visual.color = "black"
		
		# Colision tamaño
		colision.shape.size.x = ancho_pantalla
		colision.shape.size.y = 30
		
		# Colision posicion
		colision.position.x = ancho_pantalla / 2
		colision.position.y = 15

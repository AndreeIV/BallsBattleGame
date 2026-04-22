extends RigidBody2D

var stats: BossStats

@onready var labelNombre = $Control_Interfaz/Label_Nombre
@onready var labelVida = $Control_Interfaz/Label_Vida


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	stats = BossStats.new()
	
	self.mass = stats.masa
	self.labelVida.text = "❤ " + str(stats.vida_actual)
	self.labelNombre.text = "Boss_Nivel_01"
	
	print(stats.vida_actual)
	
	
	# EVENTOS
	body_entered.connect(_on_choque)
	pass # Replace with function body.

func _on_choque(body):
	if body.has_method("perder_vida"):
		body.perder_vida(stats.ataque)
	print(body.name)

func perder_vida(cant):
	stats.vida_actual -= cant
	
	
	actualizar_vida()

func actualizar_vida():
	if labelVida: labelVida.text = '♥ ' + str(int(stats.vida_actual))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

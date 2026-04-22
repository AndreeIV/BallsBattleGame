extends RigidBody2D  # 👈 O CharacterBody2D, según lo que elegiste

var escena_efectos = preload("res://EfectosEspeciales.tscn")



@onready var sprite = $Sprite2D
@onready var colision = $CollisionShape2D
@onready var label_node = $Label
@onready var label_nombre = $NombreUsuario

@onready var audio_muerte = $AudioMuerte
@onready var audio_poderes = $AudioPoderes


signal pelotaMuerta(usuario, atacante)
var poderes = [
	{"name": "dañoAumentado", "valor": 10, "activo": false},
	{"name": "velocidad", "valor": 5, "activo": false},
	{"name": "instakill", "valor": 999999, "activo": false}

]
# variables base
var salud = 0
var daño = 1
var velocidad = 200
var escala_base = 0.8


var usuario = ''
var atacante = 'El Vacío'

func _ready() -> void:
	add_to_group("pelotas")
	
	actualizarVidaVisual()
	body_entered.connect(_on_choque)
	
func Datos_Mundo(data):
	var puntos = data['puntos']
	var evento = data['evento']
	
	ganar_vida(puntos, evento)
	

func _on_choque(body):
	if body.has_method("perder_vida"):
		# Ambas pierden vida al chocar
		#if "usuario" in body:
		
			
			
		#body.atacante = usuario
		body.perder_vida(daño)
			
			#print(atacante + " Con Daño --> " + str(body.daño))
			#print(usuario + " Con Daño --> " + str(daño))
			#print("**********************")

func ganar_vida(puntos, evento):
	
	# Se agrega la vida 
	
	
	
	
	
	if evento == 'boost-recibido':
		Reproducir_Audio(audio_poderes)
		if puntos == 10:
			Activar_Superdaño(puntos)
		elif puntos >= 30:
			
			Activar_Instakill(puntos)
		elif puntos == 5:
			
			Activar_Supervelocidad()
		else:
			salud += puntos * 125
			
	elif evento == 'like-recibido':
		
		EfectoLikes()
		salud += puntos * 10
		
	else:
		salud += puntos
	
	# Efecto visual opcional: Que el texto salte o brille
	actualizarVidaVisual()
	modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE


func _integrate_forces(state):
	# 🛡️ Esta función es la más segura para manipular físicas directamente
	#if poderes[1].activo == false: return
	var direccion = state.linear_velocity.normalized()
	
	# Si la pelota se queda quieta, le damos un empujón inicial
	if direccion == Vector2.ZERO:
		direccion = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	# Forzamos a que la velocidad lineal sea SIEMPRE la velocidad_objetivo
	state.linear_velocity = direccion * velocidad
	
func Activar_Supervelocidad():	
	if poderes[1].activo == true: return
	
	velocidad = velocidad * poderes[1].valor
	
	print("👟 Supervelocidad Activado para el usuario: " + usuario + " | Puntos --> " + str(poderes[1].valor))
	
	# Opcional: Cambiar el color de la interfaz o el fondo para avisar en el stream
	#$CanvasLayer/InterfazPrincipal/LabelPoder.text = "¡DAÑO X10 ACTIVO!"
	poderes[1].activo = true
	# Opcional: Hacer que dure solo 15 segundos
	await get_tree().create_timer(30.0).timeout
	Desactivar_Supervelocidad()
	
func Desactivar_Supervelocidad():
	velocidad = 150
	poderes[1].activo = false
	#$CanvasLayer/InterfazPrincipal/LabelPoder.text = ""
	print("🛡️ Velocidad normal restaurado")
	
func Activar_Superdaño(puntos):
	if poderes[0].activo == true: return
	
	daño = daño * poderes[0].valor
	
	print("🔥 Superdaño Activado para el usuario: " + usuario + " | Puntos --> " + str(puntos))
	
	# Opcional: Cambiar el color de la interfaz o el fondo para avisar en el stream
	#$CanvasLayer/InterfazPrincipal/LabelPoder.text = "¡DAÑO X10 ACTIVO!"
	poderes[0].activo = true
	# Opcional: Hacer que dure solo 15 segundos
	await get_tree().create_timer(30.0).timeout
	Desactivar_Superdaño()
	
func Desactivar_Superdaño():
	daño = 2
	poderes[0].activo = false
	#$CanvasLayer/InterfazPrincipal/LabelPoder.text = ""
	print("🛡️ Daño normal restaurado")
	
func Activar_Instakill(puntos):
	if poderes[2].activo == true: return
	
	daño = daño * poderes[2].valor
	
	print("☠ Instakill Activado para el usuario: " + usuario + " | Puntos --> " + str(puntos))
	
	# Opcional: Cambiar el color de la interfaz o el fondo para avisar en el stream
	#$CanvasLayer/InterfazPrincipal/LabelPoder.text = "¡DAÑO X10 ACTIVO!"
	poderes[2].activo = true
	# Opcional: Hacer que dure solo 15 segundos
	await get_tree().create_timer(30.0).timeout
	Desactivar_Instakill()

func Desactivar_Instakill():
	daño = 2
	poderes[2].activo = false
	#$CanvasLayer/InterfazPrincipal/LabelPoder.text = ""
	print("🛡️ Daño normal restaurado")
	
func perder_vida(cant):
	salud -= cant
	
	# Efecto visual de perder vida
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if salud <= 0:
		pelotaMuerta.emit(usuario, atacante) # Avisamos al mundo antes de morir
		crearEfectoChoque()
		
		# 🔊 3. REPRODUCIR AUDIO
		Reproducir_Audio(audio_muerte)
		
		queue_free() # Elimina el nodo fisicamente de la memoria
		
	actualizarVidaVisual()
	
func Reproducir_Audio(audio):
	if audio:
			var sonido_temporal = audio.duplicate()
			get_tree().current_scene.add_child(sonido_temporal)
			sonido_temporal.global_position = global_position
			sonido_temporal.play()
			
			# Borramos el nodo de sonido cuando termine de sonar
			sonido_temporal.finished.connect(sonido_temporal.queue_free)


func actualizarVidaVisual():

	if label_node: label_node.text = '♥ ' + str(int(salud))
	
	
	if "Bot" in usuario:
		if label_nombre: label_nombre.text = usuario

	mass = clamp(1.0 + (salud / 100.0), 1.0, 20.0)
	
	#Actualizamos la escala de las pelotas
	if salud <= 3000:
		var nueva_escala = escala_base + (salud / 2500.0)
		var escala_final = Vector2(nueva_escala, nueva_escala)
		
		sprite.scale = escala_final
		colision.scale = escala_final

	
		
	
	
	



func cargar_foto_usuario(url_foto: String):
	if url_foto == "": return
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.request(url_foto)

func _on_request_completed(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200: return
	
	var image = Image.new()
	var error = image.load_webp_from_buffer(body)
	
	if error != OK: image.load_jpg_from_buffer(body)
	
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	
	

func crearEfectoChoque():
	var contenedor = escena_efectos.instantiate()
	contenedor.global_position = global_position
	
	
	# IMPORTANTE: Pintar las chispas del color del brillo de la pelota
	var particulas = contenedor.get_node("CPUParticles2D")
	
	if particulas:
		# 🚀 ACTIVACIÓN: Sin esto, el objeto existe pero no emite nada 
		particulas.emitting = true
	
	# Agregamos al mundo (no a la pelota, para que no se muevan con ella)
	get_tree().current_scene.add_child(contenedor)
	#print("Particulas agregadas")
	# Auto-destrucción de las partículas para no dejar basura en la RAM de la T480
	await get_tree().create_timer(1).timeout
	contenedor.queue_free()
	
func AgregarFotoBots(url):
	if url == "": return
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_al_descargar_foto)
	http_request.request(url)

func _al_descargar_foto(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200: return
	
	var image = Image.new()
	var error = image.load_webp_from_buffer(body)
	
	if error != OK: image.load_jpg_from_buffer(body)
	
	var texture = ImageTexture.create_from_image(image)
	
	sprite.texture = texture

func EfectoLikes():
	var contenedor = escena_efectos.instantiate()
	
	#print(global_position)
	#contenedor.global_position = global_position
	#$LikesRecibidos.position.x = radio + 50
	$LikesRecibidos.emitting = true
	# Definimos las particculas y las activamos
	#var particulas = contenedor.get_node("LikesRecibidos")
	#if particulas: particulas.emitting = true
	
	#get_parent().add_child(contenedor)
	
	await get_tree().create_timer(1).timeout
	contenedor.queue_free()


func Obtener_Boost():
	if poderes[1].activo == true: return
	
	velocidad = velocidad * poderes[1].valor
	
	print("👟 Supervelocidad Activado para el usuario: " + usuario + " | Puntos --> " + str(poderes[1].valor))
	
	# Opcional: Cambiar el color de la interfaz o el fondo para avisar en el stream
	#$CanvasLayer/InterfazPrincipal/LabelPoder.text = "¡DAÑO X10 ACTIVO!"
	poderes[1].activo = true
	# Opcional: Hacer que dure solo 15 segundos
	await get_tree().create_timer(5.0).timeout
	Desactivar_Supervelocidad()

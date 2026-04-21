# Script actualizado para mundo.gd
extends Node2D

var escena_pelota = preload("res://pelota.tscn")
var escena_boost = preload("res://area_2d_boost.tscn")


@onready var musicaFondo = $CanvasLayer/PantallaInicio/MusicaFondo
@onready var ContenedorPelotas = $CanvasLayer/InterfazPrincipal/ContenedorPelotas
@onready var lista_ui = $CanvasLayer/InterfazPrincipal/ScrollContainer/ListaLeaderboard

var juego_iniciado = false	

var socket = WebSocketPeer.new()
var address_conection = 'localhost:3001'

# VARIABLES DE LA BASE DE DATOS
var base_datos_usuarios = {} # { "usuario": {"kills": 0, "likes": 0, "monedas": 0} }
var RUTA_GUARDADO = 'C:/Users/USER/Desktop/Datos_Guardados.json'

# VARIABLES DEL BOT
var Indice_NombreBot = 1

var pelotas_activas = {}
var pelotas_en_cola = {}
var tabla_de_kills = {}

# VARIABLES DEL TEMPORIZADOR GANADOR PARTIDA
var tiempo_inicial = 600.0
var tiempo_restante = 600.0
var tiempo_visual = 600.0
var temporizador_activo = false
@onready var label_tiempo = $CanvasLayer/InterfazPrincipal/Control_Temporizador/Label_Tiempo
@onready var barra_tiempo = $CanvasLayer/InterfazPrincipal/Control_Temporizador/TextureProgressBar



func actualizar_leaderboard():
	# 1. Limpiamos la lista visual anterior para no duplicar datos en la RAM
	for hijo in lista_ui.get_children():
		hijo.queue_free()

	# 2. Convertimos el diccionario a un Array para poder ordenarlo
	var usuarios_array = []
	for nombre in base_datos_usuarios.keys():
		var datos = base_datos_usuarios[nombre]
		datos["nombre_usuario"] = nombre # Guardamos el nombre dentro para no perderlo
		usuarios_array.append(datos) 

	# 3. Ordenamos por Kills (de mayor a menor)
	usuarios_array.sort_custom(func(a, b): return a["kills"] > b["kills"]) 

	# 4. Creamos los elementos en el VBoxContainer
	var puesto = 1
	for datos in usuarios_array:
		var item = preload("res://ItemRanking.tscn").instantiate()
		
		# Asignamos los textos (Puesto - Foto - Usuario - Kills - Likes - Coins)
		item.get_node("Puesto").text = str(puesto) + "°"
		item.get_node("Nombre").text = datos["nombre_usuario"]
		item.get_node("Kills").text = str(int(datos["kills"]))
		item.get_node("Likes").text = str(int(datos["likes"]))
		item.get_node("Coins").text = str(int(datos["monedas"]))
		
		# Cargamos la foto si la URL existe en el JSON
		lista_ui.add_child(item)
		if datos.has("foto") and datos["foto"] != "":
			item.cargar_foto_mini(datos["foto"])
			
		puesto += 1
		
		# Opcional: Mostrar solo los top 10 para no saturar tu i5-6400
		if puesto > 10: break


# --- FUNCIÓN PARA GUARDAR ---
func guardar_datos():
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	if archivo:
		var datos_json = JSON.stringify(base_datos_usuarios)
		archivo.store_string(datos_json)
		archivo.close()
		#print("💾 Datos guardados en: ", OS.get_user_data_dir()) 


# --- FUNCIÓN PARA CARGAR ---
func cargar_datos():
	if not FileAccess.file_exists(RUTA_GUARDADO):
		return
	
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
	if archivo:
		var contenido = archivo.get_as_text()
		archivo.close()
		
		var json = JSON.new()
		var error = json.parse(contenido)
		if error == OK:
			base_datos_usuarios = json.data
			print("📂 Datos cargados exitosamente")


func _ready():
	# 🛑 YA NO CONECTAMOS AQUÍ AUTOMÁTICAMENTE
	print("🎮 Esperando a que el usuario presione Play...")
	
	tiempo_restante = tiempo_inicial
	tiempo_visual = tiempo_inicial # Esto evita que la barra "salte" desde 0
	
	# Configuramos el máximo de la barra al iniciar
	barra_tiempo.max_value = tiempo_restante
	barra_tiempo.value = tiempo_restante
	
		
	  
	
	$CanvasLayer/PantallaInicio.visible = true
	$CanvasLayer/InterfazPrincipal.visible = false # Oculta el HUD de kills
	
	musicaFondo.play()
	
func Iniciar_Conexion():
	
	if address_conection == '' or address_conection == ' ':
		var err = socket.connect_to_url("ws://localhost:3001")
		if err == OK:
			print("✅ Godot conectado al servidor (Puerto 3001)")
	else:
		var err = socket.connect_to_url("ws://" + address_conection)
		if err == OK:
			print("✅ Godot conectado al servidor (" + address_conection + ")")
			
	cargar_datos()
	actualizar_leaderboard()
	Añadir_Boost_Mundo()
	
func actualizar_ui_tiempo():
	# Actualizamos el valor visual de la barra
	barra_tiempo.value = tiempo_visual
	
	# Si aún quieres mostrar los números (opcional)
	var minutos = int(tiempo_restante) / 60
	var segundos = int(tiempo_restante) % 60
	label_tiempo.text = "%02d:%02d" % [minutos, segundos]

func finalizar_partida():
	temporizador_activo = false
	juego_iniciado = false # Detiene la recepción de mensajes del socket [cite: 2]
	
	# Buscamos al ganador en tu diccionario de kills 
	var ganador = ""
	var max_kills = -1
	
	for usuario in tabla_de_kills.keys():
		if tabla_de_kills[usuario] > max_kills:
			max_kills = tabla_de_kills[usuario]
			ganador = usuario
	
	
	
	for pelota in ContenedorPelotas.get_children():
		pelota.queue_free() # Elimina la pelota de forma segura
	
	# Reiniciamos variables de lógica
	tabla_de_kills.clear()
	pelotas_activas = {}
	
	if ganador != "":
		mostrar_anuncio_ganador(ganador, base_datos_usuarios[ganador]['foto'])
	else:
		mostrar_anuncio_empate("Nadie ganó esta vez...")
		
	tiempo_restante = tiempo_inicial # Reiniciamos el tiempo

	await get_tree().create_timer(3.0).timeout
	
	temporizador_activo = true
	juego_iniciado = true
	

	guardar_datos()
	
func mostrar_anuncio_empate(txt):
	var contenedor = $CanvasLayer/InterfazPrincipal/Ganador_Partida/VBoxContainer
	var interfaz_ganador = $CanvasLayer/InterfazPrincipal/Ganador_Partida
	print($CanvasLayer/InterfazPrincipal/Ganador_Partida/VBoxContainer/TextureRect.material)
	
	var mensaje_empate = Label.new()
	mensaje_empate.text = txt
	
	mensaje_empate.z_index = 10
	contenedor.position.x = get_viewport_rect().size.x / 2
	contenedor.position.y = get_viewport_rect().size.y / 2
	contenedor.add_child(mensaje_empate)
	interfaz_ganador.visible = true
		
	await get_tree().create_timer(5.0).timeout
	
	
	mensaje_empate.queue_free()
	interfaz_ganador.visible = false
	


func mostrar_anuncio_ganador(usuario, foto):
	var contenedor = $CanvasLayer/InterfazPrincipal/Ganador_Partida/VBoxContainer
	var interfaz_ganador = $CanvasLayer/InterfazPrincipal/Ganador_Partida
	
	
	contenedor.cargar_foto_mini(foto)
	
	var nombre_ganador = Label.new()
	nombre_ganador.text = usuario
	
	
	nombre_ganador.z_index = 10
	
	

	# Crea el Label y muestra la interfaz Ganador_Partida
	contenedor.add_child(nombre_ganador)
	contenedor.position.x = get_viewport_rect().size.x / 2
	contenedor.position.y = get_viewport_rect().size.y / 2
	interfaz_ganador.visible = true
	
	
	
	# Se borra solo después de 3 segundos
	await get_tree().create_timer(5.0).timeout


	# Elimina el Label creado y oculta la interfaz Ganador_Partida
	nombre_ganador.queue_free()
	interfaz_ganador.visible = false
	contenedor.cargar_foto_mini('')


func _process(_delta):
	
	if not juego_iniciado or not temporizador_activo: return # Si el juego no ha sido iniciado no recibe peticiones
	
	

	# Restamos el temporizador
	tiempo_restante -= _delta
	tiempo_visual = lerp(tiempo_visual, tiempo_restante, 0.1)
	barra_tiempo.value = tiempo_visual
	actualizar_ui_tiempo()
	
	if tiempo_restante <= 0:
		guardar_datos()
		finalizar_partida()
	
	socket.poll()
	var state = socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			var mensaje = packet.get_string_from_utf8()
			
			var json = JSON.new()
			var error = json.parse(mensaje)
			
			if error == OK:
				var data = json.data
				
				# 🛡️ VALIDACIÓN DE SEGURIDAD:
				# Verificamos si la clave "usuario" existe antes de usarla
				if data is Dictionary and data.has("usuario"):
					call_deferred("_on_MensajeRecibido", data)
				else:
					print("⚠️ El JSON llegó pero no tiene la clave 'usuario': ", mensaje)
			else:
				print("❌ Error al leer JSON: ", json.get_error_message())




# Asegúrate de que este nombre sea EXACTAMENTE igual al que pusiste arriba
func _on_MensajeRecibido(data):
	# Verifica que la escena pelota.tscn exista
	if !escena_pelota: print("🚨 Error: No se pudo cargar la escena pelota.tscn"); return
	
	
	var usuario = data['usuario']
	var puntos = data.get('puntos', 0)
	var evento = data.get('evento', '')
	var foto = ""
	
	# Extraemos la URL de la foto de forma segura [cite: 4]
	if data.has("fotoUrl") and data["fotoUrl"] != "":
		if typeof(data["fotoUrl"]) == TYPE_ARRAY:
			foto = data["fotoUrl"][0]
		else:
			foto = data["fotoUrl"] 
	
				
	if not base_datos_usuarios.has(usuario):
		base_datos_usuarios[usuario] = {
			"kills": 0, 
			"likes": 0, 
			"monedas": 0,
			"foto": foto  # ⬅️ Guardamos la URL aquí
		}
	else:
		# Si ya existe, actualizamos la foto por si la cambió en TikTok
		base_datos_usuarios[usuario]["foto"] = foto

	# Al llamar a guardar_datos(), esta URL se escribirá en el JSON 

	

	# 📊 PASO 2: Clasificar y guardar según el tipo de evento
	if evento == "like-recibido":
		base_datos_usuarios[usuario]["likes"] += int(puntos)
		# print("❤️ Like guardado para: ", usuario)
	
	elif evento == "boost-recibido": # Ajusta según tus etiquetas de Node.js
		base_datos_usuarios[usuario]["monedas"] += int(puntos)
		# print("💰 Monedas guardadas para: ", usuario)

	# 💾 PASO 3: Persistencia inmediata (opcional, ver nota de rendimiento)
	
	
	
	# Si la pelota existe solo maneja eventos de agregar vida
	if pelotas_activas.has(usuario) and is_instance_valid(pelotas_activas[usuario]):
		
		# Aumenta la vida si la pelota existe
		var pelota = pelotas_activas[usuario]
		pelota.Datos_Mundo(data)
	
	
	
	# Si la instancia no existe, LA CREA
	if !pelotas_activas.has(usuario):
		
		#if pelotas_activas.size() >= 2: return
		
		
		# Crea una instancia y asigna atributos
		var nueva_pelota = escena_pelota.instantiate()
		var fuerza_inicial = Vector2(randf_range(-200, 200), randf_range(-200, 200))
		#var fuerza_inicial = Vector2(nueva_pelota.velocidad, nueva_pelota.velocidad)
		
		nueva_pelota.position = Vector2(randf_range(100, 1000), randf_range(100, 600))
		nueva_pelota.name = usuario # Asignamos un nombre
		nueva_pelota.usuario = usuario
		nueva_pelota.salud = 50
		pelotas_activas[usuario] = nueva_pelota # Agrega la instancia a 'pelotas activas'
		
		nueva_pelota.pelotaMuerta.connect(_on_registrar_kill)
		
		# Damos una fuerza aleatoria para que se muevan
		nueva_pelota.apply_central_impulse(fuerza_inicial)
		ContenedorPelotas.add_child(nueva_pelota)
		#add_child(nueva_pelota) # Agrega la pelota a la escena 'mundo'
		nueva_pelota.Datos_Mundo(data)
	
		
		
		nueva_pelota.cargar_foto_usuario(base_datos_usuarios[usuario]["foto"])

		
		
		
func Crear_Bot():
	var usuario = "Bot_" + str(Indice_NombreBot)
	
	
	if pelotas_activas.has(usuario): return # Si la pelota existe, no se crea
	
	
	var bot = escena_pelota.instantiate()
	var fuerza_inicial = Vector2(randf_range(-200, 200), randf_range(-200, 200))
	
	
	bot.position = Vector2(randf_range(100, 1000), randf_range(100, 600))
	bot.name = usuario
	bot.usuario = bot.name
	bot.salud = 100
	
	
	pelotas_activas[usuario] = bot
	
	
	bot.pelotaMuerta.connect(_on_registrar_kill)
	bot.apply_central_impulse(fuerza_inicial)
	
	ContenedorPelotas.add_child(bot)
	
	var url_imagen = "https://robohash.org/" + str(Indice_NombreBot)
	
	bot.AgregarFotoBots(url_imagen)
	print('Se agregó al mundo ' + bot.name)
	
	Indice_NombreBot += 1
	


func _on_registrar_kill(usuario, atacante):
	if pelotas_activas.has(usuario):
		pelotas_activas.erase(usuario) # Limpiamos las pelotas activas
		
		if atacante != "El Vacío" and atacante != usuario:
			if not tabla_de_kills.has(atacante):
				tabla_de_kills[atacante] = 0
			
			tabla_de_kills[atacante] += 1
			if not base_datos_usuarios.has(atacante):
				base_datos_usuarios[atacante] = {"kills": 0, "likes": 0, "monedas": 0}
				
			
			base_datos_usuarios[atacante]["kills"] += 1
			guardar_datos()
			
			
			print("⚔️ KILL: ", atacante, " eliminó a ", usuario)
			print("📊 ", atacante, " lleva ", tabla_de_kills[atacante], " kills.")
			
			var txt = atacante + " ⚔️ " + usuario
			mostrar_anuncio_kill(txt)
			if pelotas_activas.has(atacante): pelotas_activas[atacante].ganar_vida(20, '')
		
# Dentro de _registrar_kill en mundo.gd
func mostrar_anuncio_kill(txt):
	var anuncio = Label.new()
	anuncio.text = txt
	anuncio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$BannerKills/KillFeed.add_child(anuncio)
	
	# Se borra solo después de 3 segundos
	await get_tree().create_timer(3.0).timeout
	anuncio.queue_free()



func _on_button_pressed() -> void:
	$CanvasLayer/InterfazPrincipal/MenuPartida.visible = true


func _on_button_salir_pressed() -> void:
	if socket:
		socket.close()
	get_tree().quit()


# Boton que inicia el juego
func _on_button_play_pressed() -> void:
	
	if not juego_iniciado:
		Iniciar_Conexion()
		
		tiempo_restante = tiempo_inicial # Reiniciamos el tiempo

		$CanvasLayer/PantallaInicio.visible = false
		$CanvasLayer/InterfazPrincipal.visible = true
		
		temporizador_activo = true
		juego_iniciado = true


func _on_musica_fondo_finished() -> void:
	musicaFondo.play()
	pass # Replace with function body.


func _on_button_admin_abuse_pressed() -> void:
	$CanvasLayer/InterfazPrincipal/MenuPartida.visible = false
	$CanvasLayer/InterfazPrincipal/AdminAbuse.visible = true
	pass # Replace with function body.


func _on_button_salir_menu_pressed() -> void:
	$CanvasLayer/InterfazPrincipal/MenuPartida.visible = false
	pass # Replace with function body.


func _on_button_volver_pressed() -> void:
	$CanvasLayer/InterfazPrincipal/AdminAbuse.visible = false
	$CanvasLayer/InterfazPrincipal/MenuPartida.visible = true
	pass # Replace with function body.


func _on_button_volver_inicio_pressed() -> void:
	$CanvasLayer/PantallaInicio/TextureRect/VBoxContainer.visible = true
	$CanvasLayer/PantallaInicio/Menu_EstablecerConexion.visible = false
	guardar_datos()
	
	pass # Replace with function body.


func _on_button_establecer_conexion_pressed() -> void:
	
	address_conection = $CanvasLayer/PantallaInicio/Menu_EstablecerConexion/Panel/VBoxContainer/ConexionUsuario.text
	
	pass # Replace with function body.


func _on_button_regresar_inicio_pressed() -> void:
	if socket:
		# 🔌 Cerramos la conexión de forma segura (Código 1000 = Normal Closure)
		socket.close(1000, "Desconexión manual por el usuario")
		
		
		# 🧹 Recorremos cada hijo del contenedor y lo borramos
		for pelota in ContenedorPelotas.get_children():
			pelota.queue_free() # Elimina la pelota de forma segura
		
		# Reiniciamos variables de lógica
		tabla_de_kills.clear()
		pelotas_activas = {}
		print("♻️ Mundo purgado. Listo para nueva partida.")
		
		
		# 🚩 Cambiamos el estado para que _process deje de intentar leer
		juego_iniciado = false 
		
		# 🧹 Limpiamos la tabla visual si lo deseas
		print("🛑 Conexión finalizada. El firewall interno ha bloqueado el tráfico.")
		
		# Opcional: Volver a la pantalla de inicio
		$CanvasLayer/InterfazPrincipal.visible = false
		$CanvasLayer/PantallaInicio.visible = true
	
	pass # Replace with function body.


func _on_button_configuracion_pressed() -> void:
	$CanvasLayer/PantallaInicio/TextureRect/VBoxContainer.visible = false
	$CanvasLayer/PantallaInicio/Menu_EstablecerConexion.visible = true
	pass # Replace with function body.


func _on_button_nueva_partida_pressed() -> void:
	# 🧹 Recorremos cada hijo del contenedor y lo borramos
	cargar_datos()
	actualizar_leaderboard()
	
	for pelota in ContenedorPelotas.get_children():
		pelota.queue_free() # Elimina la pelota de forma segura
	
	# Reiniciamos variables de lógica
	tabla_de_kills.clear()
	pelotas_activas = {}
	print("♻️ Mundo purgado. Listo para nueva partida.")
	pass # Replace with function body.




func _on_button_crear_bot_pressed() -> void:
	Crear_Bot()
	pass # Replace with function body.


func _on_button_top_global_toggled(toggled_on: bool) -> void:
	if toggled_on:
		cargar_datos()
		actualizar_leaderboard()
		$CanvasLayer/InterfazPrincipal/ScrollContainer.visible = true
		print("activado")
	else:
		$CanvasLayer/InterfazPrincipal/ScrollContainer.visible = false
		print("desactivado")

func _on_button_menu_burger_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$CanvasLayer/InterfazPrincipal/MenuPartida.visible = true
	else:
		$CanvasLayer/InterfazPrincipal/MenuPartida.visible = false


func _on_button_musica_fondo_toggled(toggled_on: bool) -> void:
	var musica = $CanvasLayer/PantallaInicio/MusicaFondo
	var button = $CanvasLayer/PantallaInicio/Button_MusicaFondo
	
	if toggled_on:
		musica.volume_db = -80.0
		button.icon = preload("res://imagenes/volumen_desactivado.png")
	else:
		musica.volume_db = 0.0
		button.icon = preload("res://imagenes/volumen_activado.png")
		
	pass # Replace with function body.


func Añadir_Boost_Mundo():
	var boost = escena_boost.instantiate()
	
	boost.position = Vector2(randf_range(100, 1820), randf_range(100, 980))
	
	ContenedorPelotas.add_child(boost)
	
	
	await get_tree().create_timer(15.0).timeout
	
	if boost: boost.queue_free()
	
	Añadir_Boost_Mundo()

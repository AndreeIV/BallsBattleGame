extends Control

@onready var foto_rect = $TextureRect # Asegúrate de que el TextureRect se llame 'Foto'

func cargar_foto_mini(url_foto: String):
	if url_foto == "": foto_rect.texture = null; return
	
	# 🌐 Creamos un nodo de petición HTTP para descargar la miniatura
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_foto_descargada)
	http_request.request(url_foto)

func _on_foto_descargada(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	
	var image = Image.new()
	# Intentamos cargar como WebP (formato común en TikTok) o JPG
	var error = image.load_webp_from_buffer(body)
	if error != OK: 
		image.load_jpg_from_buffer(body)
	
	var texture = ImageTexture.create_from_image(image)
	foto_rect.texture = texture

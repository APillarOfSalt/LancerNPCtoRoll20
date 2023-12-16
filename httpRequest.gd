extends PanelContainer

var lcpNameAuthor : String

func Request(named : String, author : String, url : String) -> void:
	lcpNameAuthor = named + "\n by : " + author
	$v/Label.text = lcpNameAuthor
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = $HTTPRequest.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Called when the HTTP request is completed.
func _on_http_request_request_completed(_result, _response_code, _headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
	#set the image
	var tex = ImageTexture.create_from_image(image)
	$v/TextureRect.texture = tex
	#set the text
	$v/Label.text = lcpNameAuthor


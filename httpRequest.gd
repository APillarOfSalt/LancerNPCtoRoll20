extends PanelContainer

var lcpNameAuthor : String

func Request(named : String, author : String, url : String) -> void:
	lcpNameAuthor = named + "\n by : " + author
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
	#set the image
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	$v/TextureRect.texture = tex
	#set the text
	$v/Label.text = lcpNameAuthor

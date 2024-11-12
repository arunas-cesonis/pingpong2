extends Node2D

func _ready() -> void:
	$SubViewport/Polygon2D.material.set_shader_parameter("offset", 100.0)
	await RenderingServer.frame_post_draw
	var img: Image = $SubViewport.get_texture().get_image()
	img.resize(16, 16, Image.INTERPOLATE_NEAREST)
	print(img.get_data())
	pass

func _draw() -> void:
	pass
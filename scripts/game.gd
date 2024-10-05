extends Node2D

class_name Game

@onready var player: CharacterBody2D = $Larva
@onready var camera: Camera2D = $Camera
@onready var skyLayer: ParallaxLayer = $Parallax/SkyLayer
@onready var sky: Sprite2D = $Parallax/SkyLayer/Sky
@onready var gui: GUI = $GUI

var backgroundSize = Vector2(1024, 2048)
var viewportSize = Vector2(1024, 768)

func _ready() -> void:
	_on_viewport_resize()

	get_viewport().connect("size_changed", _on_viewport_resize)

	$Larva.init(gui)


func _on_viewport_resize() -> void:
	var size = DisplayServer.window_get_size()

	var windowRatio = float(size.x) / size.y
	var viewportRatio = viewportSize.x / viewportSize.y

	var scale = 1
	if windowRatio > viewportRatio:
		scale = size.x / viewportSize.x
	else:
		scale = size.y / viewportSize.y
	
	skyLayer.motion_mirroring = Vector2(backgroundSize.x, 0) * scale
	sky.scale = Vector2.ONE * scale


func _process(_delta: float) -> void:
	camera.position = player.position


func _on_sunlight_body_entered(body:Node2D) -> void:
	if body is Larva:
		if body.evolveState == Larva.State.EGG:
			body.level_up()

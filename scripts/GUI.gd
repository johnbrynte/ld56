extends CanvasLayer

class_name GUI

func _ready() -> void:
	set_subtitle("")


func set_stage(state: Larva.State) -> void:
	$StageMarginContainer/PanelContainer/VBoxContainer/Label.text = "Stage: {state}".format({
		"state": Larva.State.keys()[state],
	})
	$StageMarginContainer/PanelContainer/VBoxContainer/ProgressBar.value = 0


func set_stage_progress(value: float):
	var tween = get_tree().create_tween()
	tween.tween_property($StageMarginContainer/PanelContainer/VBoxContainer/ProgressBar, "value", value, 0.5)


func set_subtitle(text: String) -> void:
	$SubtitleMarginContainer.visible = text != ""
	$SubtitleMarginContainer/PanelContainer/Label.text = text

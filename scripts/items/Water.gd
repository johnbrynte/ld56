extends Area2D


func slurp_up():
	$AnimationPlayer.play("slurp")
	$AnimationPlayer.animation_finished.connect(_on_slurped)


func _on_slurped():
	queue_free()


func _on_body_exited(body:Node2D) -> void:
	pass

func _on_body_entered(body:Node2D) -> void:
	if body is Larva:
		body.collect_item(self)

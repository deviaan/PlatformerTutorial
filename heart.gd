extends Area2D




func _on_body_entered(body):
	queue_free()
	if get_tree().get_nodes_in_group("Hearts").size() == 1:
		Events.level_completed.emit()

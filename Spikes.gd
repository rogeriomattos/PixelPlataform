extends Area2D


func _on_Spikes_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is Player:
		get_tree().reload_current_scene();
		
		
	pass # Replace with function body.

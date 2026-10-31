extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		if body.has_method("die"):
			body.die()
		else:
			get_tree().reload_current_scene()

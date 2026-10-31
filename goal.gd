extends Area2D

@export_file("*.tscn") var next_scene_path: String = "res://Scenes/Victory.tscn"
@export var custom_level_name: String = ""

var _transitioning: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	# Iniciar cronómetro y métricas de nivel al cargar la escena
	var db = get_node_or_null("/root/DatabaseManager")
	if db and db.has_method("start_level_tracking"):
		db.start_level_tracking(_detect_level_name())

func _on_body_entered(body: Node2D) -> void:
	if _transitioning:
		return
	if body.name == "Player" or body.is_in_group("player") or body is CharacterBody2D:
		_transitioning = true
		_save_session_record(body)
		call_deferred("_change_level")

func _save_session_record(player_body: Node2D = null) -> void:
	var db = get_node_or_null("/root/DatabaseManager")
	if db and db.has_method("finish_level_and_save"):
		var lvl = _detect_level_name()
		var player_coords: Array = []
		if player_body:
			if player_body.has_method("record_current_position"):
				player_body.record_current_position()
			if "position_history" in player_body:
				player_coords = player_body.position_history
		var session = db.finish_level_and_save(lvl, -1, player_coords)
		print("[Goal] ¡Nivel completado! Sesión registrada en SQLite con coordenadas: ", session)

func _detect_level_name() -> String:
	if custom_level_name != "":
		return custom_level_name
	if get_tree() and get_tree().current_scene:
		var scene_name = get_tree().current_scene.name
		if scene_name == "World" or scene_name == "world":
			return "Nivel 1"
		elif scene_name == "Nivel2" or scene_name == "World2":
			return "Nivel 2"
		elif scene_name != "":
			return scene_name
	return "Nivel 1"

func _change_level() -> void:
	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Goal reached! Loading scene: ", next_scene_path)

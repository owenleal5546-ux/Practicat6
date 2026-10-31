extends Camera2D

@export var follow_speed: float = 5.0
@export var vertical_deadzone: float = 40.0 # Tolerancia para que los saltos no muevan la cámara verticalmente de golpe

func _process(delta: float) -> void:
	# Obtiene la posición global del jugador (su nodo padre)
	var player = get_parent() as Node2D
	if not player:
		return
		
	var target_pos = player.global_position
	
	# Suaviza el movimiento horizontal (Eje X) para que vaya fluido
	global_position.x = lerp(global_position.x, target_pos.x, follow_speed * delta)
	
	# Manejo inteligente del Eje Y (para que los saltos pequeños no muevan la cámara y veas el piso)
	var diff_y = target_pos.y - global_position.y
	if abs(diff_y) > vertical_deadzone:
		# Solo se mueve verticalmente si el jugador sube o baja mucho (como en plataformas altas)
		global_position.y = lerp(global_position.y, target_pos.y - (vertical_deadzone * sign(diff_y)), follow_speed * delta)

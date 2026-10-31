# Sunny Land Forest (Godot 4)

Proyecto de plataforma 2D desarrollado en Godot 4 con integración de base de datos SQLite, registro de progreso, tablero de puntuaciones (leaderboard), servidor web local en Flask, mecánicas avanzadas de Game Feel y soporte completo para dispositivos móviles (táctil).

---

## 1. Parámetros Técnicos de Jugabilidad y Game Feel
A continuación se detallan las constantes y valores configurados en el script del personaje (player.gd) y la cámara (player_camera.gd):

### Mecánicas de Salto y Plataformeo
| Parámetro | Variable | Valor | Descripción |
| :--- | :--- | :--- | :--- |
| Input Buffering | jump_buffer_time | 0.14 s (140 ms) | Margen para registrar y ejecutar automáticamente el salto si se presiona la tecla antes de tocar el suelo. |
| Coyote Time | coyote_time | 0.14 s (140 ms) | Tiempo de gracia para permitir saltar tras abandonar el borde de una plataforma en caída. |
| Velocidad de Salto | JUMP_VELOCITY | -200.0 px/s | Impulso vertical del salto. |
| Velocidad de Movimiento | SPEED | 110.0 px/s | Velocidad horizontal de desplazamiento. |
| Gravedad | gravity | 300.0 px/s² | Aceleración vertical hacia abajo. |

### Vibración de Pantalla (Screenshake)
Función reutilizable: apply_screenshake(intensity, duration) en Camera2D. Modula el offset de cámara con decaimiento lineal sin afectar el seguimiento (position_smoothing).

| Evento | Intensidad (px) | Duración (s) | Condición de Activación |
| :--- | :--- | :--- | :--- |
| Daño recibido | 5.5 | 0.25 s | Al recibir un impacto de enemigo o trampa (take_damage). |
| Pisotón sobre enemigo | 3.5 | 0.15 s | Al impactar y rebotar sobre la cabeza de un enemigo (_stomp_feedback). |
| Aterrizaje fuerte | 2.2 | 0.12 s | Al tocar suelo tras caer con velocidad vertical $\ge 170.0 \text{ px/s}$. |
| Ataque cuerpo a cuerpo | 1.8 | 0.10 s | Al ejecutar un ataque frontal con attack_hitbox. |

### Retroalimentación Visual (Squash & Stretch y Destellos)
| Acción | Transformación / Color | Duración |
| :--- | :--- | :--- |
| Despegue de Salto | Escala (0.85, 1.15) \to (1.0, 1.0) | 0.06 s + 0.09 s |
| Aterrizaje Fuerte | Escala (1.20, 0.82) \to (1.0, 1.0) | 0.06 s + 0.08 s |
| Recolección de Ítem | Escala (1.18, 1.18) y modulación Color(1.8, 1.6, 0.5) | 0.12 s / 0.15 s |
| Destello de Daño | Modulación Color(2.5, 0.3, 0.3) \to \text{Color.WHITE} | 0.14 s |
| Partículas de Ítem | CPUParticles2D (12 partículas, velocidad 30-70, vida 0.45 s) | 0.45 s (one-shot) |

### Audio Procedural Retro (AudioStreamWAV a 22.05 kHz)
Generados dinámicamente en código sin requerir archivos de audio externos:
* *Salto:* Barrido ascendente 240 Hz $\to$ 520 Hz (0.09 s).
* *Recolección (Zanahoria/Estrella):* Doble tono armónico 880 Hz + 1320 Hz (0.14 s).
* *Daño:* Barrido descendente con ruido blanco 190 Hz $\to$ 70 Hz (0.16 s).
* *Aterrizaje:* Impacto grave 120 Hz $\to$ 50 Hz (0.08 s).

---

## 2. Adaptación a Dispositivos Móviles y Controles Táctiles
Sistema de entrada multiplataforma diseñado para convivir con teclado y gamepad mediante el Input Map unificado, respetando la ergonomía y las normas de diseño móvil:

| Parámetro Táctil | Valor Configurado | Descripción |
| :--- | :--- | :--- |
| Radio del joystick | 100 px | Área analógica virtual para el movimiento horizontal fluido. |
| Zona muerta | 0.20 | Margen de tolerancia para evitar entradas involuntarias. |
| Tamaño mínimo de botones | $\ge 96 \text{ px}$ ($\approx 9 \text{ mm}$) | Área táctil optimizada para el uso cómodo con los pulgares. |
| Opacidad de controles | 0.55 | Nivel de transparencia de la interfaz para no obstruir la visibilidad del nivel. |
| Duración de vibración | 50 ms | Retroalimentación háptica (Input.vibrate_handheld) en eventos clave (daño y recolección). |
| Orientación y stretch | Landscape, canvas_items + expand | Escalado responsivo y respeto automático de la Safe Area (DisplayServer.get_display_safe_area()). |

### Características Clave Implementadas:
* *Multitouch:* Permite la ejecución simultánea de desplazamiento y acciones de salto o ataque.
* *Detección Automática y Depuración:* Ocultamiento o visualización de controles táctiles según la plataforma (DisplayServer.is_touchscreen_available()), con opción de alternancia rápida en PC.
* *Persistencia:* Guardado de preferencias de opacidad y vibración en el sistema de configuración.

# 战斗小地图 - 显示一维坐标轴和所有单位位置
extends Control
class_name CombatMiniMap

signal position_clicked(x: float)  # 点击了小地图某位置

@export var map_height: float = 60.0
@export var map_padding: float = 20.0

var player_marker: ColorRect
var enemy_markers: Array[ColorRect] = []

@onready var background: ColorRect = $Background
@onready var track: ColorRect = $Track
@onready var player_icon: ColorRect = $PlayerIcon
@onready var enemy_container: Control = $EnemyContainer

func _ready():
	Signals.combat_started.connect(_on_combat_started)
	Signals.combat_ended.connect(_on_combat_ended)
	Signals.combatant_moved.connect(_on_combatant_moved)
	
	# 点击小地图移动玩家位置
	gui_input.connect(_on_gui_input)
	
	_update_map_layout()

func _update_map_layout() -> void:
	var viewport_size = get_viewport_rect().size
	var map_width = viewport_size.x - map_padding * 2
	
	# 底部小地图区域
	position = Vector2(map_padding, viewport_size.y - map_height - map_padding)
	custom_minimum_size = Vector2(map_width, map_height)
	
	# 更新轨道
	track.size = Vector2(map_width - 20, 4)
	track.position = Vector2(10, map_height / 2 - 2)
	
	# 更新玩家图标
	if player_icon:
		player_icon.custom_minimum_size = Vector2(16, 16)
		player_icon.position = Vector2(0, map_height / 2 - 8)

func _on_combat_started(_event_id: String):
	visible = true
	update_positions()

func _on_combat_ended():
	visible = false

func _on_combatant_moved(_combatant: BaseCombatant):
	update_positions()

func update_positions() -> void:
	var map_width = custom_minimum_size.x - 30  # 边距
	
	# 更新玩家位置
	var player = Global.get_player()
	if player:
		var player_screen_x = (player.position_x / 1000.0) * map_width + 10
		player_icon.position.x = player_screen_x - 8
	
	# 更新敌人位置
	# 清除旧的
	for marker in enemy_markers:
		marker.queue_free()
	enemy_markers.clear()
	
	# 添加新的
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is BaseCombatant:
			var marker = ColorRect.new()
			marker.color = Color.RED
			marker.custom_minimum_size = Vector2(12, 12)
			var enemy_screen_x = (enemy.position_x / 1000.0) * map_width + 10
			marker.position = Vector2(enemy_screen_x - 6, map_height / 2 - 6)
			enemy_container.add_child(marker)
			enemy_markers.append(marker)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var map_width = custom_minimum_size.x - 30
		var clicked_x = (local_pos.x - 10) / map_width * 1000.0
		clicked_x = clamp(clicked_x, 0, 1000)
		position_clicked.emit(clicked_x)

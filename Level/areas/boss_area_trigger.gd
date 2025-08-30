class_name BossAreaTrigger extends Area2D

@export var boss:Enemy
@export var gates:TileMapLayer
@export var music:AudioStream

func _ready() -> void:
	gates.hide()
	gates.collision_enabled = false
	area_entered.connect(_on_area_entered)

func _on_area_entered(area:Area2D)->void:
	AudioManager.play_music(music)
	gates.show()
	gates.collision_enabled = true
	if boss:
		boss.vision_area.collision_mask = 1
		PlayerHud.show_boss_bar(boss.enemy_name)
		PlayerHud.update_boss_hp(boss.hp, boss.max_hp)
	area_entered.disconnect(_on_area_entered)
	pass

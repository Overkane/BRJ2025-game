extends CanvasLayer

@onready var boss_hp_bar = $BossHP

func _ready() -> void:
	boss_hp_bar.value = 100
	
func _on_boss_hit(current_boss_life_perc: float) -> void:
	if current_boss_life_perc != 0:
		boss_hp_bar.value = current_boss_life_perc
	else:
		boss_hp_bar.queue_free()

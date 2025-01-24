extends Node2D

var boss1: CharacterBody2D
const boss1_scene := preload("res://scenes/bosses/boss_1.tscn")


# Player entered boss 1 area
func _on_boss_1_area_enter_body_entered(body:Node2D) -> void:
    if boss1 != null:
        boss1.queue_free()
    
    boss1 = boss1_scene.instantiate()
    boss1.rotation = 3 * PI / 2 # Rotation to the endter area by default
    boss1.activate(body)
    add_child(boss1)

func _on_player_hit() -> void:
    $Player.on_death_reset()

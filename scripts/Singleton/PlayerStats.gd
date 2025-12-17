extends Node

signal effect_added(effect: String)
signal effect_removed(effecr: String)

var score: int = 0
var elapsed_time: int = 0
var current_level: int = 1

var start_time: float = 0.0
var effects: Array[String] = []

func add_points(points: int):
	score += points
	
func add_level():
	current_level += 1
	
func reset_score():
	score = 0
	elapsed_time = 0
	current_level = 1

func add_effect(effect: String):
	if effect in effects:
		return
	effects.append(effect)
	effect_added.emit(effect)
	
func remove_effect(effect: String):
	if effect not in effects:
		return
	effects.erase(effect)
	effect_removed.emit(effect)
	
func has_effect(effect: String):
	return effects.has(effect)

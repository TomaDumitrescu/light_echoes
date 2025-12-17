extends Node2D

const BEST_SCORE_KEY = "BEST_SCORE"
const BEST_LEVEL_KEY = "BEST_LEVEL"

func save_score(score: int, level: int):
	var best = get_best()
	
	if score > best[BEST_SCORE_KEY]:
		best[BEST_SCORE_KEY] = score
	if level > best[BEST_LEVEL_KEY]:
		best[BEST_LEVEL_KEY] = level

	var save_game = FileAccess.open("user://score.save", FileAccess.WRITE)
	var json_string = JSON.stringify(best)
	save_game.store_line(json_string)

func get_best() -> Dictionary:
	var empty_best = {
			BEST_SCORE_KEY: 0,
			BEST_LEVEL_KEY: 1
		}
	if not FileAccess.file_exists("user://score.save"):
		return empty_best
	var save_game = FileAccess.open("user://score.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		
		var best_score = node_data.get(BEST_SCORE_KEY, 0)
		var best_level = node_data.get(BEST_LEVEL_KEY, 1)
		return {
			BEST_SCORE_KEY: best_score,
			BEST_LEVEL_KEY: best_level
		}
	return empty_best

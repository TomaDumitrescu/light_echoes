extends Node2D

func save_score(score: int):
	var best = get_best()
	
	if score > best:
		best = score
	var score_dict = {
		"score": score,
		"best": best
	}
	var save_game = FileAccess.open("user://score.save", FileAccess.WRITE)
	var json_string = JSON.stringify(score_dict)
	save_game.store_line(json_string)


func get_best() -> int:
	if not FileAccess.file_exists("user://score.save"):
		return 0
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
		
		var best = node_data.get("best", 0)
		return best
	return 0

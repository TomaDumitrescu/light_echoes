###################################################################################################
#                                        PriorityQueue                                            #
###################################################################################################
# Min-heap priority queue: lower priority value = popped first.
# - _heap: Array of { "priority": float, "value": any }
# - container: Dictionary used as a membership set: value -> true (if in heap)

class_name PriorityQueue
extends RefCounted

var _heap = []
var container = {}   # value -> true if currently in heap


func is_empty():
	return _heap.is_empty()


func size():
	return _heap.size()


func clear():
	_heap.clear()
	container.clear()


func contains(value):
	# Convenience helper: check if a value is currently in the queue.
	return container.has(value)


func push(value, priority):
	# Optional: avoid duplicates in the queue (useful for A* open set).
	if container.has(value):
		return

	var entry = {
		"priority": priority,
		"value": value
	}

	_heap.append(entry)
	container[value] = true
	_sift_up(_heap.size() - 1)


func pop_min():
	# Returns the value with the smallest priority (or null if empty)
	if _heap.is_empty():
		return null

	var root = _heap[0]
	var result = root["value"]

	# Remove from membership set
	container.erase(result)

	var last_index = _heap.size() - 1
	if last_index == 0:
		# Only one element in heap
		_heap.clear()
		return result

	# Move last to root and shrink
	_heap[0] = _heap[last_index]
	_heap.pop_back()
	_sift_down(0)

	return result


func peek_min():
	# Look at smallest element WITHOUT modifying heap or container
	if _heap.is_empty():
		return null

	return {
		"value": _heap[0]["value"],
		"priority": _heap[0]["priority"]
	}


# -------------------------
# Internal helpers
# -------------------------

func _swap(i, j):
	var tmp = _heap[i]
	_heap[i] = _heap[j]
	_heap[j] = tmp


func _sift_up(i):
	# Bubble element at index i up until heap property is satisfied
	while i > 0:
		var parent = (i - 1) >> 1
		if _heap[i]["priority"] < _heap[parent]["priority"]:
			_swap(i, parent)
			i = parent
		else:
			break


func _sift_down(i):
	# Push element at index i down until heap property is satisfied
	var n = _heap.size()
	while true:
		var left = 2 * i + 1
		var right = 2 * i + 2
		var smallest = i

		if left < n and _heap[left]["priority"] < _heap[smallest]["priority"]:
			smallest = left
		if right < n and _heap[right]["priority"] < _heap[smallest]["priority"]:
			smallest = right

		if smallest != i:
			_swap(i, smallest)
			i = smallest
		else:
			break

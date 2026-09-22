extends Node

enum State{
	PAUSED,
	UNPAUSED
}

var state: State = State.UNPAUSED
var menus: Array[Control] = []

func check_pause_condition():
	if menus.is_empty():
		Engine.time_scale = 1.0
		state = State.UNPAUSED
	else:
		Engine.time_scale = 0.0
		state = State.PAUSED

func add_menu(menu: Control):
	menus.append(menu)
	check_pause_condition()

func remove_menu(menu: Control):
	if menus.has(menu) and is_current_menu(menu):
		menus.erase(menu)
	check_pause_condition()

func is_current_menu(menu: Control) -> bool:
	if menus.is_empty():
		return false
	
	if menu == menus.back():
		return true
	
	return false

func clear_all_menus():
	if menus.is_empty():
		return
	menus.clear()
	check_pause_condition()

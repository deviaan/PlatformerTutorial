extends CenterContainer

@onready var start_game = %StartGame
@onready var quit_game = %QuitGame


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_game.grab_focus()


func _on_start_game_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://level_one.tscn")
	LevelTransition.fade_from_black()


func _on_quit_game_pressed():
	get_tree().quit()

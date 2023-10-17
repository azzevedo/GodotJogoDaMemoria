extends Control


@onready var play_button: Button = get_node("CenterContainer/Panel/VBoxContainer/PlayButton")

func _ready() -> void:
	get_tree().paused = true

func _On_play_button_pressed() -> void:
	# Botão para iniciar o jogo foi pressionado
	get_tree().paused = false
	# Quando iniciar o jogo, o InitializeDeck rodará 2 vezes
	# Quando o PopUp aparecer após finalizar uma rodada, será uma chamada
	# normal dentro do 'ResetGame'
	GameManager.ResetGame()
	queue_free()


func Win() -> void:
	# Modifica a textura do TextureRect para indicar 'jogo completo'
	var win_banner: Resource = load("res://Assets/ui/complete.png")
	var texture_rect: TextureRect = get_node("CenterContainer/Panel/VBoxContainer/TextureRect")
	texture_rect.texture = win_banner

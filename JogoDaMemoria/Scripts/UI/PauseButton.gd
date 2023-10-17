extends Button


func _ready() -> void:
	# Quando reiniciar o jogo, algumas ações são tomadas em 
	# GameManager, e depois é como 'apertar o play outra vez'
	GameManager.connect("restart", _pressed)

func _pressed() -> void:
	# Alterna entre  play e pause no jogo
	var paused: bool = get_tree().paused
	get_tree().paused = !paused
	ChangeIcon(!paused)

func ChangeIcon(paused: bool) -> void:
	# Muda o ícone do botão
	# Se 'paused' for 'true', fica com o ícone de 'play'
	var image: Resource

	if (paused):
		image = load("res://Assets/ui/play.png")
	else:
		image = load("res://Assets/ui/pause.png")

	icon = image


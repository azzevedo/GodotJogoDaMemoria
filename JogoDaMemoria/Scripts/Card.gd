extends TextureButton
class_name Card


var suit: CardEnums.Suit
var value: CardEnums.Value
var back: Resource = GameManager.card_back
# var back: Resource = preload("res://Assets/cards/cardBack_green2.png")
var face: Resource



func _init(_value, _suit):
	# Inicializar a carta com os valores
	# definidos nos argumentos do construtor
	value = _value
	suit = _suit

	# Carregar a imagem desta carta
	# de acordo com os valores nos Enums
	face = load("res://Assets/cards/card-%d-%d.png" %[suit, value])

	# Atribuir a textura
	texture_normal = back


func _ready():
	# Redimensionar o TextureButton (Carta)
	# 'dizer' ao grid (seu container) para centralizar numa célula
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	ignore_texture_size = true


func _pressed():
	GameManager.ChooseCard(self)
	# Flip()

func Flip() -> void:
	# Vira a carta
	# mostra a face se ela estiver para baixo
	# ou mostra as costas se a face estiver exposta
	#TODO criar um delay para virar as cartas, sem poder selecionar outras
	if (texture_normal == back):
		texture_normal = face
		return
	
	# else ==== face
	#await get_tree().create_timer(1).timeout
	texture_normal = back


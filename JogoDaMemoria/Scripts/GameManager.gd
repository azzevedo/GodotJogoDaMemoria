extends Node

var card_back: Resource = preload("res://Assets/cards/cardBack_red2.png")
# Game.tscn serve mais para representar a parte visual do jogo
# GameManager representa a parte lógica, mais instancia as texturas
# das cartas
# /root/Game é onde está rodando a cena principal Game.tscn
@onready var game: Control = get_node("/root/Game")


var deck: Array[Card]
# Só pode selecionar 2 cartas por vez
var card1: Card
var card2: Card
# Manter contagem das cartas viradas
var flipped_cards: int = 0
# Pontuação do jogador, tempo decorrido e movimentos realizados
var score: int = 0
var seconds: float = 0
var moves: int = 0

# HUD
var score_label: Label
var seconds_label: Label
var moves_label: Label
var restart_button: Button

var pop_up: PackedScene = preload("res://UI/PopUp.tscn")

signal restart


func _ready() -> void:
	# Esperar o Node Game.tscn estar pronto
	await game.ready

	ShowSplash("find all 26 pairs to win!")

	# Inicializar o deck
	InitializeDeck()
	InitHUD()


func _process(delta: float) -> void:
	# Calcular o tempo decorrido
	seconds += delta
	UpdateHUD()


func ShowSplash(msg: String, win: bool = false) -> void:
	# Mostra uma tela antes de iniciar o jogo
	var pop: Control = pop_up.instantiate()
	var lbl: Label = pop.get_node("CenterContainer/Panel/VBoxContainer/Label")
	# Adicionar um informação ao Label
	# Este PopUp pode ser chamado ao iniciar [primeira vez] ou
	# após um game over [com as informações do último jogo]
	lbl.text = msg

	# Mudar a textura se for o fim do jogo
	if (win):
		pop.Win()

	game.add_child(pop)


func InitHUD() -> void:
	# Guardar referências as labels que exibirão informações na tela
	score_label = game.get_node("HUD/Panel/Sections/SectionScore/ScoreLabel")
	seconds_label = game.get_node("HUD/Panel/Sections/SectionTimer/TimerLabel")
	moves_label = game.get_node("HUD/Panel/Sections/SectionMoves/MovesLabel")
	restart_button = game.get_node("HUD/Panel/Sections/SectionReset/RestartButton")
	# Conectar ao botão de reiniciar partida com o método ResetGame
	# Já tô pegando os Labels da mesma lógica acima : HUD/Panel....
	# então, melhor fazer assim mesmo
	restart_button.connect("pressed", ResetGame, CONNECT_DEFERRED)


func UpdateHUD() -> void:
	# Atualizar as informações ao jogador
	score_label.text = str(score)
	# seconds_label.text = str(floor(seconds))
	seconds_label.text = "%.1f" %[seconds]
	moves_label.text = str(moves)


func InitializeDeck() -> void:
	# Limpar cartas, por garantia
	ClearGrid()
	# Criar as cartas
	FillDeck()
	# Embaralhar as cartas 2 vezes
	ShuffleDeck(2)
	# Adicionar cartas ao Grid
	DealCards()


func ClearGrid() -> void:
	# Limpa as cartas do Grid
	get_tree().call_group("cards", "queue_free")


func FillDeck() -> void:
	# Instancia todas as cartas do baralho e as coloca no deck
	# Garante que o Array esteja vazio
	# deck.clear()
	deck = []
	for suit in range(1, len(CardEnums.Suit) + 1):
		for value in range(1, len(CardEnums.Value) + 1):
			var newCard = Card.new(int(value), int(suit))
			deck.append(newCard)


func ShuffleDeck(times: int = 1) -> void:
	# Embaralha o deck quantas vezes forem informadas
	for time in times:
		randomize()
		deck.shuffle()


func DealCards() -> void:
	# Adiciona as cartas do deck no Grid [parte visual]
	var grid: GridContainer = game.get_node("MarginContainer/Grid")
	for card in deck:
		# Adicionar a um grupo para ficar fácil remover depois do Grid
		card.add_to_group("cards")
		# Adicionar a carta ao Grid
		grid.add_child(card)


func ChooseCard(card_taken: Card) -> void:
	# Escolhe uma carta e mantem uma referência a ela
	if (card1 == null):
		card1 = card_taken
		card1.Flip()
		card1.disabled = true
	elif (card2 == null):
		card2 = card_taken
		card2.Flip()
		card2.disabled = true

		# A cada 2 cartas viradas, há um movimento
		moves += 1

		# Só avaliamos quando a segunda carta está selecionada
		CheckCards()


func CheckCards() -> void:
	# Aqui as duas cartas foram escolhidas
	#TODO refatorar
	if (AreCardsAMatch()):
		# Se as cartas combinam, aumenta o placar [score]
		score += 1
		# Aplicar visualmente esta combinação
		await MatchCardsAndScore()
	else:
		# Revirar as cartas
		# Como este método tem um await lá, ele vai criar a corotina
		# aqui é para esperar aquela corotina finalizar
		await TurnOverCards()

	# Independente de ser um match ou não, limpar as referências
	# à cartas selecionada para poder selecionar outras
	ResetSelectedCards()
	EvaluateEndGame()


func EvaluateEndGame() -> void:
	# Avalia se o jogo terminou
	# O jogo termina quando todas as cartas estão viradas
	if (flipped_cards == deck.size()):
		#TODO mostrar tela de reinício
		var msg: String = "you made %d points in %.1f seconds - moves: %d" %[score, seconds, moves]
		ShowSplash(msg, true)


func MatchCardsAndScore() -> void:
	# Espera um pouco e cria um fade no efeito da carta
	# fica mais cinza e transparente
	await get_tree().create_timer(0.5).timeout
	var fade = Color(0.6, 0.6, 0.6, 0.5)
	card1.modulate = fade
	card2.modulate = fade
	# Toda vez que há um Match, acrescentar 2 à soma de cartas viradas
	flipped_cards += 2


func TurnOverCards() -> void:
	# Espera um pouco e revira as cartas que não combinaram
	await get_tree().create_timer(0.5).timeout

	card1.Flip()
	card1.disabled = false
	card2.Flip()
	card2.disabled = false


func ResetSelectedCards() -> void:
	# As cartas selecionadas voltam a ser 'null'
	card1 = null
	card2 = null


func AreCardsAMatch() -> bool:
	# A combinação só considera o valor da carta, não o naipe
	return (card1.value == card2.value)


func ResetGame() -> void:
	# Resetar o movimento, cartas viradas, tempo e pontuação
	moves = 0
	score = 0
	seconds = 0
	flipped_cards = 0

	ResetSelectedCards()
	InitializeDeck()
	UpdateHUD()

	# Tirar o pause
	# O botão de pause será ativado, em PauseButton há a conexão a este evento [signal]
	# Só emite o signal se estiver pausado, para mudar o botão de "play/pause"
	if (get_tree().paused):
		restart.emit()

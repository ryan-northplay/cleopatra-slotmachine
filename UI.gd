extends Control

# // UI labels : onready (pre-carga)
onready var betline_label = $MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/VBoxContainer/Bet/Apuesta
onready var lines_label = $"MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/LBoxContainer/Lines/Líneas"
onready var bet_label = $"MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/LBoxContainer/BetLine/BetLínea"

# // Sliding score parameters
var animationTime : float 	# // how many frames between each credit tick
	
var _saldo : float
var saldo_inicial : float
var saldo_actual : int = 0

# ///////////////////////////////////////////////
# // Actualización de cambios  en la interfaz UI: Saldo - Bet - Líneas
# ///////////////////////////////////////////////

func _ready():
	
	 # // Valor estático (Requiere atención y mejoras para lograr una variable de valores dinámicos que reciba la información del saldo actual que dispone el cliente)
	lines_label.text = str(5)
	betline_label.text = str(25)
	bet_label.text = str(5)

func setBetting (lineBet, bet):
	
	betline_label.text = str(lineBet)
	bet_label.text = str(bet)
	$ButtonClick.play()

func void_notification():
	
	$MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message1.text = ("¡Buena suerte!")

func free_spins ():
	
	# // Warning panel : Coroutine (delay)
	yield(get_tree().create_timer(3.0),"timeout")
	$MarginContainer2/FreeSpins.show()
	yield(get_tree().create_timer(9.2),"timeout")
	$MarginContainer2/FreeSpins.hide()
	
	$MarginContainer/HBoxContainer/VBoxContainerCenter/Logo/AnimationPlayer.play("logo_out")

# // Free Spins Animations : UI
func _free_spins ():
	
	$MarginContainer2/VBoxContainer/FreeSpins2.hide()
	yield(get_tree().create_timer(1.0),"timeout")
	$MarginContainer/HBoxContainer/VBoxContainerCenter/Logo/AnimationPlayer.play("logo_entry")

# // Free Spins Amount : UI
func update_freeSpins (spins):
	
	$MarginContainer2/VBoxContainer/FreeSpins2.show()
	$MarginContainer2/VBoxContainer/FreeSpins2.text = ("Tiros Gratis " + str(spins) + " de 8") # // Basic SCATTER (Starter Pack)

func update_coins (saldo):
	
	$MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/VBoxContainer/Coins/Saldo.text = str(saldo)

# // Configure y establezca las funciones dinámicas necesarias: SALDO, POZO y BET. (Mejoras NO incluídas en el paquete actual)
func setNumber (value : float):
	saldo_inicial = saldo_actual
	_saldo = value

func AddToNumber (value : float):
	saldo_inicial = saldo_actual
	_saldo += value

func _process (delta : float):
	
	if saldo_actual != _saldo:
		if saldo_inicial  < _saldo:
			saldo_actual += (animationTime * delta) * (_saldo - saldo_inicial)
			if saldo_actual >= _saldo:
				saldo_actual = _saldo
		else:
			saldo_actual -= (animationTime * delta) * (_saldo - saldo_inicial)
			if saldo_actual <= _saldo:
				saldo_actual = _saldo
		
		$MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message2.text = ("GANANCIAS: "+ str(saldo_actual))


 # // UI Panel de notificaciones : MAIN
func earnings(ganancias):

	saldo_actual = 0
	_saldo = ganancias
	
	if ganancias >= 100: 
		 animationTime = 1.63
	else:
		animationTime = 7.63
		
	
	$MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message2.show()
	get_tree().get_nodes_in_group("sfx")[5].play() # // Success! sound 
	$MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message2/AnimationPlayer.play("Earnings")


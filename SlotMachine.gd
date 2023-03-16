# Copyright © 2020 by DIEGOT PRODUCTIONS
#
# IGT Slots License:
#
# All rights reserved. No part of this slot machine may be reproduced, distributed,
# or transmitted in any form or by any means, includingcompiling, recording,
# or other electronic or digital methods, without the prior written permission
# of the publisher, except in the case of brief quotations embodied in critical
# reviews and certain other noncommercial uses permitted by copyright law. For
# permission requests, write to the developer, thanks for reading.

# //-----------------------------------------
# // AUTORES / DESARROLLADORES : Cleopatra II
# //-----------------------------------------
#	Programming by Diego Hiroshi (CC-BY 3.0)
#	Sounds by IGT Slots (© 2020 IGT. All rights reserved.)
#	Art by IGT Slots (© 2020 IGT. All rights reserved.)

#	///////////////////////////////
#	Visit Us : www.diegohiroshi.com
#	///////////////////////////////

# //------------------------------------
# // ÚLTIMAS ACTUALIZACIONES v1.2 Reborn
# //------------------------------------
#   SFX Environment
#   Wild System (Starter Pack : No WILD Animation) / (Professional Pack : Full WILD)
#   Scatter System (Starter Pack : Basic SCATTER) / (Professional : Full SCATTER)
#   Payments Table System
#   Lines Payment System (Starter Pack : 5 playing-lines) / (Elite Pack : 10 playing-lines) / (Professional Pack : 20 playing-lines)
#   Full Payouts Symbols 3 /  4 / 5 / WILD
#   Fixed Line Animations (REPORTED bug v0.9.1)
#   Lines Highlight System (Starter Pack : Basic Highlight) / (Elite Pack : Fill Highlight)
#   Custom Symbols : 5 Commons / 4 Specials / 1 Wild / 1 Scatter
# //------------------------------------
#   Function findMatch() index issues in Godot 3.2 has been fixed (BUG REPORTED by Damir Kamerdino)
#   Video animation Tile (colours bug in BGR) has been fixed (BUG reported by Production)
#   Score animation freezes with values less than 100 han been fixed 


extends Node2D
var PayData = preload ("res://PayData.gd").new()

var reels: Array # // Tambores del Slot Machine
var current_slot := 4 # // Instancia de variable inicial de reels

var saldo = 5000 # // Saldo inicial

var ganancias  # // Variable dinámica de la "Tabla de Pagos" temporal (MODO DE PRUEBAS)
var bet = 5
var betIndex : int = 0
var totalBet : int = 25 # // Apuesta inicial

var lines : int = 5 # // Cantidad de líneas MAX. 5 (ELITE PACK REQUIRED! for more lines functions.)

var scatterIndex : int
var wildIndex : int
var freeSpins : bool = false

onready var AnimationPlayer = get_node("AnimationTree/AnimationPlayer")
onready var winlines = AnimationPlayer.get_animation("winlines")

onready var timeout = get_node("Timeout") # // Tiempo de espera definido entre reel & reel
var rand = RandomNumberGenerator.new() # // Función de ejecución aletoria definida
 
func _ready():
	
	PayData._ready()
	
	# // Carga de tambores sobre un array de 5 elementos
	reels = [$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/SlotMachineWindow1,
			 $UI/MarginContainer/HBoxContainer/VBoxContainerCenter/SlotMachineWindow2,
			 $UI/MarginContainer/HBoxContainer/VBoxContainerCenter/SlotMachineWindow3,
			 $UI/MarginContainer/HBoxContainer/VBoxContainerCenter/SlotMachineWindow4,
			 $UI/MarginContainer/HBoxContainer/VBoxContainerCenter/SlotMachineWindow5
			]
			
	$UI.update_coins(saldo)
	scatterIndex = PayData.scatter_index
	wildIndex = PayData.wild_index

func minusBet():
	
	betIndex = (betIndex - 1 + PayData.betting.size()) % PayData.betting.size()
	setBet()

func plusBet():
	
	betIndex = (betIndex + 1) % PayData.betting.size()
	setBet()

func setBet():
	
	totalBet = PayData.betting [betIndex]
	bet = totalBet / lines
	$UI.setBetting(totalBet, bet)

# // Constructor de arranque : Recibe un valor y pone en marcha el rodillo id correspondiente 
func start_slots (window_id):

	reels[window_id].start()

# // Constructor de apagado de tambores y funciones línea de ejecución
func stop_slots (window_id):
	
	reels[window_id].stop()

# // Spin function : Main
func _on_TextureButton_pressed():
	
	$AnimationTree/AnimationPlayer.play("winlines")
	$AnimationTree/AnimationPlayer.seek(0, true)
#	$AnimationTree/AnimationPlayer.stop()
	
	winlines.track_set_enabled(0, false)
	winlines.track_set_enabled(1, false)
	winlines.track_set_enabled(2, false)
	winlines.track_set_enabled(3, false)
	winlines.track_set_enabled(4, false)
	
	# // Comprobando si el saldo disponible da para realizar otra tirada.
	if saldo < totalBet:
		$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message3.show()
	else:
		
		if freeSpins != true:
			saldo -= totalBet
			$UI.update_coins(saldo)
			# // Mensajes del recuadro de notiticaciones
			$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message1.show()
			$UI.void_notification() # // Good Luck!
			
		$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message2.hide()
		$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message3.hide()
		
		# // Spin deshabilitado mientras la tirada permanezca activa
		$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/TextureButton.set_disabled(true)
		
		$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/LBoxContainer/BetLine/Minus.set_disabled(true)
		$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/LBoxContainer/BetLine/Plus.set_disabled(true)


		# // Que comience la fiesta y puesta en marcha de cada uno de los reels disponibles
		start_slots(0)
		get_tree().get_nodes_in_group("vfx")[0].show()
		start_slots(1)
		get_tree().get_nodes_in_group("vfx")[1].show()
		start_slots(2)
		get_tree().get_nodes_in_group("vfx")[2].show()
		start_slots(3)
		get_tree().get_nodes_in_group("vfx")[3].show()
		start_slots(4)
		get_tree().get_nodes_in_group("vfx")[4].show()


		# // Current_slot incrementará hasta 4 a medida que los rodillos entren en estado de reposo
		if current_slot == 4:
			if freeSpins != true:
				timeout.set_wait_time(0.5)
			else: 
				timeout.set_wait_time(0.2)
			
			timeout.start()
			
			if freeSpins != true:
				rand.randomize() # // Función de asignación de valores aleatorios
				
				var rand_music = rand.randf_range(0, 4)
				get_tree().get_nodes_in_group("sfx")[rand_music].play()
					
			current_slot = 0
			return

func _on_Timeout():
	
	# // Cada cierto tiempo reels consecutivos al anterior pasarán a estado de resposo
	if current_slot < 1:
		yield(get_tree().create_timer(rand_range(0.1, 0.4)),"timeout") # // Stopping : DELAY
		stop_slots(current_slot)
		get_tree().get_nodes_in_group("vfx")[0].hide()
		current_slot += 1
		timeout.stop()
		get_tree().get_nodes_in_group("sfx")[4].play()
		timeout.start()
		
	elif current_slot < 2:
		stop_slots(1)
		get_tree().get_nodes_in_group("vfx")[1].hide()
		current_slot += 1
		get_tree().get_nodes_in_group("sfx")[4].play()
		timeout.start()
	elif current_slot < 3:
		stop_slots(2)
		get_tree().get_nodes_in_group("vfx")[2].hide()
		current_slot += 1
		get_tree().get_nodes_in_group("sfx")[4].play()
		timeout.start()
	elif current_slot < 4:
		stop_slots(3)
		get_tree().get_nodes_in_group("vfx")[3].hide()
		current_slot += 1
		get_tree().get_nodes_in_group("sfx")[4].play()
		timeout.start()
	
	else:
			
		stop_slots(4)
		get_tree().get_nodes_in_group("vfx")[4].hide()
		timeout.stop()
		get_tree().get_nodes_in_group("sfx")[4].play()
		
		# // Delay de espera antes del match : Tween
		yield(get_tree().create_timer(0.6),"timeout")
		findMatch()
		
			# // Mensajes del recuadro de notificación 
		$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/Panel/Message1.hide()
		
		# // Spin habilitado para una nueva tirada
		if freeSpins != true:
			$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/TextureButton.set_disabled(false)
			
			$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/LBoxContainer/BetLine/Minus.set_disabled(false)
			$UI/MarginContainer/HBoxContainer/VBoxContainerCenter/HBoxContainer/LBoxContainer/BetLine/Plus.set_disabled(false)

		# // Indicar orden de detener la música cuando el quinto reel se haya detenido
		get_tree().get_nodes_in_group("sfx")[0].stop()
		get_tree().get_nodes_in_group("sfx")[1].stop()
		get_tree().get_nodes_in_group("sfx")[2].stop()
		get_tree().get_nodes_in_group("sfx")[3].stop()

# // Payouts checking
func findMatch(): # // Scatter, wild and payouts lines

	# // typeList : int
	# // countList : int
	var totalScore : int = 0
	#var totalScatter : int = 0
	var items : Array
	
	for j in range (reels.size()):
		var type : Array  = reels[j].tiles
		
		items.append(type)
	
	# // for (int i = 0; i < lines; i++) : Start
	for i in range (lines): # // Para jugar a una mayor cantidad de líneas obtenga la versión v1.5 o Superior
		
		var count : int = 0
		var firstType : int = 0
#		var isWild : bool = false
	
		for j in range (reels.size()):
			
			var pos : int = PayData.line[i][j]
			var type1 = items[j][pos]
			
			#var type1 : int =  item [firstType]
			
			if type1 != wildIndex:
				firstType = type1
				break
#			else:
#				isWild = true

#			if firstType < -1 && isWild : firstType = wildIndex
	
		for j in range (reels.size()):
			
			var pos : int = PayData.line[i][j]
		
			var type : int = items[j][pos]
			
			if type == scatterIndex || (firstType != type && wildIndex != type):
				break # // Cartas desiguales adyacentes a la otra finaliza la iteración
			else:
				count += 1 # // Cartas iguales adyacentes a la otra suma al contador

		# // Balance : Score
		# // -------------------------------------------------------
		if count > 0:
			
			var score : int = PayData.table[firstType][count-1]
			if score > 0:
				
				totalScore += score
				print ("El puntaje total es: ", score)
				
				if i == 0:
					winlines.track_set_enabled(0, true)
					AnimationPlayer.play("winlines")
				if i == 1:
					winlines.track_set_enabled(1, true)
					AnimationPlayer.play("winlines")
				if i == 2:
					winlines.track_set_enabled(2, true)
					AnimationPlayer.play("winlines")
				if i == 3:
					winlines.track_set_enabled(3, true)
					AnimationPlayer.play("winlines")
				if i == 4:
					winlines.track_set_enabled(4, true)
					AnimationPlayer.play("winlines")
					
	ganancias = totalScore*bet
	if ganancias > 0:
		
		$UI.earnings(ganancias) # // Monto total de recompensas : Message2
		saldo += ganancias # // Asigna al saldo actual las ganancias obtenidas
#			bingoList.append(i)
		$UI.update_coins(saldo)

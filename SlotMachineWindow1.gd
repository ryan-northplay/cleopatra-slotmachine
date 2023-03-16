extends Node2D
var PayData = preload ("res://PayData.gd").new()

const speed:float = 2.4 # // Dale la velocidad que quieras

var running: bool
var acceleration:float
const respawn = 1400 # // Cartas que llegan al límite en bot pasan a top generando un movimiento cíclico

# // Desplazamiento de los elementos componentes del reel
var spinner_offsets := [-0.40, -0.20, 0.00, 0.20, 0.40, ] # // Modificar en caso de asignar más tiles en juego [0.00, 0.20, -0.20, 0.40, -0.40]
#var rng = RandomNumberGenerator.new() # // Función de ejecución aletoria definida
var card

var anim 

# // Symbols config % [0] : [11]
onready var symbol_min = 0 
onready var symbol_max = 5
onready var special_symbols = 9 # // Avatars

var scatterIndex : int
var wildIndex : int

var tiles = []
var items : Array

func _ready():
	
	initArena()
	
	scatterIndex = PayData.scatter_index
	wildIndex = PayData.wild_index

func _process(delta : float):
	
	update_spinners()
	
	# // El modo running activa el movimiento de los reels basados en la fórmula de cálculo de aceleración / seg
	if running:
		
		acceleration -= speed*delta
		random_system()

func start():
	
	# //////////////////////////////////////////////////////////////////////////
	# // Normaliza a 0 evitando el append de items y/o sobrecarga de elementos : SCATTER, WILD & PAYLINES
	# //////////////////////////////////////////////////////////////////////////
	tiles = [] # // Reset de tiles
	items.clear() 
	
	var itemWild = $ReelContainer/Tile001
	itemWild.get_child(0).hide()
	
	running = true

func stop():

	running = false
	
	# // Rebote e interpolación
	var rebound = round(5*acceleration) / 5 +  0.20
	$Tween.interpolate_property(self, 'acceleration', acceleration, rebound, 0.23, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	# // Delay de espera antes del match : Tween
	yield(get_tree().create_timer(0.5),"timeout")
	findMatch()

func initArena():
	
	# // Dynamic RNG : READY
	randomize()
	spinner_offsets.shuffle()
	
	# // Tile line loop 
	for i in range(spinner_offsets.size()):
		
		# // Tile loop in some line
		#for j in range(spinner_offsets.size()):
			
			var tile = $ReelContainer.get_child(i)
			if tile.name == "Tile001":
				tile = tile.set_frame(rand_range(5, 9))
			else:
				tile = tile.set_frame(rand_range(0, symbol_max))
	
	get_tree().get_nodes_in_group("sfx")[6].play() # // Environment sound 
	return

func update_spinners():
	
	# // Disposición de tiles a lo alto del reel
	for id in range(spinner_offsets.size()):
		
		card = $ReelContainer.get_child(id)
		card.position.y = roll(id)

func roll(id : int):
	
	# // Ecuación de cálculo de movimiento y respawn de cada uno de los slots del reel disponible
	var rolling = acceleration + spinner_offsets[id]
	rolling -= int(rolling - 0.5)
	 
	return  rolling * (- respawn - respawn)
	
# // La función de sistema rng básico permite aplicar estándares de premios, tablas y manipulación de salida del: WILD/BONUS/SCATTER
func random_system():
	
	# -----------------
	# // RANDOM SYSTEM
	# -----------------
	for i in range (spinner_offsets.size()):
		var tile = $ReelContainer.get_child(i)
		var slot1 = get_node("ReelContainer/Tile001")
		
		randomize() # // Dynamic RNG : READY
		
		if tile.position.y > 950 || tile.position.y < -950 && running:
			
			var c = $ReelContainer.get_child(i)
			
			# // Usted puede forzar al Slot Machine a obtener cualquier símbolo especial si así lo requiera
			c.set_frame(rand_range(symbol_min, symbol_max)) # // Reference -> 0 : 10 , 1 : A , 2 : J , 3 : K , 4 : Q
			
		if slot1.position.y > 950 || slot1.position.y < -950 && running:
			slot1.set_frame(rand_range(5 , special_symbols)) # // rand_range(0, 5)


# // Control de parejas existentes : Scatter / Payouts
# // -------------------------------------------------
func findMatch():
	
	# // La cuadrícula canvas dispone de 25 tiles, visibles únicamente durante el run time del programa
	for i in range (spinner_offsets.size()):
		var item = $ReelContainer.get_child(i)
		
		if item.position.y > -5 && item.position.y < 5: # // Mid lane
			tiles.append(item.frame) # // Frame correspondiente de la instancia : AniamtedSprite
			if item.frame == wildIndex:
				animMatch(item)

	for i in range (spinner_offsets.size()):
		var item = $ReelContainer.get_child(i)
		if item.position.y > -565 && item.position.y < -5: # // Top lane
			tiles.append(item.frame) # // Frame correspondiente de la instancia : AniamtedSprite
			if item.frame == wildIndex:
				animMatch(item)

	for i in range (spinner_offsets.size()):
		var item = $ReelContainer.get_child(i)
		if item.position.y > 555 && item.position.y < 565: # // Bot lane
			tiles.push_back(item.frame) # // Frame correspondiente de la instancia : AniamtedSprite
			if item.frame == wildIndex:
				animMatch(item)
				
	return tiles

func animMatch(item):
	item.get_child(0).show()
	item.get_child(0).play()

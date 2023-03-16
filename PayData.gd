extends Node

const symbols : int = 5 # // Cantidad de símbolos en juego
const wild_index : int = 8
const scatter_index : int = 10 # // Índice predefinido del SCATTER (Valor NO editable)
const bonus_index : int = 8

var betting : Array

var table : Array
var line : Array

# ///////////////////////////////////////
# // Sistema Matricial de Control Interno
# ///////////////////////////////////////

func _ready():
	
	PayData()
	
func PayData():
	
	table = [
	[0, 0, 2, 5, 25],		# // 0 : 10
	[0, 0, 2, 5, 25],		# // 1 : J
	[0, 0, 5, 15, 50],		# // 2 : Q
	[0, 0, 5, 15, 50],		# // 3 : K
	[0, 0, 5, 15, 50],		# // 4 : A
	[0, 0, 10, 25, 100],	# // 5 : Egypcian Godness 1
	[0, 0, 10, 40, 150],	# // 6 : Egypcian Godness 2
	[0, 0, 15, 50, 250],	# // 7 : Egypcian Godness 3
	[0, 0, 20, 75, 375],	# // 8 : Egypcian Godness 4
	]
	
	line = [
	[0, 0, 0, 0, 0],	# // Line 1
	[1, 1, 1, 1, 1],	# // Line 5
	[2, 2, 2, 2, 2],	# // Line 9
	[1, 0, 2, 0, 1],	# // Line 3
	[2, 0, 1, 0, 2] 	# // Line 7
	]
	
	betting = [
	25, 50, 100, 200, 500, 1000, 5000, 10000
	]

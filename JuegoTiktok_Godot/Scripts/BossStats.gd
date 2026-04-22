# BossStats.gd
extends Resource
class_name BossStats # Esto permite que Godot reconozca el tipo

@export var vida_max: int = 500000
@export var vida_actual: int = 500000
@export var ataque: int = 25

@export var exp_max: int = 500
@export var exp_actual: int = 0
@export var nivel = 1

@export var masa: int = 100
@export var velocidad: int = 100

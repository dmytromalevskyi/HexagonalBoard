extends KinematicBody

class_name Tile

var beveled_tile_mesh = load("res://Assets/3D/GameReady/HexagonBeveled.obj")
var simple_tile_mesh = load("res://Assets/3D/GameReady/HexagonSimple.obj")

export(ENUMS.TILE_TYPE) var type: int = 0 setget set_type, get_type




func initialise(TILE_TYPE_ENUM: int = 0) -> void:
	self.type = TILE_TYPE_ENUM


func get_mesh(TILE_TYPE_ENUM: int):
	match TILE_TYPE_ENUM:
		ENUMS.TILE_TYPE.BEVELED:
			return beveled_tile_mesh
		ENUMS.TILE_TYPE.SIMPLE:
			return simple_tile_mesh


func set_type(TILE_TYPE_ENUM: int) -> void:
	var mesh = get_mesh(TILE_TYPE_ENUM)
	$MeshInstance.set_mesh(mesh)


func get_type() -> int:
	return type

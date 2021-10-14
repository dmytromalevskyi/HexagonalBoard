extends KinematicBody
class_name Stracture



# STRACTURE - Mesh Instance
var castle_mesh = load("res://Assets/3D/GameReady/Castle.obj")


export(ENUMS.STRACTURE_TYPE) var type: int = 0 setget set_type, get_type



func initialise(STRACTURE_TYPE_ENUM: int = 0) -> void:
	self.type = STRACTURE_TYPE_ENUM


func get_mesh(STRACTURE_TYPE_ENUM: int):
	match STRACTURE_TYPE_ENUM:
		ENUMS.STRACTURE_TYPE.CASTLE:
			return castle_mesh

func set_type(STRACTURE_TYPE_ENUM: int) -> void:
	if STRACTURE_TYPE_ENUM == ENUMS.STRACTURE_TYPE.EMPTY:
		set_empty()
		return
	else:
		var mesh = get_mesh(STRACTURE_TYPE_ENUM)
		$MeshInstance.set_mesh(mesh)
		$CollisionShape.disabled = false
		visible = true


func get_type() -> int:
	return type


func set_empty() -> void:
	$CollisionShape.disabled = true
	visible = false

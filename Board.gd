extends Spatial
class_name Board

# POINTY HEXAGONS
# rotation = Vector3(0, PI/3 ,0)		Calibrated for the camera (change in _ready func)

# Axial (in relation to the camera)
# Vector2(q,r)
# q - right
# r - right and down

# Cube (in relation to the camera)
# Vector3(x,y,z)
# x - right and up
# y - left and up
# z - down

# Translation (in relation to the camera)
# x - left
# y - const 0 (above ground)
# z - forward

export(int, 0,15 ) var number_of_circles = 4
export(float, 1,2,0.2 ) var seperation = 1

export(PackedScene) var tile_pucked_scene := preload("Hexagon.tscn")
export(PackedScene) var stracture_pucked_scene := preload("Stracture.tscn")

var tiles = []
var stractures = []
var decentralised_CENTER2
var decentralised_CENTER3


func _ready() -> void:
	rotation = Vector3(0, -PI/3 ,0)    # For camera calibration
	decentralised_CENTER2 = Vector2(number_of_circles,number_of_circles)
	decentralised_CENTER3 = axial_to_cube(decentralised_CENTER2)

	for q in range(number_of_circles*2 +1):
		tiles.append([])
		stractures.append([])
		for r in range(number_of_circles*2 +1):
			if r+q < number_of_circles: # TOP LEFT
				tiles[q].append(null)
			elif r+q >= number_of_circles*3 +1: # BOTTOM LEFT
				tiles[q].append(null)
			else:
				var tile := tile_pucked_scene.instance() as Tile
				tile.initialise(ENUMS.TILE_TYPE.BEVELED)
				tiles[q].append(tile)
				var position = get_tile_translation(centralise(Vector2(q,r)))
				tiles[q][r].translation = position
				add_child(tiles[q][r])
			stractures[q].append(null)
	for_tests_only()


func for_tests_only() -> void:
	randomize()
	while true:
		var rand_vector := Vector2(round(rand_range(-number_of_circles,number_of_circles)),round(rand_range(-number_of_circles,number_of_circles)))		
		
		if not is_out_of_range(rand_vector):
			var rand_vector_3d = axial_to_cube(rand_vector)
			print("The centralised axial vector is ("+str(rand_vector.x)+","+str(rand_vector.y)+"). "		+ "The centralised cube vector is ("+str(rand_vector_3d.x)+","+str(rand_vector_3d.y)+","+str(rand_vector_3d.z)+").")
			set_stracture(ENUMS.STRACTURE_TYPE.CASTLE, rand_vector)
		else:
			continue
		yield(get_tree().create_timer(3.0), "timeout")
		remove_stracture(rand_vector)


# Must be in the centralised form
func get_tile(centralised_cube_or_axial) -> Tile:
	return get_tile_decentralised(decentralise(to_axial(centralised_cube_or_axial)))


func set_stracture(STRACTURE_TYPE_ENUM, centralised_cube_or_axial) -> void:
	var decentralised_axial = to_axial(decentralise(centralised_cube_or_axial))
	var q = decentralised_axial.x;		var r = decentralised_axial.y
	var building = stracture_pucked_scene.instance()
	building.initialise(STRACTURE_TYPE_ENUM)
	building.translation = get_tile_translation(centralised_cube_or_axial)
	add_child(building)
	stractures[q][r] = building

func get_stracture(centralised_cube_or_axial) -> Stracture:
	var decentralised_axial = to_axial(decentralise(centralised_cube_or_axial))
	var q = decentralised_axial.x;		var r = decentralised_axial.y
	if not has_stracture(centralised_cube_or_axial):
		assert(false, "ERROR: get_stracture can't return a Stracture as the tile Vector("+str(q)+","+str(r)+") on centralised coordinate has no stracture or its type is not Stracture.");
		return null
	else:
		return  stractures[q][r]

func remove_stracture(centralised_cube_or_axial) -> bool:
	if not has_stracture(centralised_cube_or_axial):
		return false
	else:
		var decentralised_axial = to_axial(decentralise(centralised_cube_or_axial))
		var q = decentralised_axial.x;		var r = decentralised_axial.y
		get_stracture(centralised_cube_or_axial).queue_free()
		stractures[q][r] = null
		return true

func has_stracture(centralised_cube_or_axial) -> bool:
	var decentralised_axial = to_axial(decentralise(centralised_cube_or_axial))
	var q = decentralised_axial.x
	var r = decentralised_axial.y
	if stractures[q][r] is Stracture:
		return true
	else:
		return false 


func get_tile_decentralised(decentralised_cube_or_axial) -> Tile:
	var axial := to_axial(decentralised_cube_or_axial)
	var tile = tiles[axial.x][axial.y]
	if tile == null:
		assert(false, "ERROR: get_tile_decentralised can't return a tile as the given decentralised axial ("+str(axial.x)+","+str(axial.y)+") points to a null" )
		return null
	else:
		return tile


func centralise(decentralised_cube_or_axial):
	if decentralised_cube_or_axial is Vector2:
		return centralise_axial(decentralised_cube_or_axial)
	else:
		return centralise_cube(decentralised_cube_or_axial)


func decentralise(centralised_cube_or_axial):
	if centralised_cube_or_axial is Vector2:
		return decentralise_axial(centralised_cube_or_axial)
	else:
		return decentralise_cube(centralised_cube_or_axial)


func centralise_axial(decentralised_axial: Vector2) -> Vector2:
	return decentralised_axial - decentralised_CENTER2


func decentralise_axial(centralised_axial: Vector2) -> Vector2:
	return centralised_axial + decentralised_CENTER2


func centralise_cube(decentralised_cube: Vector3) -> Vector3:
	var decentralised_axial = cube_to_axial(decentralised_cube)
	return axial_to_cube(centralise_axial(decentralised_axial))


func decentralise_cube(centralised_cube: Vector3) -> Vector3:
	var centralised_axial = cube_to_axial(centralised_cube)
	return axial_to_cube(decentralise_axial(centralised_axial))


func is_out_of_range(centralised_cube_or_axial) -> bool:
	var centralised_axial = decentralise(to_axial(centralised_cube_or_axial))
	var q = centralised_axial.x
	var r = centralised_axial.y
	if r+q < number_of_circles: # TOP LEFT
		return true
	elif r+q >= number_of_circles*3 +1: # BOTTOM RIGHT
		return true
	else:
		return false
	


func to_axial(cube_or_axial) -> Vector2:
	var axial := Vector2()
	if cube_or_axial is Vector3:
		axial = cube_to_axial(cube_or_axial)
	elif cube_or_axial is Vector2:
		axial = cube_or_axial
	else:
		assert(false, "ERROR: to_axial can only accept Vector3 and Vector2 as an argument.");
	return axial


func to_cube(cube_or_axial) -> Vector3:
	var cube := Vector3()
	if cube_or_axial is Vector3:
		cube = cube_or_axial
	elif cube_or_axial is Vector2:
		cube = axial_to_cube(cube_or_axial)
	else:
		assert(false, "ERROR: to_cube can only accept Vector3 and Vector2 as an argument.")
	return cube


func cube_to_axial(cube: Vector3) -> Vector2:
	var q = cube.x
	var r = cube.z
	return Vector2(q, r)


func axial_to_cube(axial: Vector2) -> Vector3:
	var x = axial.x
	var z = axial.y
	var y = -x-z
	return Vector3(x, y, z)

# If the center, top-left and left tiles are removed than the camera and Vector2/Vector3 systems are callibrated successfully
# For the camera +x should be left and +z forward
func calibrate_to_camera() -> void:
	get_tile(Vector2.ZERO).set_visible(false)
	get_tile(Vector3.ZERO).set_visible(false)
	
	get_tile(Vector2(-1,0)).set_visible(false)
	get_tile(Vector3(-1,1,0)).set_visible(false)
	
	get_tile(Vector2(0,-1)).set_visible(false)
	get_tile(Vector3(0,1,-1)).set_visible(false)
	
# NOT TESTED	NOT TESTED	NOT TESTED	NOT TESTED	NOT TESTED	NOT TESTED	NOT TESTED
func translation_to_axial(translation_vector: Vector3) -> Vector2:
	translation_vector = translation_vector / seperation
	var x = translation_vector.x
	var z = translation_vector.z
	
	var r = z / (3*sin(PI/6))
	var q = - ((x + r*cos(PI/6)) / (pow(3, 0.5)))
	return Vector2(round(q),round(r))
	

func translation_to_cube(translation_vector: Vector3) -> Vector3:
	return axial_to_cube(translation_to_axial(translation_vector)) 


func get_tile_translation(centralised_cube_or_axial) -> Vector3:
	var axial := to_axial(centralised_cube_or_axial)
	var r = axial.x
	var q = axial.y
	# width = sqr(3) for sire 1
	var width = pow(3, 0.5)
	#	PI/6 = 30 deg
	return seperation * Vector3( (-q*width)-(r*cos(PI/6)) , 0 , 3*r*sin(PI/6) )

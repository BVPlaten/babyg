# https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#classes


# const globalCnfgFile = "res://config/AdvancedBricks.json"     # for 3D Tetris



# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class Brick : it creates a brick
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
# 
class_name Brick

var brickFactory
var amountOfBricks
var sizeOfSpace
var globalCnfgFile 

# constructor - if id is not given a random brick will be created
#
# cfgFile:       path to the json configuration file
# amount:        number of bricks, 
# sizeDict:      defining the size of the matrix available for a brick
#                'X' : width
#                'Y' : heigth
#                'Z' : depth
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-21   bvp   initial realease
func _init(cfgFl:String="res://config/terominoes.json", amount:int=7, sizeDict:Dictionary={'X': 4, 'Y': 4, 'Z': 1}):
	globalCnfgFile = cfgFl
	amountOfBricks = amount
	sizeOfSpace = sizeDict
	brickFactory = BrickFactory.new(globalCnfgFile,sizeOfSpace)


# create a brick by a given index 
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-21   bvp   initial realease
func create_brick(idx:int=-1):
	var index:int
	if idx < 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		index = rng.randi()%amountOfBricks
	else:
		index = idx
	brickFactory.create_brick(index)
	print(brickFactory)


# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###                          # 3D Array as DataContainer for the MeshInstances### ### ### ### ### ### ### ### ### ###
#     class Box configuration as dictionary
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
#
class Box:
	export var mtrl : SpatialMaterial		                         # 3D Array as DataContainer for the MeshInstances	# the look (every box has an own instnce)
	export var texture : ImageTexture
	export var colr : Color

	# constructor
	#
	func _init():
		mtrl = SpatialMaterial.new()
		texture = ImageTexture.new()

		
	# apply_color : change the color of the MeshInstance
	#
	# parameter : color   : the color of the box
	#                       null for random color
	func apply_color(color):
		if(color == null):
			colr = random_color()
		else:
			colr = color
		mtrl.albedo_color = colr

		
	# apply_texture : set a texture to the single box
	#
	# parameter : txtr_path path to the image-file
	#
	func apply_texture(txtr_path : String):
		if(txtr_path == ""):
			push_warning("no texture in Box.apply_texture(..)")
			return
		var image = Image.new()
		image.load(txtr_path)
		texture.create_from_image(image)
		mtrl.albedo_texture = texture
		

	# _random_color : returns a random color 
	#
	func random_color():
		var rng = RandomNumberGenerator.new()
		return Color(rng.randf_range(0.0, 1.0),rng.randf_range(0.0, 1.0),rng.randf_range(0.0, 1.0))



# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class ConfigLoader : load JSON file with the brick configuration
#                      the object in the json-file is converted to and stored in a dictionary. the bricks must have numeric keys
#                      the path to the file must be given in the constructor
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-22   bvp   initial realease
# 2021-06-01   bvp   added access to the layers of the configuration
class ConfigLoader:
	var cfgFile				# the complete path/filename to the configuration
	var loadInfo 			# theconfig-dict with infos how to load the config-file
	var cfg					# the cfg loaded from file as dictionary

	# load the configureration-file given as param
	#		
	# parameter configurationfile     : path configuration as dictionary
	# 
	func _init(configurationfile:String,ldInf:Dictionary):
		cfgFile = configurationfile
		loadInfo = ldInf
		load_confg()


	# loads json configuration file and returns it as dict
	#
	# parameter filePath     : path configuration as dictionary
	#
	func load_confg(filePath:String=cfgFile):
		var file = File.new()
		file.open(filePath, file.READ)
		var text = file.get_as_text()
		file.close()
		var conf = JSON.parse(text)
		if conf.error != OK:
			push_error("error loading config-file in ConfigLoader.load_confg()")
		cfg =  conf.result


	# get_config_amount : get the amount of configured bricks in the conf-dict
	#
	func get_config_amount():
		if(cfg==null):
			return     0
		else:
			return cfg.size()
			
	
	# all_bricks : creates a string with all bricks from configuration
	#
	func all_bricks():
		var rslt = ""
		for i in range(get_config_amount()):
			rslt += "brick " + str(i) + "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  \n"
			rslt += str(cfg[str(i)])
			rslt += "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  \n"
		return rslt
			

	# bricks_as_str : get the given brick by index as string
	# parameter : int index 
	#
	func bricks_as_str(index:int):
		var rslt = ""
		var source = cfg[str(index)]
		var amountLines = loadInfo['Y']
		var amountLevels = loadInfo['Z']
		for y in amountLines:
			for z in amountLevels:
				# rslt += source[str(y)][z] +"\n"
				rslt += source[str(z)][y] +"\n"
			rslt += "\n"
		return rslt



	
	# # get_layer(brickId:int, lyrId:int):
	# #
	# func get_layer(brickId:String, lyrId:int):
	# 	var brck = cfg[brickId]
	# 	for i in range(4):
	# 		print(brck[lyrId])
		
		
	



# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class BrickFactory : creates a matrix of box-mesh-instances from the form given in the configuration-file
#                      
#                      
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-22   bvp   initial realease
class BrickFactory:
	var sizeX:int							# amount of boxes in configuration for this dimension
	var sizeY:int							#   "         "             "          "
	var sizeZ:int							#   "         "             "          "
	var config 								# configuration-dict
	var matrix 								# 3D Array as DataContainer for the MeshInstances (boxes :-) )
	var brickIdx                            # index of current brick in the configuration

	# load the configureration-file given as param
	#		
	# parameter configurationfile  : path configuration as dictionary
	#            sizeDict['X']     : possible horizontal size of a brick
	#            sizeDict['Y']     : possible vertical size of a brick
	#            sizeDict['Z']     : possible depth of a brick
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func _init(configurationfile:String, sizeDict:Dictionary ):
		sizeX = sizeDict['X']
		sizeY = sizeDict['Y']
		sizeZ = sizeDict['Z']
		brickIdx = null
		config = ConfigLoader.new(configurationfile,sizeDict).cfg


	# create_array : "memory-allocation" for the empty 3D matrix
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func create_array(xS:int=sizeX, yS:int=sizeY, zS:int=sizeZ):
		var array = []
		array.resize(xS)    					# X-dimension
		for x in xS:    						# this method should be faster than range since it uses a real iterator iirc
			array[x] = []
			array[x].resize(yS)    				# Y-dimension
			for y in yS:
				array[x][y] = []
				array[x][y].resize(zS)    		# Z-dimension
				for z in zS:
					array[x][y][z] = null
		return array
		
				
	# create_matrix : this is the main-function. it generates a matrix with boxes
	#
	# parameter :  idx = which brick should be created (idx in JSON cfg)
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func create_brick(idx : int):
		matrix = create_array()
		brickIdx = idx
		for x in sizeX:				
			for y in sizeY:
				for z in sizeZ:
					if (get_point(idx,x,y,z)):
						matrix[x][y][z] = '#'  # add_box_here
					else:
						matrix[x][y][z] = '.'  # add null here


	# get_point : returns true if the given point for the given brick-idx is set
	#             the first line in the configuration is the last line in the coord-system
	#             so there must be a coord-convesion to avoid becoming crazy
	#
	# parameter : idx : the index of the brick in the configuration
	#             x   : the x-coordinate
	#             y   : the y-coordinate
	#             z   : the z-coordinate
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func get_point(idx:int, x:int, y:int, z:int):
		var data = config[String(idx)]
		if (data[str(x)][y][z] == '#'):
			return true
		else:
			return false


	# print a given matrx for debugging 
	#
	# parameter : mtrx is the matrix that should be printed
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func text_of_matrix(mtrx=matrix):
		var txt = ""
		for x in sizeX:
			for y in sizeY:
				txt += "x=" + str(x) + " y=" + str(y) + ' |'
				for z in sizeZ:
					txt += str(mtrx[x][y][z])
				txt += '\n'
			txt += '\n'
		return txt


	# string representation 
	#
	func _to_string():
		var outP = "Size of the layer is " + str(sizeX) + " * " + str(sizeY) + " * " + str(sizeZ) + "\n"
		outP += "configuration index of the brick : " + str(brickIdx) + " \n"
		outP += text_of_matrix()
		outP += '\n'
		return outP


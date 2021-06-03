extends Spatial


# Called when the node enters the scene tree for the first time.
# https://www.reddit.com/r/godot/comments/ao2bkh/need_help_creating_a_3d_array/
#
func _ready():
	var cnfgFile = "res://config/three_dim_test.json"   		# path to the config-file
	var loadCnfg = {'X': 4, 'Y': 4, 'Z': 4}		# information how to load the config
	var config = load("res://tools/brick.gd").ConfigLoader.new(cnfgFile,loadCnfg)
	print(config.cfg["0"])
	print("\n------------------------------\nList of bricks in the configuration\n------------------------------")
	print(config.get_config_amount())
	print()
	print(config.all_bricks())


	





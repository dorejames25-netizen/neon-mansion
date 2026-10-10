extends Node3D
const A = preload("res://assets/neon-mansion/scripts/architecture.gd")
const BRASS = preload("res://assets/neon-mansion/materials/brass.tres")
const METAL = preload("res://assets/neon-mansion/materials/dark_metal.tres")
const CYAN = preload("res://assets/neon-mansion/materials/cyan_indicator.tres")
const MAGENTA = preload("res://assets/neon-mansion/materials/magenta_trim.tres")
@export_enum("sconce", "chandelier", "flush") var kind := "sconce"
@export var energy := 1.8
@export var range_metres := 7.0
@export var warm := false
var normal_color: Color
var light: OmniLight3D

func _ready() -> void:
	normal_color = Color(0.9, 0.70, 0.45) if warm else Color(0.60, 0.80, 0.86)
	# Modern suspended bars and flush strips replace candles and vintage sconces.
	if kind == "chandelier":
		for side in [-1,1]:
			A.box(self,Vector3(3.6,0.12,0.12),Vector3(0,0,side*1.2),CYAN)
			A.box(self,Vector3(0.12,0.12,2.4),Vector3(side*1.8,0,0),MAGENTA)
			A.box(self,Vector3(0.035,1.5,0.035),Vector3(side*1.4,0.75,0),METAL)
	elif kind == "sconce":
		A.box(self,Vector3(0.16,1.4,0.10),Vector3.ZERO,METAL)
		A.box(self,Vector3(0.055,1.3,0.025),Vector3(0,0,0.065),MAGENTA if warm else CYAN)
	else:
		A.box(self,Vector3(2.4,0.09,0.16),Vector3.ZERO,METAL)
		A.box(self,Vector3(2.25,0.025,0.06),Vector3(0,-0.06,0),CYAN)
	light = OmniLight3D.new()
	light.light_color = normal_color
	light.light_energy = 0.0 # Lighting deferred; retain the interaction hook.
	light.omni_range = range_metres
	light.position.z = 0.5 if kind == "sconce" else 0
	light.shadow_enabled = false
	add_child(light)
	add_to_group("nightmare_light_hooks")

func set_frequency(active: bool) -> void:
	light.light_color = Color(1, 0.03, 0.3) if active else normal_color


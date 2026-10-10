extends RefCounted
## Reuses the approved Subway shader and source artwork, with local owned copies.
const SURFACE = preload("res://assets/neon-mansion/materials/shaders/retrowave.gdshader")
const ART = preload("res://assets/neon-mansion/materials/textures/subway_retrowave_benchmark.png")
static var cache: Dictionary = {}
static func converted(original: Material, role: String) -> Material:
 if original == null: return original
 if original is ShaderMaterial and original.shader == SURFACE: return original
 if original.has_meta("subway_style"): return original
 var key := str(original.get_instance_id())+role
 if cache.has(key): return cache[key]
 var name := original.resource_path.get_file().to_lower()
 var color := Color(0.32,0.20,0.43)
 var accent := false
 if "cyan" in name or "brass" in name:
  color=Color(0.10,0.88,1.0);accent=true
 elif "magenta" in name:
  color=Color(0.72,0.02,0.74);accent=true
 elif "metal" in name: color=Color(0.08,0.05,0.14)
 elif "glass" in name: color=Color(0.012,0.006,0.025)
 elif "walnut" in name: color=Color(0.24,0.12,0.32)
 elif "charcoal" in name: color=Color(0.18,0.12,0.27)
 elif "garden" in name: color=Color(0.065,0.055,0.12)
 elif original is StandardMaterial3D:
  var old := original as StandardMaterial3D
  if old.emission_enabled:
   color=Color(0.10,0.88,1.0) if old.emission.b>old.emission.r else Color(0.72,0.02,0.74)
   accent=true
 elif original is ShaderMaterial and not original.shader.resource_path.ends_with("stylised_surface.gdshader"):
  return original
 var result: Material
 if accent:
  var flat := StandardMaterial3D.new()
  flat.albedo_color=color
  flat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  flat.specular_mode=BaseMaterial3D.SPECULAR_DISABLED
  flat.roughness=1.0
  result=flat
 else:
  var painted := ShaderMaterial.new()
  painted.shader=SURFACE
  painted.set_shader_parameter("stone_color",color)
  painted.set_shader_parameter("style_art",ART)
  painted.set_shader_parameter("reference_art",ART)
  painted.set_shader_parameter("floor_surface",role=="floor")
  painted.set_shader_parameter("tiled_wall",role=="wall")
  result=painted
 result.set_meta("subway_style",true)
 cache[key]=result
 return result
static func surface_role(mesh: MeshInstance3D) -> String:
 var bounds: AABB=mesh.global_transform*mesh.get_aabb()
 var size:=bounds.size
 var room: Node=mesh.get_parent()
 while room != null:
  if room.get("definition") is Dictionary:
   var definition: Dictionary=room.get("definition")
   if definition.has("height") and bounds.position.y>room.global_position.y+float(definition.height)-0.6:
    return "plain"
   break
  room=room.get_parent()
 if size.y<0.55 and size.x>0.8 and size.z>0.8: return "floor"
 if size.y>1.3 and minf(size.x,size.z)<0.65 and maxf(size.x,size.z)>1.2: return "wall"
 return "plain"
static func apply(node: Node) -> void:
 if node is MeshInstance3D:
  var mesh := node as MeshInstance3D
  var role := surface_role(mesh)
  if mesh.material_override != null: mesh.material_override=converted(mesh.material_override,role)
  elif mesh.mesh != null:
   for i in range(mesh.mesh.get_surface_count()):
    mesh.set_surface_override_material(i,converted(mesh.get_active_material(i),role))
 if node is Label3D: node.modulate=Color(0.10,0.90,1.0)
 if node is Light3D: node.visible=false
 if node is WorldEnvironment and node.environment != null:
  var env: Environment=node.environment
  env.ssr_enabled=false;env.glow_enabled=false;env.ssao_enabled=false
  env.fog_enabled=false;env.volumetric_fog_enabled=false
  env.ambient_light_energy=0.0;env.tonemap_mode=Environment.TONE_MAPPER_LINEAR
  env.background_color=Color(0.012,0.004,0.028)
 for child in node.get_children(): apply(child)

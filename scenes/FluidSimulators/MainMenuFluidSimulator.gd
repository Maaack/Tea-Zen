extends Node


func apply_velocity_force(position, vector, cascade : bool = false):
	$VelocityViewport/Sprite.material.set_shader_param("brushCenterUV", position)
	$VelocityViewport/Sprite.material.set_shader_param("brushColor", Color(vector.x, vector.y, 0.0, 1.0))
	$VelocityViewport/Sprite.material.set_shader_param("brushOn", true)
	if (cascade):
		apply_dye_paint(position, vector)

func release_velocity_force(cascade : bool = false):
	$VelocityViewport/Sprite.material.set_shader_param("brushOn", false)
	$VelocityViewport/Sprite.material.set_shader_param("brushColor", Color.black)
	if (cascade):
		release_dye_paint()

func apply_velocity_force_2(position, vector):
	$VelocityViewport/Sprite.material.set_shader_param("brushCenterUV2", position)
	$VelocityViewport/Sprite.material.set_shader_param("brushColor2", Color(vector.x, vector.y, 0.0, 1.0))
	$VelocityViewport/Sprite.material.set_shader_param("brushOn2", true)

func release_velocity_force_2():
	$VelocityViewport/Sprite.material.set_shader_param("brushOn2", false)
	$VelocityViewport/Sprite.material.set_shader_param("brushColor2", Color.black)

func apply_dye_paint(position, vector, cascade : bool = false):
	$DyeViewport/Sprite.material.set_shader_param("brushCenterUV", position)
	$DyeViewport/Sprite.material.set_shader_param("brushOn", true)
	if (cascade):
		apply_velocity_force(position, vector)

func release_dye_paint(cascade : bool = false):
	$VelocityViewport/Sprite.material.set_shader_param("brushColor", Color.white)
	$DyeViewport/Sprite.material.set_shader_param("brushOn", false)
	if (cascade):
		release_velocity_force()

func _ready():
	var velocity_texture = $ViscosityViewport.get_texture()
	$VelocityViewport/Sprite.texture = velocity_texture
	$VelocityViewport/Sprite.material.set_shader_param("velocity", $VelocityForcesViewport.get_texture())
	var dye_texture = $DyeBackBufferViewport.get_texture()
	$DyeViewport/Sprite.texture = dye_texture
	$DyeViewport/Sprite.material.set_shader_param("brushColor", Color.white)

func _process(delta):
	$DyeViewport/Sprite.material.set_shader_param("deltaTime", delta)
	$VelocityViewport/Sprite.material.set_shader_param("deltaTime", delta)

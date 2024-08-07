extends Area2D

func _ready():
    # 设置碰撞形状
    var shape = RectangleShape2D.new()
    shape.size = Vector2(200, 200)  # 设置大小
    $CollisionShape2D.shape = shape

    # 设置粒子系统
    setup_particles()

func setup_particles():
    var particles = GPUParticles2D.new()
    add_child(particles)
    
    # 配置粒子
    particles.amount = 1000
    particles.lifetime = 2.0
    particles.explosiveness = 0.0
    particles.randomness = 1.0
    particles.local_coords = true
    
    # 创建粒子材质
    var particle_material = ParticleProcessMaterial.new()
    particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    particle_material.emission_box_extents = Vector3(100, 100, 1)
    particle_material.direction = Vector3(0, 0, 0)
    particle_material.spread = 180
    particle_material.initial_velocity_min = 10
    particle_material.initial_velocity_max = 20
    particle_material.scale_min = 2
    particle_material.scale_max = 4
    particle_material.color = Color(0.5, 0.7, 1.0, 0.5)  # 蓝色半透明
    
    particles.process_material = particle_material

    # 创建并应用着色器
    var shader_material = ShaderMaterial.new()
    shader_material.shader = load("res://forTest/Particle/jelly_shader.gdshader")
    particles.material = shader_material
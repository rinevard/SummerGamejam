extends CharacterBody2D
class_name Player

# 连接enemy_handler
signal player_position_changed(global_pos: Vector2)
# 连接HUD
signal player_health_changed(new_health: int)
# 这个信号发给handler提醒它移除星轨
signal remove_track(action: String)
# 这几个create_track发给handler提醒它创建星轨
signal create_circle_track(action: String, global_pos: Vector2)
signal create_gravity_circle_track(action: String, global_pos: Vector2)
signal create_ring_track(action: String, global_pos: Vector2)
signal create_speed_track(action: String, global_pos: Vector2, direction: Vector2) # 角度而非弧度
signal create_square_track(action: String, st_global_pos: Vector2, ed_global_pos: Vector2)
signal item_arr_updated() # 发给HUD提醒它更新道具显示
signal score_updated(new_score: int) # 发给HUD提醒它更新分数显示

const SPEED := 200.0
const JUMP_VELOCITY := -400.0
const CORE_SPEED := 250.0
const DASH_SPEED := 2000.0
const PUSH_ADDITION_RATIO := 100
const WALL_STUCK_THRESHOLD := 0.15
const DEFAULT_WALL_STUCK_HELP_MOVE := 3.0  # 卡在墙里时默认的辅助移动距离
const CLICKS_TO_BUILD_TRACK : Dictionary = {
    GlobalEnums.TrackName.CircleTrack: 1,
    GlobalEnums.TrackName.GravityCircleTrack: 1,
    GlobalEnums.TrackName.RingTrack: 1,
    GlobalEnums.TrackName.SpeedTrack: 1,
    GlobalEnums.TrackName.SquareTrack: 2
}
const ACTION_TO_INDEX := {
    "ui_q": 0,
    "ui_w": 1,
    "ui_e": 2,
    "ui_r": 3
}
const PLAYER_MAX_HEALTH = 8

@export var item_arr: ItemArray
@export var death_menu: DeathMenu

var is_alive: bool = true
var cannot_be_attacked: bool = false
var cannot_move: bool = false
var player_health : int = 8
var wall_stuck_help_move : float = DEFAULT_WALL_STUCK_HELP_MOVE
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _in_core_mode := false
var _star_tracks : Array[StarTrack] = []
var ignore_push := false  # 用于标记是否忽略推力
var start_global_pos_for_square_track : Dictionary = {
    "ui_q": null, 
    "ui_w": null, 
    "ui_e": null, 
    "ui_r": null
}

# 跳跃相关变量
var remaining_jumps := 2  # 剩余跳跃次数

# 卡墙检测相关变量
var wall_stuck_timer := 0.0

# 受伤相关变量
var in_danger_zone = false
var hurt_cooldown = 1.0  # 受伤冷却时间（秒）
var hurt_timer = 0.0

# 击退相关变量
var knockback_force : float = 500.0
var hurt_color : Color = Color(1, 0, 0, 0.5)  # 半透明红色
var normal_color : Color = Color(1, 1, 1, 1)  # 正常颜色（白色）

# 分数相关变量
var score_pop_up = preload("res://scenes/UIs/score_pop.tscn")
var enemy_score: int = 10
var flower_score: int = 20
var current_score: int = 0

# normal_mode: 静止idle, 掉落fall, 跳jump, 跑run core_mode: 动climb, 不动wait_on_wall 
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _player_sprite: Sprite2D = $PlayerSprite
@onready var _star_detector: Area2D = $StarDetector
@onready var _player_collision: CollisionShape2D = $BoxCollision
@onready var _wall_detector: Area2D = $WallStuckDetector
@onready var _player_stomp: Area2D = $StarDetector
@onready var _flower_detector: Area2D = $FlowerDetector
@onready var _score_pop_container: VBoxContainer = $ScorePopContainer

func _ready() -> void:
    _clear_items()
    _update_health(PLAYER_MAX_HEALTH)
    _change_score(0)
    add_to_group("Player")
    _flower_detector.add_to_group("FlowerDetector")
    _player_stomp.add_to_group("PlayerStomp")
    _star_detector.area_entered.connect(_on_star_detector_area_entered)
    _star_detector.area_exited.connect(_on_star_detector_area_exited)
    call_deferred("_initialize_normal_mode")

func _physics_process(delta: float) -> void:
    if !is_alive:
        return
    
    process_continuous_damage(delta)
    if _in_core_mode:
        _core_move(delta)
        _update_core_animation()
    elif cannot_move:  # 添加这个条件来检查是否处于受伤状态
        _hurt_move(delta)
        _update_hurt_animation() 
    else:
        _normal_move(delta)
        _check_wall_stuck(delta)
        _update_normal_animation()
    move_and_slide()
    _check_item_usage()
    emit_signal("player_position_changed", global_position)

func _update_normal_animation() -> void:
    if velocity.x != 0:
        _player_sprite.flip_h = velocity.x < 0
    if is_on_floor():
        if abs(velocity.x) > 0.1:
            _animation_player.play("run")
        else:
            _animation_player.play("idle")
    else:
        if velocity.y < 0:
            _animation_player.play("jump")
        else:
            _animation_player.play("fall")

func _update_core_animation() -> void:
    var speed = velocity.length()
    if speed > 0.1:
        _animation_player.play("climb")
        # 计算动画播放速度，可以根据需要调整系数
        var animation_speed = clamp(speed / 100.0, 0.5, 2.0)
        _animation_player.set_speed_scale(animation_speed)
    else:
        _animation_player.play("wait_on_wall")
        _animation_player.set_speed_scale(1.0)  # 重置为正常速度

func _update_hurt_animation() -> void:
    _animation_player.play("hurt")

func random_get_item():
    var items = [
        preload("res://resources/items/circle_item.tres"),
        preload("res://resources/items/gravity_item.tres"),
        preload("res://resources/items/ring_item.tres"),
        preload("res://resources/items/speed_item.tres"),
        preload("res://resources/items/square_item.tres")
    ]
    
    # 随机选择一个道具
    var random_item = items[randi() % items.size()]
    
    # 添加随机选择的道具
    _add_item(random_item.duplicate())

func _check_item_usage() -> void:
    for action in ACTION_TO_INDEX:
        if Input.is_action_just_pressed(action):
            var item_idx : int = ACTION_TO_INDEX[action]
            if item_arr and item_arr.has_item(item_idx):
                _use_item(action)
            break

func _remove_item(action: String) -> void:
    """
    action should in ["ui_q", "ui_w", "ui_e", "ui_r"]
    """
    var item_idx: int = ACTION_TO_INDEX[action]
    if (!item_arr.has_item(item_idx)):
        return
    item_arr.remove_item(item_idx)
    emit_signal("item_arr_updated")
    emit_signal("remove_track", action)

func _add_item(item: Item):
    item_arr.add_item(item.duplicate())
    emit_signal("item_arr_updated")

func _use_item(action: String) -> void:
    var item_idx : int = ACTION_TO_INDEX[action]
    if (!item_arr.has_item(item_idx)):
        return
    var item_name : GlobalEnums.TrackName = item_arr.get_item_name(item_idx)
    var clicked_times : int = item_arr.get_item_clicked_times(item_idx)
    
    if clicked_times == CLICKS_TO_BUILD_TRACK[item_name]:
        # Track has been built, remove it
        print("removing...")
        _remove_item(action)
        start_global_pos_for_square_track[action] = null
        return
    
    match item_name:
        GlobalEnums.TrackName.CircleTrack:
            emit_signal("create_circle_track", action, global_position)
        GlobalEnums.TrackName.GravityCircleTrack:
            emit_signal("create_gravity_circle_track", action, global_position)
        GlobalEnums.TrackName.RingTrack:
            emit_signal("create_ring_track", action, global_position)
        GlobalEnums.TrackName.SpeedTrack:
            var direction = get_place_track_direction()
            emit_signal("create_speed_track", action, global_position, direction)
        GlobalEnums.TrackName.SquareTrack:
            if clicked_times == 0:
                start_global_pos_for_square_track[action] = global_position
            elif clicked_times == 1:
                var start_pos = start_global_pos_for_square_track[action]
                if start_pos:
                    emit_signal("create_square_track", action, start_pos, global_position)
                    start_global_pos_for_square_track[action] = null
    
    print("Used item: %s (action: %s, Used times: %d)" % [item_name, action, clicked_times])
    item_arr.use_item(item_idx)
    emit_signal("item_arr_updated")
    return 

func get_place_track_direction() -> Vector2:
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    
    if input_vector != Vector2.ZERO:
        # 如果有输入，使用输入方向
        return input_vector.normalized()
    elif velocity != Vector2.ZERO:
        # 如果正在移动，使用当前移动方向
        return velocity.normalized()
    else:
        # 如果静止，使用面朝方向（这里假设 rotation 表示面朝方向）
        return Vector2.RIGHT.rotated(rotation)

func _initialize_normal_mode() -> void:
    _in_core_mode = false
    _player_collision.set_deferred("disabled", false)
    remaining_jumps = 2
    print("Initialized in normal mode")

func _normal_move(delta: float) -> void:
    var jump_timer: SceneTreeTimer
    if is_on_floor():
        remaining_jumps = 2
        if jump_timer:
            jump_timer.time_left = 0
    else:
        velocity.y += gravity * delta
        if remaining_jumps > 1:
            if not jump_timer or jump_timer.time_left <= 0:
                jump_timer = get_tree().create_timer(0.3) # 设置0.5秒延时，土狼跳
                jump_timer.connect("timeout", func():
                    if not is_on_floor() and remaining_jumps > 1:
                        remaining_jumps = 1
                )

    if Input.is_action_just_pressed("ui_accept") and remaining_jumps > 0:
        velocity.y = JUMP_VELOCITY
        remaining_jumps -= 1

    var direction := Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
    if velocity.y >= 1000: # 避免玩家下落速度过快而在踩到怪时由于怪的碰撞伤害受伤
        velocity.y = 1000

func _core_move(delta: float) -> void:
    var direction := Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down")
    )
    velocity = direction * CORE_SPEED
    
    ignore_push = Input.is_action_pressed("ui_accept")
    if ignore_push:
        velocity /= 5.0
    
    if not ignore_push:  # 只在不忽略推力时应用轨道力
        _apply_star_track_forces(delta)
    

func _hurt_move(delta: float) -> void:
    # 在受伤状态下，我们可以让玩家无法控制移动，只是让其按照被击退的方向移动
    velocity.y += gravity * delta  # 添加重力影响
    velocity.x = move_toward(velocity.x, 0, SPEED * 0.1)  # 缓慢减少水平速度

func _apply_star_track_forces(delta: float) -> void:
    var total_push_vector := Vector2.ZERO
    for track in _star_tracks:
        total_push_vector += track.get_push_vector(global_position) * PUSH_ADDITION_RATIO
    velocity += total_push_vector * delta

func _on_star_detector_area_entered(area: Node2D) -> void:
    if area is StarTrack:
        _star_tracks.append(area)
        if not _in_core_mode:
            call_deferred("_enter_core_mode")

func _on_star_detector_area_exited(area: Node2D) -> void:
    if area is StarTrack:
        _star_tracks.erase(area)
        if _star_tracks.is_empty():
            call_deferred("_exit_core_mode")

func _enter_core_mode() -> void:
    if not _in_core_mode:
        _in_core_mode = true
        _player_collision.set_deferred("disabled", true)
        print("Entered core mode")

func _exit_core_mode() -> void:
    if _in_core_mode:
        _in_core_mode = false
        _player_collision.set_deferred("disabled", false)
        remaining_jumps = 1  # 从核心模式退出时重置为1次跳跃机会
        print("Exited core mode")
        
func _place_star_square() -> void:
    emit_signal("create_square")
    print("Square created")

func _place_star_ring() -> void:
    emit_signal("create_ring", global_position)
    print("Ring created at", global_position)

func _update_health(new_health: int) -> void:
    player_health = new_health
    emit_signal("player_health_changed", player_health)
    if (player_health <= 0):
        die()

func _be_hurt(attacker_position: Vector2) -> void:
    if cannot_be_attacked:
        return
    _update_health(player_health - 1)
    cannot_be_attacked = true
    cannot_move = true
    
    # 击退效果
    var knockback_direction = global_position - attacker_position
    print(knockback_direction)
    velocity = knockback_direction.normalized() * knockback_force
    
    # 变红效果
    modulate = hurt_color
    
    var movability_timer = get_tree().create_timer(0.5)
    movability_timer.timeout.connect(_reset_movability)

    # 创建一个定时器来1秒后重置无敌状态和颜色
    var timer = get_tree().create_timer(1.0)
    timer.timeout.connect(_reset_invincibility)

func _reset_movability() -> void:
    cannot_move = false

func _reset_invincibility() -> void:
    cannot_be_attacked = false
    modulate = normal_color

func _check_wall_stuck(delta: float) -> void:
    if _wall_detector.has_overlapping_bodies():
        wall_stuck_timer += delta
        if wall_stuck_timer >= WALL_STUCK_THRESHOLD:
            wall_stuck_help_move += 2.0
            _handle_wall_stuck()
            wall_stuck_timer = 0.0
    else:
        wall_stuck_help_move = DEFAULT_WALL_STUCK_HELP_MOVE
        wall_stuck_timer = 0.0

func _handle_wall_stuck() -> void:
    position += Vector2(randf_range(-wall_stuck_help_move, wall_stuck_help_move), 
                        randf_range(-wall_stuck_help_move, wall_stuck_help_move))
    velocity = Vector2.ZERO # 避免计算重力 
    print("Handled wall stuck")

func _on_flower_handler_item_collected(item:Item, _global_pos: Vector2):
    _add_item(item)
    _get_score(flower_score)

func _on_stomp_detector_area_entered(_area: Area2D) -> void:
    velocity.y = JUMP_VELOCITY  # 对玩家施加向上的冲量
    remaining_jumps = 1
    _get_score(enemy_score)

func _on_hurt_detector_area_entered(area: Area2D):
    in_danger_zone = true
    _be_hurt(area.global_position)  # 立即造成第一次伤害
    hurt_timer = 0.0  # 重置计时器，为下一次伤害做准备

func _on_hurt_detector_area_exited(_area: Area2D):
    in_danger_zone = false
    hurt_timer = 0.0

func process_continuous_damage(delta: float):
    if in_danger_zone and not cannot_be_attacked:
        hurt_timer += delta
        if hurt_timer >= hurt_cooldown:
            _be_hurt(global_position)  # 使用玩家自身位置，因为没有具体的攻击者
            hurt_timer = 0.0  # 重置计时器

func _change_score(new_score: int) -> void:
    current_score = new_score
    emit_signal("score_updated", current_score)
    return

func _get_score(bonus_score: int):
    _change_score(current_score + bonus_score)
    var score_pop: PopScore = score_pop_up.instantiate()
    score_pop.set_score(bonus_score)
    _score_pop_container.add_child(score_pop)

func _clear_items() -> void:
    _remove_item("ui_q")
    _remove_item("ui_w")
    _remove_item("ui_e")
    _remove_item("ui_r")



func die() -> void:
    _clear_items()
    # 播放死亡动画
    is_alive = false
    _animation_player.play("hurt")
    await _animation_player.animation_finished
    Engine.time_scale = 0
    death_menu.show()
    # 切换场景
    return
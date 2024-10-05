class_name Larva extends CharacterBody2D


enum State {
	EGG,
	LARVA,
	BIGLARVA,
	PUPA,
	BUTTERFLY
}


const LARVA_SPEED = 80.0
const BIGLARVA_SPEED = 200.0
const JUMP_VELOCITY = -400.0
const EGG_JUMP_VELOCITY = -100.0
const EGG_MOVE_VELOCITY = 400.0

const WATER_PROGRESS = 17

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
var gui: GUI

@export var evolveState: State = State.EGG :
	set(val):
		evolveState = val
		_update_evolve_state()
	get:
		return evolveState

var currentDirection = 1
var isMoving = false
var isEvolving = false
var canMove = false
var isAirborne = false
var movementTimer = 0
var animationPrefix = ""
var progress = 0


func _physics_process(delta: float) -> void:
	if isEvolving:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not isAirborne:
			isAirborne = true
	else:
		if isAirborne:
			isAirborne = false
			isMoving = false
			_play_animation("default")
	

	# Handle jump.
	if Input.is_action_just_pressed("action") and is_on_floor():
		match evolveState:
			State.EGG:
				velocity.y = EGG_JUMP_VELOCITY
				velocity.x = EGG_MOVE_VELOCITY * currentDirection
				isAirborne = true
				_play_animation("jump")
			State.BIGLARVA:
				velocity.y = JUMP_VELOCITY
				isAirborne = true
				_play_animation("jump")

	var speed = 0
	match evolveState:
		State.EGG:
			speed = EGG_MOVE_VELOCITY * 0.3
		State.LARVA:
			speed = LARVA_SPEED
		State.BIGLARVA:
			speed = BIGLARVA_SPEED

	var direction := Input.get_axis("left", "right")
	if direction != 0 and canMove:
		currentDirection = direction
		if !isMoving:
			isMoving = true
			movementTimer = 0
			if not isAirborne:
				_play_animation("crawl")
		movementTimer += delta
		sprite.scale.x = direction

		var anim = _get_animation_name("crawl")
		var t = sprite.sprite_frames.get_frame_count(anim) / sprite.sprite_frames.get_animation_speed(anim)
		match evolveState:
			State.LARVA:
				velocity.x = ((1 + sin((movementTimer / t) * PI * 2 - PI)) / 2) * direction * speed
			State.BIGLARVA:
				if isAirborne:
					velocity.x = direction * speed * 0.7
				else:
					velocity.x = ((1 + sin((movementTimer / t) * PI * 2 - PI / 2)) / 2) * direction * speed
	else:
		if isMoving:
			isMoving = false
			if not isAirborne:
				_play_animation("default")
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _update_evolve_state():
	animationPrefix = State.keys()[evolveState] + "_"
	canMove = false
	match evolveState:
		State.LARVA:
			canMove = true
		State.BIGLARVA:
			canMove = true
	if sprite != null:
		_play_animation("default")
	if gui != null:
		gui.set_stage(evolveState)


func _play_animation(anim: String):
	var animName = _get_animation_name(anim)
	if sprite.sprite_frames.has_animation(animName):
		sprite.play(animName)
	if animationPlayer.has_animation(animName):
		animationPlayer.stop()
		animationPlayer.play(animName)


func _get_animation_name(anim: String):
	return animationPrefix + anim


func level_up():
	match evolveState:
		State.EGG:
			gui.set_stage_progress(100)
			await _animate_evolution(State.LARVA)
		State.LARVA:
			await _animate_evolution(State.BIGLARVA)
	progress = 0


func _animate_evolution(state: State):
	isEvolving = true

	animationPlayer.stop()
	animationPlayer.play("evolving")

	$Evolve/AnimationPlayer.play("fade_in")
	$Evolve/Sound.play()
	$Evolve/Sound/AnimationPlayer.play("fade_in")
	
	await get_tree().create_timer(5.0).timeout

	$Evolve/SoundDone.play()

	await get_tree().create_timer(1.0).timeout

	$Evolve/AnimationPlayer.play("fade_out")
	$Evolve/Sound/AnimationPlayer.play("fade_out")
	
	animationPlayer.stop()
	animationPlayer.play("RESET")

	isEvolving = false
	evolveState = state


func init(_gui: GUI):
	gui = _gui

	_update_evolve_state()


func collect_item(item: Node2D):
	if item.is_in_group("water"):
		item.slurp_up()
		progress += WATER_PROGRESS
		gui.set_stage_progress(progress)
		if progress >= 100:
			level_up()

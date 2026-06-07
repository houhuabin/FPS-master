extends CenterContainer

@export var PLAYER_CONTROLLER : CharacterBody3D

# 中心点
@export var DOT_RADIUS : float = 2.0
@export var DOT_COLOR : Color = Color.WHITE

# 准星线
@export var LINE_LENGTH : float = 8.0
@export var LINE_WIDTH : float = 2.0

# 基础间距
@export var RETICLE_DISTANCE : float = 8.0

# 扩散倍率
@export var SPREAD_MULTIPLIER : float = 2.0

# 最大扩散距离
@export var MAX_SPREAD : float = 25.0

# 动画速度
@export var RETICLE_SPEED : float = 20.0

var current_gap : float


func _ready():
	current_gap = RETICLE_DISTANCE
	queue_redraw()


func _process(delta):

	var target_gap = RETICLE_DISTANCE

	if PLAYER_CONTROLLER:

		var horizontal_speed = Vector2(
			PLAYER_CONTROLLER.velocity.x,
			PLAYER_CONTROLLER.velocity.z
		).length()

		target_gap = clamp(
			RETICLE_DISTANCE + horizontal_speed * SPREAD_MULTIPLIER,
			RETICLE_DISTANCE,
			MAX_SPREAD
		)

	current_gap = lerpf(
		current_gap,
		target_gap,
		delta * RETICLE_SPEED
	)

	queue_redraw()


func _draw():

	var center = Vector2.ZERO

	# 中心点
	draw_circle(
		center,
		DOT_RADIUS,
		DOT_COLOR
	)

	# 上
	draw_line(
		center + Vector2(0, -current_gap),
		center + Vector2(0, -current_gap - LINE_LENGTH),
		DOT_COLOR,
		LINE_WIDTH
	)

	# 下
	draw_line(
		center + Vector2(0, current_gap),
		center + Vector2(0, current_gap + LINE_LENGTH),
		DOT_COLOR,
		LINE_WIDTH
	)

	# 左
	draw_line(
		center + Vector2(-current_gap, 0),
		center + Vector2(-current_gap - LINE_LENGTH, 0),
		DOT_COLOR,
		LINE_WIDTH
	)

	# 右
	draw_line(
		center + Vector2(current_gap, 0),
		center + Vector2(current_gap + LINE_LENGTH, 0),
		DOT_COLOR,
		LINE_WIDTH
	)

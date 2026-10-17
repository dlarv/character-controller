extends Node
class_name StaminaHandler

signal stamina_empty
signal stamina_refreshed

enum RefillMode { CUMULATIVE, REPLACE }

const PlayerController := preload("uid://275scp4h71ib")

@export var player: PlayerController
@export var max_stamina := 100.0
## If -INF, stamina has no bottom cap
@export var min_stamina := 0.0
## Minimum threshold of stamina player needs after hitting 0 in order to use abilities again.
@export var winded_threshold := 3.0
## How often to recalculate stamina.
@export var tick_rate := 1.0
## How much stamina to regain each tick.
@export var refresh_amount := 10.0
## Determines behavior for when player is using stamina and stamina is simultaneously refilling.
## CUMULATIVE: refill - usage
## REPLACE: stamina only drains when used
@export var refill_mode := RefillMode.REPLACE
## How quickly different abilities drain stamina.
## Where key is ability name
## and value is amount drained per tick_rate
@export var drainage_rates: Dictionary[StringName, float]

@onready var stamina := max_stamina
var is_empty := false

var _curr_drain_rate := 0.0
var _tick_rate_timer: Timer
var _active_abilities: Array[StringName] = []

func _ready() -> void:
	_tick_rate_timer = Timer.new()
	_tick_rate_timer.one_shot = false
	_tick_rate_timer.wait_time = 1 / tick_rate
	add_child(_tick_rate_timer)
	_tick_rate_timer.start()
	_tick_rate_timer.timeout.connect(_on_refresh_tick)

	if not player and get_parent() is PlayerController:
		player = get_parent()
	if not player:
		push_warning("StaminaHandler(%s) not connected to PlayerController" % get_path())
		return

	var states := player.get_state_data()
	for key in states:
		if not drainage_rates.has(key): continue
		if states[key].get("enabled", false):
			_active_abilities.append(key)

	stamina_empty.connect(player.enable_abilities.bind(_active_abilities, false))
	stamina_refreshed.connect(player.enable_abilities.bind(_active_abilities, true))


func _on_refresh_tick() -> void:
	var _delta: float
	if refill_mode == RefillMode.CUMULATIVE:
		_delta = refresh_amount - _curr_drain_rate
	elif _curr_drain_rate <= 0:
		_delta = refresh_amount
	else:
		_delta = -_curr_drain_rate

	stamina = clampf(stamina + _delta, min_stamina, max_stamina)

	if stamina <= 0:
		stamina_empty.emit()
		is_empty = true
	elif is_empty and stamina >= winded_threshold:
		stamina_refreshed.emit()
		is_empty = false


func ability_started(key: StringName) -> void:
	_curr_drain_rate += drainage_rates.get(key, 0)


func ability_finished(key: StringName) -> void:
	_curr_drain_rate -= drainage_rates.get(key, 0)
	_curr_drain_rate = max(_curr_drain_rate, 0)


func _on_ability_granted(key: StringName) -> void:
	if drainage_rates.has(key):
		_active_abilities.append(key)

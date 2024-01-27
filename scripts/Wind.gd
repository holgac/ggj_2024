extends Node2D

class_name GDWind

# TODO: times some coef
@export var wind_speed = 512000;
@export var min_cooldown: int = 5;
@export var max_cooldown: int = 10;
@export var initial_wind_start: int = 2;
@export var min_wind_duration: int = 4;
@export var max_wind_duration: int = 10;

@onready var wind_cooldown_label: Label = get_node("../HUD/WindCooldown")
@onready var wind_indicator: Node2D = get_node("Sprite2D")
@onready var players: Node2D = get_node("../Players")
var wind_time_left = 0;
var next_wind_start: int = initial_wind_start;
var wind_direction: Vector2 = Vector2.ZERO;


var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
  get_node('Timer').connect('timeout', second_timer)
  wind_indicator.hide()
  wind_cooldown_label.hide()

func second_timer():
  next_wind_start -= 1
  wind_time_left -= 1
  if wind_time_left < 0:
    wind_indicator.hide()
  if next_wind_start == 0:
    wind_indicator.show()
    wind_cooldown_label.hide()
    wind_time_left = rng.randi_range(min_wind_duration, max_wind_duration);
    next_wind_start = wind_time_left + rng.randi_range(min_cooldown, max_cooldown)
    wind_direction = Vector2(rng.randf(), rng.randf()).normalized();
    wind_direction = Vector2(2 * rng.randf() - 1, 2 * rng.randf() - 1).normalized();
    wind_indicator.look_at(wind_indicator.global_position + wind_direction)
  elif next_wind_start < 5:
    wind_cooldown_label.show()
    wind_cooldown_label.set_text(str(next_wind_start))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if wind_time_left > 0:
    for player: GDPlayer in players.get_children():
      player.apply_force(wind_direction * delta * wind_speed);
    

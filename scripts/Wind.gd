extends Node2D

class_name GDWind

# TODO: times some coef
@export var wind_speed = 512000;
@export var min_cooldown: int = 5;
@export var max_cooldown: int = 10;
@export var initial_wind_start: int = 60;
@export var min_wind_duration: int = 4;
@export var max_wind_duration: int = 10;

@onready var wind_cooldown_label: Label = get_node("../HUD/WindCountdown_Frame/WindCooldown")
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
  if next_wind_start == 0:
    wind_cooldown_label.hide()
    get_node('Timer').stop();
    get_node('WindSound').play();
  else:
    wind_cooldown_label.set_text(str(next_wind_start));

func start_wind(start_in: float, duration: float, direction: Vector2 = Vector2.ZERO):
  next_wind_start = start_in
  wind_time_left = duration;
  wind_cooldown_label.show()
  wind_cooldown_label.set_text(str(next_wind_start))
  # wind_indicator.show();
  if direction.length_squared() < 0.01:
    wind_direction = Vector2(2 * rng.randf() - 1, 2 * rng.randf() - 1).normalized();
  wind_indicator.look_at(wind_indicator.global_position + wind_direction)
  get_node('Timer').start();
  wind_cooldown_label.set_text(str(next_wind_start));
  wind_indicator.show()

func _process(delta):
  if next_wind_start == 0 and wind_time_left > 0:
    wind_time_left -= delta;
    if wind_time_left <= 0:
      wind_indicator.hide();
    for player: GDPlayer in players.get_children():
      player.apply_force(wind_direction * delta * wind_speed);
    

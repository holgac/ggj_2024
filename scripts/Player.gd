extends RigidBody2D
class_name GDPlayer

@export var player_id: String;
@export var speed: float = 240000;
@export var attack_speed: float = 10000;
@export var attack_speed_on_victim: float = -1000;
@export var max_velocity: float = 5000;
@export var dash_speed: float = 10000;
@export var dash_cooldown: float = 0.3;
@export var dash_duration: float = 0.1;
@onready var max_velocity_squared: float = max_velocity * max_velocity;

var dash_cur_cooldown = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
  pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func is_dashing():
  return (dash_cooldown - dash_cur_cooldown) < dash_duration

func _physics_process(delta):
  dash_cur_cooldown -= delta;
  var movement = Vector2.ZERO;
  if Input.is_action_pressed(player_id + "_left"):
    movement.x -= 1;
  if Input.is_action_pressed(player_id + "_right"):
    movement.x += 1;
  if Input.is_action_pressed(player_id + "_up"):
    movement.y -= 1;
  if Input.is_action_pressed(player_id + "_down"):
    movement.y += 1;
  if movement.length_squared() > 0.1:
    movement = movement.normalized();
  if Input.is_action_just_pressed(player_id + "_dash"):
    try_dash(movement)
  if movement.length_squared() > 0.1:
     movement = movement * delta * speed;
  if linear_velocity.length_squared() > max_velocity_squared:
    var cur_max_velocity = max_velocity
    var ratioDiff = 1 - (max_velocity / linear_velocity.length())
    # print('ratioDiff: ', ratioDiff)
    movement -= (ratioDiff * 500 * delta) * linear_velocity
  if movement.length_squared() > 0.01:
    apply_force(movement);
  # TODO: pressed or just pressed?
  if Input.is_action_just_pressed(player_id + "_attack"):
    try_attack()

func try_dash(movement: Vector2):
  if dash_cur_cooldown > 0 or movement.length_squared() < 0.01:
    return
  dash_cur_cooldown = dash_cooldown
  apply_impulse(movement * dash_speed);

func try_attack():
  var query = PhysicsShapeQueryParameters2D.new()
  query.collision_mask = 0x2;
  var shape = CircleShape2D.new()
  # TODO: don't hardcode
  shape.radius = 200
  query.shape = shape
  query.exclude = [self]
  query.transform.origin = global_position
  var results = get_world_2d().direct_space_state.intersect_shape(query);
  for result in results:
    var otherPlayer: RigidBody2D = result['collider']
    var normal = (global_position - otherPlayer.global_position).normalized()
    apply_impulse(normal * attack_speed)
    otherPlayer.apply_impulse(normal * attack_speed_on_victim)
    print('Collider: ', result['collider']);
  

extends Node2D

@export var min_force = 3000;
@export var max_force = 5000;
@export var is_puller: bool = true;

var cur_force: float;
var radius: float;
var push_coef;


var bodies: Array[Node2D] = [];

# Called when the node enters the scene tree for the first time.
func _ready():
  var area: Area2D = get_node('Area2D');
  area.connect('body_entered', body_entered)
  area.connect('body_exited', body_exited)
  var rng = RandomNumberGenerator.new()
  cur_force = min_force + (max_force - min_force) * rng.randf();
  if is_puller:
    push_coef = -1
  else:
    push_coef = 1
  var cshape: CollisionShape2D = area.get_node('CollisionShape2D');
  var circle: CircleShape2D = cshape.shape;
  radius = circle.radius;
  #area.connect('body_shape_entered', body_entered)
  #area.connect('body_shape_exited', body_exited)
  

func body_entered(body: Node2D):
  print(body.name, 'entered!')
  bodies.append(body)

func body_exited(body: Node2D):
  print(body.name, 'exited!')
  bodies.erase(body);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  for body: RigidBody2D in bodies:
    var diff = body.global_position - global_position
    var distance = diff.length()
    var normal: Vector2 = diff * (1.0 / distance)
    var force_ratio = distance / radius
    force_ratio = cos(force_ratio * PI / 4)
    body.apply_force(normal * (force_ratio * cur_force * push_coef))

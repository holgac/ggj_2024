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
  area.connect('area_entered', area_entered)
  area.connect('area_exited', area_exited)
  var rng = RandomNumberGenerator.new()
  cur_force = min_force + (max_force - min_force) * rng.randf();
  if is_puller:
    push_coef = -1
  else:
    push_coef = 1
  var cshape: CollisionShape2D = area.get_node('CollisionShape2D');
  var circle: CircleShape2D = cshape.shape;
  radius = circle.radius;
  var as2d: AnimatedSprite2D = get_node('AnimatedSprite2D');
  as2d.play();
  as2d = get_node('AnimatedSprite2D2');
  # as2d.set_frame(4);
  as2d.play();
  #area.connect('body_shape_entered', body_entered)
  #area.connect('body_shape_exited', body_exited)
  

func body_entered(body: Node2D):
  bodies.append(body)

func body_exited(body: Node2D):
  bodies.erase(body);

func area_entered(body: Node2D):
  bodies.append(body)

func area_exited(body: Node2D):
  bodies.erase(body);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  for node in bodies:
    var diff = node.global_position - global_position
    var distance = diff.length()
    var normal: Vector2 = diff * (1.0 / distance)
    var force_ratio = distance / radius
    force_ratio = cos(force_ratio * PI / 4)
    if node is RigidBody2D:
      var body: RigidBody2D = node
      body.apply_force(normal * (force_ratio * cur_force * push_coef))
    else:
      var area: Area2D = node

extends Node2D
class_name GDPuke;

var bodies: Array[Node2D] = [];

# Called when the node enters the scene tree for the first time.
func _ready():
  connect('body_entered', body_entered)
  connect('body_exited', body_exited)
  get_node('Timer').connect('timeout', queue_free);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func body_entered(body: Node2D):
  bodies.append(body)

func body_exited(body: Node2D):
  bodies.erase(body);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  for node in bodies:
    var diff = node.global_position - global_position
    var distance = diff.length()
    var normal: Vector2 = diff * (1.0 / distance)
    if node is RigidBody2D:
      var body: RigidBody2D = node
      var invVel = -body.linear_velocity;
      body.apply_force(invVel * delta * 1000);

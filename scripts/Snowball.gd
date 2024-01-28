extends Area2D
class_name GDSnowball;

@export var speed: float = 1000;
@export var direction: Vector2 = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
  connect('body_shape_entered', body_shape_entered)

func _physics_process(delta):
  translate(direction * speed * delta);
  # translate();
  # TODO: do this in a better way after waking up
  if position.length_squared() > 20000 * 20000:
    queue_free()

func body_shape_entered(body_rid: RID, node: Node, body_shape_idx: int, local_idx: int):
  print('snowball hit', node.name)

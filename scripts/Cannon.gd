extends AnimatedSprite2D
class_name GDCannon

@export var SnowballScene: PackedScene;
# @export var mine: PackedScene;


# Called when the node enters the scene tree for the first time.
func _ready():
  connect('animation_changed', animation_changed)
  pass # Replace with function body.

func animation_changed():
  if animation == 'fire':
    animation = 'idle'
  var snowball: GDSnowball = SnowballScene.instantiate();
  # snowball.position = global_position;
  var barrel: Node2D = get_node('Barrel');
  snowball.transform = barrel.global_transform;
  snowball.direction = (barrel.global_position - global_position).normalized()
  get_tree().root.call_deferred('add_child', snowball);
  # snowball
    

func fire():
  animation = 'fire'

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

extends RigidBody2D
class_name GDPlayer

@export var player_id: String;
@export var speed: float = 60000;

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func _physics_process(delta):
  var movement = Vector2.ZERO;
  if Input.is_action_pressed(player_id + "_left"):
    movement.x -= delta * speed;
  if Input.is_action_pressed(player_id + "_right"):
    movement.x += delta * speed;
  if Input.is_action_pressed(player_id + "_up"):
    movement.y -= delta * speed;
  if Input.is_action_pressed(player_id + "_down"):
    movement.y += delta * speed;
  if movement.length_squared() > 0.01:
    apply_force(movement);

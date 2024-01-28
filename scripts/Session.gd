extends Node;

class_name GDSession;

var current_scene: Node;

#const MainMenuScene: String = "res://scenes/MainMenu.tscn";
#const CreditsScene: String = "res://scenes/Credits.tscn";
const Level1Scene: String = "res://scenes/Level1.tscn";

func _ready():
  var root = get_tree().root;
  current_scene = root.get_child(root.get_child_count() - 1);
  # goto_scene(MainMenuScene)

func goto_scene(path):
  call_deferred("_deferred_goto_scene", path);

func _deferred_goto_scene(path):
  if current_scene:
    current_scene.free();
  var s = ResourceLoader.load(path);
  current_scene = s.instantiate();
  current_scene.get_tree();
  get_tree().root.add_child(current_scene);
  get_tree().current_scene = current_scene;

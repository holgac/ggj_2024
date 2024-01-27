extends Node
class_name GDHud;

func _ready():
  pass

func on_score_updated(game: GDGame):
  for player in game.scores:
    var label: Label = get_node(player + 'Score');
    label.set_text(str(game.scores[player]))


func _on_pause_button_toggled(toggled_on):
  print('is toggled?', toggled_on)
  get_tree().set_pause(toggled_on)

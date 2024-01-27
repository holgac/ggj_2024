extends Node
class_name GDHud;

func _ready():
  pass

func on_score_updated(game: GDGame):
  for player in game.scores:
    var label: Label = get_node(player + 'Score');
    label.set_text(str(game.scores[player]))

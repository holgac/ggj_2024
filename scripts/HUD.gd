extends Node
class_name GDHud;

var time_left = 300;

func _ready():
  pass

func on_score_updated(game: GDGame):
  for player in game.scores:
    var label: Label = get_node('TopUI_Frame/' + player + '_Frame/' + player + 'Score');
    label.set_text(str(game.scores[player]))


func _on_pause_button_toggled(toggled_on):
  print('is toggled?', toggled_on)
  get_tree().set_pause(toggled_on)


func _on_second_timer_timeout():
  if time_left <= 0:
    Session.goto_scene(Session.MainMenuScene);
  time_left -= 1;
  var lbl: Label = get_node('TopUI_Frame/GameCountdown');
  if time_left < 60:
    lbl.set_text(str(time_left))
  else:
    var minute = int(time_left / 60)
    var second = time_left % 60;
    if second < 10:
      lbl.set_text(str(minute) + ':0' + str(second))
    else:
      lbl.set_text(str(minute) + ':' + str(second))
    
  pass # Replace with function body.

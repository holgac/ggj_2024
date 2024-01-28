extends Node
class_name GDGame;

signal player_score_change;
@export var PusherScene: PackedScene;
@export var PullerScene: PackedScene;
@export var events: Array[Dictionary] = [];
@onready var wind: GDWind = get_node("Wind");
@onready var eventTimer: Timer = get_node("EventTimer");
@onready var hud: GDHud = get_node('HUD');
var eventIdx: int = -1;
var playerTurn: GDPlayer = null;

var score_left_for_next_event: int;
# 'Player1'
var scores: Dictionary;

func fill_events_for_first_level():
  events.append({'type': 'chase', 'duration': -1, 'score': 2})

func _ready():
  fill_events_for_first_level()
  eventTimer.connect('timeout', start_next_event);
  for player: GDPlayer in get_node('Players').get_children():
    scores[player.name] = 0
    player.connect('body_shape_entered', player_body_entered.bind(player));
  start_next_event();
  wind.start_wind(2, 5);

#func player_body_entered(player: GDPlayer, node: Node):
func player_body_entered(body_rid: RID, node: Node, body_shape_idx: int, local_idx: int, player: GDPlayer):
  if node is GDPlayer:
    get_node('PlayerPlayerHitSound').play();
    var otherPlayer: GDPlayer = node;
    if eventIdx != -1 and eventIdx < events.size() and events[eventIdx]['type'] == 'chase':
      scores[playerTurn.name] += 1
      score_left_for_next_event -= 1
      if score_left_for_next_event == 0:
        start_next_event()
      if otherPlayer == playerTurn:
        playerTurn = player;
      else:
        playerTurn = otherPlayer;
      hud.on_score_updated(self);
      player_score_change.emit();
  else:
    get_node('PlayerEnvironmentHitSound').play();
  print(player.name, 'collide', node.name)
  for body in player.get_colliding_bodies():
    print('collision with', body)

func start_next_event():
  if eventIdx != -1:
    # cleanup depends on next event type, do it there to avoid code repetition?
    match events[eventIdx]['type']:
        'chase':
          playerTurn = null;
        _:
          assert(false);
  eventIdx += 1
  if eventIdx < events.size():
    match events[eventIdx]['type']:
      'chase':
        playerTurn = get_node('Players').get_child(0);
        var otherPlayer = get_node('Players').get_child(1);
        if events[eventIdx]['duration'] > 0:
          eventTimer.set_wait_time(events[eventIdx]['duration']);
          eventTimer.start();
        score_left_for_next_event = events[eventIdx]['score']
      _:
        assert(false);
  
  # create new event

func _process(delta: float):
  pass

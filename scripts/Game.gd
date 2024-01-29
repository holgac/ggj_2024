extends Node
class_name GDGame;

signal player_score_change;
@export var PusherScene: PackedScene;
@export var PullerScene: PackedScene;
@export var CheckpointScene: PackedScene;
@export var events: Array[Dictionary] = [];
@export var subEvents: Array[Dictionary] = [];
@export var checkpoint_score_cooldown = 0.5;
@onready var wind: GDWind = get_node("Wind");
@onready var eventTimer: Timer = get_node("EventTimer");
@onready var subEventTimer: Timer = get_node("SubEventTimer");
@onready var hud: GDHud = get_node('HUD');
var eventIdx: int = -1;
var subEventIdx: int = -1;
var playerTurn: GDPlayer = null;
@onready var rng = RandomNumberGenerator.new();

var score_left_for_next_event: int;
var last_checkpoint_score: float = 0;
var last_checkpoint_idx: int = 0;

# 'Player1'
var scores: Dictionary;

func fill_events_for_first_level():
  # events are game modes
  events.append({'type': 'chase', 'duration': -1, 'score': 2})
  events.append({'type': 'checkpoint', 'duration': 60, 'score': -1})
  events.append({'type': 'chase', 'duration': 60, 'score': -1})
  events.append({'type': 'checkpoint', 'duration': 60, 'score': -1})
  events.append({'type': 'chase', 'duration': 60, 'score': -1})
  events.append({'type': 'checkpoint', 'duration': 600, 'score': -1})

  # sub events are traps and other stuff that makes the level harder/more interesting
  subEvents.append({'type': 'nothing', 'wait_time': 30, 'duration': 30, 'count': 1})
  subEvents.append({'type': 'pusher', 'wait_time': 5, 'duration': 5, 'count': 2})
  subEvents.append({'type': 'pusher', 'wait_time': 5, 'duration': 5, 'count': 2})
  subEvents.append({'type': 'pusher', 'wait_time': 15, 'duration': 5, 'count': 3})
  for i in range(30):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'nothing', 'wait_time': 10, 'duration': 10, 'count': 1})
  subEvents.append({'type': 'wind', 'wait_time': 13, 'duration':3, 'warn': 5})
  subEvents.append({'type': 'wind', 'wait_time': 13, 'duration':3, 'warn': 5})
  subEvents.append({'type': 'nothing', 'wait_time': 10, 'duration': 10, 'count': 1})
  
  subEvents.append({'type': 'wind', 'wait_time': 0, 'duration':3, 'warn': 5})
  for i in range(10):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'wind', 'wait_time': 0, 'duration':3, 'warn': 5})
  for i in range(10):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'wind', 'wait_time': 0, 'duration':3, 'warn': 5})
  for i in range(10):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'nothing', 'wait_time': 10, 'duration': 10, 'count': 1})
  
  subEvents.append({'type': 'pusher', 'wait_time': 5, 'duration': 10, 'count': 2})
  for i in range(5):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'pusher', 'wait_time': 5, 'duration': 10, 'count': 2})
  for i in range(5):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'pusher', 'wait_time': 5, 'duration': 10, 'count': 2})
  for i in range(5):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'nothing', 'wait_time': 10, 'duration': 10, 'count': 1})
  
  subEvents.append({'type': 'pusher', 'wait_time': 0, 'duration': 10, 'count': 2})
  subEvents.append({'type': 'wind', 'wait_time': 10, 'duration':3, 'warn': 5})
  subEvents.append({'type': 'pusher', 'wait_time': 0, 'duration': 10, 'count': 2})
  subEvents.append({'type': 'wind', 'wait_time': 10, 'duration':3, 'warn': 5})
  subEvents.append({'type': 'pusher', 'wait_time': 0, 'duration': 10, 'count': 2})
  subEvents.append({'type': 'wind', 'wait_time': 10, 'duration':3, 'warn': 5})
  subEvents.append({'type': 'nothing', 'wait_time': 10, 'duration': 10, 'count': 1})
  
  subEvents.append({'type': 'pusher', 'wait_time': 0, 'duration': 10, 'count': 2})
  subEvents.append({'type': 'wind', 'wait_time': 10, 'duration':3, 'warn': 5})
  for i in range(5):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'pusher', 'wait_time': 0, 'duration': 10, 'count': 2})
  subEvents.append({'type': 'wind', 'wait_time': 10, 'duration':3, 'warn': 5})
  for i in range(10):
    subEvents.append({'type': 'cannon', 'wait_time': 1, 'count': 1 + (i%4)});
  subEvents.append({'type': 'nothing', 'wait_time': 20, 'duration': 20, 'count': 1})

func _ready():
  fill_events_for_first_level()
  eventTimer.connect('timeout', start_next_event);
  subEventTimer.connect('timeout', start_next_subevent);
  for player: GDPlayer in get_node('Players').get_children():
    scores[player.name] = 0 
    player.connect('body_shape_entered', player_body_entered.bind(player));
    player.game = self;
  start_next_event();
  start_next_subevent();

var last_player_hit = 0;
var player_hit_cooldown = 0.2;
func player_body_entered(body_rid: RID, node: Node, body_shape_idx: int, local_idx: int, player: GDPlayer):
  if node is GDPlayer:
    if last_player_hit < 0:
      get_node('PlayerPlayerHitSound').play();
      var otherPlayer: GDPlayer = node;
      player.incrementPukeMeter();
      otherPlayer.incrementPukeMeter();
      if eventIdx != -1 and eventIdx < events.size() and events[eventIdx]['type'] == 'chase':
        last_player_hit = player_hit_cooldown;
        for p in scores:
          if p != playerTurn.name:
            scores[p] += 1
        score_left_for_next_event -= 1
        playerTurn.get_node('Ring').hide();
        hud.on_score_updated(self);
        if score_left_for_next_event == 0:
          start_next_event()
        else:
          if otherPlayer == playerTurn:
            playerTurn = player;
          else:
            playerTurn = otherPlayer;
          playerTurn.get_node('Ring').show();
          player_score_change.emit();
  elif node is GDSnowball:
    get_node('PlayerSnowballHitSound').play();
    node.queue_free();
    player.incrementPukeMeter(0.3);
    player.freeze();
  else:
    player.incrementPukeMeter(0.6);
    player.get_node('PlayerEnvironmentHitSound').play();

func remove_pushers(timer: Timer):
  var pusherInstances = get_node('EventNodes/Pushers');
  for child in pusherInstances.get_children():
    child.queue_free();
  timer.queue_free();

func start_pushers(event: Dictionary):
  spawn_pushers(event['count']);
  var timer: Timer = Timer.new();
  timer.set_wait_time(event['duration']);
  timer.connect('timeout', remove_pushers.bind(timer));
  add_child(timer);
  timer.start();

func start_next_subevent():
  if subEventIdx < subEvents.size():
    subEventIdx += 1
  if subEventIdx < subEvents.size():
    match subEvents[subEventIdx]['type']:
      'wind':
        wind.start_wind(subEvents[subEventIdx]['warn'], subEvents[subEventIdx]['duration']);
      'pusher':
        start_pushers(subEvents[subEventIdx])
      'nothing':
        pass
      'cannon':
        fire_cannon(subEvents[subEventIdx]['count']);
      _:
        assert(false, 'unhandled event type!');
    if subEvents[subEventIdx]['wait_time'] == 0:
      start_next_subevent();
    else:
      subEventTimer.set_wait_time(subEvents[subEventIdx]['wait_time']);
      subEventTimer.start();

func start_next_event():
  if eventIdx < events.size():
    eventIdx += 1
  if eventIdx < events.size():
    match events[eventIdx]['type']:
      'chase':
        for child in get_node('EventNodes/Checkpoints').get_children():
          child.queue_free();
        playerTurn = get_node('Players').get_child(0);
        playerTurn.get_node('Ring').show();
        var otherPlayer = get_node('Players').get_child(1);
        if events[eventIdx]['duration'] > 0:
          eventTimer.set_wait_time(events[eventIdx]['duration']);
          eventTimer.start();
        score_left_for_next_event = events[eventIdx]['score']
      'checkpoint':
        # TODO: remove red circle from other player
        playerTurn.get_node('Ring').hide();
        playerTurn = null;
        assert(events[eventIdx]['duration'] > 0, 'checkpoint duration should be positive');
        spawn_new_checkpoint();
        eventTimer.set_wait_time(events[eventIdx]['duration']);
        eventTimer.start();
      _:
        assert(false);
  else:
    if playerTurn:
      playerTurn.get_node('Ring').hide();
    playerTurn = null;

func fire_cannon(count: int):
  var cannons = get_node('EventData/Cannons').get_children();
  cannons.shuffle();
  for i in range(count):
    var cannon: GDCannon = cannons[i];
    cannon.fire();
  
func spawn_pushers(count: int):
  var pusherMarkers = get_node('EventData/Pushers');
  var children = pusherMarkers.get_children();
  children.shuffle();
  var pusherInstances = get_node('EventNodes/Pushers');
  for i in range(count):
    var pusher: Node2D = PusherScene.instantiate();
    pusher.transform = children[i].transform;
    pusherInstances.add_child(pusher);

func spawn_new_checkpoint():
  var checkpoints = get_node('EventData/Checkpoints');
  var idx = rng.randi_range(0, checkpoints.get_child_count() - 2);
  if idx >= last_checkpoint_idx:
    idx += 1
  last_checkpoint_idx = idx;
  var checkpoint: Node2D = CheckpointScene.instantiate();
  checkpoint.connect('body_entered', on_checkpoint_hit.bind(checkpoint))
  checkpoint.transform = checkpoints.get_child(idx).transform;
  get_node('EventNodes/Checkpoints').call_deferred('add_child', checkpoint);
  last_checkpoint_score = 0;

func on_checkpoint_hit(player: Node, checkpoint: Node):
  if last_checkpoint_score < checkpoint_score_cooldown:
    return
  last_checkpoint_score = 0;
  scores[player.name] += 1;
  hud.on_score_updated(self);
  checkpoint.queue_free();
  spawn_new_checkpoint();

func _process(delta: float):
  last_checkpoint_score += delta;
  last_player_hit -= delta;

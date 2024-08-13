extends Panel
@onready var message_label = $VBoxContainer/MessageLabel

# Learnings
# get_remote_sender_id does not return the same value per client
# You cannot make multipla

var server_address = "localhost";
var packet = {};
var thread: Thread = Thread.new();
var mutex: Mutex = Mutex.new();

var info = {
		"count": 0,
		"sender": randi()
	};

func _ready():
	_set_data("info", info);
	multiplayer.server_disconnected.connect(_server_disconnected);
	thread.start(thread_loop);
	
func _exit_tree():
	thread.free();
	
func _set_data(key, value):
	mutex.lock();
	packet[key] = value;
	mutex.unlock();
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		info["count"] += 1;
		_set_data("info", info);
		
func thread_loop():
	mutex.lock()
	var serialized = var_to_str(packet);
	mutex.unlock();
	
	_get_packet.rpc_id(1,serialized);

@rpc("any_peer")
func _get_packet(packet):
	var data = str_to_var(packet);
	print(str(multiplayer.get_unique_id()) + ": Recieved " + str(data) + " from " + str(multiplayer.get_remote_sender_id()))

func _server_disconnected():
	message_label.text = "Disconnected";

func _on_host_button_pressed():
	message_label.text = "Creating Server";
	
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_server(5656);
	if error != OK:
		message_label.text = "Error: " + str(error.message_text);
		return;
	
	multiplayer.multiplayer_peer = peer;
	message_label.text = "";
	
	message_label.text = "Hosting";

func _on_join_container_pressed():
	message_label.text = "Connecting to Server " + server_address
	
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(server_address, 5656);
	if error != OK:
		message_label.text = "Error: " + str(error);
		return;
		
	multiplayer.multiplayer_peer = peer;
	message_label.text = "Connected to Server";

func _on_server_address_edit_text_changed(new_text):
	server_address = new_text;

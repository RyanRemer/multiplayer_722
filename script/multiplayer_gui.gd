extends Panel
@onready var message_label = $VBoxContainer/MessageLabel

var server_address = "localhost";
var packet = {
	"count" : 0,
}

func _ready():
	packet["sender"] = randi();
	multiplayer.server_disconnected.connect(_server_disconnected);
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		packet["count"] += 1;
		var serialize = var_to_str(packet);
		_get_packet.rpc_id(1, serialize);

@rpc("any_peer")
func _get_packet(packet):
	var data = str_to_var(packet);
	print(str(multiplayer.get_unique_id()) + ": Recieved " + str(data) + " from " + str(multiplayer.get_remote_sender_id()))
	print(multiplayer.get_peers())

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

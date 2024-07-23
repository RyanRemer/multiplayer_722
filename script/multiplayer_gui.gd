extends Panel
@onready var message_label = $VBoxContainer/MessageLabel

var server_address = "localhost";

func _ready():
	multiplayer.server_disconnected.connect(_server_disconnected);

func _server_disconnected():
	message_label.text = "Disconnected";

func _on_host_button_pressed():
	message_label.text = "Creating Server";
	
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_server(5656);
	if error != OK:
		message_label.text = "Error: " + error.message_text;
	
	multiplayer.multiplayer_peer = peer;
	message_label.text = "";
	
	message_label.text = "Hosting";

func _on_join_container_pressed():
	message_label.text = "Connecting to Server " + server_address
	
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(server_address, 5656);
	if error != OK:
		message_label.text = "Error: " + error.message_text;
		
	multiplayer.multiplayer_peer = peer;
	message_label.text = "Connected to Server";

func _on_server_address_edit_text_changed(new_text):
	server_address = new_text;

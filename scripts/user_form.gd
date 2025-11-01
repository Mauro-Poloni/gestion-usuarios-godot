extends Control

var UserManagerScript = preload("res://scripts/UserManager.gd")
var user_manager
var edit_mode = false
var edit_id = -1

# Usar onready para evitar errores
@onready var title = get_node_or_null("VBoxContainer/TitleLabel")
@onready var name_input = get_node_or_null("VBoxContainer/NameInput")
@onready var lastname_input = get_node_or_null("VBoxContainer/LastNameInput")
@onready var dni_input = get_node_or_null("VBoxContainer/DNIInput")
@onready var error_label = get_node_or_null("VBoxContainer/ErrorLabel")
@onready var save_btn = get_node_or_null("VBoxContainer/HBoxContainer/SaveButton")
@onready var cancel_btn = get_node_or_null("VBoxContainer/HBoxContainer/CancelButton")

func _ready():
	user_manager = UserManagerScript.new()
	add_child(user_manager)
	
	# Verificar que los nodos existen
	if not save_btn:
		print("ERROR: SaveButton no encontrado")
		return
	if not cancel_btn:
		print("ERROR: CancelButton no encontrado")
		return
	
	save_btn.pressed.connect(_on_save)
	cancel_btn.pressed.connect(_on_cancel)
	
	if error_label:
		error_label.visible = false
	
	if get_tree().root.has_meta("edit_user_id"):
		edit_mode = true
		edit_id = get_tree().root.get_meta("edit_user_id")
		get_tree().root.remove_meta("edit_user_id")
		load_user()
	else:
		if title:
			title.text = "Agregar Usuario"

func load_user():
	if title:
		title.text = "Editar Usuario"
	var user = user_manager.get_user_by_id(edit_id)
	if user:
		if name_input:
			name_input.text = user.nombre
		if lastname_input:
			lastname_input.text = user.apellido
		if dni_input:
			dni_input.text = user.dni

func _on_save():
	if not name_input or not lastname_input or not dni_input:
		print("ERROR: Faltan inputs")
		return
		
	var nombre = name_input.text.strip_edges()
	var apellido = lastname_input.text.strip_edges()
	var dni = dni_input.text.strip_edges()
	
	if nombre.is_empty():
		show_error("Nombre obligatorio")
		return
	if apellido.is_empty():
		show_error("Apellido obligatorio")
		return
	if dni.is_empty():
		show_error("DNI obligatorio")
		return
	
	var success = false
	if edit_mode:
		success = user_manager.update_user(edit_id, nombre, apellido, dni)
	else:
		success = user_manager.add_user(nombre, apellido, dni)
	
	print("Guardado exitoso: ", success)
	
	if success:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		show_error("DNI ya existe")

func _on_cancel():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func show_error(msg: String):
	if error_label:
		error_label.text = msg
		error_label.visible = true

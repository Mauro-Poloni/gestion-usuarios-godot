extends Control

var UserManagerScript = preload("res://scripts/UserManager.gd")
var user_manager

@onready var user_list = $VBoxContainer/ScrollContainer/UserList
@onready var add_button = $VBoxContainer/AddButton

var confirm_dialog: ConfirmationDialog
var pending_delete_id: int = -1  # Guarda el id del usuario a eliminar


func _ready():
	user_manager = UserManagerScript.new()
	add_child(user_manager)
	add_button.pressed.connect(_on_add_pressed)

	# Crear y configurar el diálogo de confirmación
	confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Confirmar eliminación"
	confirm_dialog.dialog_text = "¿Estás seguro de que deseas eliminar este usuario?"
	add_child(confirm_dialog)

	# Configurar botones
	confirm_dialog.get_ok_button().text = "Confirmar"
	confirm_dialog.get_cancel_button().text = "Cancelar"

	# Conectar evento de confirmación
	confirm_dialog.confirmed.connect(_on_confirm_delete)

	# Configuración visual mínima
	confirm_dialog.transient = true
	confirm_dialog.min_size = Vector2(300, 150)

	# Ajustar tamaño dinámicamente
	_make_dialog_responsive()
	get_viewport().size_changed.connect(_make_dialog_responsive)

	mostrar_usuarios()


func _make_dialog_responsive():
	# Dimensiones del viewport actual
	var viewport_size = get_viewport_rect().size

	# Tamaño relativo (60% ancho, 30% alto)
	var dialog_width = viewport_size.x * 0.6
	var dialog_height = viewport_size.y * 0.3

	# Limitar tamaños razonables
	dialog_width = clamp(dialog_width, 280.0, 600.0)
	dialog_height = clamp(dialog_height, 150.0, 400.0)

	# Aplicar tamaño
	confirm_dialog.size = Vector2(dialog_width, dialog_height)

	# Si ya está visible, recentrarlo
	if confirm_dialog.visible:
		confirm_dialog.popup_centered(Vector2(dialog_width, dialog_height))


func mostrar_usuarios():
	# Limpiar lista
	for child in user_list.get_children():
		child.queue_free()
	
	var users = user_manager.get_all_users()
	
	if users.is_empty():
		var label = Label.new()
		label.text = "No hay usuarios"
		user_list.add_child(label)
		return
	
	for user in users:
		var label = Label.new()
		label.text = user.nombre + " " + user.apellido + " - DNI: " + user.dni
		label.add_theme_font_size_override("font_size", 20)
		user_list.add_child(label)
		
		var hbox = HBoxContainer.new()
		user_list.add_child(hbox)
		
		var btn_editar = Button.new()
		btn_editar.text = "Editar"
		btn_editar.pressed.connect(_on_edit.bind(user.id))
		hbox.add_child(btn_editar)
		
		var btn_eliminar = Button.new()
		btn_eliminar.text = "Eliminar"
		btn_eliminar.pressed.connect(_on_delete.bind(user.id))
		hbox.add_child(btn_eliminar)
		
		var separator = HSeparator.new()
		user_list.add_child(separator)


func _on_add_pressed():
	get_tree().change_scene_to_file("res://scenes/user_form.tscn")


func _on_edit(user_id: int):
	get_tree().root.set_meta("edit_user_id", user_id)
	get_tree().change_scene_to_file("res://scenes/user_form.tscn")


func _on_delete(user_id: int):
	pending_delete_id = user_id
	if confirm_dialog:
		_make_dialog_responsive() # Asegura que el tamaño esté actualizado
		confirm_dialog.popup_centered()  # Mostrar confirmación


func _on_confirm_delete():
	if pending_delete_id != -1:
		user_manager.delete_user(pending_delete_id)
		pending_delete_id = -1
		mostrar_usuarios()

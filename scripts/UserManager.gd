extends Node
# Este script maneja TODOS los usuarios (como un Controller en Laravel)

# Array que almacena todos los usuarios (como una tabla MySQL)
var users = []

# Ruta del archivo donde guardamos los datos
var data_path = "res://data/users.json"

func _ready():
	# Se ejecuta al iniciar (como __construct en PHP)
	load_users()

# Cargar usuarios desde archivo
func load_users():
	var file = FileAccess.open(data_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			users = json.data
		file.close()
	else:
		users = []

# Guardar usuarios en archivo
func save_users():
	var file = FileAccess.open(data_path, FileAccess.WRITE)
	var json_string = JSON.stringify(users)
	file.store_string(json_string)
	file.close()

# CREATE: Agregar usuario
func add_user(nombre: String, apellido: String, dni: String) -> bool:
	for user in users:
		if user.dni == dni:
			return false
	
	var new_user = {
		"id": generate_id(),
		"nombre": nombre,
		"apellido": apellido,
		"dni": dni
	}
	users.append(new_user)
	save_users()
	return true

# READ: Obtener todos los usuarios
func get_all_users() -> Array:
	return users

# READ: Obtener un usuario por ID
func get_user_by_id(id: int):
	for user in users:
		if user.id == id:
			return user
	return null

# UPDATE: Actualizar usuario
func update_user(id: int, nombre: String, apellido: String, dni: String) -> bool:
	for i in range(users.size()):
		if users[i].id == id:
			for user in users:
				if user.dni == dni and user.id != id:
					return false
			
			users[i].nombre = nombre
			users[i].apellido = apellido
			users[i].dni = dni
			save_users()
			return true
	return false

# DELETE: Eliminar usuario
func delete_user(id: int) -> bool:
	for i in range(users.size()):
		if users[i].id == id:
			users.remove_at(i)
			save_users()
			return true
	return false

# Generar ID único
func generate_id() -> int:
	if users.is_empty():
		return 1
	var max_id = 0
	for user in users:
		if user.id > max_id:
			max_id = user.id
	return max_id + 1

extends PanelContainer

# Señal emitida cuando el usuario hace clic en una tecla
signal key_pressed(char: String)

@export var button_size: Vector2 = Vector2(50, 50)

# Letras y números
const KEYS = [
	"1","2","3","4","5","6","7","8","9","0",
	"Q","W","E","R","T","Y","U","I","O","P",
	"A","S","D","F","G","H","J","K","L",
	"Z","X","C","V","B","N","M",
	"←","SPACE","CLEAR"
]

func _ready():
	# Fondo y margen del teclado
	add_theme_constant_override("margin_left", 10)
	add_theme_constant_override("margin_top", 10)
	add_theme_constant_override("margin_right", 10)
	add_theme_constant_override("margin_bottom", 10)

	var grid = GridContainer.new()
	grid.columns = 10
	grid.name = "KeyboardGrid"
	add_child(grid)

	for key in KEYS:
		var btn = Button.new()
		btn.text = key
		btn.custom_minimum_size = button_size
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_key_pressed.bind(key))
		grid.add_child(btn)


func _on_key_pressed(key: String):
	match key:
		"SPACE":
			emit_signal("key_pressed", " ")
		"←":
			emit_signal("key_pressed", "BACKSPACE")
		"CLEAR":
			emit_signal("key_pressed", "CLEAR")
		_:
			emit_signal("key_pressed", key)

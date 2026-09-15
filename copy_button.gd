extends Button

const AVAILABLE_SIZES: Array[int] = [50, 100, 150]

var copies_made := 0
var target_copies := 3
var target_size := 100
var selected_size := 100
var order_complete := false

@onready var order_label: Label = $"../OrderLabel"
@onready var reduce_button: Button = $"../SizeControls/ReduceButton"
@onready var normal_button: Button = $"../SizeControls/NormalButton"
@onready var enlarge_button: Button = $"../SizeControls/EnlargeButton"

func _ready() -> void:
	pressed.connect(handle_button_press)
	reduce_button.pressed.connect(select_size.bind(50))
	normal_button.pressed.connect(select_size.bind(100))
	enlarge_button.pressed.connect(select_size.bind(150))
	update_order_text()
	update_size_buttons()

func handle_button_press() -> void:
	if order_complete:
		start_new_order()
	else:
		make_copy()

func make_copy() -> void:
	if selected_size != target_size:
		order_complete = true
		order_label.text = "WRONG SIZE! PAPER JAM!"
		text = "NEXT ORDER"
		return

	copies_made += 1
	text = "COPIES MADE: %d" % copies_made

	if copies_made >= target_copies:
		order_complete = true
		order_label.text = "ORDER COMPLETE!"
		text = "NEXT ORDER"

func start_new_order() -> void:
	copies_made = 0
	target_copies = randi_range(1, 5)
	target_size = AVAILABLE_SIZES.pick_random()
	selected_size = 100
	order_complete = false
	text = "MAKE COPY"
	update_order_text()
	update_size_buttons()

func update_order_text() -> void:
	var copy_word := "COPY" if target_copies == 1 else "COPIES"
	order_label.text = "ORDER: %d %s AT %d%%" % [
		target_copies,
		copy_word,
		target_size
	]

func select_size(new_size: int) -> void:
	selected_size = new_size
	update_size_buttons()

func update_size_buttons() -> void:
	reduce_button.text = "[50%]" if selected_size == 50 else "50%"
	normal_button.text = "[100%]" if selected_size == 100 else "100%"
	enlarge_button.text = "[150%]" if selected_size == 150 else "150%"

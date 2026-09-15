extends Control

const DOCUMENTS: Array[String] = ["MEMO", "INVOICE", "PHOTO"]
const SIZES: Array[int] = [50, 100, 150]
const FINISHES: Array[String] = ["NONE", "STAMP", "STAPLE"]
const MAX_TONER := 8
const TOTAL_ORDERS := 6
const COPIER_READY := preload("res://art/copier-workstation-clean-night-01-v2.png")
const COPIER_TONER_EMPTY := preload("res://art/copier-workstation-toner-empty-night-01-v1.png")

var order_number := 1
var score := 0
var completed_orders := 0
var failed_orders := 0
var toner := MAX_TONER
var copies_made := 0
var target_document := "MEMO"
var target_size := 100
var target_finish := "NONE"
var target_copies := 2
var selected_document := "MEMO"
var selected_size := 100
var selected_finish := "NONE"
var awaiting_next_order := false
var shift_finished := false
var machine_busy := false

@onready var shift_label: Label = %ShiftLabel
@onready var order_counter: Label = %OrderCounter
@onready var score_label: Label = %ScoreLabel
@onready var toner_label: Label = %TonerLabel
@onready var toner_bar: ProgressBar = %TonerBar
@onready var order_title: Label = %OrderTitle
@onready var order_details: Label = %OrderDetails
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel
@onready var copier_art: TextureRect = %CopierArt
@onready var scanner_glow: Node2D = %ScannerGlow
@onready var scanner_sweep: TextureRect = %ScannerSweep
@onready var scan_sound: AudioStreamPlayer = %ScanSound
@onready var machine_status: Label = %MachineStatus
@onready var document_preview: Label = %DocumentPreview
@onready var output_paper: Panel = %OutputPaper
@onready var copy_lines: Label = %CopyLines
@onready var machine_panel: Panel = %MachinePanel
@onready var document_label: Label = %DocumentLabel
@onready var size_label: Label = %SizeLabel
@onready var finish_label: Label = %FinishLabel
@onready var hint_label: Label = %HintLabel
@onready var footer_label: Label = %Footer
@onready var memo_button: Button = %MemoButton
@onready var invoice_button: Button = %InvoiceButton
@onready var photo_button: Button = %PhotoButton
@onready var reduce_button: Button = %ReduceButton
@onready var normal_button: Button = %NormalButton
@onready var enlarge_button: Button = %EnlargeButton
@onready var none_button: Button = %NoneButton
@onready var stamp_button: Button = %StampButton
@onready var staple_button: Button = %StapleButton
@onready var copy_button: Button = %CopyButton
@onready var replace_toner_button: Button = %ReplaceTonerButton
@onready var exit_station_button: Button = %ExitStationButton
@onready var shift_overlay: Control = %ShiftOverlay
@onready var shift_complete_label: Label = %ShiftComplete
@onready var summary_label: Label = %SummaryLabel
@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	randomize()
	memo_button.pressed.connect(_select_document.bind("MEMO"))
	invoice_button.pressed.connect(_select_document.bind("INVOICE"))
	photo_button.pressed.connect(_select_document.bind("PHOTO"))
	reduce_button.pressed.connect(_select_size.bind(50))
	normal_button.pressed.connect(_select_size.bind(100))
	enlarge_button.pressed.connect(_select_size.bind(150))
	none_button.pressed.connect(_select_finish.bind("NONE"))
	stamp_button.pressed.connect(_select_finish.bind("STAMP"))
	staple_button.pressed.connect(_select_finish.bind("STAPLE"))
	copy_button.pressed.connect(_on_copy_pressed)
	replace_toner_button.pressed.connect(_replace_toner)
	restart_button.pressed.connect(_restart_shift)
	exit_station_button.pressed.connect(_exit_station)
	output_paper.modulate.a = 0.0
	shift_overlay.visible = false
	_refresh_localized_static_text()
	_refresh_everything()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_exit_station()


func _exit_station() -> void:
	if machine_busy:
		return
	get_tree().change_scene_to_file("res://station_select.tscn")


func _refresh_localized_static_text() -> void:
	shift_label.text = Locale.text("shift_location")
	document_label.text = Locale.text("select_document")
	size_label.text = Locale.text("select_size")
	finish_label.text = Locale.text("select_finish")
	hint_label.text = Locale.text("hint")
	footer_label.text = Locale.text("footer")
	machine_status.text = Locale.text("machine_status")
	copy_lines.text = "%s\n-------\n-------\n----\n-------" % Locale.text("output_copy")
	status_label.text = Locale.text("status_check")
	replace_toner_button.text = Locale.text("replace_toner")
	exit_station_button.text = Locale.text("station_exit")
	shift_complete_label.text = Locale.text("shift_complete")
	restart_button.text = Locale.text("restart_shift")


func _select_document(new_document: String) -> void:
	if awaiting_next_order or shift_finished:
		return
	selected_document = new_document
	document_preview.text = _document_preview_text(new_document)
	_refresh_selection_buttons()


func _select_size(new_size: int) -> void:
	if awaiting_next_order or shift_finished:
		return
	selected_size = new_size
	_refresh_selection_buttons()


func _select_finish(new_finish: String) -> void:
	if awaiting_next_order or shift_finished:
		return
	selected_finish = new_finish
	_refresh_selection_buttons()


func _on_copy_pressed() -> void:
	if shift_finished or machine_busy:
		return
	if awaiting_next_order:
		if order_number >= TOTAL_ORDERS:
			_finish_shift()
		else:
			order_number += 1
			_start_new_order()
		return
	if toner <= 0:
		status_label.text = Locale.text("status_toner_empty")
		status_label.modulate = Color("ffcf5c")
		_update_machine_display()
		_flash_machine(Color("ffcf5c"))
		return

	toner -= 1
	_update_header()
	_update_machine_display()
	machine_busy = true
	copy_button.disabled = true
	exit_station_button.disabled = true
	_set_option_buttons_disabled(true)
	await _animate_scanner()
	machine_busy = false
	copy_button.disabled = false
	exit_station_button.disabled = false
	_set_option_buttons_disabled(false)
	if not _settings_match_order():
		_fail_order()
		return
	copies_made += 1
	progress_label.text = Locale.text("copies_progress") % [copies_made, target_copies]
	status_label.text = Locale.text("status_copy_ok")
	status_label.modulate = Color("71f7c4")
	_animate_paper(true)
	if copies_made >= target_copies:
		completed_orders += 1
		score += 100
		awaiting_next_order = true
		status_label.text = Locale.text("status_order_complete")
		copy_button.text = _next_action_text()
		_set_option_buttons_disabled(true)
		_update_header()


func _settings_match_order() -> bool:
	return selected_document == target_document and selected_size == target_size and selected_finish == target_finish


func _fail_order() -> void:
	failed_orders += 1
	score = maxi(0, score - 25)
	awaiting_next_order = true
	status_label.text = Locale.text("status_wrong")
	status_label.modulate = Color("ff6b9d")
	copy_button.text = _next_action_text()
	_set_option_buttons_disabled(true)
	_animate_paper(false)
	_flash_machine(Color("ff4f87"))
	_update_header()


func _next_action_text() -> String:
	return Locale.text("end_shift") if order_number >= TOTAL_ORDERS else Locale.text("next_order")


func _start_new_order() -> void:
	copies_made = 0
	target_document = DOCUMENTS.pick_random()
	target_size = SIZES.pick_random()
	target_finish = FINISHES.pick_random()
	target_copies = randi_range(1, 4)
	selected_document = "MEMO"
	selected_size = 100
	selected_finish = "NONE"
	awaiting_next_order = false
	copy_button.text = Locale.text("make_copy")
	status_label.text = Locale.text("status_check")
	status_label.modulate = Color("b8c0d9")
	document_preview.text = _document_preview_text(selected_document)
	_set_option_buttons_disabled(false)
	_refresh_everything()


func _replace_toner() -> void:
	toner = MAX_TONER
	status_label.text = Locale.text("status_new_toner")
	status_label.modulate = Color("71f7c4")
	_update_machine_display()
	_update_header()


func _restart_shift() -> void:
	order_number = 1
	score = 0
	completed_orders = 0
	failed_orders = 0
	toner = MAX_TONER
	shift_finished = false
	machine_busy = false
	shift_overlay.visible = false
	scanner_glow.visible = false
	target_document = "MEMO"
	target_size = 100
	target_finish = "NONE"
	target_copies = 2
	selected_document = "MEMO"
	selected_size = 100
	selected_finish = "NONE"
	copies_made = 0
	awaiting_next_order = false
	copy_button.text = Locale.text("make_copy")
	status_label.text = Locale.text("status_check")
	status_label.modulate = Color("b8c0d9")
	document_preview.text = _document_preview_text(selected_document)
	_set_option_buttons_disabled(false)
	_refresh_everything()


func _finish_shift() -> void:
	shift_finished = true
	summary_label.text = Locale.text("summary") % [score, completed_orders, failed_orders, _summary_verdict()]
	shift_overlay.visible = true


func _summary_verdict() -> String:
	if completed_orders >= 5:
		return Locale.text("verdict_great")
	if completed_orders >= 3:
		return Locale.text("verdict_ok")
	return Locale.text("verdict_bad")


func _refresh_everything() -> void:
	_update_order_card()
	_update_header()
	_update_machine_display()
	_refresh_selection_buttons()
	progress_label.text = Locale.text("copies_progress") % [copies_made, target_copies]
	document_preview.text = _document_preview_text(selected_document)
	if not awaiting_next_order:
		copy_button.text = Locale.text("make_copy")


func _update_order_card() -> void:
	order_title.text = Locale.text("order_title") % order_number
	var copy_word: String = Locale.text("copy_singular") if target_copies == 1 else Locale.text("copy_plural")
	order_details.text = Locale.text("order_details") % [target_copies, copy_word, Locale.document_name(target_document), target_size, Locale.finish_name(target_finish)]


func _update_header() -> void:
	order_counter.text = Locale.text("order_counter") % [order_number, TOTAL_ORDERS]
	score_label.text = Locale.text("score") % score
	toner_label.text = Locale.text("toner") % [toner, MAX_TONER]
	toner_bar.max_value = MAX_TONER
	toner_bar.value = toner
	replace_toner_button.disabled = toner > 0 or awaiting_next_order or shift_finished


func _update_machine_display() -> void:
	copier_art.texture = COPIER_TONER_EMPTY if toner <= 0 else COPIER_READY


func _refresh_selection_buttons() -> void:
	_set_selected_button(memo_button, selected_document == "MEMO", Locale.document_name("MEMO"))
	_set_selected_button(invoice_button, selected_document == "INVOICE", Locale.document_name("INVOICE"))
	_set_selected_button(photo_button, selected_document == "PHOTO", Locale.document_name("PHOTO"))
	_set_selected_button(reduce_button, selected_size == 50, "50%")
	_set_selected_button(normal_button, selected_size == 100, "100%")
	_set_selected_button(enlarge_button, selected_size == 150, "150%")
	_set_selected_button(none_button, selected_finish == "NONE", Locale.finish_name("NONE"))
	_set_selected_button(stamp_button, selected_finish == "STAMP", Locale.finish_name("STAMP"))
	_set_selected_button(staple_button, selected_finish == "STAPLE", Locale.finish_name("STAPLE"))


func _set_selected_button(button: Button, selected: bool, label: String) -> void:
	button.text = "[ %s ]" % label if selected else label
	button.modulate = Color("71f7c4") if selected else Color.WHITE


func _set_option_buttons_disabled(disabled: bool) -> void:
	for button: Button in [memo_button, invoice_button, photo_button, reduce_button, normal_button, enlarge_button, none_button, stamp_button, staple_button]:
		button.disabled = disabled


func _document_preview_text(document: String) -> String:
	match document:
		"INVOICE":
			return Locale.text("preview_invoice")
		"PHOTO":
			return Locale.text("preview_photo")
		_:
			return Locale.text("preview_memo")


func _animate_paper(success: bool) -> void:
	output_paper.visible = true
	output_paper.position = Vector2(154, 377)
	output_paper.modulate = Color.WHITE if success else Color("ff6b9d")
	output_paper.modulate.a = 1.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(output_paper, "position:y", 452.0, 0.42).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(output_paper, "modulate:a", 0.0, 0.42).set_delay(0.18)
	tween.chain().tween_callback(func() -> void: output_paper.visible = false)


func _animate_scanner() -> void:
	scanner_glow.visible = true
	scanner_glow.modulate.a = 0.0
	scanner_sweep.position = Vector2(110, 190)
	scan_sound.play()
	var fade_in := create_tween()
	fade_in.tween_property(scanner_glow, "modulate:a", 1.0, 0.08)
	await fade_in.finished
	var sweep := create_tween()
	sweep.tween_property(scanner_sweep, "position:x", 322.0, 0.95).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await sweep.finished
	var fade_out := create_tween()
	fade_out.tween_property(scanner_glow, "modulate:a", 0.0, 0.20)
	await fade_out.finished
	scanner_glow.visible = false


func _flash_machine(flash_color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(machine_panel, "modulate", flash_color, 0.06)
	tween.tween_property(machine_panel, "modulate", Color.WHITE, 0.08)
	tween.tween_property(machine_panel, "modulate", flash_color, 0.06)
	tween.tween_property(machine_panel, "modulate", Color.WHITE, 0.12)

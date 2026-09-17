extends Control

const TOTAL_ORDERS := 6
const SCISSORS_LIMIT := 5
const TOOL_SCISSORS := "scissors"
const TOOL_GUILLOTINE := "guillotine"

var order_number := 1
var score := 0
var completed_orders := 0
var failed_orders := 0
var target_sheets := 3
var awaiting_next_order := false
var shift_finished := false
var machine_busy := false

@onready var shift_label: Label = %ShiftLabel
@onready var order_counter: Label = %OrderCounter
@onready var score_label: Label = %ScoreLabel
@onready var rule_label: Label = %TonerLabel
@onready var rule_bar: ProgressBar = %TonerBar
@onready var order_title: Label = %OrderTitle
@onready var order_details: Label = %OrderDetails
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel
@onready var cutter_art: TextureRect = %CopierArt
@onready var machine_panel: Panel = %MachinePanel
@onready var machine_status: Label = %MachineStatus
@onready var instruction_label: Label = %DocumentLabel
@onready var scissors_button: Button = %MemoButton
@onready var guillotine_button: Button = %InvoiceButton
@onready var unused_tool_button: Button = %PhotoButton
@onready var next_button: Button = %CopyButton
@onready var replace_toner_button: Button = %ReplaceTonerButton
@onready var hint_label: Label = %HintLabel
@onready var footer_label: Label = %Footer
@onready var exit_station_button: Button = %ExitStationButton
@onready var shift_overlay: Control = %ShiftOverlay
@onready var shift_complete_label: Label = %ShiftComplete
@onready var summary_label: Label = %SummaryLabel
@onready var restart_button: Button = %RestartButton

@onready var machine_brand: Label = $MainMargin/AppVBox/GameArea/MachinePanel/MachineBrand
@onready var top_unit: Control = $MainMargin/AppVBox/GameArea/MachinePanel/TopUnit
@onready var lid: Control = $MainMargin/AppVBox/GameArea/MachinePanel/Lid
@onready var body: Control = $MainMargin/AppVBox/GameArea/MachinePanel/Body
@onready var scanner_glow: Node2D = %ScannerGlow
@onready var output_paper: Control = %OutputPaper
@onready var document_preview: Label = %DocumentPreview
@onready var size_label: Label = %SizeLabel
@onready var size_buttons: HBoxContainer = $MainMargin/AppVBox/GameArea/ControlPanel/ControlMargin/ControlVBox/SizeButtons
@onready var finish_label: Label = %FinishLabel
@onready var finish_buttons: HBoxContainer = $MainMargin/AppVBox/GameArea/ControlPanel/ControlMargin/ControlVBox/FinishButtons


func _ready() -> void:
	randomize()
	scissors_button.pressed.connect(_on_tool_pressed.bind(TOOL_SCISSORS))
	guillotine_button.pressed.connect(_on_tool_pressed.bind(TOOL_GUILLOTINE))
	next_button.pressed.connect(_on_next_pressed)
	restart_button.pressed.connect(_restart_shift)
	exit_station_button.pressed.connect(_exit_station)
	_prepare_copier_layout_for_cutting()
	shift_overlay.visible = false
	_refresh_localized_static_text()
	_refresh_everything()


func _prepare_copier_layout_for_cutting() -> void:
	top_unit.visible = false
	lid.visible = false
	body.visible = false
	scanner_glow.visible = false
	output_paper.visible = false
	document_preview.visible = false
	unused_tool_button.visible = false
	size_label.visible = false
	size_buttons.visible = false
	finish_label.visible = false
	finish_buttons.visible = false
	replace_toner_button.visible = false
	rule_bar.visible = false
	next_button.visible = false
	cutter_art.visible = true


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_exit_station()


func _exit_station() -> void:
	if machine_busy:
		return
	get_tree().change_scene_to_file("res://station_select.tscn")


func _refresh_localized_static_text() -> void:
	shift_label.text = Locale.text("cutting_shift_location")
	rule_label.text = Locale.text("cutting_rule")
	machine_brand.text = Locale.text("cutting_station_title")
	machine_status.text = Locale.text("cutting_machine_status")
	instruction_label.text = Locale.text("cutting_instruction")
	scissors_button.text = Locale.text("cutting_scissors")
	guillotine_button.text = Locale.text("cutting_guillotine")
	hint_label.text = Locale.text("cutting_hint")
	footer_label.text = Locale.text("cutting_footer")
	exit_station_button.text = Locale.text("station_exit")
	shift_complete_label.text = Locale.text("shift_complete")
	restart_button.text = Locale.text("restart_shift")


func _on_tool_pressed(tool: String) -> void:
	if shift_finished or machine_busy or awaiting_next_order:
		return
	machine_busy = true
	_set_tool_buttons_disabled(true)
	exit_station_button.disabled = true
	await _animate_cut(tool)
	machine_busy = false
	exit_station_button.disabled = false

	if tool != _required_tool():
		_fail_order()
		return

	completed_orders += 1
	score += 100
	awaiting_next_order = true
	progress_label.text = Locale.text("cutting_progress") % [target_sheets, target_sheets]
	status_label.text = Locale.text("cutting_status_ok") % _tool_name(tool)
	status_label.modulate = Color("71f7c4")
	_update_header()
	await get_tree().create_timer(0.2).timeout
	status_label.text = Locale.text("cutting_status_complete")
	_show_next_button()


func _on_next_pressed() -> void:
	if not awaiting_next_order or machine_busy:
		return
	if order_number >= TOTAL_ORDERS:
		_finish_shift()
	else:
		order_number += 1
		_start_new_order()


func _required_tool() -> String:
	return TOOL_SCISSORS if target_sheets <= SCISSORS_LIMIT else TOOL_GUILLOTINE


func _tool_name(tool: String) -> String:
	return Locale.text("cutting_scissors_name") if tool == TOOL_SCISSORS else Locale.text("cutting_guillotine_name")


func _fail_order() -> void:
	failed_orders += 1
	score = maxi(0, score - 25)
	awaiting_next_order = true
	status_label.text = Locale.text("cutting_status_wrong") % [target_sheets, _tool_name(_required_tool())]
	status_label.modulate = Color("ff6b9d")
	_flash_machine(Color("ff4f87"))
	_update_header()
	_show_next_button()


func _show_next_button() -> void:
	_set_tool_buttons_disabled(true)
	next_button.visible = true
	next_button.disabled = false
	next_button.text = Locale.text("end_shift") if order_number >= TOTAL_ORDERS else Locale.text("next_order")


func _start_new_order() -> void:
	target_sheets = randi_range(1, 12)
	awaiting_next_order = false
	next_button.visible = false
	_set_tool_buttons_disabled(false)
	_refresh_everything()


func _restart_shift() -> void:
	order_number = 1
	score = 0
	completed_orders = 0
	failed_orders = 0
	target_sheets = 3
	awaiting_next_order = false
	shift_finished = false
	machine_busy = false
	shift_overlay.visible = false
	next_button.visible = false
	_set_tool_buttons_disabled(false)
	_refresh_localized_static_text()
	_refresh_everything()


func _finish_shift() -> void:
	shift_finished = true
	summary_label.text = Locale.text("cutting_summary") % [score, completed_orders, failed_orders, _summary_verdict()]
	shift_overlay.visible = true


func _summary_verdict() -> String:
	if completed_orders >= 5:
		return Locale.text("verdict_great")
	if completed_orders >= 3:
		return Locale.text("verdict_ok")
	return Locale.text("verdict_bad")


func _refresh_everything() -> void:
	_update_header()
	order_title.text = Locale.text("order_title") % order_number
	order_details.text = Locale.text("cutting_order_details") % target_sheets
	progress_label.text = Locale.text("cutting_progress") % [0, target_sheets]
	status_label.text = Locale.text("cutting_status_check")
	status_label.modulate = Color("b8c0d9")


func _update_header() -> void:
	order_counter.text = Locale.text("order_counter") % [order_number, TOTAL_ORDERS]
	score_label.text = Locale.text("score") % score


func _set_tool_buttons_disabled(disabled: bool) -> void:
	scissors_button.disabled = disabled
	guillotine_button.disabled = disabled


func _animate_cut(tool: String) -> void:
	var flash_color := Color("71f7c4") if tool == TOOL_SCISSORS else Color("ffcf5c")
	var tween := create_tween()
	tween.tween_property(cutter_art, "modulate", flash_color, 0.08)
	tween.tween_property(cutter_art, "modulate", Color.WHITE, 0.16)
	await tween.finished


func _flash_machine(flash_color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(machine_panel, "modulate", flash_color, 0.06)
	tween.tween_property(machine_panel, "modulate", Color.WHITE, 0.08)
	tween.tween_property(machine_panel, "modulate", flash_color, 0.06)
	tween.tween_property(machine_panel, "modulate", Color.WHITE, 0.12)

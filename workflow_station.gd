extends Control

@export_enum("counter", "copier", "cutting", "binding", "packaging") var station_id := "copier"

const ART := {
	"counter": preload("res://art/service-counter-clean-night-01-v3.png"),
	"copier": preload("res://art/copier-workstation-clean-night-01-v2.png"),
	"cutting": preload("res://art/guillotine-workstation-clean-night-01-v1.png"),
	"binding": preload("res://art/binding-workstation-clean-night-01-v4.png"),
	"packaging": preload("res://art/packaging-workstation-clean-night-01-v2.png")
}
const EMPTY_TONER := preload("res://art/copier-workstation-toner-empty-night-01-v1.png")
var busy := false
var document := "MEMO"
var paper_size := 100
var stamp := false
var selected_tool := "scissors"
var selected_binding := "STAPLE"
var feedback := ""
var feedback_error := false
var body: VBoxContainer
var picker: OptionButton
var detail: Label
var route: Label
var status: Label
var quantity: SpinBox
var action: Button
var refill: Button
var navigation: Button
var config_controls: Array[Control] = []
var ticket: VBoxContainer
var animation: Tween


func _ready() -> void:
	GameState.current_station = station_id
	%ShiftOverlay.hide()
	%ScannerGlow.hide()
	%OutputPaper.hide()
	%TonerBar.visible = station_id == "copier"
	%CopierArt.texture = ART[station_id]
	$MainMargin/AppVBox/GameArea/MachinePanel/MachineBrand.text = Locale.station_name(station_id)
	%ShiftLabel.text = _t("TURNO DA NOITE // ", "NIGHT SHIFT // ") + Locale.station_name(station_id)
	%MachineStatus.text = _t("OS LOTES ACOMPANHAM VOCÊ ENTRE AS BANCADAS", "BATCHES TRAVEL WITH YOU BETWEEN STATIONS")
	%MachineStatus.add_theme_font_size_override("font_size", 10)
	%Footer.text = _t("PEDIDOS → CÓPIA → CORTE* → ACABAMENTO* → EMBALAGEM → ENTREGA",
		"ORDERS → COPY → CUT* → FINISH* → PACKAGE → DELIVER")
	%Footer.add_theme_font_size_override("font_size", 10)
	%ExitStationButton.text = Locale.text("station_exit")
	%ExitStationButton.pressed.connect(_exit)
	_build_panel()
	GameState.workflow_changed.connect(_refresh)
	_refresh()


func _t(pt: String, en: String) -> String:
	return GameState.tr_pair(pt, en)


func _build_panel() -> void:
	var margin: MarginContainer = $MainMargin/AppVBox/GameArea/ControlPanel/ControlMargin
	var old: Control = margin.get_node("ControlVBox")
	margin.remove_child(old)
	old.queue_free()
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	scroll.add_child(body)
	var title := _label(Locale.station_name(station_id), 21, Color("71f7c4"))
	body.add_child(title)
	if station_id == "counter":
		ticket = VBoxContainer.new()
		ticket.add_theme_constant_override("separation", 10)
		body.add_child(ticket)
	else:
		picker = OptionButton.new()
		picker.custom_minimum_size.y = 36
		picker.fit_to_longest_item = false
		picker.item_selected.connect(_select_batch)
		body.add_child(picker)
		detail = _label("", 14)
		body.add_child(detail)
		route = _label("", 13, Color("ffcf5c"))
		body.add_child(route)
		_build_options()
	status = _label("", 13, Color("b8c0d9"))
	layout.add_child(status)
	action = _button("", _operate)
	action.add_theme_color_override("font_color", Color("71f7c4"))
	if station_id == "copier":
		var actions := HBoxContainer.new()
		layout.add_child(actions)
		action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(action)
		refill = _button(Locale.text("replace_toner").replace("\n", " "), _refill)
		actions.add_child(refill)
	else:
		layout.add_child(action)
	navigation = _button("", _navigate)
	layout.add_child(navigation)


func _label(value: String, font_size: int, color := Color("e4e9fa")) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _button(value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 42
	button.pressed.connect(callback)
	return button


func _option(caption: String, labels: Array, values: Array, selected: int, callback: Callable, target: Control = null) -> void:
	var container: Control = body if target == null else target
	container.add_child(_label(caption, 12, Color("ffcf5c")))
	var option := OptionButton.new()
	option.custom_minimum_size.y = 34
	for value: String in labels:
		option.add_item(value)
	option.select(selected)
	option.item_selected.connect(func(index: int) -> void: callback.call(values[index]))
	config_controls.append(option)
	container.add_child(option)


func _build_options() -> void:
	match station_id:
		"copier":
			var settings := HBoxContainer.new()
			settings.add_theme_constant_override("separation", 8)
			body.add_child(settings)
			var columns: Array[VBoxContainer] = []
			for i in range(3):
				var column := VBoxContainer.new()
				column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				settings.add_child(column)
				columns.append(column)
			_option(_t("DOCUMENTO", "DOCUMENT"),
				[Locale.document_name("MEMO"), Locale.document_name("INVOICE"), Locale.document_name("PHOTO")],
				["MEMO", "INVOICE", "PHOTO"], 0, func(value: String) -> void: document = value, columns[0])
			_option(_t("TAMANHO", "SIZE"), ["50%", "100%", "150%"], [50, 100, 150], 1,
				func(value: int) -> void: paper_size = value, columns[1])
			_option(_t("CARIMBO", "STAMP"),
				[Locale.finish_name("NONE"), Locale.finish_name("STAMP")], [false, true], 0,
				func(value: bool) -> void: stamp = value, columns[2])
			var row := HBoxContainer.new()
			var caption := _label(_t("FOLHAS NESTA IMPRESSÃO", "SHEETS IN THIS RUN"), 12)
			caption.custom_minimum_size.x = 220
			caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(caption)
			quantity = SpinBox.new()
			quantity.min_value = 1
			quantity.max_value = GameState.MAX_TONER
			quantity.step = 1
			quantity.allow_greater = false
			quantity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(quantity)
			body.add_child(row)
		"cutting":
			_option(Locale.text("cutting_rule"),
				[Locale.text("cutting_scissors_name"), Locale.text("cutting_guillotine_name")],
				["scissors", "guillotine"], 0, func(value: String) -> void: selected_tool = value)
		"binding":
			_option(_t("ACABAMENTO SOLICITADO", "REQUESTED FINISH"),
				[_t("GRAMPEAR", "STAPLE"), _t("ENCADERNAR", "BIND")],
				["STAPLE", "BIND"], 0, func(value: String) -> void: selected_binding = value)
			body.add_child(_label(_t("Grampo e encadernação são alternativas. Aplique apenas o acabamento solicitado.",
				"Stapling and binding are alternatives. Apply only the requested finish."), 13))
		"packaging":
			body.add_child(_label(_t("Embale cada lote após concluir todas as suas etapas.",
				"Package each batch after all its required steps are complete."), 15))


func _refresh() -> void:
	if not is_node_ready():
		return
	%OrderCounter.text = Locale.text("order_title") % GameState.order_number
	%ScoreLabel.text = Locale.text("score") % GameState.score
	if station_id == "copier":
		%TonerLabel.text = Locale.text("toner") % [GameState.toner, GameState.MAX_TONER]
		%TonerBar.max_value = GameState.MAX_TONER
		%TonerBar.value = GameState.toner
		%CopierArt.texture = EMPTY_TONER if GameState.toner == 0 else ART.copier
	else:
		%TonerLabel.text = _t("ENTREGUES: %d", "DELIVERED: %d") % GameState.delivered_orders
	if station_id == "counter":
		_refresh_counter()
	else:
		_refresh_batch()
	status.text = feedback
	if feedback.is_empty() and station_id == "counter":
		status.text = _t("Confira os lotes e receba o pedido para iniciar.", "Review the batches and accept the order to begin.")
		if not GameState.active_order.is_empty():
			status.text = _t("Embale todos os lotes para liberar a entrega.", "Package all batches to enable delivery.")
			if GameState.can_deliver():
				status.text = _t("Todos os lotes estão embalados. Pedido pronto para entrega!", "All batches are packaged. Order ready for delivery!")
	status.modulate = Color("ff6b9d") if feedback_error else Color.WHITE
	action.disabled = action.disabled or busy
	picker_disabled(busy)
	%ExitStationButton.disabled = busy


func picker_disabled(value: bool) -> void:
	if picker != null:
		picker.disabled = value
	for control: Control in config_controls:
		(control as OptionButton).disabled = value
	if quantity != null:
		quantity.editable = not value
	if refill != null:
		refill.disabled = value or GameState.toner >= GameState.MAX_TONER
	navigation.disabled = value


func _refresh_counter() -> void:
	for child in ticket.get_children():
		ticket.remove_child(child)
		child.queue_free()
	var accepted := not GameState.active_order.is_empty()
	var order: Dictionary = GameState.active_order if accepted else GameState.pending_order
	var items: Array = order.get("batches", [])
	ticket.add_child(_label(_t("PEDIDO #%02d • %d LOTES", "ORDER #%02d • %d BATCHES") %
		[GameState.order_number, items.size()], 18, Color("ff6b9d")))
	for i in range(items.size()):
		var item: Dictionary = items[i]
		var card := PanelContainer.new()
		var content := VBoxContainer.new()
		card.add_child(content)
		content.add_child(_label(_t("LOTE %d", "BATCH %d") % (i + 1), 14, Color("71f7c4")))
		content.add_child(_label(GameState.description(item), 14))
		if accepted:
			content.add_child(_label(_t("Próxima etapa: ", "Next step: ") +
				GameState.stage_name(GameState.next_stage(item)), 12, Color("ffcf5c")))
		ticket.add_child(card)
	action.text = _t("ENTREGAR PEDIDO", "DELIVER ORDER") if accepted else _t("RECEBER PEDIDO", "ACCEPT ORDER")
	action.disabled = accepted and not GameState.can_deliver()
	navigation.text = _t("IR PARA AS BANCADAS", "GO TO WORKSTATIONS")
	navigation.visible = accepted


func _refresh_batch() -> void:
	var items := GameState.batches()
	picker.clear()
	for i in range(items.size()):
		picker.add_item(_t("LOTE %d • %d FOLHAS • ", "BATCH %d • %d SHEETS • ") %
			[i + 1, items[i].quantity] + GameState.stage_name(GameState.next_stage(items[i])))
	var item := GameState.batch(GameState.selected_batch)
	if item.is_empty():
		detail.text = _t("Receba um pedido no balcão de atendimento para começar.",
			"Accept an order at the service counter to begin.")
		route.text = ""
		action.text = _t("SEM LOTE", "NO BATCH")
		action.disabled = true
		navigation.text = _t("IR AO BALCÃO", "GO TO COUNTER")
		navigation.visible = true
		return
	picker.select(GameState.selected_batch)
	detail.text = GameState.description(item)
	var stage := GameState.next_stage(item)
	route.text = _t("Impressas: %d/%d • Próxima etapa: %s", "Printed: %d/%d • Next step: %s") % [
		item.printed, item.quantity, GameState.stage_name(stage)]
	action.text = {"copier": _t("IMPRIMIR FOLHAS", "PRINT SHEETS"),
		"cutting": _t("CORTAR LOTE", "CUT BATCH"), "binding": _t("APLICAR ACABAMENTO", "APPLY FINISH"),
		"packaging": _t("EMBALAR LOTE", "PACKAGE BATCH")}.get(station_id, "")
	action.disabled = stage != station_id
	if quantity != null:
		var remaining: int = maxi(1, int(item.quantity) - int(item.printed))
		quantity.max_value = maxi(1, mini(remaining, GameState.toner))
		quantity.value = quantity.max_value
		action.disabled = action.disabled or GameState.toner == 0
	navigation.visible = true
	navigation.text = _t("VER BANCADAS", "VIEW WORKSTATIONS") if stage == station_id else (
		_t("IR PARA: ", "GO TO: ") + GameState.stage_name("counter" if stage == "done" else stage))


func _select_batch(index: int) -> void:
	if busy:
		return
	feedback = ""
	GameState.select_batch(index)


func _operate() -> void:
	if busy:
		return
	if station_id == "counter":
		var accepted := GameState.active_order.is_empty()
		var success := GameState.accept_order() if accepted else GameState.deliver_order()
		feedback = _t("Pedido recebido. Prepare os lotes nas bancadas.", "Order accepted. Prepare the batches at the workstations.") if accepted else _t("Pedido entregue! O próximo cliente já tem um pedido.", "Order delivered! The next customer has an order.")
		if not success:
			feedback = _t("Conclua e embale todos os lotes antes de entregar.", "Finish and package every batch before delivery.")
		feedback_error = not success
		_refresh()
		return
	var index := GameState.selected_batch
	var item := GameState.batch(index)
	if item.is_empty() or GameState.next_stage(item) != station_id:
		return
	busy = true
	var result := ""
	match station_id:
		"copier":
			result = GameState.print_sheets(index, document, paper_size, stamp, int(quantity.value))
		"cutting":
			result = GameState.cut_batch(index, selected_tool)
		"binding":
			result = GameState.finish_batch(index, selected_binding)
		"packaging":
			result = GameState.pack_batch(index)
	_refresh()
	if result == "ok" or result == "wrong":
		await _animate_operation()
	busy = false
	feedback_error = result != "ok"
	match result:
		"ok":
			feedback = _t("Etapa registrada. Confira o próximo destino do lote.", "Step recorded. Check the batch's next destination.")
		"wrong":
			feedback = _t("Configuração incorreta (-25). Corrija e tente novamente; o lote não avançou.",
				"Wrong setting (-25). Correct it and retry; the batch did not advance.")
		"toner":
			feedback = Locale.text("status_toner_empty")
		_:
			feedback = _t("Ação indisponível para este lote.", "Action unavailable for this batch.")
	_refresh()


func _animate_operation() -> void:
	animation = create_tween()
	if station_id == "copier":
		%ScannerGlow.show()
		%ScannerSweep.position = Vector2(110, 190)
		%ScanSound.play()
		animation.tween_property(%ScannerSweep, "position:x", 322.0, 0.7)
	else:
		animation.tween_property(%CopierArt, "modulate", Color("71f7c4"), 0.12)
		animation.tween_property(%CopierArt, "modulate", Color.WHITE, 0.2)
	await animation.finished
	%ScannerGlow.hide()


func _refill() -> void:
	if busy:
		return
	GameState.refill_toner()
	feedback = Locale.text("status_new_toner")
	feedback_error = false
	_refresh()


func _navigate() -> void:
	if busy:
		return
	var destination := "counter"
	if not GameState.active_order.is_empty():
		destination = GameState.next_stage(GameState.batch(GameState.selected_batch))
		if destination == "done":
			destination = "counter"
	if station_id == "counter" or destination == station_id:
		_exit()
	else:
		GameState.current_station = destination
		get_tree().change_scene_to_file(GameState.scene_for(destination))


func _exit() -> void:
	if not busy:
		get_tree().change_scene_to_file("res://station_select.tscn")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_exit()

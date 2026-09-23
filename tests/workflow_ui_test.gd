extends SceneTree
var state: Node
var screen: Node
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func open_station(id: String) -> void:
	if is_instance_valid(screen):
		screen.queue_free()
		await process_frame
	var packed: PackedScene = load(state.scene_for(id))
	screen = packed.instantiate()
	root.add_child(screen)
	await process_frame
	await process_frame

func _run() -> void:
	state = root.get_node("GameState")
	await open_station("counter")
	check(screen.action.text == state.tr_pair("RECEBER PEDIDO", "ACCEPT ORDER"), "Counter receives, not generates local batches")
	await screen._operate()
	check(state.batches().size() == 3, "Accept from counter UI")
	await open_station("copier")
	check(screen.config_controls.size() == 3, "Document, size, stamp only")
	for index in range(3):
		screen._select_batch(index)
		var item: Dictionary = state.batch(index)
		screen.document = item.document
		screen.paper_size = item.size
		screen.stamp = item.stamp
		while state.next_stage(item) == "copier":
			screen._refill()
			check(not screen.action.disabled, "Printing enabled")
			await screen._operate()
			check(not screen.busy, "Busy state clears after printing")
	check(state.batch(0).printed == 5 and state.batch(1).printed == 15 and state.batch(2).printed == 30, "Exact copy counts from UI")
	await open_station("cutting")
	screen._select_batch(0)
	check(screen.action.disabled, "No optional cutting for memo")
	screen._select_batch(2)
	screen.selected_tool = "guillotine"
	await screen._operate()
	check(state.batch(2).cut_done, "Cut through UI")
	await open_station("binding")
	screen._select_batch(1)
	screen.selected_binding = "STAPLE"
	await screen._operate()
	check(state.batch(1).binding_done, "Staple through binding UI")
	await open_station("packaging")
	for index in range(3):
		screen._select_batch(index)
		await screen._operate()
		check(state.batch(index).packed, "Package through UI")
	await open_station("counter")
	check(not screen.action.disabled, "Delivery enabled")
	await screen._operate()
	check(state.delivered_orders == 1 and state.active_order.is_empty(), "UI delivery completes order")
	await screen._operate()
	check(state.active_order.id == 2, "UI accepts next order")
	screen.queue_free()
	await process_frame
	root.get_node("MusicManager").stop()
	await create_timer(0.2).timeout
	print("WORKFLOW UI TESTS: ", "PASS" if failures == 0 else "FAIL")
	quit(1 if failures else 0)

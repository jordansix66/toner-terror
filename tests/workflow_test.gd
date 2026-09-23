extends SceneTree

var failures := 0
var state: Node

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func print_all(index: int) -> void:
	var item: Dictionary = state.batch(index)
	while state.next_stage(item) == "copier":
		state.refill_toner()
		var count := mini(state.toner, int(item.quantity) - int(item.printed))
		check(state.print_sheets(index, item.document, item.size, item.stamp, count) == "ok", "Print batch")

func _run() -> void:
	state = root.get_node("GameState")
	check(state.active_order.is_empty(), "No accepted order on startup")
	check(state.pack_batch(0) == "blocked", "No phantom batch")
	check(state.accept_order(), "Accept first order")
	check(not state.accept_order(), "Cannot replace in-progress order")
	check(state.batches().size() == 3, "Three example batches")
	check(not state.deliver_order(), "Reject early delivery")
	check(state.cut_batch(2, "guillotine") == "blocked", "Cannot cut before printing")
	check(state.finish_batch(1, "STAPLE") == "blocked", "Cannot staple before printing")
	check(state.print_sheets(0, "MEMO", 50, true, 6) == "quantity", "No overproduction")
	check(state.print_sheets(0, "MEMO", 100, true, 1) == "wrong", "Reject wrong settings")
	check(state.batch(0).printed == 0, "Mistake does not advance")
	check(state.print_sheets(0, "MEMO", 50, true, 2) == "ok", "Partial print")
	# Scene changes and re-entry must not reset accepted orders or partial work.
	for id: String in ["counter", "copier", "cutting", "binding", "packaging", "copier"]:
		var packed: PackedScene = load(state.scene_for(id))
		var scene: Node = packed.instantiate()
		root.add_child(scene)
		await process_frame
		check(scene.station_id == id, "Station identity: " + id)
		check(state.batch(0).printed == 2, "Persistent partial progress: " + id)
		scene.queue_free()
		await process_frame
	print_all(0)
	check(state.next_stage(state.batch(0)) == "packaging", "Skip unrequested steps")
	check(state.cut_batch(0, "scissors") == "blocked", "No unrequested cutting")
	check(state.pack_batch(0) == "ok", "Pack memo")
	check(state.pack_batch(0) == "blocked", "Cannot package twice")
	print_all(1)
	check(state.finish_batch(1, "BIND") == "wrong", "Staple excludes binding")
	check(state.pack_batch(1) == "blocked", "Cannot pack before stapling")
	check(state.finish_batch(1, "STAPLE") == "ok", "Staple at binding table")
	check(state.pack_batch(1) == "ok", "Pack invoice")
	print_all(2)
	check(state.pack_batch(2) == "blocked", "Cannot pack before cutting")
	check(state.cut_batch(2, "scissors") == "wrong", "30 sheets require guillotine")
	check(state.cut_batch(2, "guillotine") == "ok", "Cut photos")
	check(state.pack_batch(2) == "ok", "Pack photos")
	check(state.can_deliver(), "All three batches ready")
	check(state.deliver_order(), "Deliver complete order")
	check(not state.deliver_order(), "Prevent double delivery")
	check(state.delivered_orders == 1 and state.pending_order.id == 2, "Next order prepared")
	# Explicit boundaries and combined cut + binding.
	for count: int in [1, 5, 6, 30]:
		var item: Dictionary = state.make_batch("MEMO", count, 100, false, true, "BIND")
		state.active_order = {"id": 2, "batches": [item]}
		check(state.required_tool(item) == ("scissors" if count <= 5 else "guillotine"), "Tool boundary")
		print_all(0)
		check(state.finish_batch(0, "BIND") == "blocked", "Cut before binding")
		check(state.cut_batch(0, state.required_tool(item)) == "ok", "Cut boundary")
		check(state.finish_batch(0, "BIND") == "ok", "Bind after cutting")
		check(state.pack_batch(0) == "ok", "Package bound batch")
	var locale: Node = root.get_node("Locale")
	locale.current_language = "en"
	check("copies" in state.description(state.batch(0)), "English description")
	print("WORKFLOW TESTS: ", "PASS" if failures == 0 else "FAIL (%d)" % failures)
	await create_timer(0.5).timeout
	root.get_node("MusicManager").stop()
	await process_frame
	quit(1 if failures else 0)

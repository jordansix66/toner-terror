extends Node

signal workflow_changed

const MAX_TONER := 8
const SCISSORS_LIMIT := 5
var current_station := "counter"
var order_number := 1
var active_order: Dictionary = {}
var pending_order: Dictionary = {}
var selected_batch := 0
var delivered_orders := 0
var score := 0
var mistakes := 0
var toner := MAX_TONER


func scene_for(station: String) -> String:
	return {"counter": "res://service_counter.tscn", "copier": "res://prototype.tscn",
		"cutting": "res://cutting_station.tscn", "binding": "res://binding_station.tscn",
		"packaging": "res://packaging_station.tscn"}.get(station, "res://station_select.tscn")


func _ready() -> void:
	prepare_order()


func make_batch(document: String, quantity: int, size: int, stamp: bool, cut: bool, binding: String) -> Dictionary:
	assert(quantity > 0 and size in [50, 100, 150])
	assert(document in ["MEMO", "INVOICE", "PHOTO"])
	assert(binding in ["NONE", "STAPLE", "BIND"])
	return {"document": document, "quantity": quantity, "size": size,
		"stamp": stamp, "cut": cut, "binding": binding,
		"printed": 0, "cut_done": false, "binding_done": false, "packed": false}


func prepare_order() -> void:
	if not pending_order.is_empty() or not active_order.is_empty():
		return
	var batches: Array = []
	if order_number == 1:
		batches = [
			make_batch("MEMO", 5, 50, true, false, "NONE"),
			make_batch("INVOICE", 15, 150, false, false, "STAPLE"),
			make_batch("PHOTO", 30, 100, false, true, "NONE")]
	else:
		for i in range(randi_range(2, 3)):
			batches.append(make_batch(["MEMO", "INVOICE", "PHOTO"].pick_random(),
				[3, 5, 6, 10, 15, 30].pick_random(), [50, 100, 150].pick_random(),
				randf() < 0.35, randf() < 0.5, ["NONE", "STAPLE", "BIND"].pick_random()))
	pending_order = {"id": order_number, "batches": batches}


func accept_order() -> bool:
	if not active_order.is_empty():
		return false
	prepare_order()
	active_order = pending_order.duplicate(true)
	pending_order = {}
	selected_batch = 0
	workflow_changed.emit()
	return true


func batches() -> Array:
	return active_order.get("batches", [])


func batch(index: int) -> Dictionary:
	var items := batches()
	if index < 0 or index >= items.size():
		return {}
	return items[index]


func select_batch(index: int) -> void:
	if not batch(index).is_empty():
		selected_batch = index
		workflow_changed.emit()


# The single source of truth for prerequisites, also used by every UI.
func next_stage(item: Dictionary) -> String:
	if item.is_empty():
		return "counter"
	if int(item.printed) < int(item.quantity):
		return "copier"
	if item.cut and not item.cut_done:
		return "cutting"
	if item.binding != "NONE" and not item.binding_done:
		return "binding"
	if not item.packed:
		return "packaging"
	return "done"


func required_tool(item: Dictionary) -> String:
	return "scissors" if int(item.quantity) <= SCISSORS_LIMIT else "guillotine"


func print_sheets(index: int, document: String, size: int, stamp: bool, count: int) -> String:
	var item := batch(index)
	if next_stage(item) != "copier" or item.is_empty():
		return "blocked"
	if count < 1 or count > int(item.quantity) - int(item.printed):
		return "quantity"
	if count > toner:
		return "toner"
	toner -= count
	if item.document != document or int(item.size) != size or item.stamp != stamp:
		return _mistake()
	item.printed += count
	workflow_changed.emit()
	return "ok"


func cut_batch(index: int, tool: String) -> String:
	var item := batch(index)
	if item.is_empty() or next_stage(item) != "cutting":
		return "blocked"
	if tool != required_tool(item):
		return _mistake()
	item.cut_done = true
	workflow_changed.emit()
	return "ok"


func finish_batch(index: int, finish: String) -> String:
	var item := batch(index)
	if item.is_empty() or next_stage(item) != "binding":
		return "blocked"
	if finish != item.binding:
		return _mistake()
	item.binding_done = true
	workflow_changed.emit()
	return "ok"


func pack_batch(index: int) -> String:
	var item := batch(index)
	if item.is_empty() or next_stage(item) != "packaging":
		return "blocked"
	item.packed = true
	workflow_changed.emit()
	return "ok"


func can_deliver() -> bool:
	if active_order.is_empty():
		return false
	for item: Dictionary in batches():
		if next_stage(item) != "done":
			return false
	return true


func deliver_order() -> bool:
	if not can_deliver():
		return false
	score += 100 * batches().size()
	delivered_orders += 1
	order_number += 1
	active_order = {}
	selected_batch = 0
	prepare_order()
	workflow_changed.emit()
	return true


func refill_toner() -> void:
	toner = MAX_TONER
	workflow_changed.emit()


func _mistake() -> String:
	mistakes += 1
	score = maxi(0, score - 25)
	workflow_changed.emit()
	return "wrong"


func tr_pair(pt: String, en: String) -> String:
	return pt if Locale.current_language == Locale.PORTUGUESE else en


func stage_name(stage: String) -> String:
	return tr_pair("EMBALADO", "PACKED") if stage == "done" else Locale.station_name(stage)


func description(item: Dictionary) -> String:
	var yes := tr_pair("SIM", "YES")
	var no := tr_pair("NÃO", "NO")
	return tr_pair(
		"%d cópias de %s • %d%%\nCarimbo: %s • Corte: %s\nGrampo: %s • Encadernação: %s • Embalar",
		"%d copies of %s • %d%%\nStamp: %s • Cut: %s\nStaple: %s • Binding: %s • Package"
	) % [item.quantity, Locale.document_name(item.document), item.size,
		yes if item.stamp else no, yes if item.cut else no,
		yes if item.binding == "STAPLE" else no, yes if item.binding == "BIND" else no]

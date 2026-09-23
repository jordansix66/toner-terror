extends Control

const STATIONS := ["counter", "copier", "cutting", "binding", "packaging"]

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var back_button: Button = %BackButton
@onready var footer_hint: Label = %FooterHint
@onready var buttons := {
	"counter": %CounterButton,
	"copier": %CopierButton,
	"cutting": %CuttingButton,
	"binding": %BindingButton,
	"packaging": %PackagingButton
}


func _ready() -> void:
	back_button.pressed.connect(_back_to_menu)
	for station_id: String in STATIONS:
		var button: Button = buttons[station_id]
		button.pressed.connect(_open_station.bind(station_id))
	_refresh_text()


func _refresh_text() -> void:
	title_label.text = Locale.text("station_select_title")
	subtitle_label.text = Locale.text("station_select_subtitle")
	back_button.text = Locale.text("station_back_menu")
	footer_hint.text = Locale.text("station_footer")
	for station_id: String in STATIONS:
		var button: Button = buttons[station_id]
		button.text = "%s\n%s" % [
			Locale.station_name(station_id),
			Locale.station_description(station_id)
		]
		if not GameState.active_order.is_empty():
			var count := 0
			for item: Dictionary in GameState.batches():
				if GameState.next_stage(item) == station_id:
					count += 1
			if station_id == "counter" and GameState.can_deliver():
				button.text += "\n" + GameState.tr_pair("PEDIDO PRONTO PARA ENTREGA", "ORDER READY FOR DELIVERY")
			elif count > 0:
				button.text += "\n" + GameState.tr_pair("%d LOTE(S) AGUARDANDO", "%d BATCH(ES) WAITING") % count


func _open_station(station_id: String) -> void:
	GameState.current_station = station_id
	get_tree().change_scene_to_file(GameState.scene_for(station_id))


func _back_to_menu() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

extends Node

signal language_changed

const ENGLISH := "en"
const PORTUGUESE := "pt_BR"

const STRINGS := {
	ENGLISH: {
		"menu_prototype": "SOLO PROTOTYPE // NIGHT ONE",
		"menu_start": "START NIGHT SHIFT",
		"menu_language": "LANGUAGE: ENGLISH",
		"menu_quit": "QUIT",
		"station_select_title": "CHOOSE YOUR WORKSTATION",
		"station_select_subtitle": "NIGHT SHIFT // SELECT A STATION TO BEGIN",
		"station_counter": "SERVICE COUNTER",
		"station_copier": "PHOTOCOPIER",
		"station_cutting": "CUTTING & GLUING TABLE",
		"station_binding": "BINDING TABLE",
		"station_packaging": "PACKAGING TABLE",
		"station_counter_desc": "Serve customers, receive orders, collect payments and deliver finished work.",
		"station_copier_desc": "Configure documents, sizes and copies.",
		"station_cutting_desc": "Use the paper cutter, scissors and glue.",
		"station_binding_desc": "Staple, punch and bind finished documents.",
		"station_packaging_desc": "Prepare envelopes and protective packaging.",
		"station_back_menu": "BACK TO MAIN MENU",
		"station_footer": "TONER TERROR // WORKSTATION SELECT",
		"station_exit": "EXIT STATION",
		"station_exit_hint": "SPACE: EXIT STATION",
		"station_in_development": "THIS WORKSTATION IS READY FOR ITS NEXT DEVELOPMENT STEP.",
		"shift_location": "NIGHT SHIFT // 02:13 AM // PRINT ROOM",
		"order_counter": "ORDER %d / %d",
		"score": "SCORE %04d",
		"toner": "TONER %d / %d",
		"order_title": "ORDER #%02d",
		"copy_singular": "COPY",
		"copy_plural": "COPIES",
		"order_details": "%d %s OF %s\nSIZE: %d%%     FINISH: %s",
		"copies_progress": "COPIES: %d / %d",
		"select_document": "1. SELECT DOCUMENT",
		"select_size": "2. SELECT SIZE",
		"select_finish": "3. SELECT FINISH",
		"doc_memo": "MEMO",
		"doc_invoice": "INVOICE",
		"doc_photo": "PHOTO",
		"finish_none": "NONE",
		"finish_stamp": "STAMP",
		"finish_staple": "STAPLE",
		"make_copy": "MAKE COPY",
		"replace_toner": "REPLACE\nTONER",
		"next_order": "NEXT ORDER",
		"end_shift": "END SHIFT",
		"hint": "TIP: CHECK THE ORDER BEFORE STARTING THE MACHINE.",
		"footer": "PROTOTYPE BUILD // NIGHT ONE",
		"machine_status": "POWER: ON    MAINTENANCE: OK",
		"output_copy": "COPY",
		"status_check": "CHECK EVERY SETTING BEFORE MAKING THE COPY.",
		"status_toner_empty": "TONER EMPTY! REPLACE THE CARTRIDGE.",
		"status_copy_ok": "COPY ACCEPTED.",
		"status_order_complete": "ORDER COMPLETE!",
		"status_new_toner": "NEW TONER INSTALLED.",
		"status_wrong": "MISPRINT! THE ORDER SETTINGS DID NOT MATCH.",
		"shift_complete": "SHIFT COMPLETE",
		"summary": "FINAL SCORE: %d\nORDERS COMPLETED: %d\nMISPRINTS: %d\n\n%s",
		"verdict_great": "VERDICT: EXCELLENT SHIFT",
		"verdict_ok": "VERDICT: GOOD ENOUGH FOR TONIGHT",
		"verdict_bad": "VERDICT: MORE TRAINING REQUIRED",
		"restart_shift": "START ANOTHER SHIFT",
		"preview_memo": "INTERNAL MEMO\n\nTO: NIGHT STAFF\nFROM: MANAGEMENT\n\nDO NOT FEED THE\nCOPIER AFTER 2 AM.",
		"preview_invoice": "INVOICE\n\nACME OFFICE SUPPLY\n----------------\nTONER ........ $66\nPAPER ........ $13\nSERVICE ...... $20",
		"preview_photo": "EMPLOYEE PHOTO\n\n       [ O  O ]\n       [  --  ]\n       [ ____ ]\n\nDO NOT DUPLICATE"
	},
	PORTUGUESE: {
		"menu_prototype": "PROTÓTIPO SOLO // PRIMEIRA NOITE",
		"menu_start": "INICIAR TURNO DA NOITE",
		"menu_language": "LINGUAGEM: PORTUGUÊS (BRASIL)",
		"menu_quit": "SAIR",
		"station_select_title": "ESCOLHA SUA ESTAÇÃO DE TRABALHO",
		"station_select_subtitle": "TURNO DA NOITE // SELECIONE UMA ESTAÇÃO PARA COMEÇAR",
		"station_counter": "BALCÃO DE ATENDIMENTO",
		"station_copier": "FOTOCOPIADORA",
		"station_cutting": "MESA DE CORTE E COLAGEM",
		"station_binding": "MESA DE ENCADERNAMENTO",
		"station_packaging": "MESA DE EMBALAGENS",
		"station_counter_desc": "Atenda clientes, receba pedidos, cobre e entregue trabalhos finalizados.",
		"station_copier_desc": "Configure documentos, tamanhos e cópias.",
		"station_cutting_desc": "Use a guilhotina de papel, a tesoura e a cola.",
		"station_binding_desc": "Grampeie, perfure e encaderne documentos finalizados.",
		"station_packaging_desc": "Prepare envelopes e embalagens de proteção.",
		"station_back_menu": "VOLTAR AO MENU PRINCIPAL",
		"station_footer": "TONER TERROR // SELEÇÃO DE ESTAÇÃO",
		"station_exit": "SAIR DA ESTAÇÃO",
		"station_exit_hint": "ESPAÇO: SAIR DA ESTAÇÃO",
		"station_in_development": "ESTA ESTAÇÃO ESTÁ PRONTA PARA A PRÓXIMA ETAPA DO DESENVOLVIMENTO.",
		"shift_location": "TURNO DA NOITE // 02:13 // SALA DE IMPRESSÃO",
		"order_counter": "PEDIDO %d / %d",
		"score": "PONTOS %04d",
		"toner": "TONER %d / %d",
		"order_title": "PEDIDO Nº %02d",
		"copy_singular": "CÓPIA",
		"copy_plural": "CÓPIAS",
		"order_details": "%d %s DE %s\nTAMANHO: %d%%     ACABAMENTO: %s",
		"copies_progress": "CÓPIAS: %d / %d",
		"select_document": "1. SELECIONE O DOCUMENTO",
		"select_size": "2. SELECIONE O TAMANHO",
		"select_finish": "3. SELECIONE O ACABAMENTO",
		"doc_memo": "MEMORANDO",
		"doc_invoice": "FATURA",
		"doc_photo": "FOTO",
		"finish_none": "NENHUM",
		"finish_stamp": "CARIMBO",
		"finish_staple": "GRAMPO",
		"make_copy": "FAZER CÓPIA",
		"replace_toner": "TROCAR\nTONER",
		"next_order": "PRÓXIMO PEDIDO",
		"end_shift": "ENCERRAR TURNO",
		"hint": "DICA: CONFIRA O PEDIDO ANTES DE LIGAR A MÁQUINA.",
		"footer": "VERSÃO DE PROTÓTIPO // PRIMEIRA NOITE",
		"machine_status": "ENERGIA: LIGADA    MANUTENÇÃO: OK",
		"output_copy": "CÓPIA",
		"status_check": "CONFIRA TODAS AS OPÇÕES ANTES DE FAZER A CÓPIA.",
		"status_toner_empty": "TONER VAZIO! TROQUE O CARTUCHO.",
		"status_copy_ok": "CÓPIA ACEITA.",
		"status_order_complete": "PEDIDO CONCLUÍDO!",
		"status_new_toner": "NOVO TONER INSTALADO.",
		"status_wrong": "ERRO DE IMPRESSÃO! AS OPÇÕES NÃO CONFEREM COM O PEDIDO.",
		"shift_complete": "TURNO CONCLUÍDO",
		"summary": "PONTUAÇÃO FINAL: %d\nPEDIDOS CONCLUÍDOS: %d\nERROS DE IMPRESSÃO: %d\n\n%s",
		"verdict_great": "RESULTADO: TURNO EXCELENTE",
		"verdict_ok": "RESULTADO: BOM O SUFICIENTE POR HOJE",
		"verdict_bad": "RESULTADO: É PRECISO TREINAR MAIS",
		"restart_shift": "INICIAR OUTRO TURNO",
		"preview_memo": "MEMORANDO INTERNO\n\nPARA: TURNO DA NOITE\nDE: ADMINISTRAÇÃO\n\nNÃO MEXA NA\nCOPIADORA APÓS 2H.",
		"preview_invoice": "FATURA\n\nSUPRIMENTOS ACME\n----------------\nTONER ........ R$ 66\nPAPEL ........ R$ 13\nSERVIÇO ...... R$ 20",
		"preview_photo": "FOTO DO FUNCIONÁRIO\n\n       [ O  O ]\n       [  --  ]\n       [ ____ ]\n\nNÃO DUPLICAR"
	}
}

var current_language := PORTUGUESE


func _ready() -> void:
	var settings := ConfigFile.new()
	if settings.load("user://settings.cfg") == OK:
		current_language = settings.get_value("language", "current", PORTUGUESE)
	if not STRINGS.has(current_language):
		current_language = PORTUGUESE


func text(key: String) -> String:
	return STRINGS[current_language].get(key, key)


func toggle_language() -> void:
	current_language = PORTUGUESE if current_language == ENGLISH else ENGLISH
	var settings := ConfigFile.new()
	settings.set_value("language", "current", current_language)
	settings.save("user://settings.cfg")
	language_changed.emit()


func document_name(document: String) -> String:
	return text({"MEMO": "doc_memo", "INVOICE": "doc_invoice", "PHOTO": "doc_photo"}.get(document, "doc_memo"))


func finish_name(finish: String) -> String:
	return text({"NONE": "finish_none", "STAMP": "finish_stamp", "STAPLE": "finish_staple"}.get(finish, "finish_none"))


func station_name(station_id: String) -> String:
	return text("station_%s" % station_id)


func station_description(station_id: String) -> String:
	return text("station_%s_desc" % station_id)

extends Area2D
class_name CardResposta

signal resposta_arrastada(valor)

var valor: int = 0
var posicao_original: Vector2
var fixado: bool = false

@onready var sprite: Sprite2D = $SpriteCard_Fase_1

var _arrastando := false
var _offset: Vector2

func _ready():
	# ⭐ NOVO: Extrair valor automaticamente do nome
	_extrair_valor_do_nome()
	
	# Configurar posição original
	if posicao_original == Vector2.ZERO:
		posicao_original = global_position
	
	# Conectar input_event
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)
	
	input_pickable = true
	
	print("✅ Card carregado - Nome: ", name, " - Valor: ", valor)

# ⭐ NOVO: Método para extrair valor do nome
func _extrair_valor_do_nome():
	# Procura por números no nome do nó
	var regex = RegEx.new()
	
	# Tenta compilar a expressão regular
	if regex.compile("(\\d+)") == OK:
		var resultado = regex.search(name)
		if resultado:
			valor = resultado.get_string().to_int()
			print("🎯 Valor extraído do nome: ", name, " → ", valor)
		else:
			push_warning("❌ Nenhum número encontrado no nome do card: " + name)
			valor = 0
	else:
		push_error("❌ Erro ao compilar regex")
		valor = 0

# ⭐ CORREÇÃO: Método configurar atualizado
func configurar(_eh_correta: bool) -> void:
	# ⭐ AGORA o valor já foi extraído do nome automaticamente
	print("🔧 Card ", name, " configurado - Valor: ", valor, " - Correto: ", _eh_correta)

# Resto do código permanece igual...
func _on_input_event(_viewport, event, _shape_idx):
	if fixado:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_iniciar_arrasto()
		else:
			if _arrastando:
				_terminar_arrasto()
	
	elif event is InputEventMouseMotion and _arrastando:
		global_position = get_global_mouse_position() + _offset

func _iniciar_arrasto():
	_arrastando = true
	_offset = global_position - get_global_mouse_position()
	z_index = 10
	get_viewport().set_input_as_handled()
	print("🔄 Iniciando arrasto do card: ", name, " - Valor: ", valor)

func _terminar_arrasto():
	_arrastando = false
	z_index = 0
	_processar_soltura()

func _processar_soltura():
	print("🔄 Soltando card: ", name, " - Valor: ", valor)
	
	var areas_sobrepostas = get_overlapping_areas()
	var area_resposta_proxima = null
	var menor_distancia = 100.0
	
	for area in areas_sobrepostas:
		if area.has_method("get_valor_esperado") or area is AreaResposta:
			var distancia = global_position.distance_to(area.global_position)
			print("📏 Área encontrada a distância: ", distancia)
			
			if distancia < menor_distancia:
				menor_distancia = distancia
				area_resposta_proxima = area
	
	if area_resposta_proxima:
		print("🎯 Card ", valor, " solto perto da área - Distância: ", menor_distancia)
		var tween = create_tween()
		tween.tween_property(self, "global_position", area_resposta_proxima.global_position, 0.2)
		tween.tween_callback(_emitir_sinal.bind(area_resposta_proxima))
	else:
		print("❌ Nenhuma área próxima - voltando para posição original")
		voltar_para_original()

func _emitir_sinal(area):
	print("📢 Emitindo sinal para área - Card valor: ", valor)
	emit_signal("resposta_arrastada", valor)
	
	if area.has_method("receber_card"):
		area.receber_card(self)

func get_valor() -> int:
	return valor

func voltar_para_original():
	print("↩️ Voltando card ", name, " para posição original")
	var tween = create_tween()
	tween.tween_property(self, "global_position", posicao_original, 0.3)

func fixar_na_posicao_atual():
	if fixado:
		return
		
	fixado = true
	_arrastando = false
	modulate = Color(0.7, 0.7, 0.7)
	collision_layer = 0
	collision_mask = 0
	input_pickable = false
	print("📌 Card ", name, " FIXADO! - Valor: ", valor)

func liberar_card():
	if not fixado:
		return
		
	fixado = false
	modulate = Color.WHITE
	collision_layer = 1
	collision_mask = 1
	input_pickable = true
	print("🔓 Card ", name, " liberado - Valor: ", valor)

func _process(_delta):
	if _arrastando:
		global_position = get_global_mouse_position() + _offset

func _exit_tree():
	if _arrastando:
		_arrastando = false

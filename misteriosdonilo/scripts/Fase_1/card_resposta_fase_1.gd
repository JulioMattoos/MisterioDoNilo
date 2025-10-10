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
	# Configurar posição original
	if posicao_original == Vector2.ZERO:
		posicao_original = global_position
	
	# ⭐ CORREÇÃO: Verificar se já está conectado antes de conectar
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)
	
	input_pickable = true  # ⭐ IMPORTANTE: Permitir que receba input
	
	print("✅ Card carregado - Nome: ", name, " - Valor: ", valor)

# ⭐ CORREÇÃO: Método configurar melhorado
func configurar(novo_valor: int, _eh_correta: bool) -> void:
	valor = novo_valor
	# ⭐ GARANTIR que o valor seja configurado corretamente
	print("🔧 Card ", name, " configurado com valor: ", valor)

func _on_input_event(_viewport, event, _shape_idx):
	if fixado:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# ⭐ CORREÇÃO: Iniciar arrasto
			_iniciar_arrasto()
		else:
			# ⭐ CORREÇÃO: Soltar apenas se estava arrastando
			if _arrastando:
				_terminar_arrasto()
	
	# ⭐ CORREÇÃO: Movimento do mouse deve ser processado mesmo sem clique
	elif event is InputEventMouseMotion and _arrastando:
		global_position = get_global_mouse_position() + _offset

# ⭐ NOVO: Método para iniciar arrasto
func _iniciar_arrasto():
	_arrastando = true
	_offset = global_position - get_global_mouse_position()
	
	# ⭐ CORREÇÃO: Trazer para frente quando arrastado
	z_index = 10
	
	get_viewport().set_input_as_handled()
	print("🔄 Iniciando arrasto do card: ", name, " - Valor: ", valor)

# ⭐ NOVO: Método para terminar arrasto
func _terminar_arrasto():
	_arrastando = false
	z_index = 0  # ⭐ Voltar ao z_index normal
	
	# ⭐ CORREÇÃO: Processar soltura
	_processar_soltura()

# ⭐ CORREÇÃO: Método melhorado para processar soltura
func _processar_soltura():
	print("🔄 Soltando card: ", name, " - Valor: ", valor)
	
	var areas_sobrepostas = get_overlapping_areas()
	var area_resposta_proxima = null
	var menor_distancia = 100.0  # ⭐ Aumentei a distância máxima
	
	# ⭐ CORREÇÃO: Buscar áreas de resposta específicas
	for area in areas_sobrepostas:
		# ⭐ VERIFICAR se é uma área de resposta válida
		if area.has_method("get_valor_esperado") or area is AreaResposta:
			var distancia = global_position.distance_to(area.global_position)
			print("📏 Área encontrada a distância: ", distancia)
			
			if distancia < menor_distancia:
				menor_distancia = distancia
				area_resposta_proxima = area
	
	if area_resposta_proxima:
		print("🎯 Card ", valor, " solto perto da área - Distância: ", menor_distancia)
		
		# ⭐ CORREÇÃO: Usar tween para animação suave
		var tween = create_tween()
		tween.tween_property(self, "global_position", area_resposta_proxima.global_position, 0.2)
		tween.tween_callback(_emitir_sinal.bind(area_resposta_proxima))
	else:
		print("❌ Nenhuma área próxima - voltando para posição original")
		voltar_para_original()

# ⭐ NOVO: Emitir sinal após animação
func _emitir_sinal(area):
	print("📢 Emitindo sinal para área - Card valor: ", valor)
	emit_signal("resposta_arrastada", valor)
	
	# ⭐ CORREÇÃO: Também notificar a área diretamente se possível
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
	
	# ⭐ CORREÇÃO: Configurações visuais e de colisão
	modulate = Color(0.7, 0.7, 0.7)  # Escurecer um pouco
	collision_layer = 0  # Não colidir mais
	collision_mask = 0   # Não detectar mais colisões
	input_pickable = false  # ⭐ IMPEDIR input quando fixado
	
	print("📌 Card ", name, " FIXADO! - Valor: ", valor)

func liberar_card():
	if not fixado:
		return
		
	fixado = false
	modulate = Color.WHITE
	collision_layer = 1  # ⭐ AJUSTAR conforme sua configuração
	collision_mask = 1   # ⭐ AJUSTAR conforme sua configuração
	input_pickable = true
	
	print("🔓 Card ", name, " liberado - Valor: ", valor)

# ⭐ NOVO: Método para debug
func _process(_delta):
	if _arrastando:
		# Manter posição atualizada durante arrasto
		global_position = get_global_mouse_position() + _offset

# ⭐ NOVO: Garantir que o mouse seja liberado se o card for removido
func _exit_tree():
	if _arrastando:
		_arrastando = false

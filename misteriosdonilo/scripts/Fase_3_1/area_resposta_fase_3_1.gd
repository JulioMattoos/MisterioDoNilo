extends Area2D
class_name AreaResposta_3_1

signal resposta_recebida(valor: int, correto_para_esta_area: bool)
signal card_entrou_na_area(area: AreaResposta_3_1, card: Object)

var resultado_esperado: int = 2
var expressao: String = ""
var tem_card_correto: bool = false

# ⭐ VARIÁVEIS PARA TROCA DE CARDS - CORRIGIDO
var card_correto_sprite: Sprite2D
var ultimo_card_recebido: int = -1

func _ready():
	# Conectar sinais
	if not is_connected("area_entered", _on_area_entered):
		connect("area_entered", _on_area_entered)
	
	# ⭐ INICIALIZAR SPRITE DO CARD CORRETO
	_inicializar_sprite_card_correto()
	
	if resultado_esperado == 0 and expressao.is_empty():
		push_warning("AreaResposta_3_1 não foi configurada corretamente - use a função configurar()")

# ⭐ FUNÇÃO CRÍTICA: Inicializar o sprite
func _inicializar_sprite_card_correto():
	# Buscar o Sprite2D que já existe na cena
	card_correto_sprite = get_node_or_null("CardCorretoSprite")
	
	if card_correto_sprite:
		print("✅ Sprite encontrado para área: ", name)
		# ⭐ CARREGAR TEXTURA DINAMICAMENTE baseado no resultado esperado
		_carregar_textura_card_correto()
		card_correto_sprite.visible = false  # Começar invisível
	else:
		print("❌ ERRO: CardCorretoSprite não encontrado na área: ", name)
		# Debug: listar todos os filhos para ver o que existe
		print("   Filhos disponíveis:")
		for child in get_children():
			print("   - ", child.name, " (", child.get_class(), ")")

# ⭐⭐ NOVA FUNÇÃO: Carregar textura do card correto
func _carregar_textura_card_correto():
	if not card_correto_sprite or resultado_esperado == 0:
		return
	
	# Mapeamento de valores para texturas - FASE 3
	# Deve corresponder exatamente às imagens dos cards de alternativa
	var texturas_map = {
		8: "res://imagens/cards_Fase_3_1/pg3-a1.png",
		12: "res://imagens/cards_Fase_3_1/pg3-a2.png", 
		36: "res://imagens/cards_Fase_3_1/pg3-a3.png",
		32: "res://imagens/cards_Fase_3_1/pg3-a4.png",
		9: "res://imagens/cards_Fase_3_1/pg3-a5.png"
	}
	
	if texturas_map.has(resultado_esperado):
		var texture_path = texturas_map[resultado_esperado]
		var texture = load(texture_path)
		if texture:
			card_correto_sprite.texture = texture
			card_correto_sprite.scale = Vector2(0.06, 0.06)  # MESMA ESCALA DA FASE 1
			print("✅ Textura carregada para card correto: ", texture_path)
		else:
			print("❌ ERRO: Não foi possível carregar textura: ", texture_path)
	else:
		print("⚠️ AVISO: Textura não mapeada para valor: ", resultado_esperado)

func configurar(_resultado_esperado: int, _expressao: String):
	resultado_esperado = _resultado_esperado
	expressao = _expressao
	tem_card_correto = false
	print("🎯 Área ", name, " configurada: ", expressao, " = ", resultado_esperado)
	# ⭐ CARREGAR TEXTURA DEPOIS DE CONFIGURAR VALOR
	_carregar_textura_card_correto()

func _on_area_entered(area: Area2D):
	print("=== ÁREA DETECTOU ENTRADA ===")
	
	# Verificar se é um CardResposta_3_1
	if area is CardResposta_3_1:
		var card: CardResposta_3_1 = area
		
		if not card.has_method("get_valor"):
			push_error("CardResposta_3_1 não possui método get_valor()")
			return
		
		var valor_card: int = card.get_valor()
		_processar_resposta(valor_card, card)
		return
	
	print("Objeto não reconhecido como card: ", area.name)

func _processar_resposta(_valor_card: int, _card: Object):
	var correto_para_esta_area: bool = (_valor_card == resultado_esperado)
	tem_card_correto = correto_para_esta_area
	ultimo_card_recebido = _valor_card
	
	print("Card valor: ", _valor_card)
	print("Área espera: ", resultado_esperado, " (", expressao, ")")
	print("Correto para esta área: ", correto_para_esta_area)
	
	# ⭐⭐ PASSO 3 ADICIONADO AQUI: ATIVAR CARD CORRETO ESPECÍFICO
	if correto_para_esta_area:
		print("🎯 RESPOSTA CORRETA! Ativando card específico...")
		
		# 1. Esconder o card arrastado
		if _card is CardResposta_3_1:
			print("🔴 Escondendo card arrastado: ", _card.name)
			_card.visible = false
			_card.queue_free()
		
		# 2. MOSTRAR O CARD CORRETO ESPECÍFICO
		_ativar_card_correto_especifico()
		
		print("✅ Troca concluída!")
	
	# Emitir sinal normalmente
	resposta_recebida.emit(_valor_card, correto_para_esta_area)

# ⭐⭐ E ADICIONE ESTA FUNÇÃO NO MESMO SCRIPT (AreaResposta.gd):
func _ativar_card_correto_especifico():
	print("🔍 Ativando card correto específico para: ", name)
	
	# MÉTODO 1: Tentar usar o sprite interno primeiro
	if card_correto_sprite and is_instance_valid(card_correto_sprite):
		# ⭐ CORREÇÃO: Garantir que o sprite está na posição correta (0,0 relativo à área)
		card_correto_sprite.position = Vector2.ZERO
		card_correto_sprite.visible = true
		print("✅ Card correto interno ativado: ", name)
		print("   📍 Posição local: ", card_correto_sprite.position)
		print("   📍 Posição global: ", card_correto_sprite.global_position)
		print("   🎨 Modulacao: ", card_correto_sprite.modulate)
		print("   📦 Z-index: ", card_correto_sprite.z_index)
		print("   👁️ Visible: ", card_correto_sprite.visible)
		print("   🖼️ Texture: ", card_correto_sprite.texture)
		# Verificar se está sendo escondido pelo pai
		var pai = card_correto_sprite.get_parent()
		if pai:
			print("   👪 Pai: ", pai.name, " | Visível: ", pai.visible, " | Posição: ", pai.global_position)
		return
	
	# MÉTODO 2: Procurar card correto externo (FALLBACK - apenas se o sprite interno não existir)
	var numero_area = ""
	var regex = RegEx.new()
	if regex.compile("\\d+") == OK:
		var result = regex.search(name)
		if result:
			numero_area = result.get_string()
	
	if numero_area.is_empty():
		print("❌ Não foi possível extrair número da área: ", name)
		return
	
	var card_correto_path = "../Card_Correto_Fase_%s" % numero_area
	print("🧭 Procurando card externo no caminho: ", card_correto_path)
	
	var card_correto = get_node_or_null(card_correto_path)
	
	if card_correto:
		# ⭐ CORREÇÃO: Posicionar o card correto externo na mesma posição da área
		card_correto.global_position = global_position
		card_correto.visible = true
		print("✅ Card correto externo ativado e posicionado: ", card_correto.name)
		print("   📍 Posição: ", card_correto.global_position)
	else:
		print("❌ Card correto não encontrado para área: ", name)

# ✅ MÉTODO PARA MOSTRAR CARD CORRETO
func mostrar_card_correto():
	print("🟢 Mostrando card correto na área: ", name)
	_ativar_card_correto_especifico()

func esconder_card_correto():
	print("🔲 Escondendo card correto na área: ", name)
	
	# MÉTODO 1: Esconder sprite interno
	if card_correto_sprite and is_instance_valid(card_correto_sprite):
		card_correto_sprite.visible = false
	
	# MÉTODO 2: Esconder card externo
	var numero_area = ""
	var regex = RegEx.new()
	if regex.compile("\\d+") == OK:
		var result = regex.search(name)
		if result:
			numero_area = result.get_string()
	
	if not numero_area.is_empty():
		var card_correto_path = "../Card_Correto_Fase_%s" % numero_area
		var card_correto = get_node_or_null(card_correto_path)
		if card_correto:
			card_correto.visible = false

func tem_card_correto_visivel() -> bool:
	# Verificar sprite interno
	if card_correto_sprite and is_instance_valid(card_correto_sprite):
		return card_correto_sprite.visible
	
	# Verificar card externo
	var numero_area = ""
	var regex = RegEx.new()
	if regex.compile("\\d+") == OK:
		var result = regex.search(name)
		if result:
			numero_area = result.get_string()
	
	if not numero_area.is_empty():
		var card_correto_path = "../Card_Correto_Fase_%s" % numero_area
		var card_correto = get_node_or_null(card_correto_path)
		if card_correto:
			return card_correto.visible
	
	return false

func get_posicao_card_correto() -> Vector2:
	if card_correto_sprite:
		return card_correto_sprite.global_position
	return global_position

func esta_correta() -> bool:
	return tem_card_correto

func resetar():
	tem_card_correto = false
	esconder_card_correto()

func get_info() -> String:
	return "AreaResposta_3_1: %s = %d (Correto: %s)" % [expressao, resultado_esperado, tem_card_correto]

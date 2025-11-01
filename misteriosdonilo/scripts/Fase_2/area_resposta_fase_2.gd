extends Area2D
class_name AreaResposta_2

signal resposta_recebida(valor: int, correto_para_esta_area: bool)
signal card_entrou_na_area(area: AreaResposta_2, card: CardResposta_2)

var resultado_esperado: int = 2
var expressao: String = ""
var tem_card_correto: bool = false

# ⭐ VARIÁVEIS PARA TROCA DE CARDS - CORRIGIDO
var card_correto_sprite: Sprite2D
var ultimo_card_recebido: int = -1

func _ready():
	# Conectar sinais - ✅ CORREÇÃO: usar Callable corretamente
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	
	# ⭐ INICIALIZAR SPRITE DO CARD CORRETO
	_inicializar_sprite_card_correto()
	
	if resultado_esperado == 0 and expressao.is_empty():
		push_warning("AreaResposta_2 não foi configurada corretamente - use a função configurar()")

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
	
	# Mapeamento de valores para texturas
	var texturas_map = {
		2: "res://imagens/cards_Fase_1/pg1_a5.png",
		6: "res://imagens/cards_Fase_1/pg1_a3.png", 
		28: "res://imagens/cards_Fase_1/pg2_a2.png",
		40: "res://imagens/cards_Fase_1/pg2_a3.png",
		48: "res://imagens/cards_Fase_1/pg2_a4.png",
		# Adicionar mais valores conforme necessário
	}
	
	if texturas_map.has(resultado_esperado):
		var texture_path = texturas_map[resultado_esperado]
		var texture = load(texture_path)
		if texture:
			card_correto_sprite.texture = texture
			card_correto_sprite.scale = Vector2(0.06, 0.06)  # 0.05 (interno) * 1.2 (exterior) = 0.06
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
	print("Área: ", name, " | Espera: ", resultado_esperado, " (", expressao, ")")
	print("Objeto que entrou: ", area.name, " | Tipo: ", area.get_class())
	
	# ⭐⭐ SIMPLIFICADO: Seguir a mesma lógica da Fase 1
	if area is CardResposta_2:
		var card: CardResposta_2 = area as CardResposta_2
		
		if not card.has_method("get_valor"):
			push_error("CardResposta_2 não possui método get_valor()")
			print("❌ Card não tem método get_valor()")
			return
		
		var valor_card: int = card.get_valor()
		print("📥 Card entrou na área: ", card.name, " | Valor: ", valor_card)
		_processar_resposta(valor_card, card)
		return
	
	print("❌ Objeto não reconhecido como card: ", area.name)

func receber_card(card: Node):
	# ⭐⭐ FUNÇÃO: Receber card via método direto (usado pelo sistema de arrasto)
	print("📥 receber_card() chamado - Objeto: ", card.name, " | Tipo: ", card.get_class())
	
	if card is CardResposta_2:
		var card_typed: CardResposta_2 = card as CardResposta_2
		if card_typed.has_method("get_valor"):
			var valor_card = card_typed.get_valor()
			print("✅ Card recebido via receber_card(): ", card.name, " | Valor: ", valor_card)
			_processar_resposta(valor_card, card_typed)
		else:
			print("❌ Card não tem método get_valor()")
	else:
		print("❌ Objeto recebido não é CardResposta_2: ", card.name, " | Classe: ", card.get_class())

func _processar_resposta(_valor_card: int, _card):
	# ⭐⭐ CORREÇÃO CRÍTICA: Verificar se o valor do card corresponde ao resultado esperado
	var correto_para_esta_area: bool = (_valor_card == resultado_esperado)
	tem_card_correto = correto_para_esta_area
	ultimo_card_recebido = _valor_card
	
	print("🔍 VALIDAÇÃO:")
	print("   Card valor: ", _valor_card)
	print("   Área espera: ", resultado_esperado, " (", expressao, ")")
	print("   Correto para esta área: ", correto_para_esta_area)
	
	# ⭐⭐ CORREÇÃO: Só processar troca se for realmente correto
	if correto_para_esta_area:
		print("🎯 RESPOSTA CORRETA! Ativando card específico...")
		
		# 1. Esconder o card arrastado
		if _card is CardResposta_2:
			var card_node: CardResposta_2 = _card as CardResposta_2
			print("🔴 Escondendo card arrastado: ", card_node.name)
			# Usar método desaparecer() se disponível, senão esconder normalmente
			if card_node.has_method("desaparecer"):
				card_node.desaparecer()
			else:
				card_node.visible = false
				await get_tree().create_timer(0.1).timeout
				if is_instance_valid(card_node):
					card_node.queue_free()
		
		# 2. MOSTRAR O CARD CORRETO ESPECÍFICO
		_ativar_card_correto_especifico()
		
		print("✅ Troca concluída!")
	else:
		print("❌ RESPOSTA INCORRETA! Card não corresponde ao esperado.")
		# Se card incorreto, tentar fazer voltar para posição original
		if _card is CardResposta_2 and _card.has_method("voltar_para_original"):
			_card.voltar_para_original()
	
	# ⭐⭐ IMPORTANTE: Emitir sinal SEMPRE para que Fase_2.gd saiba o resultado
	resposta_recebida.emit(_valor_card, correto_para_esta_area)

# ⭐⭐ FUNÇÃO PARA ATIVAR CARD CORRETO
func _ativar_card_correto_especifico():
	print("🔍 Ativando card correto específico para: ", name)
	
	# MÉTODO 1: Tentar usar o sprite interno primeiro
	if card_correto_sprite and is_instance_valid(card_correto_sprite):
		card_correto_sprite.visible = true
		print("✅ Card correto interno ativado: ", name)
		print("   📍 Posição: ", card_correto_sprite.global_position)
		print("   🎨 Modulacao: ", card_correto_sprite.modulate)
		print("   📦 Z-index: ", card_correto_sprite.z_index)
		print("   👁️ Visible: ", card_correto_sprite.visible)
		print("   🖼️ Texture: ", card_correto_sprite.texture)
		# Verificar se está sendo escondido pelo pai
		var pai = card_correto_sprite.get_parent()
		if pai:
			print("   👪 Pai: ", pai.name, " | Visível: ", pai.visible)
		return
	
	# MÉTODO 2: Procurar card correto externo (Fase 2 usa Card_Correto_Fase_21, 22, 23)
	var numero_area = ""
	var regex = RegEx.new()
	if regex.compile("\\d+") == OK:
		var result = regex.search(name)
		if result:
			numero_area = result.get_string()
	
	if numero_area.is_empty():
		print("❌ Não foi possível extrair número da área: ", name)
		return
	
	# Na Fase 2, os cards são: Card_Correto_Fase_21, Card_Correto_Fase_22, Card_Correto_Fase_23
	var card_correto_path = "../Card_Correto_Fase_2%s" % numero_area
	print("🧭 Procurando card no caminho: ", card_correto_path)
	
	var card_correto = get_node_or_null(card_correto_path)
	
	if card_correto:
		card_correto.visible = true
		print("✅ Card correto externo ativado: ", card_correto.name)
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
	
	# MÉTODO 2: Esconder card externo (Fase 2 usa Card_Correto_Fase_21, 22, 23)
	var numero_area = ""
	var regex = RegEx.new()
	if regex.compile("\\d+") == OK:
		var result = regex.search(name)
		if result:
			numero_area = result.get_string()
	
	if not numero_area.is_empty():
		# Na Fase 2, os cards são: Card_Correto_Fase_21, Card_Correto_Fase_22, Card_Correto_Fase_23
		var card_correto_path = "../Card_Correto_Fase_2%s" % numero_area
		var card_correto = get_node_or_null(card_correto_path)
		if card_correto:
			card_correto.visible = false
			print("✅ Card correto externo escondido: ", card_correto.name)
		else:
			print("⚠️ Card correto não encontrado no caminho: ", card_correto_path)

func tem_card_correto_visivel() -> bool:
	# Verificar sprite interno
	if card_correto_sprite and is_instance_valid(card_correto_sprite):
		return card_correto_sprite.visible
	
	# Verificar card externo (Fase 2 usa Card_Correto_Fase_21, 22, 23)
	var numero_area = ""
	var regex = RegEx.new()
	if regex.compile("\\d+") == OK:
		var result = regex.search(name)
		if result:
			numero_area = result.get_string()
	
	if not numero_area.is_empty():
		# Na Fase 2, os cards são: Card_Correto_Fase_21, Card_Correto_Fase_22, Card_Correto_Fase_23
		var card_correto_path = "../Card_Correto_Fase_2%s" % numero_area
		var card_correto = get_node_or_null(card_correto_path)
		if card_correto:
			return card_correto.visible
	
	return false

func get_posicao_card_correto() -> Vector2:
	if card_correto_sprite and is_instance_valid(card_correto_sprite):
		return card_correto_sprite.global_position
	return global_position

func esta_correta() -> bool:
	return tem_card_correto

func resetar():
	tem_card_correto = false
	esconder_card_correto()

func get_info() -> String:
	return "AreaResposta_2: %s = %d (Correto: %s)" % [expressao, resultado_esperado, tem_card_correto]

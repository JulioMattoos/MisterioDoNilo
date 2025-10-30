extends Area2D
class_name AreaResposta

signal resposta_recebida(valor: int, correto_para_esta_area: bool)
signal card_entrou_na_area(area: AreaResposta, card: Object)

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
		push_warning("AreaResposta não foi configurada corretamente - use a função configurar()")

# ⭐ FUNÇÃO CRÍTICA: Inicializar o sprite
func _inicializar_sprite_card_correto():
	# Buscar o Sprite2D que já existe na cena
	card_correto_sprite = get_node_or_null("CardCorretoSprite")
	
	if card_correto_sprite:
		print("✅ Sprite encontrado para área: ", name)
		card_correto_sprite.visible = false  # Começar invisível
	else:
		print("❌ ERRO: CardCorretoSprite não encontrado na área: ", name)
		# Debug: listar todos os filhos para ver o que existe
		print("   Filhos disponíveis:")
		for child in get_children():
			print("   - ", child.name, " (", child.get_class(), ")")

func configurar(_resultado_esperado: int, _expressao: String):
	resultado_esperado = _resultado_esperado
	expressao = _expressao
	tem_card_correto = false

func _on_area_entered(area: Area2D):
	print("=== ÁREA DETECTOU ENTRADA ===")
	
	# Verificar se é um CardResposta
	if area is CardResposta:
		var card: CardResposta = area
		
		if not card.has_method("get_valor"):
			push_error("CardResposta não possui método get_valor()")
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
		if _card is CardResposta:
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
	
	# Buscar o card correto específico apenas desta área
	var card_correto_path = ""
	
	match name:
		"AreaResposta1Fase1":
			card_correto_path = "../Card_Correto_Fase_1"
		"AreaResposta2Fase1":
			card_correto_path = "../Card_Correto_Fase_2"
		"AreaResposta3Fase1":
			card_correto_path = "../Card_Correto_Fase_3"
		_:
			print("❌ Nome da área não reconhecido: ", name)
			return
	
	var card_correto = get_node_or_null(card_correto_path)
	
	if card_correto:
		card_correto.visible = true
		print("✅ Card correto ativado para área: ", name)
	else:
		print("❌ Card correto não encontrado para área: ", name)



func esconder_card_correto():
	if card_correto_sprite:
		card_correto_sprite.visible = false
		tem_card_correto = false
		print("🔲 Card correto escondido na área: ", name)

func tem_card_correto_visivel() -> bool:
	if card_correto_sprite:
		return card_correto_sprite.visible
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
	return "AreaResposta: %s = %d (Correto: %s)" % [expressao, resultado_esperado, tem_card_correto]

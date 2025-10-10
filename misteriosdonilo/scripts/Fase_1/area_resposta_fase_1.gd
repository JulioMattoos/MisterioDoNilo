extends Area2D
class_name AreaResposta

signal resposta_recebida(valor: int, correto_para_esta_area: bool)
signal card_entrou_na_area(area: AreaResposta, card: Object)

var resultado_esperado: int = 2
var expressao: String = ""
var tem_card_correto: bool = false

func _ready():
	# SOLUÇÃO: Verificar se já está conectado antes de conectar
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	
	if resultado_esperado == 0 and expressao.is_empty():
		push_warning("AreaResposta não foi configurada corretamente - use a função configurar()")

func configurar(_resultado_esperado: int, _expressao: String):
	resultado_esperado = _resultado_esperado
	expressao = _expressao
	tem_card_correto = false
	print("Área configurada: ", expressao, " = ", resultado_esperado)

func _on_area_entered(area: Area2D):
	print("=== ÁREA DETECTOU ENTRADA ===")
	
	# Verificar se a área tem um nó pai que seja um TextureRect (card arrastável)
	var card_node = area.get_parent()
	
	if card_node is TextureRect and card_node.has_method("_get_drag_data"):
		print("Card TextureRect detectado: ", card_node.name)
		card_entrou_na_area.emit(self, card_node)
		
		# Tentar obter o valor do card se possível
		if card_node.has_method("get_valor"):
			var valor_card: int = card_node.get_valor()
			_processar_resposta(valor_card, card_node)
		return
	
	# Verificação original para CardResposta (se for uma Area2D especializada)
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
	
	print("Card valor: ", _valor_card)
	print("Área espera: ", resultado_esperado, " (", expressao, ")")
	print("Correto para esta área: ", correto_para_esta_area)
	
	resposta_recebida.emit(_valor_card, correto_para_esta_area)

func esta_correta() -> bool:
	return tem_card_correto

func resetar():
	tem_card_correto = false

func get_info() -> String:
	return "AreaResposta: %s = %d (Correto: %s)" % [expressao, resultado_esperado, tem_card_correto]

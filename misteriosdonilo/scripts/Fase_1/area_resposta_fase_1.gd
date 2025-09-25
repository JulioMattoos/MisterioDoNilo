extends Area2D

class_name AreaResposta

# Sinal quando um card é solto nesta área
signal resposta_recebida(valor, eh_correta)

func _ready():
	# Conectar sinal de quando uma área entra
	connect("area_entered", _on_area_entered)

# Quando um card entra nesta área
func _on_area_entered(area):
	# Verificar se é um card
	if area is CardResposta:
		# Emitir sinal com os dados do card
		resposta_recebida.emit(area.get_valor(), area.eh_correta)

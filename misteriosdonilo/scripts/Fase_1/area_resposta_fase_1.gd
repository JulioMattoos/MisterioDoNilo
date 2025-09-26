extends Area2D
class_name AreaResposta

# Sinal quando um card é solto nesta área (valor, eh_correta)
signal resposta_recebida(valor, eh_correta)

func _ready():
	var cb = Callable(self, "_on_area_entered")
	if not is_connected("area_entered", cb):
		connect("area_entered", cb)

# Quando um card entra nesta área
func _on_area_entered(area):
	# Verificar se é um card (classe CardResposta)
	if area is CardResposta:
		# Emitir sinal com os dados do card
		emit_signal("resposta_recebida", area.get_valor(), area.eh_correta)

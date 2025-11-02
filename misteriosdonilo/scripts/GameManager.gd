extends Node

# Singleton para gerenciar o progresso do jogo (apenas na sessão atual)
var fase_1_completa: bool = false
var fase_2_completa: bool = false
var fase_3_completa: bool = false
var fase_3_1_completa: bool = false

# ⭐⭐ Variável para controlar se o DialogueBox já foi mostrado nesta sessão
var dialogue_box_mostrado: bool = false

func concluir_fase(numero_fase):
	if numero_fase == 1:
		fase_1_completa = true
		print("✅ Fase 1 marcada como concluída (sessão atual)")
	elif numero_fase == 2:
		fase_2_completa = true
		print("✅ Fase 2 marcada como concluída (sessão atual)")
	elif numero_fase == 3:
		fase_3_completa = true
		print("✅ Fase 3 marcada como concluída (sessão atual)")
	elif numero_fase == 3_1 or numero_fase == "3_1":
		fase_3_1_completa = true
		print("✅ Fase 3_1 marcada como concluída (sessão atual)")

func fase_concluida(numero_fase) -> bool:
	if numero_fase == 1:
		return fase_1_completa
	elif numero_fase == 2:
		return fase_2_completa
	elif numero_fase == 3:
		return fase_3_completa
	elif numero_fase == 3_1 or numero_fase == "3_1":
		return fase_3_1_completa
	return false

func resetar_progresso():
	fase_1_completa = false
	fase_2_completa = false
	fase_3_completa = false
	fase_3_1_completa = false
	print("🔄 Progresso resetado!")


extends Node

# Singleton para gerenciar o progresso do jogo (apenas na sessão atual)
var fase_1_completa: bool = false
var fase_2_completa: bool = false

func concluir_fase(numero_fase: int):
	if numero_fase == 1:
		fase_1_completa = true
		print("✅ Fase 1 marcada como concluída (sessão atual)")
	elif numero_fase == 2:
		fase_2_completa = true
		print("✅ Fase 2 marcada como concluída (sessão atual)")

func fase_concluida(numero_fase: int) -> bool:
	if numero_fase == 1:
		return fase_1_completa
	elif numero_fase == 2:
		return fase_2_completa
	return false

func resetar_progresso():
	fase_1_completa = false
	fase_2_completa = false
	print("🔄 Progresso resetado!")


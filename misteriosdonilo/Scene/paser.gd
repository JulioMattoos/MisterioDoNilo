extends CharacterBody2D

# Nota: dialogue_box_mostrado agora está no GameManager

# Variável para rastrear se o jogador está na área de interação.
var player_in_range = false

# Variável para controlar se o diálogo está ativo, para evitar múltiplas instâncias.
var dialogue_is_active = false

# Instância da cena de diálogo que será criada.
var dialogue_instance = null

# O Godot vai permitir que você arraste as cenas para esses campos no Inspector.
@export var dialogue_box_scene : PackedScene
@export var next_level_scene : PackedScene
@export var fase_2_scene : PackedScene  # ⭐⭐ Cena da fase 2

# ⭐⭐ Posições do Paser: posição inicial e posição após fase 1
var posicao_inicial: Vector2
var posicao_fase_2: Vector2 = Vector2(265, -71)  # ⭐⭐ Posição após concluir fase 1

func _ready():
	# Salvar posição inicial
	posicao_inicial = global_position
	
	# Verifica se a cena do diálogo foi atribuída no Inspector.
	# Isso ajuda a evitar o erro "Cannot call method 'instantiate' on a null value".
	if dialogue_box_scene == null:
		print("Erro: A cena de diálogo não foi atribuída no Inspector!")
	
	# Verifica se a cena da próxima fase foi atribuída no Inspector.
	if next_level_scene == null:
		print("Erro: A cena da próxima fase não foi atribuída no Inspector!")
	
	# ⭐⭐ Verificar se fase 1 foi concluída e mover Paser para nova posição
	_verificar_e_mover_paser()

func _process(delta):
	# Condição para depuração.
	# Verifica se a tecla de interação ("interact") foi pressionada.
	if Input.is_action_just_pressed("interact"):
		print("Tecla de interação pressionada!")

	# Condição para iniciar a interação:
	# 1. O jogador precisa estar na área.
	# 2. O diálogo não pode já estar ativo.
	# 3. A tecla de interação ("interact") foi pressionada.
	if player_in_range and not dialogue_is_active and Input.is_action_just_pressed("interact"):
		show_dialogue()
	# Condição para avançar ou fechar o diálogo:
	# 1. O diálogo precisa estar ativo.
	# 2. A tecla de interação foi pressionada.
	elif dialogue_is_active and Input.is_action_just_pressed("interact"):
		change_scene()

func _on_interaction_area_body_entered(body):
	print("Jogador entrou na area de interação")
	# Verifica se o corpo que entrou é o jogador.
	if body.is_in_group("player"):
		player_in_range = true

func _on_interaction_area_body_exited(body):
	print("Jogador saiu da area de colisão")
	if body.is_in_group("player"):
		player_in_range = false

func show_dialogue():
	# ⭐⭐ IMPORTANTE: Esconder o balão quando o DialogueBox aparecer
	_esconder_balao_imediato()
	
	# ⭐⭐ Marcar que o DialogueBox foi mostrado nesta sessão (usar GameManager)
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.dialogue_box_mostrado = true
		print("✅ DialogueBox marcado como mostrado. Balão não aparecerá mais nesta sessão.")
		print("📊 GameManager.dialogue_box_mostrado = ", gm.dialogue_box_mostrado)
	else:
		print("❌ ERRO: GameManager não encontrado!")
	
	# Garante que a cena de diálogo existe antes de tentar instanciá-la.
	if dialogue_box_scene != null:
		# Define o estado do diálogo como ativo.
		dialogue_is_active = true
		
		# Instancia a cena do DialogueBox e a adiciona à árvore de nós.
		dialogue_instance = dialogue_box_scene.instantiate()
		get_tree().root.add_child(dialogue_instance)
	else:
		# Imprime um erro se a cena não foi atribuída.
		print("Erro: Não é possível instanciar. A cena de diálogo é nula!")

func change_scene():
	dialogue_is_active = false
	
	if is_instance_valid(dialogue_instance):
		dialogue_instance.queue_free()
	
	# ⭐⭐ IMPORTANTE: Esconder o balão IMEDIATAMENTE antes de trocar a cena
	_esconder_balao_imediato()
	
	# ⭐⭐ Verificar qual fase carregar baseado no progresso
	var cena_para_carregar = null
	var gm = get_node_or_null("/root/GameManager")
	
	if gm:
		if gm.fase_concluida(1):
			# Se fase 1 foi concluída, carregar fase 2
			if fase_2_scene != null:
				cena_para_carregar = fase_2_scene.resource_path
				print("✅ Carregando Fase 2 (fase 1 já foi concluída)")
			else:
				print("⚠️ Fase 2 não configurada! Carregando Fase 1 como fallback.")
				cena_para_carregar = next_level_scene.resource_path if next_level_scene else null
		else:
			# Se fase 1 ainda não foi concluída, carregar fase 1
			cena_para_carregar = next_level_scene.resource_path if next_level_scene else null
			print("✅ Carregando Fase 1 (ainda não concluída)")
	else:
		# Fallback: sempre carregar fase 1 se GameManager não estiver disponível
		cena_para_carregar = next_level_scene.resource_path if next_level_scene else null
		print("⚠️ GameManager não encontrado. Carregando Fase 1 como padrão.")
	
	# Carregar a fase
	var tree = get_tree()
	if tree == null or not is_inside_tree():
		print("❌ ERRO: Árvore da cena não está disponível!")
		return
	
	if cena_para_carregar != null:
		tree.call_deferred("change_scene_to_file", cena_para_carregar)
	else:
		print("❌ ERRO: Nenhuma cena configurada para carregar!")

func _verificar_e_mover_paser():
	# Verificar se fase 1 foi concluída e mover Paser para nova posição
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if gm.fase_concluida(1):
			# Mover Paser para a posição da fase 2
			global_position = posicao_fase_2
			print("✅ Paser movido para posição da Fase 2: ", posicao_fase_2)
		else:
			# Manter Paser na posição inicial
			global_position = posicao_inicial
			print("✅ Paser mantido na posição inicial: ", posicao_inicial)
	else:
		# Se GameManager não estiver disponível, manter na posição inicial
		global_position = posicao_inicial
		print("⚠️ GameManager não encontrado. Paser mantido na posição inicial.")

func _esconder_balao_imediato():
	# Tentar encontrar e esconder o balão diretamente
	var balao = get_node_or_null("../CanvasLayer/BalaoFala")
	if balao:
		balao.visible = false
		balao.hide()
		print("✅ Balão escondido!")
	
	# Também tentar através da raiz da cena atual
	var root = get_tree().current_scene
	if root:
		balao = root.get_node_or_null("CanvasLayer/BalaoFala")
		if balao:
			balao.visible = false
			balao.hide()
			print("✅ Balão escondido através da raiz da cena!")
		
		# Procurar em todos os CanvasLayers na cena
		for canvas in root.find_children("*", "CanvasLayer", true, false):
			balao = canvas.get_node_or_null("BalaoFala")
			if balao:
				balao.visible = false
				balao.hide()
				print("✅ Balão encontrado e escondido em CanvasLayer!")

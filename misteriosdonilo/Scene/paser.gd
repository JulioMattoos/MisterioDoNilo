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

# ⭐⭐ Referência ao texto "Aperte Espaço"
var texto_aperte_espaco: Label = null
var canvas_layer: CanvasLayer = null

# ⭐⭐ Referência ao balão de fala acima do Paser
var balao_fala_paser: Sprite2D = null

func _ready():
	# Salvar posição inicial
	posicao_inicial = global_position
	
	# ⭐⭐ Buscar CanvasLayer na cena para adicionar o texto
	var root = get_tree().current_scene
	if root:
		canvas_layer = root.get_node_or_null("CanvasLayer")
		if not canvas_layer:
			# Se não encontrar, procurar em todos os CanvasLayers
			var canvas_layers = root.find_children("*", "CanvasLayer", true, false)
			if canvas_layers.size() > 0:
				canvas_layer = canvas_layers[0]
	
	# ⭐⭐ Buscar ou criar o texto "Aperte Espaço" no CanvasLayer
	if canvas_layer:
		texto_aperte_espaco = canvas_layer.get_node_or_null("TextoAperteEspaco")
		if not texto_aperte_espaco:
			# Criar Label se não existir
			texto_aperte_espaco = Label.new()
			texto_aperte_espaco.name = "TextoAperteEspaco"
			texto_aperte_espaco.text = "Aperte Espaço"
			texto_aperte_espaco.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			texto_aperte_espaco.add_theme_font_size_override("font_size", 32)
			texto_aperte_espaco.add_theme_color_override("font_color", Color.BLACK)
			texto_aperte_espaco.add_theme_color_override("font_shadow_color", Color.WHITE)
			texto_aperte_espaco.visible = false
			canvas_layer.add_child(texto_aperte_espaco)
			print("✅ Texto 'Aperte Espaço' criado no CanvasLayer!")
		else:
			texto_aperte_espaco.visible = false
			print("✅ Texto 'Aperte Espaço' encontrado no CanvasLayer!")
	else:
		print("⚠️ CanvasLayer não encontrado! Texto não será criado.")
	
	# Verifica se a cena do diálogo foi atribuída no Inspector.
	# Isso ajuda a evitar o erro "Cannot call method 'instantiate' on a null value".
	if dialogue_box_scene == null:
		print("Erro: A cena de diálogo não foi atribuída no Inspector!")
	
	# Verifica se a cena da próxima fase foi atribuída no Inspector.
	if next_level_scene == null:
		print("Erro: A cena da próxima fase não foi atribuída no Inspector!")
	
	# ⭐⭐ Criar balão de fala acima do Paser
	_criar_balao_fala_paser()
	
	# ⭐⭐ Verificar se fase 1 foi concluída e mover Paser para nova posição
	_verificar_e_mover_paser()

func _process(delta):
	# ⭐⭐ Garantir que o balão sempre está visível e acima do Paser
	# Mas não forçar se o DialogueBox estiver ativo (para não aparecer durante diálogo)
	if balao_fala_paser and not dialogue_is_active:
		if not balao_fala_paser.visible:
			balao_fala_paser.visible = true
			balao_fala_paser.show()
		# ⭐⭐ Atualizar posição do balão para ficar acima do sprite do Paser (mais próximo)
		# O sprite do Paser tem um offset, então precisamos compensar
		var sprite_paser = get_node_or_null("Sprite2D")
		if sprite_paser:
			# Posição relativa ao sprite do Paser (compensando o offset do sprite)
			# Mais próximo: mudado de -120 para -80
			balao_fala_paser.position = sprite_paser.position + Vector2(0, -80)
		else:
			# Fallback: posição acima do Paser (assumindo offset padrão)
			balao_fala_paser.position = Vector2(447.875, 269.875)  # offset sprite - nova altura (349.875 - 80)
	
	# ⭐⭐ Atualizar posição do texto continuamente se visível
	if texto_aperte_espaco and texto_aperte_espaco.visible:
		_atualizar_posicao_texto()
	
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
	# ⭐⭐ IMPORTANTE: Esconder os balões quando o DialogueBox aparecer
	_esconder_balao_imediato()
	_esconder_balao2_imediato()
	
	# ⭐⭐ Esconder balão acima do Paser e texto "Aperte Espaço" quando DialogueBox aparecer
	if balao_fala_paser:
		balao_fala_paser.visible = false
		balao_fala_paser.hide()
		print("✅ Balão de fala acima do Paser escondido!")
	
	if texto_aperte_espaco:
		texto_aperte_espaco.visible = false
		texto_aperte_espaco.hide()
		print("✅ Texto 'Aperte Espaço' escondido!")
	
	# ⭐⭐ Marcar que o DialogueBox foi mostrado nesta sessão (usar GameManager)
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.dialogue_box_mostrado = true
		print("✅ DialogueBox marcado como mostrado. Balões não aparecerão mais nesta sessão.")
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

func _criar_balao_fala_paser():
	# Buscar ou criar o balão de fala acima do Paser
	balao_fala_paser = get_node_or_null("BalaoFala")
	if not balao_fala_paser:
		# Obter o sprite do Paser para calcular a posição correta
		var sprite_paser = get_node_or_null("Sprite2D")
		var offset_sprite = Vector2(0, 0)
		if sprite_paser:
			offset_sprite = sprite_paser.position
			print("📍 Sprite do Paser encontrado com offset: ", offset_sprite)
		
		# Criar Sprite2D para o balão
		balao_fala_paser = Sprite2D.new()
		balao_fala_paser.name = "BalaoFala"
		
		# Carregar textura do balão
		var texture = load("res://imagens/mapa/fala.png")
		if texture:
			balao_fala_paser.texture = texture
			print("✅ Textura do balão carregada!")
		else:
			print("❌ ERRO: Não foi possível carregar a textura do balão!")
		
		# ⭐⭐ Posicionar acima do sprite do Paser (mais próximo)
		# O sprite tem offset de (447.875, 349.875), então precisamos compensar
		# Posição = offset do sprite + offset vertical para ficar acima (mais próximo agora)
		balao_fala_paser.position = offset_sprite + Vector2(0, -80)  # Mais próximo do Paser
		balao_fala_paser.scale = Vector2(0.4, 0.4)  # Ajustar tamanho
		balao_fala_paser.z_index = 10  # Garantir que aparece acima de outros elementos
		
		# ⭐⭐ Sempre visível desde o início
		balao_fala_paser.visible = true
		balao_fala_paser.show()
		
		# ⭐⭐ IMPORTANTE: Adicionar como filho DIRETO do Paser para seguir automaticamente
		add_child(balao_fala_paser)
		print("✅ Balão de fala criado acima do Paser como filho direto!")
		print("   Posição do balão: ", balao_fala_paser.position)
		print("   Visível: ", balao_fala_paser.visible)
	else:
		# Se já existir, garantir que está visível e com posição correta
		var sprite_paser = get_node_or_null("Sprite2D")
		if sprite_paser:
			balao_fala_paser.position = sprite_paser.position + Vector2(0, -80)  # Mais próximo do Paser
		balao_fala_paser.visible = true
		balao_fala_paser.show()
		print("✅ Balão de fala encontrado e VISÍVEL!")

func _verificar_e_mover_paser():
	# Verificar se fase 1 foi concluída e mover Paser para nova posição
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if gm.fase_concluida(1):
			# Mover Paser para a posição da fase 2
			global_position = posicao_fase_2
			
			# ⭐⭐ Garantir que balão de fala está visível (sempre visível)
			if balao_fala_paser:
				balao_fala_paser.visible = true
				balao_fala_paser.show()
				print("✅ Balão de fala visível acima do Paser!")
			
			# ⭐⭐ Mostrar e posicionar texto "Aperte Espaço" quando Paser estiver no novo local
			_atualizar_posicao_texto()
			if texto_aperte_espaco:
				texto_aperte_espaco.visible = true
				texto_aperte_espaco.show()
				print("✅ Texto 'Aperte Espaço' visível!")
			
			print("✅ Paser movido para posição da Fase 2: ", posicao_fase_2)
		else:
			# Manter Paser na posição inicial
			global_position = posicao_inicial
			
			# ⭐⭐ Garantir que balão de fala está visível (sempre visível)
			if balao_fala_paser:
				balao_fala_paser.visible = true
				balao_fala_paser.show()
			
			# ⭐⭐ Esconder texto quando Paser estiver na posição inicial
			if texto_aperte_espaco:
				texto_aperte_espaco.visible = false
				texto_aperte_espaco.hide()
			
			print("✅ Paser mantido na posição inicial: ", posicao_inicial)
	else:
		# Se GameManager não estiver disponível, manter na posição inicial
		global_position = posicao_inicial
		
		# ⭐⭐ Garantir que balão de fala está visível (sempre visível)
		if balao_fala_paser:
			balao_fala_paser.visible = true
			balao_fala_paser.show()
		
		# ⭐⭐ Esconder texto se GameManager não estiver disponível
		if texto_aperte_espaco:
			texto_aperte_espaco.visible = false
			texto_aperte_espaco.hide()
		
		print("⚠️ GameManager não encontrado. Paser mantido na posição inicial.")
	
	# Atualizar posição do texto continuamente se visível
	if texto_aperte_espaco and texto_aperte_espaco.visible:
		_atualizar_posicao_texto()

func _atualizar_posicao_texto():
	# Atualizar posição do texto para ficar acima do Paser na tela
	if not texto_aperte_espaco:
		return
	
	# Obter posição do Paser no mundo
	var pos_paser_mundo = global_position
	
	# Obter a câmera do Khepre para converter coordenadas do mundo para tela
	var khepre = get_tree().current_scene.get_node_or_null("Khepre")
	if khepre:
		var camera = khepre.get_node_or_null("Camera2D")
		if camera:
			# Converter posição do mundo para posição na tela usando a câmera
			var viewport = get_viewport()
			var screen_size = viewport.get_visible_rect().size
			var camera_pos = camera.global_position
			var zoom = camera.zoom
			
			# Calcular posição na tela
			var screen_pos = (pos_paser_mundo - camera_pos) * zoom + screen_size / 2.0
			
			# Posicionar texto acima do Paser (subtrair ~50 pixels para ficar acima)
			texto_aperte_espaco.position = Vector2(screen_pos.x - 100, screen_pos.y - 80)
			texto_aperte_espaco.size = Vector2(200, 30)
		else:
			# Fallback: usar posição fixa centralizada
			var viewport = get_viewport()
			var screen_size = viewport.get_visible_rect().size
			texto_aperte_espaco.position = Vector2(screen_size.x / 2 - 100, screen_size.y / 2 - 100)
			texto_aperte_espaco.size = Vector2(200, 30)
	else:
		# Fallback: usar posição fixa centralizada
		var viewport = get_viewport()
		var screen_size = viewport.get_visible_rect().size
		texto_aperte_espaco.position = Vector2(screen_size.x / 2 - 100, screen_size.y / 2 - 100)
		texto_aperte_espaco.size = Vector2(200, 30)

func _esconder_balao_imediato():
	# Tentar encontrar e esconder o balão diretamente
	var balao = get_node_or_null("../CanvasLayer/BalaoFala")
	if balao:
		balao.visible = false
		balao.hide()
		print("✅ Balão 1 escondido!")
	
	# Também tentar através da raiz da cena atual
	var root = get_tree().current_scene
	if root:
		balao = root.get_node_or_null("CanvasLayer/BalaoFala")
		if balao:
			balao.visible = false
			balao.hide()
			print("✅ Balão 1 escondido através da raiz da cena!")
		
		# Procurar em todos os CanvasLayers na cena
		for canvas in root.find_children("*", "CanvasLayer", true, false):
			balao = canvas.get_node_or_null("BalaoFala")
			if balao:
				balao.visible = false
				balao.hide()
				print("✅ Balão 1 encontrado e escondido em CanvasLayer!")

func _esconder_balao2_imediato():
	# Tentar encontrar e esconder o balão 2 diretamente
	var balao2 = get_node_or_null("../CanvasLayer/BalaoFala2")
	if balao2:
		balao2.visible = false
		balao2.hide()
		print("✅ Balão 2 escondido!")
	
	# Também tentar através da raiz da cena atual
	var root = get_tree().current_scene
	if root:
		balao2 = root.get_node_or_null("CanvasLayer/BalaoFala2")
		if balao2:
			balao2.visible = false
			balao2.hide()
			print("✅ Balão 2 escondido através da raiz da cena!")
		
		# Procurar em todos os CanvasLayers na cena
		for canvas in root.find_children("*", "CanvasLayer", true, false):
			balao2 = canvas.get_node_or_null("BalaoFala2")
			if balao2:
				balao2.visible = false
				balao2.hide()
				print("✅ Balão 2 encontrado e escondido em CanvasLayer!")

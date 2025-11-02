extends Node2D

# Array com os caminhos das imagens do rito final
var imagens_rito: Array[String] = [
	"res://imagens/rito_final/1.png",
	"res://imagens/rito_final/2.png",
	"res://imagens/rito_final/3.png",
	"res://imagens/rito_final/4.png",
	"res://imagens/rito_final/5.png",
	"res://imagens/rito_final/6.png"
]

var imagem_atual: int = 0
var espaco_pressionado: bool = false

@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready():
	print("🎬 Rito Final iniciado!")
	
	# Configurar o TextureRect para preencher a tela
	if texture_rect:
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Mostrar a primeira imagem
	mostrar_imagem_atual()

func _input(event):
	if event is InputEventKey and event.pressed:
		# Detectar tecla Espaço
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			espaco_pressionado = true
			print("⌨️ Tecla Espaço/Enter detectada!")
			avancar_imagem()

func mostrar_imagem_atual():
	if imagem_atual < imagens_rito.size():
		var caminho_imagem = imagens_rito[imagem_atual]
		var texture = load(caminho_imagem)
		
		if texture and texture_rect:
			texture_rect.texture = texture
			print("📸 Mostrando imagem ", imagem_atual + 1, "/", imagens_rito.size(), ": ", caminho_imagem)
		else:
			push_error("❌ Erro ao carregar imagem: " + caminho_imagem)
	else:
		print("🎊 Todas as imagens foram exibidas!")
		finalizar_rito()

func avancar_imagem():
	imagem_atual += 1
	
	if imagem_atual < imagens_rito.size():
		mostrar_imagem_atual()
	else:
		finalizar_rito()

func finalizar_rito():
	print("📝 Abrindo formulário de avaliação...")
	
	# Abrir o link do formulário no navegador
	var url = "https://forms.office.com/r/tXebFkRTku"
	OS.shell_open(url)
	
	print("✅ Navegador aberto com o formulário!")
	print("🎮 Encerrando o jogo...")
	
	# Aguardar um breve momento antes de fechar
	if get_tree():
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()
	else:
		push_error("❌ Erro: get_tree() retornou null ao tentar encerrar!")


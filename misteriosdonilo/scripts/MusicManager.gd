extends Node

var audio_player: AudioStreamPlayer
var musica_path = "res://musica/musica.mp3"

func _ready():
	print("🎵 MusicManager inicializado!")
	
	# Criar AudioStreamPlayer
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Carregar e tocar a música
	_carregar_e_tocar_musica()

func _carregar_e_tocar_musica():
	# Carregar o arquivo de áudio
	var audio_stream = load(musica_path)
	
	if audio_stream:
		# Configurar para tocar em loop
		if audio_stream is AudioStreamMP3:
			audio_stream.loop = true
		elif audio_stream is AudioStreamOggVorbis:
			audio_stream.loop = true
		
		# Configurar o stream
		audio_player.stream = audio_stream
		
		# ⭐⭐ Configurar volume para 15%
		audio_player.volume_db = linear_to_db(0.15)
		print("🔊 Volume configurado para 15%")
		
		# Tocar a música
		audio_player.play()
		print("✅ Música carregada e tocando em loop infinito!")
	else:
		print("❌ ERRO: Não foi possível carregar a música em: ", musica_path)

func parar_musica():
	if audio_player:
		audio_player.stop()
		print("⏹️ Música parada!")

func retomar_musica():
	if audio_player and not audio_player.playing:
		audio_player.play()
		print("▶️ Música retomada!")


extends Node

var soundPlayer := AudioStreamPlayer2D.new() 

func playSound(stream) -> void:
    soundPlayer.stream = stream
    soundPlayer.play()
    
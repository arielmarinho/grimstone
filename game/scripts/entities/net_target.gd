extends Node2D
class_name NetTarget
## NetTarget — alvo virtual dos mobs no SERVIDOR DEDICADO (sem player local)
## Representa o player online mais proximo; o dano vai por RPC pro cliente dele

var peer_id: int = 0
var dead: bool = false

extends standard_door
@export var key_type : String

func interact():
	if open == false and not $AnimationPlayer.is_playing(): 
		var player = Playerstatus.keepplayer
		for i in player.inventory.slots:
			if i.item != null:
				if i.item.name == key_type:
					i.amount -= 1
					if i.amount == 0: i.item = null
					opening()
	#elif open == true and not $AnimationPlayer.is_playing(): closing()

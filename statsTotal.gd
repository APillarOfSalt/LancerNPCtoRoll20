extends VBoxContainer

func changeAll(stats : Dictionary, tier : int):
	for s in stats.keys():
		match s:
			"edef":
				get_node("mid/E-Defense").changeNum(str(stats[s][tier]))
			"heatcap":
				get_node("mid/Heat Capacity").changeNum(str(stats[s][tier]))
			"size":
				$bot/Size.changeNum(str(stats[s][tier][0]))
			_:
				for c in get_children():
					for ch in c.get_children():
						if ch.name.to_lower() == s:
							ch.changeNum(str(stats[s][tier]))

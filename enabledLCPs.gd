extends MenuButton

var bigDaddy : Node

func _ready() -> void:
	get_popup().connect("id_pressed", self, "_on_PopupMenu_id_pressed")


func _on_PopupMenu_id_pressed(id: int) -> void:
	var checked = !get_popup().is_item_checked(id)
	get_popup().set_item_checked(id, checked)
	var named = get_popup().get_item_text(id)
	bigDaddy.lcpIO(named, checked)

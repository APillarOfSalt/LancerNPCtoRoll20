extends Node


var styleboxes : Dictionary = {
	"set" : preload("res://settingsStylebox.tres"),
	"setDel" : preload("res://settingsDeleteStylebox.tres"),
	"gms" : preload("res://GMSredStylebox.tres"),
	"hor" : preload("res://HORUSstylebox.tres"),
	"aps" : preload("res://stylebox.tres")
}

var defaultStylebox : StyleBox = styleboxes.aps

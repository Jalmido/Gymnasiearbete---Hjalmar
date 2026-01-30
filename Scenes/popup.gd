extends Control

func _TipPopup():
	$UI/ItemPopup.popup()
	
func _HideTipPopup():
	$UI/ItemPopup.hide()

extends Node
signal buttonPressed(idx:int)
func callbuttonPressed(idx:int):
	buttonPressed.emit(idx)

extends Control
@onready var optionList = $OptionScroller/OptionList
@onready var btnTemplate = $ButtonTemplate
@export var stageNames: Array[String]
@export var optionNames: Array[String]
@export var stagePreviewImages: Array[Texture2D]
@onready var midbars = $Midbars
@onready var stagePreviewPic = $StagePreviewImage
@onready var header = $OptionsHeader
@onready var stageHeader = $PreviewHeader
@onready var description = $OptionDescription
@export var descriptions: Array[String]
var selectedStage=-1
enum MENUS{
	STAGES,
	EDITMAIN
}
var menu:MENUS = MENUS.STAGES

func _ready() -> void:
	Global.buttonPressed.connect(btnPressed)
	btnTemplate.visible=false
	refreshMenu()

func refreshMenu():
	if selectedStage>-1:
		stageHeader.text = stageNames[selectedStage]
	else:
		stageHeader.text = "No Stage Selected"
	for i in optionList.get_children():
		i.queue_free()
	match menu:
		MENUS.STAGES:
			header.text = "Select Stage"
			for i in stageNames.size():
				var newBtn= btnTemplate.duplicate()
				newBtn.text=stageNames[i]
				newBtn.visible=true
				if i>=10 and i!=15:
					newBtn.modulate.g=0.75
					newBtn.modulate.b=0.75
				optionList.add_child(newBtn)
		MENUS.EDITMAIN:
			header.text = "Editing Stage"
			for i in optionNames.size():
				var newBtn= btnTemplate.duplicate()
				newBtn.text=optionNames[i]
				newBtn.visible=true
				#if i>=10 and i!=15:
				#	newBtn.modulate.g=0.75
				#	newBtn.modulate.b=0.75
				optionList.add_child(newBtn)

func _process(delta: float) -> void:
	midbars.position.y=fmod(midbars.position.y+delta*50.0+64.0,64.0)-64.0
	stagePreviewPic.visible=false
	description.visible=false
	if menu == MENUS.STAGES:
		for i in optionList.get_children():
			if i.is_hovered():
				stagePreviewPic.visible=true
				if i.get_index()+1<=stagePreviewImages.size():
					stagePreviewPic.texture=stagePreviewImages[i.get_index()]
	elif menu == MENUS.EDITMAIN:
		for i in optionList.get_children():
			if i.is_hovered():
				description.visible=true
				description.text=descriptions[i.get_index()]
func btnPressed(idx:int):
	selectedStage=idx
	menu=MENUS.EDITMAIN
	refreshMenu()

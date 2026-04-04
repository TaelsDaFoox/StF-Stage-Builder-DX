extends Control
@onready var optionList = $OptionScroller/OptionList
@onready var btnTemplate = $ButtonTemplate
@export var stageNames: Array[String]
@export var optionNames: Array[String]
@export var mainMenuOptions: Array[String]
@export var stagePreviewImages: Array[Texture2D]
@onready var midbars = $Midbars
@onready var stagePreviewPic = $StagePreviewImage
@onready var header = $OptionsHeader
@onready var stageHeader = $PreviewHeader
@onready var description = $OptionDescription
@export var descriptions: Array[String]
@onready var sfxMove = $SFX/Move
@onready var sfxConfirm = $SFX/Confirm
@onready var sfxBack = $SFX/Back
@onready var lineEditTemplate = $LineEditTemplate
var romPath:String
var selectedStage=-1
enum MENUS{
	MAIN,
	STAGES,
	EDITMAIN,
	SETPATH
}
var menu:MENUS = MENUS.MAIN

func _ready() -> void:
	Global.buttonPressed.connect(btnPressed)
	btnTemplate.visible=false
	lineEditTemplate.visible=false
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
		MENUS.MAIN:
			header.text = "Main Menu"
			for i in mainMenuOptions.size():
				var newBtn= btnTemplate.duplicate()
				newBtn.text=mainMenuOptions[i]
				newBtn.visible=true
				#if i<4:
				#	newBtn.disabled=true
				optionList.add_child(newBtn)
		MENUS.SETPATH:
			header.text = "Set ROM Path"
			var newBtn= lineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.placeholder_text="Path to rom_code1.bin"
			optionList.add_child(newBtn)
			newBtn=btnTemplate.duplicate()
			newBtn.visible=true
			newBtn.text="Done!"
			optionList.add_child(newBtn)


func _process(delta: float) -> void:
	midbars.position.y=fmod(midbars.position.y+delta*50.0+64.0,64.0)-64.0
	stagePreviewPic.visible=false
	description.visible=false
	match menu:
		MENUS.STAGES:
			for i in optionList.get_children():
				if i.is_hovered():
					stagePreviewPic.visible=true
					if i.get_index()+1<=stagePreviewImages.size():
						stagePreviewPic.texture=stagePreviewImages[i.get_index()]
		MENUS.EDITMAIN:
			for i in optionList.get_children():
				if i.is_hovered():
					description.visible=true
					description.text=descriptions[i.get_index()]
		MENUS.SETPATH:
			description.visible=true
			description.text="Enter the path to rom_code1.bin in your Sonic the Fighters installation.\n\nIt should be located in your RPCS3 folder at:\n\ndev_hdd0/game/NPUB30927/USRDIR/rom/stf_rom/rom_code1.bin"
func btnPressed(idx:int):
	sfxConfirm.play()
	match menu:
		MENUS.STAGES:
			selectedStage=idx
			menu=MENUS.EDITMAIN
			refreshMenu()
		MENUS.MAIN:
			match idx:
				0:
					menu=MENUS.STAGES
				4:
					menu=MENUS.SETPATH
			refreshMenu()
		MENUS.SETPATH:
			menu=MENUS.MAIN
			refreshMenu()

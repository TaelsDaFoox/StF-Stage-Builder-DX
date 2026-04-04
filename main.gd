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
@export var stageRomOffsets: Array[String] = ["0x8F3D0","0x8F4D0","0x8F5D0","0x8F6D0","0x8F7D0","0x8F8D0","0x8F9D0","0x8FAD0","0x8FBD0","0x8FCD0","0x8FDD0","0x8FED0","0x8FFD0","0x900D0","0x901D0","0x902D0"]
@onready var sfxMove = $SFX/Move
@onready var sfxConfirm = $SFX/Confirm
@onready var sfxBack = $SFX/Back
@onready var lineEditTemplate = $LineEditTemplate
@onready var backBtn = $BackButton
var romPath:String
#var rom
var selectedStage=-1
enum MENUS{
	MAIN,
	STAGES,
	EDITMAIN,
	SETPATH,
	PLATFORM
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
	backBtn.visible=true
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
			backBtn.visible=false
			header.text = "Main Menu"
			for i in mainMenuOptions.size():
				var newBtn= btnTemplate.duplicate()
				newBtn.text=mainMenuOptions[i]
				newBtn.visible=true
				if i<4 and !romPath:
					newBtn.disabled=true
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
		MENUS.PLATFORM:
			header.text="Platform Model"
			description.visible=true
			var gotValue=ReadFromRomWithStageOffset("0x1A".hex_to_int())
			description.text="Original model ID:\n"+str(gotValue)
			var newBtn= lineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.placeholder_text="New Model ID"
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
		MENUS.PLATFORM:
			description.visible=true
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
			romPath=optionList.get_node("LineEditTemplate").text
			var rom = FileAccess.open(romPath, FileAccess.READ)
			if rom == null:
				print("Failed to open file: ", romPath)
				print("Error: ", FileAccess.get_open_error())
			else:
				rom.close()
				menu=MENUS.MAIN
				refreshMenu()
		MENUS.EDITMAIN:
			match idx:
				8:
					menu=MENUS.PLATFORM
					refreshMenu()
		MENUS.PLATFORM:
			if optionList.get_node("LineEditTemplate").text.is_valid_int():
				var newValue = int(optionList.get_node("LineEditTemplate").text)
				WriteToRomWithStageOffset(newValue,"0x1A".hex_to_int())
				menu=MENUS.EDITMAIN
				refreshMenu()
func WriteToRomWithStageOffset(value:int,offset:int):
	if selectedStage!=-1 and romPath:
		var rom = FileAccess.open(romPath, FileAccess.READ_WRITE)
		rom.seek(stageRomOffsets[selectedStage].hex_to_int()+offset)
		rom.store_16(value)
		rom.close()
func ReadFromRomWithStageOffset(offset:int) -> int:
	if selectedStage!=-1 and romPath:
		var rom = FileAccess.open(romPath, FileAccess.READ)
		rom.seek(stageRomOffsets[selectedStage].hex_to_int()+offset)
		var gotValue = rom.get_16()
		rom.close()
		return gotValue
	return -1


func _on_back_button_pressed() -> void:
	sfxConfirm.play()
	match menu:
		MENUS.EDITMAIN:
			selectedStage=-1
			menu=MENUS.STAGES
		MENUS.STAGES:
			menu=MENUS.MAIN
		MENUS.SETPATH:
			menu=MENUS.MAIN
		MENUS.PLATFORM:
			menu=MENUS.EDITMAIN
	refreshMenu()

func _on_back_button_mouse_entered() -> void:
	sfxMove.play()

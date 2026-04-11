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
@onready var errorLog = $ErrorLog
@onready var colorPickTemplate=$ColorPickerTemplate
@onready var labelledLineEditTemplate=$LabelledLineEditTemplate
var romPath:String
var geraldDir:String
#var rom
var selectedStage=-1
enum MENUS{
	MAIN,
	STAGES,
	EDITMAIN,
	SETPATH,
	STAGEDATA,
	BRIGHTNESS,
	POSITION,
	TEXPAL,
	RGB,
	MUSICID,
	SKYCOLOR,
	FLOOR,
	PLATFORM,
	POLE,
	EXTRA,
	OBJECTS,
	WALLS,
	PROPERTY,
	DSP,
	CLOUDS,
	SOKO,
	WALLHEIGHT,
	ARENASCALE
}
var menu:MENUS = MENUS.MAIN

func _ready() -> void:
	var config = FileAccess.open("user://config.txt", FileAccess.READ)
	if config:
		romPath=config.get_line()
		geraldDir=config.get_line()
	
	Global.buttonPressed.connect(btnPressed)
	btnTemplate.visible=false
	lineEditTemplate.visible=false
	refreshMenu()

func refreshMenu():
	errorLog.text=""
	if selectedStage>-1:
		stageHeader.text = stageNames[selectedStage]
	else:
		stageHeader.text = "No Stage Selected"
	for i in optionList.get_children():
		i.queue_free()
	backBtn.visible=true
	backBtn.text="Cancel"
	match menu:
		MENUS.STAGES:
			backBtn.text="Go Back"
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
			backBtn.text="Go Back"
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
			backBtn.text="Go Back"
			backBtn.visible=false
			header.text = "Main Menu"
			for i in mainMenuOptions.size():
				var newBtn= btnTemplate.duplicate()
				newBtn.text=mainMenuOptions[i]
				newBtn.visible=true
				if i<3 and !romPath:
					newBtn.disabled=true
				optionList.add_child(newBtn)
		MENUS.SETPATH:
			header.text = "Set ROM Path"
			var newBtn= lineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.placeholder_text="Path to rom_code1.bin"
			if romPath:
				newBtn.text=romPath
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
			newBtn.text=str(gotValue)
			optionList.add_child(newBtn)
			newBtn=btnTemplate.duplicate()
			newBtn.visible=true
			newBtn.text="Confirm!"
			optionList.add_child(newBtn)
		MENUS.FLOOR:
			header.text="Floor Model"
			description.visible=true
			var gotValue=ReadFromRomWithStageOffset("0x18".hex_to_int())
			description.text="Original model ID:\n"+str(gotValue)
			var newBtn= lineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.placeholder_text="New Model ID"
			newBtn.text=str(gotValue)
			optionList.add_child(newBtn)
			newBtn=btnTemplate.duplicate()
			newBtn.visible=true
			newBtn.text="Confirm!"
			optionList.add_child(newBtn)
		MENUS.POLE:
			header.text="Pole Model"
			description.visible=true
			var gotValue=ReadFromRomWithStageOffset("0x1C".hex_to_int())
			description.text="Original model ID:\n"+str(gotValue)
			var newBtn= lineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.placeholder_text="New Model ID"
			newBtn.text = str(gotValue)
			optionList.add_child(newBtn)
			newBtn=btnTemplate.duplicate()
			newBtn.visible=true
			newBtn.text="Confirm!"
			optionList.add_child(newBtn)
		MENUS.RGB:
			header.text="Lighting Color"
			description.visible=true
			var rgb=ReadRGBFromRomWithStageOffset("0x10".hex_to_int())
			description.text="Original Color:\n"+str(rgb)
			var newBtn= colorPickTemplate.duplicate()
			newBtn.get_node("ColorPickerButton").color=Color.from_rgba8(rgb[0]*1.9921875,rgb[1]*1.9921875,rgb[2]*1.9921875,255)
			newBtn.visible=true
			optionList.add_child(newBtn)
			newBtn=btnTemplate.duplicate()
			newBtn.visible=true
			newBtn.text="Confirm!"
			optionList.add_child(newBtn)
		MENUS.WALLS:
			header.text="Wall Models"
			#description.visible=true
			#var gotValue=ReadFromRomWithStageOffset("0x18".hex_to_int())
			#description.text="Original model ID:\n"+str(gotValue)
			var newBtn= labelledLineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.get_node("LineEdit").placeholder_text="Wall Model 1"
			newBtn.get_node("LineEdit").text=str(ReadFromRomWithStageOffset(132))
			newBtn.get_node("LabelMargin/Label").text="Wall Models (Static)"
			optionList.add_child(newBtn)
			for i in 7:
				newBtn= lineEditTemplate.duplicate()
				newBtn.visible=true
				newBtn.placeholder_text="Wall Model "+str(i+2)
				newBtn.text=str(ReadFromRomWithStageOffset(132+(i+1)*2))
				optionList.add_child(newBtn)
			
			newBtn= labelledLineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.get_node("LineEdit").placeholder_text="Wall Model 1 (Shake 1)"
			newBtn.get_node("LineEdit").text=str(ReadFromRomWithStageOffset(148))
			newBtn.get_node("LabelMargin/Label").text="Wall Models (Shake frame 1)"
			optionList.add_child(newBtn)
			for i in 7:
				newBtn= lineEditTemplate.duplicate()
				newBtn.visible=true
				newBtn.text=str(ReadFromRomWithStageOffset(148+(i+1)*2))
				newBtn.placeholder_text="Wall Model "+str(i+2)+" (Shake 1)"
				optionList.add_child(newBtn)
			
			newBtn= labelledLineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.get_node("LineEdit").placeholder_text="Wall Model 1 (Shake 2)"
			newBtn.get_node("LineEdit").text=str(ReadFromRomWithStageOffset(164))
			newBtn.get_node("LabelMargin/Label").text="Wall Models (Shake frame 2)"
			optionList.add_child(newBtn)
			for i in 7:
				newBtn= lineEditTemplate.duplicate()
				newBtn.visible=true
				newBtn.text=str(ReadFromRomWithStageOffset(164+(i+1)*2))
				newBtn.placeholder_text="Wall Model "+str(i+2)+" (Shake 2)"
				optionList.add_child(newBtn)
			
			newBtn=btnTemplate.duplicate()
			newBtn.visible=true
			newBtn.text="Confirm!"
			optionList.add_child(newBtn)
			description.text="Define up to 8 models to be used for a wall.\n(which is then duplicated for the other 3 walls, they can't be unique.)\nWalls briefly use different models when being shaken, though the vanilla game doesn't use this feature, as it defines the same models for all 3 frames."
		MENUS.TEXPAL:
			header.text="Texture/Palette"
			var newBtn= labelledLineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.get_node("LineEdit").placeholder_text="Texture Set ID"
			newBtn.get_node("LineEdit").text=str(ReadFromRomWithStageOffset(12))
			newBtn.get_node("LabelMargin/Label").text="Texture Set ID"
			optionList.add_child(newBtn)
			newBtn= labelledLineEditTemplate.duplicate()
			newBtn.visible=true
			newBtn.get_node("LineEdit").placeholder_text="Palette Set ID"
			newBtn.get_node("LineEdit").text=str(ReadFromRomWithStageOffset(14))
			newBtn.get_node("LabelMargin/Label").text="Palette Set ID"
			optionList.add_child(newBtn)
			
			newBtn=btnTemplate.duplicate()
			newBtn.visible=true
			newBtn.text="Confirm!"
			optionList.add_child(newBtn)
			description.text="Texture set cheat sheet:\n2: South Island\n3: Mushroom Hill\n4: Flying Carpet\n5: Dynamite Plant\n6: Giant Wing\n7: Casino Night\n8: Aurora Icefield\n9: Death Egg II\n10: Canyon Cruise"
func _process(delta: float) -> void:
	midbars.position.y=fmod(midbars.position.y+delta*50.0+64.0,64.0)-64.0
	stagePreviewPic.visible=false
	description.visible=false
	match menu:
		MENUS.STAGES:
			for i in optionList.get_children():
				if i.is_hovered():
					stagePreviewPic.visible=true
					stagePreviewPic.modulate=Color.WHITE
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
		MENUS.FLOOR:
			description.visible=true
		MENUS.POLE:
			description.visible=true
		MENUS.RGB:
			stagePreviewPic.visible=true
			stagePreviewPic.texture=stagePreviewImages[selectedStage]
			stagePreviewPic.modulate=optionList.get_node("ColorPickerTemplate/ColorPickerButton").color
		MENUS.WALLS:
			description.visible=true
		MENUS.TEXPAL:
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
				errorLog.text="Failed to open ROM file."
				sfxBack.play()
				print("Failed to open file: ", romPath)
				print("Error: ", FileAccess.get_open_error())
			else:
				rom.close()
				var config = FileAccess.open("user://config.txt", FileAccess.WRITE)
				config.store_line(romPath)
				config.store_line(geraldDir)
				config.close()
				menu=MENUS.MAIN
				refreshMenu()
		MENUS.EDITMAIN:
			match idx:
				3:
					menu=MENUS.TEXPAL
				4:
					menu=MENUS.RGB
				7:
					menu=MENUS.FLOOR
				8:
					menu=MENUS.PLATFORM
				9:
					menu=MENUS.POLE
				12:
					menu=MENUS.WALLS
			refreshMenu()
		MENUS.PLATFORM:
			if optionList.get_node("LineEditTemplate").text.is_valid_int():
				var newValue = int(optionList.get_node("LineEditTemplate").text)
				var result = WriteToRomWithStageOffset(newValue,"0x1A".hex_to_int())
				if result:
					menu=MENUS.EDITMAIN
					refreshMenu()
				else:
					errorLog.text="Something went wrong.\nIs the game still running? (It shouldn't be!)"
					sfxBack.play()
			else:
				errorLog.text="Invalid number!"
				sfxBack.play()
		MENUS.FLOOR:
			if optionList.get_node("LineEditTemplate").text.is_valid_int():
				var newValue = int(optionList.get_node("LineEditTemplate").text)
				var result = WriteToRomWithStageOffset(newValue,"0x18".hex_to_int())
				if result:
					menu=MENUS.EDITMAIN
					refreshMenu()
				else:
					errorLog.text="Something went wrong.\nIs the game still running? (It shouldn't be!)"
					sfxBack.play()
			else:
				errorLog.text="Invalid number!"
				sfxBack.play()
		MENUS.POLE:
			if optionList.get_node("LineEditTemplate").text.is_valid_int():
				var newValue = int(optionList.get_node("LineEditTemplate").text)
				var result = WriteToRomWithStageOffset(newValue,"0x1C".hex_to_int())
				if result:
					menu=MENUS.EDITMAIN
					refreshMenu()
				else:
					errorLog.text="Something went wrong.\nIs the game still running? (It shouldn't be!)"
					sfxBack.play()
			else:
				errorLog.text="Invalid number!"
				sfxBack.play()
		MENUS.RGB:
			var color = optionList.get_node("ColorPickerTemplate/ColorPickerButton").color
			var result = WriteByteArrayToRomWithStageOffset([int(color.r*128),int(color.g*128),int(color.b*128)],"0x10".hex_to_int())
			if result:
				menu=MENUS.EDITMAIN
				refreshMenu()
			else:
				errorLog.text="Something went wrong.\nIs the game still running? (It shouldn't be!)"
				sfxBack.play()
		MENUS.WALLS:
			for i in optionList.get_children():
				if i.name!="ButtonTemplate":
					if i.get_child_count()>0:
						var write = WriteToRomWithStageOffset(int(i.get_node("LineEdit").text),132+i.get_index()*2)
					else:
						var write = WriteToRomWithStageOffset(int(i.text),132+i.get_index()*2)
			menu=MENUS.EDITMAIN
			refreshMenu()
		MENUS.TEXPAL:
			WriteToRomWithStageOffset(int(optionList.get_child(0).get_node("LineEdit").text),12)
			WriteToRomWithStageOffset(int(optionList.get_child(1).get_node("LineEdit").text),14)
			menu=MENUS.EDITMAIN
			refreshMenu()
func WriteToRomWithStageOffset(value:int,offset:int) -> bool:
	if selectedStage!=-1 and romPath:
		var rom = FileAccess.open(romPath, FileAccess.READ_WRITE)
		rom.seek(stageRomOffsets[selectedStage].hex_to_int()+offset)
		var didItWork = rom.store_16(value)
		rom.close()
		return didItWork
	return false
func WriteByteArrayToRomWithStageOffset(value:Array[int],offset:int) -> bool:
	if selectedStage!=-1 and romPath:
		var rom = FileAccess.open(romPath, FileAccess.READ_WRITE)
		rom.seek(stageRomOffsets[selectedStage].hex_to_int()+offset)
		var didItWork=false
		for i in value:
			didItWork = rom.store_8(i)
		rom.close()
		return didItWork
	return false
func ReadFromRomWithStageOffset(offset:int) -> int:
	if selectedStage!=-1 and romPath:
		var rom = FileAccess.open(romPath, FileAccess.READ)
		rom.seek(stageRomOffsets[selectedStage].hex_to_int()+offset)
		var gotValue = rom.get_16()
		rom.close()
		return gotValue
	return -1
func ReadRGBFromRomWithStageOffset(offset:int) -> Array[int]:
	if selectedStage!=-1 and romPath:
		var rom = FileAccess.open(romPath, FileAccess.READ)
		rom.seek(stageRomOffsets[selectedStage].hex_to_int()+offset)
		var gotValue:Array[int]=[]
		for i in 3:
			gotValue.append(rom.get_8())
		rom.close()
		return gotValue
	return []


func _on_back_button_pressed() -> void:
	sfxBack.play()
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
		MENUS.FLOOR:
			menu=MENUS.EDITMAIN
		MENUS.POLE:
			menu=MENUS.EDITMAIN
		MENUS.RGB:
			menu=MENUS.EDITMAIN
		MENUS.WALLS:
			menu=MENUS.EDITMAIN
		MENUS.TEXPAL:
			menu=MENUS.EDITMAIN
	refreshMenu()

func _on_back_button_mouse_entered() -> void:
	sfxMove.play()

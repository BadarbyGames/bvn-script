@tool
extends BVN_Resources

## This is general information about the visual novel
class_name BVN_VisualNovel

@export var characters:Array[BVN_CharacterSheet]

var character_cache:Dictionary = {}
func find_character_by_name(char_name:String) -> BVN_CharacterSheet:
	var tmp := char_name.to_lower()
	
	var found:BVN_CharacterSheet = character_cache.get(tmp,null)
	if found: return found
	
	for character in characters:
		if character.display_name.to_lower().begins_with(tmp):
			character_cache[tmp] = character
			return character
	return null

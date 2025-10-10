@tool
extends BVN_Resources

## This is general information about the visual novel
class_name BVN_VisualNovel

@export var characters:Array[BVN_CharacterSheet]:
	set(v):
		characters = v
		_rebuild_cache()

func _init() -> void:
	_rebuild_cache()
	
var character_cache:Dictionary[String, BVN_CharacterSheet] = {}
var alias_cache:Dictionary[String, BVN_CharacterSheet] = {}
func find_character_by_name(char_name:String) -> BVN_CharacterSheet:
	
	
	char_name = char_name.to_lower() if char_name else ".narrator"
	var found := alias_cache.get(
		char_name, 
		character_cache.get(char_name)
	)
	
	#region EDITOR LOGIC
	if !found and Engine.is_editor_hint():
		# If in editor, you can change character's names. This is a problem because
		# The cache is added _on_init() so in the editor its easier if we just rebuild the cache
		# if it doesnt exist to be double sure
		_rebuild_cache()
		
		found = alias_cache.get(
			char_name, 
			character_cache.get(char_name)
		)
	#endregion
	
	return found
	
func _rebuild_cache():
	character_cache.clear()
	alias_cache.clear()
	var narrator:BVN_CharacterSheet
	for i in characters.size():
		var character := characters[i]
		if character == null: 
			# When adding a new element via inspector, it starts as null. 
			continue
		if character.is_narrator:
			if narrator:
				var identifier := '%s'
				if character.alias:
					identifier += ' with alias(%s)' % ','.join(character.alias)
				identifier += str(' at index ', i)
				printerr("Found another narrator %s " % identifier)
			else:
				narrator = character
		
		if character_cache.has(character.display_name):
			var identifier := character.display_name
			if character.alias:
				identifier += ' with alias(%s)' % ','.join(character.alias)
			identifier += str(' at index ', i)
			printerr("⚠ '%s' is not unique. You will not be able to access this character by display name." % identifier)
		else:
			character_cache[character.display_name.to_lower()] = character
			
		for alias in character.alias:
			if alias_cache.has(alias):
				var identifier := alias
				if character.alias:
					identifier += ' with alias(%s)' % ','.join(character.alias)
				identifier += str(' at index ', i)
				printerr("⚠ Alias '%s' from '%s' is not unique. You will not be able to access this character by this alias." % [alias, identifier])
			else:
				alias_cache[alias.to_lower()] = character.to_lower()
				
	if !narrator:
		narrator = BVN_CharacterSheet.new()
		narrator.display_name = ""
		narrator.alias = [".narrator"]
	alias_cache[".narrator"] = narrator

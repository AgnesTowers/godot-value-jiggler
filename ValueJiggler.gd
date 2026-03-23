@tool
class_name ValueJiggler extends Node

@export var target_node: Node:
	get:
		return target_node
	set(value):
		target_node = value
		if value != null:
			_array = target_node.get_property_list()
		else:
			_array = []

var _target_property: String:
	get: 
		return _target_property
	set(value):
		_target_property = value
		notify_property_list_changed()

var _array:Array[Dictionary]:
	get:
		return _array
	set(value):
			_array = value
			update_configuration_warnings()
			notify_property_list_changed.call_deferred()
			if value.is_empty():
				_target_property = ""
			
var _jiggle_base

@export var _jiggle_strength: float = 30.0
@export var _jiggle_duration: float = 0.07
@export_range(1, 100) var _number_of_jiggles: int = 4
@export var _tweens_easy_type: Tween.EaseType = Tween.EaseType.EASE_IN
@export var _tweens_trans_type: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var _recalc_with_every_jiggle = false
@export var _min_value: float = -10.0
@export var _max_value: float = 10.0

var _inital_value
var _tween: Tween

func _get_property_list():
	
	var properties = []
	
	properties.append({
		"name" : "_target_property",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : _array_to_string(_array),
		"usage" : PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
	})
	
	if target_node != null and _target_property != "":
	
		var target_property_type: Variant.Type = _get_property_by_name(_target_property).get("type")
		var target_property_hint: PropertyHint = _get_property_by_name(_target_property).get("hint")
		var target_property_hint_string: String = _get_property_by_name(_target_property).get("hint_string")
		
		properties.append({
			"name" : "_initial_value",
			"type" : target_property_type,
			"hint" : PropertyHint.PROPERTY_HINT_NONE,
			"usage" : PropertyUsageFlags.PROPERTY_USAGE_STORAGE
		})
	
	return properties


func _ready() -> void:
	
	_get_property_list()
	
	if !Engine.is_editor_hint():
		_inital_value = target_node.get(_target_property)
		_tween = _set_up_tween()
		_tween.stop()
	pass

func jiggle() -> void:
	_tween = _set_up_tween()
	_tween.play()


func _set_up_tween() -> Tween:
	var new_tween: Tween
	
	new_tween = create_tween()
	new_tween.bind_node(target_node)
	new_tween.set_ease(_tweens_easy_type)
	new_tween.set_trans(_tweens_trans_type)
	for i: int in _number_of_jiggles:
		new_tween.tween_property(
			target_node, 
			_target_property,  
			_inital_value + _randomized_property(typeof(_inital_value)) * _jiggle_strength,
			_jiggle_duration).from(_inital_value)
	
	new_tween.finished.connect(func() -> void:
		new_tween.stop()
		target_node.set(_target_property, _inital_value)
	)
	return new_tween

func _array_to_string(arr: Array[Dictionary], separator = ",") -> String:
	var string: String = ""
	for i: Dictionary in arr:
		if i.get("usage") == PropertyUsageFlags.PROPERTY_USAGE_DEFAULT || i.get("usage") == PropertyUsageFlags.PROPERTY_USAGE_EDITOR:
			string += str(i.get("name")) + separator
	return string

func _get_property_by_name(name :String) -> Dictionary:
	for dict: Dictionary in _array:
		if dict.get("name") == name:
			return dict
	return {}

func _randomized_property(type: Variant.Type) -> Variant:
	var prop = null
	match type:
		TYPE_BOOL:
			prop = prop * randi_range(0, 1)
		TYPE_INT:
			prop = randi_range(_min_value, _max_value)
		TYPE_FLOAT:
			prop = randf_range(_min_value, _max_value)
		TYPE_VECTOR2:
			prop = Vector2(randf_range(_min_value, _max_value), randf_range(_min_value, _max_value))
		TYPE_VECTOR2I:
			prop = Vector2i(randi_range(_min_value, _max_value), randi_range(_min_value, _max_value))
		TYPE_VECTOR3:
			prop = Vector3(randf_range(_min_value, _max_value), randf_range(_min_value, _max_value), randf_range(_min_value, _max_value))
		TYPE_VECTOR3I:
			prop = Vector3i(randi_range(_min_value, _max_value), randi_range(_min_value, _max_value), randi_range(_min_value, _max_value))
		TYPE_VECTOR4:
			prop = Vector4(randf_range(_min_value, _max_value), randf_range(_min_value, _max_value), randf_range(_min_value, _max_value), randf_range(_min_value, _max_value))
		TYPE_VECTOR4I:
			prop = Vector4i(randi_range(_min_value, _max_value), randi_range(_min_value, _max_value), randi_range(_min_value, _max_value), randi_range(_min_value, _max_value))
	
	return prop

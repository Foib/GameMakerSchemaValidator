// feather ignore once GM1042
/// @param {String,Array<String>} [type] string, number, boolean, object, array, null
/// @param {Struct} [properties]
/// @param {Array<String>} [required]
/// @param {Struct.Schema} [items]
/// @param {Real} [min_value]
/// @param {Real} [max_value]
/// @param {Real} [min_length]
/// @param {Real} [max_length]
/// @param {Function} [pattern_callback]
/// @param {Real} [min_items]
/// @param {Real} [max_items]
/// @param {String} [format]
/// @param {Bool,Struct.Schema} [additional_properties]
function SchemaStruct(_type=undefined, _properties=undefined, _required=undefined, _items=undefined, _min_value=undefined, _max_value=undefined, _min_length=undefined, _max_length=undefined, _pattern_callback=undefined, _min_items=undefined, _max_items=undefined, _format=undefined, _additional_properties=undefined) constructor {
    type = _type;
    properties = _properties;
    required = _required;
    items = _items;
    min_value = _min_value;
    max_value = _max_value;
    min_length = _min_length;
    max_length = _max_length;
    pattern_callback = _pattern_callback;
    min_items = _min_items;
    max_items = _max_items;
    format = _format;
    additional_properties = _additional_properties;
}

// feather ignore once GM1042
/// @param {Struct} struct
/// @return {Struct.SchemaStruct}
function Schema(_struct) {
    return struct_assign(new SchemaStruct(), _struct, false);
}
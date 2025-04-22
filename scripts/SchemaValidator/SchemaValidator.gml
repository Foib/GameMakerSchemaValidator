// feather ignore once GM1042
/// @param {Struct.Schema} schema The schema used to validate data
function SchemaValidator(_schema) constructor {
    static print_errors = true;
    static throw_errors = false;
    /// @ignore
    static __error = function(_msg) {
        _msg = $"SchemaValidator: {_msg}";
        
        if (SchemaValidator.print_errors) {
            show_debug_message(_msg);
        }
        
        if (SchemaValidator.throw_errors) {
            throw (_msg);
        }
    }
    
    schema = _schema;
    if (!is_struct(schema)) {
        schema = undefined;
        SchemaValidator.__error("Schema is not of type struct");
    }
    
    /// @ignore
    __validate_type = function(_data, _schema) {
        if (!struct_exists(_schema, "type") || is_undefined(_schema.type)) {
            return true;
        }
        
        var _types = is_array(_schema.type) ? _schema.type : [_schema.type];
        
        for (var _i = 0; _i < array_length(_types); _i++) {
            var _type = _types[_i];
            switch (_type) {
                case "string":
                    if (is_string(_data)) return true;
                    break;
                case "number":
                    if (!is_bool(_data) && is_numeric(_data)) return true;
                    break;
                case "boolean":
                    if (is_bool(_data)) return true;
                    break;
                case "object":
                    if (is_struct(_data)) return true;
                    break;
                case "array":
                    if (is_array(_data)) return true;
                    break;
                case "null":
                    if (is_undefined(_data)) return true;
                    break;
            }
        }
        
        SchemaValidator.__error($"Expected type {string_join_ext(" or ", _types)}, got {typeof(_data)}");
        return false;
    }
    
    /// @ignore
    __validate_string = function(_data, _schema) {
        var _schema_type_is_array = is_array(_schema.type);
        var _is_string_type =
            (!_schema_type_is_array && _schema.type == "string") ||
            (_schema_type_is_array && array_contains(_schema.type, "string"));
        
        if (!is_string(_data) || !_is_string_type) {
            return true;
        }
        
        var _str_length = string_length(_data);
        
        if (is_numeric(_schema.min_length) && _str_length < _schema.min_length) {
            SchemaValidator.__error($"String is too short ({string_length(_data)}), minimum length is {_schema.min_length}");
            return false;
        }
        
        if (is_numeric(_schema.max_length) && _str_length > _schema.max_length) {
            SchemaValidator.__error($"String is too long ({string_length(_data)}), maximum length is {_schema.max_length}");
            return false;
        }
        
        if (is_callable(_schema.pattern_callback) && !_schema.pattern_callback(_data)) {
            SchemaValidator.__error($"Pattern callback function does not return true");
            return false;
        }
        
        return true;
    }
    
    /// @ignore
    __validate_number = function(_data, _schema) {
        var _schema_type_is_array = is_array(_schema.type);
        var _is_number_type =
            (!_schema_type_is_array && _schema.type == "number") ||
            (_schema_type_is_array && array_contains(_schema.type, "number"));
        
        if (!is_numeric(_data) || is_bool(_data) || !_is_number_type) {
            return true;
        }
        
        if (is_numeric(_schema.min_value) && _data < _schema.min_value) {
            SchemaValidator.__error($"Number is too small {_data}, minimum is {_schema.min_value}");
            return false;
        }
        
        if (is_numeric(_schema.max_value) && _data > _schema.max_value) {
            SchemaValidator.__error($"Number is too large {_data}, maximum is {_schema.max_value}");
            return false;
        }
        
        return true;
    }
    
    /// @ignore
    __validate_object = function(_data, _schema) {
        var _schema_type_is_array = is_array(_schema.type);
        var _is_object_type =
            (!_schema_type_is_array && _schema.type == "object") ||
            (_schema_type_is_array && array_contains(_schema.type, "object"));
        
        if (!is_struct(_data) || !_is_object_type) {
            return true;
        }
        
        if (is_array(_schema.required)) {
            for (var _i = 0; _i < array_length(_schema.required); _i++) {
                var _prop = _schema.required[_i];
                
                if (!is_string(_prop)) {
                    continue;
                }
                
                if (!struct_exists(_data, _prop)) {
                    SchemaValidator.__error($"Missing required property: {_prop}");
                    return false;
                }
            }
        }
        
        if (is_struct(_schema.properties)) {
            var _data_props = struct_get_names(_data);
            
            for (var _i = 0; _i < array_length(_data_props); _i++) {
                var _prop = _data_props[_i];
                
                if (struct_exists(_schema.properties, _prop)) {
                    if (!__validate(_data[$ _prop], _schema.properties[$ _prop])) {
                        return false;
                    }
                    continue;
                }
                
                if (_schema.additional_properties == false) {
                    SchemaValidator.__error($"Additional property '{_prop}' is not allowed");
                    return false;
                }
                
                if (is_struct(_schema.additional_properties) && !__validate(_data[$ _prop], _schema.additional_properties)) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    /// @ignore
    __validate_array = function(_data, _schema) {
        var _schema_type_is_array = is_array(_schema.type);
        var _is_array_type =
            (!_schema_type_is_array && _schema.type == "array") ||
            (_schema_type_is_array && array_contains(_schema.type, "array"));
        
        if (!is_array(_data) || !_is_array_type) {
            return true;
        }
        
        if (is_numeric(_schema.min_items) && array_length(_data) < _schema.min_items) {
            SchemaValidator.__error($"Array is too short {_data}, minimum length is {_schema.min_items}");
            return false;
        }
        
        if (is_numeric(_schema.max_items) && array_length(_data) > _schema.max_items) {
            SchemaValidator.__error($"Array is too long {_data}, maximum length is {_schema.max_items}");
            return false;
        }
        
        if (is_struct(_schema.items)) {
            for (var _i = 0; _i < array_length(_data); _i++) {
                if (!__validate(_data[_i], _schema.items)) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    /// @ignore
    __validate = function(_data, _schema) {
        if (!__validate_type(_data, _schema) ||
            !__validate_string(_data, _schema) ||
            !__validate_number(_data, _schema) ||
            !__validate_object(_data, _schema) ||
            !__validate_array(_data, _schema)) {
            return false;
        }
        
        return true;
    }
    
    // feather ignore once GM1042
    /// @param {String,Real,Bool,Struct,Array,Undefined} data The struct to be validated
    /// @return {Bool}
    validate = function(_data) {
        if (is_undefined(schema)) {
            return false;
        }
        
        return __validate(_data, schema);
    }
}
new SchemaValidator(new SchemaStruct());
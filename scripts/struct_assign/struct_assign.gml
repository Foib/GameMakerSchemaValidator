/// @function                           struct_assign(target, source, [add_missing_keys])
/// @description                        Properties in the target struct are overwritten by properties in the source struct if they have the same key.
/// @param {Struct} target              The target struct — what to apply the sources' properties to, which is returned after it is modified.
/// @param {Struct} source              The source struct — struct containing the properties you want to apply.
/// @param {Bool} [add_missing_keys]    If true (default), keys from source that don't exist in target will be added to target. If false, only existing keys in target will be updated with values from source.
/// @return {Struct}
function struct_assign(target, source, add_missing_keys=true) {
    if (is_undefined(source)) {
        return target;
    }
    
    var source_keys = variable_struct_get_names(source);
    for (var i = array_length(source_keys)-1; i >= 0; --i) {
        var key = source_keys[i];
        
        if (!add_missing_keys && !struct_exists(target, key)) {
            continue;
        }
        
        var val = variable_struct_get(source, key);
        variable_struct_set(target, key, val);
    }
    
    return target;
}
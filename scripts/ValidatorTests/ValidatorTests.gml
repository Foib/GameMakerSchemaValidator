function ValidatorTests() constructor {
    StructValidator.print_errors = false;
    StructValidator.throw_errors = false;
    
    tests = [];
    passed = 0;
    failed = 0;
    
    add_test = function(_name, _test) { 
        array_push(tests, { name: _name, test: _test });
    }
    
    assert = function(_condition, _message) {
        if (!_condition) {
            show_debug_message($"\t{_message}");
            return false;
        }
        
        return true;
    }
    
    assert_validation = function(_data, _schema, _expected_valid) {
        var _validator = new StructValidator(_schema);
        var _result = _validator.validate(_data);
        
        if (!assert(_result == _expected_valid, $"Expected validation to be {_expected_valid ? "true" : "false"} but got {_result ? "true" : "false"}")) {
            return false;
        }
        
        return true;
    }
    
    add_test("String type validation", function() {
        var _schema = Schema._({ type: "string" });
        
        return
            assert_validation("test", _schema, true) &&
            assert_validation(123, _schema, false);
    });
    
    add_test("Number type validation", function() {
        var _schema = Schema._({ type: "number" });
        
        return
            assert_validation(123, _schema, true) &&
            assert_validation("123", _schema, false);
    });
    
    add_test("Boolean type validation", function() {
        var _schema = Schema._({ type: "boolean" });
        
        return
            assert_validation(true, _schema, true) &&
            assert_validation(false, _schema, true) &&
            assert_validation("true", _schema, false);
    });
    
    add_test("Object type validation", function() {
        var _schema = Schema._({ type: "object" });
        
        return
            assert_validation({}, _schema, true) &&
            assert_validation({a: 1}, _schema, true) &&
            assert_validation([], _schema, false) && 
            assert_validation("object", _schema, false);
    });
    
    add_test("Array type validation", function() {
        var _schema = Schema._({ type: "array" });
        
        return
            assert_validation([], _schema, true) &&
            assert_validation([1, 2, 3], _schema, true) &&
            assert_validation({}, _schema, false);
    });
    
    add_test("Null type validation", function() {
        var _schema = Schema._({ type: "null" });
        
        return
            assert_validation(undefined, _schema, true) &&
            assert_validation(0, _schema, false) &&
            assert_validation(false, _schema, false);
    });
    
    add_test("Union type validation", function() {
        var _schema = Schema._({ type: ["string", "number"] });
        
        return
            assert_validation("test", _schema, true) &&
            assert_validation(123, _schema, true) &&
            assert_validation(true, _schema, false);
    });
    
    add_test("String min_length validation", function() {
        var _schema = Schema._({ type: "string", min_length: 3 });
        
        return
            assert_validation("test", _schema, true) &&
            assert_validation("te", _schema, false);
    });
    
    add_test("String max_length validation", function() {
        var _schema = Schema._({ type: "string", max_length: 4 });
        
        return
            assert_validation("test", _schema, true) &&
            assert_validation("testing", _schema, false);
    });
    
    add_test("String pattern_callback validation", function() {
        var _schema = Schema._({ type: "string", pattern_callback: function(_str) { return string_char_at(_str, 1) == "t" } });
        
        return
            assert_validation("test", _schema, true) &&
            assert_validation("hello", _schema, false) &&
            assert_validation(0, _schema, false);
    });
    
    add_test("Number min_value validation", function() {
        var _schema = Schema._({ type: "number", min_value: 5 });
        
        return
            assert_validation(10, _schema, true) &&
            assert_validation(5, _schema, true) &&
            assert_validation(4, _schema, false);
    });
    
    add_test("Number max_value validation", function() {
        var _schema = Schema._({ type: "number", max_value: 10 });
        
        return
            assert_validation(5, _schema, true) &&
            assert_validation(10, _schema, true) &&
            assert_validation(11, _schema, false);
    });
    
    add_test("Required properties validation", function() {
        var _schema = Schema._({
            type: "object",
            properties: {
                name: Schema._({ type: "string" }),
                age: Schema._({ type: "number" })
            },
            required: ["name"]
        });
        
        return
            assert_validation({ name: "John" }, _schema, true) &&
            assert_validation({ name: "John", age: 30 }, _schema, true) &&
            assert_validation({ age: 30 }, _schema, false);
    });
    
    add_test("Nested object validation", function() {
        var _schema = Schema._({
            type: "object",
            properties: {
                user: Schema._({ 
                    type: "object",
                    properties: {
                        name: Schema._({ type: "string" })
                    },
                    required: ["name"]
                })
            },
            required: ["user"]
        });
        
        return
            assert_validation({ user: { name: "John" } }, _schema, true) &&
            assert_validation({ user: {} }, _schema, false) &&
            assert_validation({}, _schema, false);
    });
    
    add_test("AdditionalProperties: false validation", function() {
        var _schema = Schema._({
            type: "object",
            properties: {
                name: Schema._({ type: "string" })
            },
            additional_properties: false
        });
        
        return
            assert_validation({ name: "John" }, _schema, true) &&
            assert_validation({ name: "John", age: 30 }, _schema, false);
    });
    
    add_test("AdditionalProperties with schema validation", function() {
        var _schema = Schema._({
            type: "object",
            properties: {
                name: Schema._({ type: "string" })
            },
            additional_properties: Schema._({ type: "number" })
        });
        
        return
            assert_validation({ name: "John" }, _schema, true) &&
            assert_validation({ name: "John", age: 30 }, _schema, true) &&
            assert_validation({ name: "John", age: "30" }, _schema, false);
    });
    
    add_test("Array items validation", function() {
        var _schema = Schema._({
            type: "array",
            items: Schema._({ type: "string" })
        });
        
        return
            assert_validation(["a", "b", "c"], _schema, true) &&
            assert_validation([], _schema, true) &&
            assert_validation(["a", 1, "c"], _schema, false);
    });
    
    add_test("Array min_items validation", function() {
        var _schema = Schema._({
            type: "array",
            min_items: 2
        });
        
        return
            assert_validation([1, 2], _schema, true) &&
            assert_validation([1, 2, 3], _schema, true) &&
            assert_validation([1], _schema, false) &&
            assert_validation([], _schema, false);
    });
    
    add_test("Array max_items validation", function() {
        var _schema = Schema._({
            type: "array",
            max_items: 3
        });
        
        return
            assert_validation([], _schema, true) &&
            assert_validation([1, 2, 3], _schema, true) &&
            assert_validation([1, 2, 3, 4], _schema, false);
    });
    
    add_test("Complex object with nested arrays", function() {
        var _schema = Schema._({
            type: "object",
            properties: {
                name: Schema._({ type: "string" }),
                tags: Schema._({ 
                    type: "array",
                    items: Schema._({ type: "string" }),
                    min_items: 1
                }),
                scores: Schema._({
                    type: "array",
                    items: Schema._({ type: "number" })
                })
            },
            required: ["name", "tags"]
        });
        
        return
            assert_validation({
                name: "John", 
                tags: ["developer"], 
                scores: [85, 90, 78] 
            }, _schema, true) &&
            assert_validation({ 
                name: "John", 
                tags: [], 
                scores: [85, 90, 78] 
            }, _schema, false) &&
            assert_validation({ 
                name: "John", 
                tags: ["developer"], 
                scores: [85, "90", 78] 
            }, _schema, false);
    });
    
    add_test("Empty schema validation", function() {
        var _schema = new Schema();
        
        return
            assert_validation("test", _schema, true) &&
            assert_validation(123, _schema, true) &&
            assert_validation({}, _schema, true) &&
            assert_validation(undefined, _schema, true);
    });
    
    test = function() {
        draw_enable_drawevent(false);
        show_debug_message($"\n{string_repeat("-", 40)}\nRunning Struct Schema Validator Tests:\n");
        
        for (var _i = 0; _i < array_length(tests); _i++) {
            var _test = tests[_i];
            
            if (_test.test()) {
                show_debug_message($"✔\t{_test.name}");
                passed++;
            }else {
                show_debug_message($"❌\t{_test.name}");
                failed++;
            }
        }
        
        show_debug_message($"\nTest Results: {passed} passed, {failed} failed, {array_length(tests)} total\n{string_repeat("-", 40)}\n");
        game_end();
    }
}

new ValidatorTests().test();
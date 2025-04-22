# GameMaker Schema Validator

A JSON Schema validator for GameMaker

## Basic Usage

```gml
// Define a schema
var schema = Schema._({
  type: "object",
  properties: {
    name: Schema._({ type: "string", min_length: 2 }),
    age: Schema._({ type: "number", min_value: 0 }),
  },
  required: ["name"]
});

// Data to validate
var data = {
  name: "John",
  age: 30,
};

// Validate
var validator = new SchemaValidator(schema);
var result = validator.validate(data);

if (result) {
  show_debug_message("Validation successful");
  console.log();
} else {
  show_debug_message("Validation failed");
}
```

## Supported Schema Features

### Types

```gml
// Type validation
Schema._({ type: "string" });

// Multiple types
Schema._({ type: ["string", "number"] });
```

Supported types: `string`, `number`, `boolean`, `object`, `array`, `null`

### String Validations

```gml
Schema._({
  type: "string",
  min_length: 5, // Minimum string length
  max_length: 100, // Maximum string length
  pattern_callback: function(str) { return string_char_at(_str, 1) == "a" }, // Callback function to validate a string
});
```

### Number Validations

```gml
Schema._({
  type: "number",
  min_value: 0, // Minimum value
  max_value: 100, // Maximum value
});
```

### Object Validations

```gml
Schema._({
  type: "object",
  properties: {
    // Property definitions
    name: Schema._({ type: "string" }),
    age: Schema._({ type: "number" }),
  },
  required: ["name", "age"], // Required properties
  additional_properties: false, // No additional properties allowed
});

// With schema for additional properties
Schema._({
  type: "object",
  properties: {
    name: Schema._({ type: "string" }),
  },
  additional_properties: Schema._({ type: "number" }), // Additional properties must be numbers
});
```

### Array Validations

```gml
Schema._({
  type: "array",
  items: Schema._({ type: "string" }), // All items must be strings
  min_items: 1, // Minimum array length
  max_items: 10, // Maximum array length
});
```

## Complex Example

```gml
var schema = Schema._({
  type: "object",
  properties: {
    id: Schema._({ type: "number" }),
    name: Schema._({ type: "string", min_length: 2, max_length: 100 }),
    email: Schema._({
      type: "string",
      pattern_callback: function(str) {
        if (string_length(str) < 3 || string_count(str, "@") != 1) {
          return false;
        }

        var at_index = string_pos(str, "@");
        if (at_index == 1 || at_index == string_length(str)) {
          return false;
        }

        return true;
      },
    }),
    active: Schema._({ type: "boolean" }),
    role: Schema._({ type: "string" }),
    tags: Schema._({
      type: "array",
      items: Schema._({ type: "string" }),
      min_items: 1,
    }),
    address: Schema._({
      type: "object",
      properties: {
        street: Schema._({ type: "string" }),
        city: Schema._({ type: "string" }),
        zip: Schema._({ type: ["string", "number"] }),
      },
      required: ["street", "city"],
    }),
  },
  required: ["id", "name", "email"],
});
```

<hr>

This implementation doesn't support all features of the official JSON Schema specification!

## License

MIT

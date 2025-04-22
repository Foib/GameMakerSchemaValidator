# GameMaker Schema Validator

A JSON Schema validator for GameMaker

## Basic Usage

```gml
// Define a schema
var schema = Schema({
  type: "object",
  properties: {
    name: Schema({ type: "string", min_length: 2 }),
    age: Schema({ type: "number", min_value: 0 }),
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
Schema({ type: "string" });

// Multiple types
Schema({ type: ["string", "number"] });
```

Supported types: `string`, `number`, `boolean`, `object`, `array`, `null`

### String Validations

```gml
Schema({
  type: "string",
  min_length: 5, // Minimum string length
  max_length: 100, // Maximum string length
  pattern_callback: function(str) { return string_char_at(str, 1) == "a" }, // Callback function to validate a string
});
```

### Number Validations

```gml
Schema({
  type: "number",
  min_value: 0, // Minimum value
  max_value: 100, // Maximum value
});
```

### Object Validations

```gml
Schema({
  type: "object",
  properties: {
    // Property definitions
    name: Schema({ type: "string" }),
    age: Schema({ type: "number" }),
  },
  required: ["name", "age"], // Required properties
  additional_properties: false, // No additional properties allowed
});

// With schema for additional properties
Schema({
  type: "object",
  properties: {
    name: Schema({ type: "string" }),
  },
  additional_properties: Schema({ type: "number" }), // Additional properties must be numbers
});
```

### Array Validations

```gml
Schema({
  type: "array",
  items: Schema({ type: "string" }), // All items must be strings
  min_items: 1, // Minimum array length
  max_items: 10, // Maximum array length
});
```

## Complex Example

```gml
var schema = Schema({
  type: "object",
  properties: {
    id: Schema({ type: "number" }),
    name: Schema({ type: "string", min_length: 2, max_length: 100 }),
    email: Schema({
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
    active: Schema({ type: "boolean" }),
    role: Schema({ type: "string" }),
    tags: Schema({
      type: "array",
      items: Schema({ type: "string" }),
      min_items: 1,
    }),
    address: Schema({
      type: "object",
      properties: {
        street: Schema({ type: "string" }),
        city: Schema({ type: "string" }),
        zip: Schema({ type: ["string", "number"] }),
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

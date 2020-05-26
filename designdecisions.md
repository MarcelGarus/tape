This document contains design decisions.
Every one has a similar structure: The problem is outlined. Different solutions are layed out. Arguments for the solutions are listed, preceded with + or - for pro or contra (or multiple of these signs for really big pro or contra arguments).

## When to specify default values?

Tape should be compatible with other encoding versions. When removing a field, a previous decoder should use a default value for the field.
How can we do that?

- (a) force users to specify default values up front for every field
- (b) force users to specify default values when they remove fields.

**Arguments:**

- +a: This leaves no undefined behavior: When decoding a type and a field is missing, we have to do *something*. Might as well let the developer specify what to do in that case.
- +b: When removing fields, developers have more experience and probably choose better default values.
- -a: Changing default values may lead to weird behavior. For example, having a `bool` field with default value `true` in version one of your app, `false` in version two, and removed from that point on leads to two versions interpreting some bytes differently.
  - If users change the defaul value, we could make them aware that they did and warn them about this behavior.
- ++a: We could just remove the fields entirely without littering the code with removed fields or littering the encoded bytes with values. There is no technical debt in removing a field.

The chosen one: a.

## Default values

Use
- (a) `freezed`'s `@Default()` annotation,
- (b) provide our own `@Default` or `@TapeDefault` annotation, or
- (c) add `defaultValue` parameter to `@TapeField`
- (d) for every field `someField`, users would have to also add a ``?

Arguments:

- +a: The `freezed_annotation` package is lightweight.
- +a: Only one `@Default` annotation per field needed.
- -a -b: Extra `@Default` annotation is maybe more boilerplate than adding a parameter to the `@TapeField`.
- ---a: We force users to add `@Default` annotations, but they probably don't want to make all their `@freezed` class's fields named parameters. This is a **dealbreaker for (a)**.
- -c: A positional parameter is not that self-documenting (for example, `@TapeField(2, 3)` for an `int` field), so we would use a named one. Because `default` is a reserved keyword, the parameter would need to be named `defaultValue` or something similar, which is long.
- -b: Using `@tape.Default` and `@freezed.Default` would be a pain.
- -c: We would force users to specify the default value two times when also using the `freezed` default value.
- +b: 

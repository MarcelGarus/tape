Roadmap:
- [ ] Parsing
- [ ] Formatting
- [ ] be more generous in accepting commas between fields and variants
- [ ] Binary specification
- [ ] Enum variant auto-chooser for values. "Hi" instead of string("Hi")
- [ ] Rust backend
- [ ] arithmetics (+ - *)
- [ ] support full semantic versions
- [ ] CLI
- [ ] Language Server for highlighting and analyzing
- [ ] semantic versioning enforement
- [ ] Dart backend
- [ ] support packages from path
- [ ] support packages from GitHub
- [ ] support \t
- [ ] tapefactory
- [ ] support packages from tapefactory
- [ ] Language Server for code actions
- [ ] taco guidelines
- [ ] standard library
- [ ] documentation, guides
- [ ] number formats like 0xff, 0b00101
- [ ] support _ in numbers to make them more readable
- [ ] package scoring
- [ ] automatically suggest packages from tapefactory

Errors:
- [ ] Invalid UTF8.

Warnings:
- [ ] No space after doubleslash for comment.
- [ ] Unused imports.
- [ ] Unused "use" statements.
- [ ] Screaming caps in UpperCamelCase. Abbreviations like HTTP should be capitalized just like normal words: "HttpRequest"
- [ ] Enforce UpperCamelCase in struct, enum, alias name, enum values.
- [ ] Enforce snake_case in struct fields and const names.
- [ ] Multiple adjacent underscores.
- [ ] Leading zeroes in decimal numbers.
- [ ] No comment for type, value or field.
- [ ] Comment references type or value using backticks instead of edge braces.
- [ ] Comment references value without definition using edge braces.
- [ ] Comment references unresolvable element in edge braces.
- [ ] Todo not following guidelines for "TODO(name): text".
- [ ] Todo name not a valid GitHub name.
- [ ] Link unresolvable.

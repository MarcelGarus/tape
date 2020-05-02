use crate::parse::error::ParseError;
use crate::parse::tokens::{Token, TokenKind};
use crate::parse::utils::{CursorParser, MatchActions};
use crate::utils::Case;
use crate::utils::Span;
use num::{BigInt, ToPrimitive};

pub struct TapeFile {
    package_name: Identifier,
    comment: Option<Comment>,
    imports: Vec<Import>,
    definitions: Vec<Definition>,
}

#[derive(Debug)]
pub struct Identifier {
    name: String,
    span: Span,
}

#[derive(Debug)]
pub struct Comment {
    text: String,
    span: Span,
}

#[derive(Debug)]
pub struct Import {
    source: Identifier,
    imports: Vec<Identifier>,
    span: Span,
}

#[derive(Debug)]
pub enum Definition {
    Struct(Struct),
    Enum(Enum),
    Alias(Alias),
    Value(Value),
}

#[derive(Debug)]
struct Struct {
    decorations: Decorations,
    name: TypeDefinition,
    fields: Vec<Field>,
    span: Span,
}

#[derive(Debug)]
struct Field {
    decorations: Decorations,
    name: Identifier,
    field_type: Type,
    default: Option<Value>,
    span: Span,
}

#[derive(Debug)]
struct Enum {
    decorations: Decorations,
    name: Identifier,
    variants: Vec<Variant>,
    span: Span,
}

#[derive(Debug)]
struct Variant {
    decorations: Decorations,
    name: Identifier,
    associated_type: Option<Type>,
    span: Span,
}

#[derive(Debug)]
pub struct Alias {
    decorations: Decorations,
    name: TypeDefinition,
    aliased_type: Type,
    span: Span,
}

#[derive(Debug)]
pub struct Value {
    decorations: Decorations,
    name: Identifier,
    value_type: Type,
    literal: Literal,
    span: Span,
}

#[derive(Debug)]
pub struct Decorations {
    comment: Option<Comment>,
    added: Option<AddedAnnotation>,
    deprecated: Option<DeprecatedAnnotation>,
}
impl Decorations {
    fn is_empty(&self) -> bool {
        matches!(self.comment, None)
            && matches!(self.added, None)
            && matches!(self.deprecated, None)
    }
}

#[derive(Debug)]
enum Annotation {
    Added(AddedAnnotation),
    Deprecated(DeprecatedAnnotation),
}

#[derive(Debug)]
struct AddedAnnotation {
    version: Version,
    span: Span,
}

#[derive(Debug)]
struct DeprecatedAnnotation {
    version: Version,
    reason: StringLiteral,
    span: Span,
}

#[derive(Debug)]
pub struct Version {
    version: semver::Version,
    span: Span,
}

#[derive(Debug)]
struct VersionNumber {
    number: u64,
    span: Span,
}

#[derive(Debug)]
pub struct TypeDefinition {
    name: Identifier,
    generics: Vec<Identifier>,
}

#[derive(Debug)]
pub struct Type {
    name: Identifier,
    generics: Vec<Type>,
}

#[derive(Debug)]
pub enum Literal {
    String(StringLiteral),
    Integer(IntegerLiteral),
    Float(FloatLiteral),
    // TODO: add other types of literals
}

#[derive(Debug)]
pub struct StringLiteral {
    string: String,
    span: Span,
}

#[derive(Debug)]
pub struct IntegerLiteral {
    number: BigInt,
    span: Span,
}

#[derive(Debug)]
pub struct FloatLiteral {
    before_dot: BigInt,
    after_dot: BigInt,
    span: Span,
}

// ---

macro_rules! Token {
    ($token_kind_pattern:pat) => {
        Token {
            kind: $token_kind_pattern,
            ..
        }
    };
}

macro_rules! TokenWithSpan {
    ($token_kind_pattern:pat, $span:pat) => {
        Token {
            kind: $token_kind_pattern,
            span: $span,
        }
    };
}

pub type Parser<'a> = CursorParser<'a, Token>;

impl Parser<'_> {
    pub fn parse(&mut self) -> Option<TapeFile> {
        // Parse comment and package name.
        let comment = match self.peek() {
            Some(Token!(TokenKind::Comment(comment))) => self.parse_comment(),
            None => None,
        };
        let package_name = match self.parse_package() {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_package_statement(unimplemented!()));
                return None;
            }
        };

        // Parse imports.
        let imports: Vec<Import> = vec![];
        loop {
            match self.peek() {
                Some(Token!(TokenKind::Word(word))) if word == "from" => {
                    if let Some(import) = self.parse_import() {
                        imports.push(import);
                        continue;
                    }
                }
            }
            break;
        }

        // Parse definitions.
        let definitions: Vec<Definition> = vec![];
        while !self.is_done() {
            match self.parse_definition() {
                Some(definition) => definitions.push(definition),
                None => {}
            }
        }

        Some(TapeFile {
            package_name,
            comment,
            imports,
            definitions,
        })

        // loop {
        //     match self.peek() {
        //         Some(Atom::Word(word)) => match word.as_ref() {
        //             "struct" => self.parse_struct().map(|s| RootElement::Struct(s)),
        //             "enum" => self.parse_enum().map(|e| RootElement::Enum(e)),
        //             "alias" => self.parse_alias().map(|alias| RootElement::Alias(alias)),
        //             "val" => self.parse_val().map(|value| RootElement::Const(value)),
        //             _ => unimplemented!(),
        //         },
        //         _ => unimplemented!(), // TODO: throw
        //     }
        //     .map(|element| body.push(element));
        // }
    }

    /// Parses a (possibly multiline) comment.
    ///
    /// ```tape
    /// // Some text.
    /// // Other text.
    /// ```
    fn parse_comment(&mut self) -> Option<Comment> {
        let mut text = "".to_string();
        let mut span: Option<Span> = None;
        loop {
            match self.peek() {
                Some(TokenWithSpan!(TokenKind::Comment(comment), token_span)) => {
                    text.push_str(&comment);
                    span = Some(match span {
                        Some(span) => span.start..token_span.end,
                        None => *token_span,
                    });
                    self.advance();
                }
                _ => {
                    // We found something non-comment-y, so we're done here.
                    break match span {
                        Some(span) => Some(Comment { text, span }),
                        None => None,
                    };
                }
            }
        }
    }

    /// Parses a package statement.
    ///
    /// ```tape
    /// package example
    /// ```
    fn parse_package(&mut self) -> Option<Identifier> {
        self.expect_keyword("package")?;
        self.parse_identifier(Some(Case::Kebab))
    }

    /// Parses an import statement.
    ///
    /// ```tape
    /// from json use Json, Something, Else
    /// ```
    fn parse_import(&mut self) -> Option<Import> {
        let from_keyword = self.expect_keyword("from")?;
        let source = match self.parse_identifier(Some(Case::Kebab)) {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_source(from_keyword.span));
                return None;
            }
        };
        let use_keyword = match self.expect_keyword("use") {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_use_keyword(from_keyword.span));
                return None;
            }
        };
        let mut imports: Vec<Identifier> = vec![match self.parse_identifier(None) {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_import(use_keyword.span));
                return None;
            }
        }];
        loop {
            match self.peek() {
                Some(TokenWithSpan!(TokenKind::Comma, span)) => {
                    self.advance();
                    let import = match self.parse_identifier(None) {
                        Some(identifier) => identifier,
                        None => {
                            self.register(ParseError::expected_import(use_keyword.span));
                            return None;
                        }
                    };
                    imports.push(import);
                }
                None => break,
            }
        }
        Some(Import {
            source,
            imports,
            span: from_keyword.span.start..imports.last().unwrap().span.end,
        })
    }

    /// Parses a definition of a struct, enum, alias or val.
    ///
    /// ```tape
    /// // Some comment.
    /// @added(1.0.0)
    /// struct SomeStruct { ... }
    /// ```
    fn parse_definition(&mut self) -> Option<Definition> {
        let decorations = self.parse_decorations();
        match self.peek() {
            Some(TokenWithSpan!(TokenKind::Word(word), span)) => match word.as_ref() {
                "struct" => self
                    .parse_struct(decorations)
                    .map(|d| Definition::Struct(d)),
                "enum" => self.parse_enum(decorations).map(|d| Definition::Enum(d)),
                "alias" => self.parse_alias(decorations).map(|d| Definition::Alias(d)),
                "val" => self.parse_value(decorations).map(|d| Definition::Value(d)),
                _ => {
                    self.register(ParseError::expected_definition(*span));
                    None
                }
            },
            Some(TokenWithSpan!(_, span)) => {
                self.register(ParseError::expected_definition(*span));
                None
            }
            None => {
                if !decorations.is_empty() {
                    self.register(ParseError::expected_definition_after_decoration(
                        0..0, //decorations.last().unwrap().span, TODO:
                    ));
                }
                None
            }
        }
    }

    /// Parses decorations. That's comments and annotations.
    ///
    /// ```tape
    /// // Some comment.
    /// @added(1.0.0)
    /// ```
    fn parse_decorations(&mut self) -> Decorations {
        let mut comment: Option<Comment> = None;
        let mut added: Option<AddedAnnotation> = None;
        let mut deprecated: Option<DeprecatedAnnotation> = None;

        loop {
            match self.peek() {
                Some(Token!(TokenKind::Comment(_))) => {
                    let new_comment = self.parse_comment().unwrap();
                    if let Some(comment) = comment {
                        self.register(ParseError::multiple_comments(comment, new_comment));
                    }
                    comment = Some(new_comment)
                }
                Some(Token!(TokenKind::At)) => match self.parse_annotation() {
                    Some(Annotation::Added(new_added)) => {
                        if let Some(added) = added {
                            self.register(ParseError::multiple_added_annotations(added, new_added));
                        }
                        added = Some(new_added)
                    }
                    Some(Annotation::Deprecated(new_deprecated)) => {
                        if let Some(deprecated) = deprecated {
                            self.register(ParseError::multiple_deprecated_annotations(
                                deprecated,
                                new_deprecated,
                            ));
                        }
                        deprecated = Some(new_deprecated)
                    }
                    None => continue, // Parsing this annotation failed, so let's try the next one.
                },
                _ => break,
            }
        }
        Decorations {
            comment,
            added,
            deprecated,
        }
    }

    /// Parses an annotation.
    ///
    /// ```tape
    /// @deprecated(1.2.3, "Some reason.")
    /// ```
    fn parse_annotation(&mut self) -> Option<Annotation> {
        let at = match self.advance() {
            Some(token @ Token!(TokenKind::At)) => token,
            Some(token) => panic!(
                "parse_annotation called, but next token is not @, but {:?}.",
                token
            ),
            None => panic!("parse_annotation called, but reached the end of the source."),
        };
        let name = match self.parse_identifier(Some(Case::Dromedar)) {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_annotation(at.span));
                return None;
            }
        };
        match name.name.as_ref() {
            "added" => {
                let paren_open = match self.advance() {
                    Some(token @ Token!(TokenKind::ParenOpen)) => token,
                    _ => {
                        self.register(ParseError::expected_opening_parenthesis(
                            at.span.start..name.span.end,
                        ));
                        return None;
                    }
                };
                let version = match self.parse_version() {
                    Some(version) => version,
                    None => {
                        self.register(ParseError::expected_version(
                            at.span.start..paren_open.span.end,
                        ));
                        return None;
                    }
                };
                let paren_close = match self.advance() {
                    Some(token @ Token!(TokenKind::ParenClose)) => token,
                    _ => {
                        self.register(ParseError::expected_closing_parenthesis(
                            at.span.start..version.span.end,
                        ));
                        return None;
                    }
                };
                Some(Annotation::Added(AddedAnnotation {
                    version,
                    span: at.span.start..paren_close.span.end,
                }))
            }
            "deprecated" => {
                let paren_open = match self.advance() {
                    Some(token @ Token!(TokenKind::ParenOpen)) => token,
                    _ => {
                        self.register(ParseError::expected_opening_parenthesis(
                            at.span.start..name.span.end,
                        ));
                        return None;
                    }
                };
                let version = match self.parse_version() {
                    Some(version) => version,
                    None => {
                        self.register(ParseError::expected_version(
                            at.span.start..paren_open.span.end,
                        ));
                        return None;
                    }
                };
                let comma = match self.advance() {
                    Some(token @ Token!(TokenKind::Comma)) => token,
                    _ => {
                        self.register(ParseError::expected_comma(at.span.start..version.span.end));
                        return None;
                    }
                };
                let reason = match self.parse_string() {
                    Some(reason) => reason,
                    _ => {
                        self.register(ParseError::expected_deprecation_reason(
                            at.span.start..comma.span.end,
                        ));
                        return None;
                    }
                };
                let paren_close = match self.advance() {
                    Some(token @ Token!(TokenKind::ParenClose)) => token,
                    _ => {
                        self.register(ParseError::expected_closing_parenthesis(
                            at.span.start..version.span.end,
                        ));
                        return None;
                    }
                };
                Some(Annotation::Deprecated(DeprecatedAnnotation {
                    version,
                    reason,
                    span: at.span.start..paren_close.span.end,
                }))
            }
            _ => {
                self.register(ParseError::unknown_annotation(name));
                None
            }
        }
    }

    /// Parses a version.
    ///
    /// ```tape
    /// 1.2.3
    /// ```
    fn parse_version(&mut self) -> Option<Version> {
        let major = match self.parse_version_number() {
            Some(number) => number,
            None => {
                self.register(ParseError::expected_major_version_number(unimplemented!()));
                return None;
            }
        };
        let first_dot = match self.advance() {
            Some(token @ Token!(TokenKind::Dot)) => token,
            _ => {
                self.register(ParseError::expected_dot(unimplemented!()));
                return None;
            }
        };
        let minor = match self.parse_version_number() {
            Some(number) => number,
            None => {
                self.register(ParseError::expected_minor_version_number(unimplemented!()));
                return None;
            }
        };
        let second_dot = match self.advance() {
            Some(token @ Token!(TokenKind::Dot)) => token,
            _ => {
                self.register(ParseError::expected_dot(unimplemented!()));
                return None;
            }
        };
        let patch = match self.parse_version_number() {
            Some(number) => number,
            None => {
                self.register(ParseError::expected_minor_version_number(unimplemented!()));
                return None;
            }
        };
        Some(Version {
            span: major.span.start..patch.span.end,
            version: semver::Version {
                major: major.number,
                minor: minor.number,
                patch: patch.number,
                pre: vec![],
                build: vec![],
            },
        })
    }

    /// Parses a single version number.
    ///
    /// ```tape
    /// 1
    /// ```
    fn parse_version_number(&mut self) -> Option<VersionNumber> {
        match self.advance() {
            Some(TokenWithSpan!(TokenKind::Number(number), span)) => match number.to_u64() {
                Some(number) => Some(VersionNumber { span, number }),
                None => {
                    self.register(ParseError::too_big());
                    return None;
                }
            },
            _ => None, // TODO
        }
    }

    /// Parses a struct.
    ///
    /// ```tape
    /// struct SampleStruct {
    ///     // Sample field.
    ///     @Added(1.1.1)
    ///     sample_field: Option<Int> = some(4)
    /// }
    /// ```
    fn parse_struct(&mut self, decorations: Decorations) -> Option<Struct> {
        self.expect_keyword("struct")?;
        let name = match self.parse_type_definition() {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_struct_name(unimplemented!()));
                return None;
            }
        };
        let open_brace = match self.advance() {
            Some(token @ Token!(TokenKind::BraceOpen)) => token,
            _ => {
                self.register(ParseError::expected_opening_brace(unimplemented!()));
                return None;
            }
        };

        let mut fields: Vec<Field> = vec![];
        while !matches!(self.peek(), Some(Token!(TokenKind::BraceClose))) {
            let decorations = self.parse_decorations();
            let field = match self.parse_field(decorations) {
                Some(field) => field,
                None => {
                    self.register(ParseError::expected_field());
                    continue;
                }
            };
        }
        self.advance(); // Consume the closing brace.
        Some(Struct {
            name,
            decorations,
            fields,
            span: 0..0, // TODO:
        })
    }

    /// Parses a field of a struct.
    ///
    /// ```tape
    /// field_name: FieldType = defaultValue
    /// ```
    fn parse_field(&mut self, decorations: Decorations) -> Option<Field> {
        let name = self.parse_identifier(Some(Case::Snake))?;
        let colon = match self.advance() {
            Some(token @ Token!(TokenKind::Colon)) => token,
            _ => {
                self.register(ParseError::expected_colon(unimplemented!()));
                return None;
            }
        };
        let field_type = match self.parse_type() {
            Some(field_type) => field_type,
            None => {
                self.register(ParseError::expected_field_type(unimplemented!()));
                return None;
            }
        };
        let default = match self.advance() {
            Some(token @ Token!(TokenKind::EqualSign)) => Some(self.parse_literal()?),
            _ => None,
        };
        Some(Field {
            decorations,
            name,
            field_type,
            default,
            span: unimplemented!(), // TODO:
        })
    }

    /// Parses an enum.
    ///
    /// ```tape
    /// enum Json {
    ///     SampleLeaf
    ///     Number -> Float64
    ///     String -> String
    ///     Object -> Map<String, Json>
    /// }
    /// ```
    fn parse_enum(&mut self, decorations: Decorations) -> Option<Enum> {
        self.expect_keyword("enum")?;
        let name = match self.parse_identifier(Some(Case::Camel)) {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_enum_name(unimplemented!()));
                return None;
            }
        };
        let open_brace = match self.advance() {
            Some(token @ Token!(TokenKind::BraceOpen)) => token,
            _ => {
                self.register(ParseError::expected_opening_brace(unimplemented!()));
                return None;
            }
        };

        let mut variants: Vec<Variant> = vec![];
        while !matches!(self.peek(), Some(Token!(TokenKind::BraceClose))) {
            let decorations = self.parse_decorations();
            let variant = match self.parse_variant(decorations) {
                Some(field) => field,
                None => {
                    self.register(ParseError::expected_variant());
                    continue;
                }
            };
        }
        self.advance(); // Consume the closing brace.
        Some(Enum {
            decorations,
            name,
            variants,
            span: unimplemented!(),
        })
    }

    /// Parse variant.
    ///
    /// ```tape
    /// Number -> Int
    /// ```
    fn parse_variant(&mut self, decorations: Decorations) -> Option<Variant> {
        let name = self.parse_identifier(Some(Case::Camel))?;
        let associated_type = match self.advance() {
            Some(token @ Token!(TokenKind::Arrow)) => Some(self.parse_type()?),
            _ => None,
        };
        Some(Variant {
            decorations,
            name,
            associated_type,
            span: unimplemented!(),
        })
    }

    /// Parses an alias.
    ///
    /// ```tape
    /// alias SomeType<T> = Map<T, T>
    /// ```
    fn parse_alias(&mut self, decorations: Decorations) -> Option<Alias> {
        self.expect_keyword("alias")?;
        let name = match self.parse_type_definition() {
            Some(identifier) => identifier,
            None => {
                self.register(ParseError::expected_alias_name(unimplemented!()));
                return None;
            }
        };
        let equal_sign = match self.advance() {
            Some(token @ Token!(TokenKind::EqualSign)) => token,
            _ => {
                self.register(ParseError::expected_equal_sign_after_alias_name(
                    unimplemented!(),
                ));
                return None;
            }
        };
        let aliased_type = match self.parse_type() {
            Some(aliased_type) => aliased_type,
            _ => {
                self.register(ParseError::expected_aliased_type(unimplemented!()));
                return None;
            }
        };
        Some(Alias {
            decorations,
            name,
            aliased_type,
            span: unimplemented!(),
        })
    }

    /// Parses a `val something = literal` statement. Returns `Some(Val)` or `None` if the statement
    /// was improperly formatted.
    fn parse_value(&mut self, decorations: Decorations) -> Option<Value> {
        self.expect_keyword("val")?;
        let name = match self.parse_identifier(Some(Case::Dromedar)) {
            Some(name) => name,
            None => {
                self.register(ParseError::expected_val_name(unimplemented!()));
                return None;
            }
        };
        let colon = match self.advance() {
            Some(token @ Token!(TokenKind::Colon)) => token,
            _ => {
                self.register(ParseError::expected_colon(unimplemented!()));
                return None;
            }
        };
        let value_type = match self.parse_type() {
            Some(value_type) => value_type,
            None => {
                self.register(ParseError::expected_value_type(unimplemented!()));
                return None;
            }
        };
        let equal_sign = match self.advance() {
            Some(token @ Token!(TokenKind::EqualSign)) => token,
            _ => {
                self.register(ParseError::expected_equal_sign_after_val_name(
                    unimplemented!(),
                ));
                return None;
            }
        };
        let literal = match self.parse_literal() {
            Some(literal) => literal,
            None => {
                self.register(ParseError::expected_literal_for_value(unimplemented!()));
                return None;
            }
        };
        Some(Value {
            decorations,
            name,
            value_type,
            literal,
        })
    }

    fn parse_type_definition(&mut self) -> Option<TypeDefinition> {
        unimplemented!()
    }

    /// Parses a type. Returns `Ok(Some(Type))` if a type was found, `Ok(None)` if an improperly
    /// formatted type was found, and `Err(())` if no type was found at all.
    fn parse_type(&mut self) -> Option<Type> {
        unimplemented!();
    }

    /// Parses a value. Returns `Ok(Some(Value))` if a value was found, `Ok(None)` if it was
    /// improperly formatted, and `Err(())` if no value was found at all.
    fn parse_literal(&mut self) -> Option<Literal> {
        unimplemented!();
    }

    /// Parses an identifier.
    fn parse_identifier(&mut self, case: Option<Case>) -> Option<Identifier> {
        match self.advance() {
            Some(TokenWithSpan!(TokenKind::Word(word), span)) => Some(Identifier {
                name: word.to_string(),
                span,
            }), // TODO: check casing
            _ => None,
        }
    }

    /// Parses a string.
    fn parse_string(&mut self) -> Option<StringLiteral> {
        let mut span: Option<Span> = None;
        let mut string = match self.peek() {
            Some(TokenWithSpan!(TokenKind::String(string), first_span)) => {
                self.advance();
                span = Some(*first_span);
                string
            }
            _ => return None,
        };
        loop {
            match self.peek() {
                Some(TokenWithSpan!(TokenKind::String(next_string), next_span)) => {
                    self.advance();
                    span = Some(span.unwrap().start..next_span.end);
                    string.push_str(next_string);
                }
                _ => break,
            }
        }
        Some(StringLiteral {
            string: *string,
            span: span.unwrap(),
        })
    }

    /// Parses a keyword. Returns `Some(Token)` if the specified keyword was found or `None` otherwise.
    fn expect_keyword(&mut self, keyword: &str) -> Option<Token> {
        self.advance_if(|atom| match atom {
            Token!(TokenKind::Word(word)) if word == keyword => true,
            _ => false,
        })
    }
}

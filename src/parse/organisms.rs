use crate::parse::atoms::Atom;
use crate::parse::error::ParseError;
use crate::parse::utils::{CursorParser, MatchActions};
use crate::utils::Case;
use crate::utils::Positioned;
use num::{BigInt, ToPrimitive};
use semver::Version;

#[derive(Debug)]
pub enum RootElement {
    Comment(Comment),
    Package(PackageName),
    Import(Import), // TODO: Rename to import
    Annotation(Annotation),
    Struct(Struct),
    Enum(Enum),
    Alias(Alias),
    Const(Val),
}

type PackageName = String;
type Comment = String;

#[derive(Debug)]
struct Import {
    source: String,
    imports: Vec<String>,
}

#[derive(Debug)]
enum Annotation {
    Added { version: Version },
    Deprecated { version: Version, reason: String },
}

#[derive(Debug)]
struct Struct {
    name: String,
    body: Vec<StructElement>,
}

#[derive(Debug)]
enum StructElement {
    Comment(Comment),
    Annotation(Annotation),
    Field(StructField),
}

#[derive(Debug)]
struct StructField {
    name: String,
    field_type: Type,
    default: Option<Value>,
}

#[derive(Debug)]
struct Enum {
    name: String,
    body: Vec<EnumElement>,
}

#[derive(Debug)]
enum EnumElement {
    Comment(Comment),
    Annotation(Annotation),
    Variant(EnumVariant),
}

#[derive(Debug)]
struct EnumVariant {
    name: String,
    associated_type: Option<Type>,
}

#[derive(Debug)]
pub struct Alias {
    name: String,
    aliased_type: Type,
}

#[derive(Debug)]
pub struct Val {
    name: String,
    value: Value,
}

#[derive(Debug)]
pub struct Type {
    name: String,
    generics: Vec<Type>,
}

#[derive(Debug)]
pub enum Value {
    String(String),
    IntegerNumber(BigInt),
    FloatNumber(BigInt, BigInt),
    EnumVariant(String, Option<Box<Value>>),
    Const(String),
}

// ---

pub type OrganismParser<'a> = CursorParser<'a, Positioned<Atom>>;

impl OrganismParser<'_> {
    pub fn parse(&mut self) -> Option<Vec<RootElement>> {
        let mut body: Vec<RootElement> = vec![];
        loop {
            match self.peek() {
                None => break Some(body), // This body has ended.
                Some(Atom::Comment(_)) => self
                    .parse_comment()
                    .map(|comment| RootElement::Comment(comment)),
                Some(Atom::At) => self
                    .parse_annotation()
                    .map(|annotation| RootElement::Annotation(annotation)),
                Some(Atom::Word(word)) => match word.as_ref() {
                    "package" => self.parse_package().map(|name| RootElement::Package(name)),
                    "from" => self.parse_use().map(|u| RootElement::Import(u)),
                    "struct" => self.parse_struct().map(|s| RootElement::Struct(s)),
                    "enum" => self.parse_enum().map(|e| RootElement::Enum(e)),
                    "alias" => self.parse_alias().map(|alias| RootElement::Alias(alias)),
                    "val" => self.parse_val().map(|value| RootElement::Const(value)),
                    _ => unimplemented!(),
                },
                _ => unimplemented!(), // TODO: throw
            }
            .map(|element| body.push(element));
        }
    }

    fn parse_comment(&mut self) -> Option<Comment> {
        let mut text = "".to_string();
        loop {
            match self.peek() {
                Some(Atom::Comment(comment)) => {
                    text.push_str(&comment);
                    self.advance();
                }
                _ => break Some(text), // We found something non-comment-y, so we're done here.
            }
        }
    }

    fn parse_annotation(&mut self) -> Option<Annotation> {
        self.advance_if(matcher!(Atom::At))?;
        match self.parse_word(None)?.as_ref() {
            "added" => {
                self.advance_if(matcher!(Atom::ParenOpen))?;
                let version = self.parse_version()?;
                self.advance_if(matcher!(Atom::ParenClose))?;
                Some(Annotation::Added { version })
            }
            "deprecated" => {
                self.advance_if(matcher!(Atom::ParenOpen))?;
                let version = self.parse_version()?;
                self.advance_if(matcher!(Atom::Comma))?;
                let reason = self.parse_string()?;
                self.advance_if(matcher!(Atom::ParenClose))?;
                Some(Annotation::Deprecated {
                    version,
                    reason: reason.to_string(),
                })
            }
            _ => None, // TODO:
        }
    }

    fn parse_version(&mut self) -> Option<Version> {
        let major = self.parse_version_number()?;
        self.advance_if(matcher!(Atom::Dot))?;
        let minor = self.parse_version_number()?;
        self.advance_if(matcher!(Atom::Dot))?;
        let patch = self.parse_version_number()?;
        Some(Version {
            major,
            minor,
            patch,
            pre: vec![],
            build: vec![],
        })
    }

    fn parse_version_number(&mut self) -> Option<u64> {
        match self.advance() {
            Some(Atom::Number(num)) => match num.to_u64() {
                Some(num) => Some(num),
                None => None, // TODO:
            },
            _ => None, // TODO
        }
    }

    fn parse_package(&mut self) -> Option<PackageName> {
        self.expect_keyword("package")?;
        self.parse_word(Some(Case::Kebab))
    }

    fn parse_use(&mut self) -> Option<Import> {
        self.expect_keyword("from")?;
        let source = self.parse_word(Some(Case::Kebab))?;
        self.expect_keyword("use")?;
        let mut imports = vec![self.parse_word(None)?];
        loop {
            match self.advance_if(matcher!(Atom::Comma)) {
                Some(_) => imports.push(self.parse_word(None)?),
                None => break Some(Import { source, imports }),
            }
        }
    }

    fn parse_struct(&mut self) -> Option<Struct> {
        self.expect_keyword("struct")?;
        let name = self.parse_word(Some(Case::Camel))?;
        self.advance_if(matcher!(Atom::BraceOpen))?;

        let mut body: Vec<StructElement> = vec![];
        loop {
            match self.peek() {
                Some(Atom::BraceClose) => break, // This body has ended.
                Some(Atom::Comment(_)) => self
                    .parse_comment()
                    .map(|comment| StructElement::Comment(comment)),
                Some(Atom::At) => self
                    .parse_annotation()
                    .map(|annotation| StructElement::Annotation(annotation)),
                Some(Atom::Word(_)) => self
                    .parse_struct_field()
                    .map(|field| StructElement::Field(field)),
                _ => unimplemented!(), // TODO: throw
            }
            .map(|element| body.push(element));
        }
        Some(Struct { name, body })
    }

    fn parse_struct_field(&mut self) -> Option<StructField> {
        let name = self.parse_word(Some(Case::Snake))?;
        self.advance_if(matcher!(Atom::Colon))?;
        let field_type = self
            .parse_type()
            .on_no_match(|| self.register(ParseError::expected_struct_field_type()))?;
        let default = match self.advance_if(matcher!(Atom::EqualSign)) {
            Some(_) => Some(self.parse_value()?),
            None => None,
        };
        Some(StructField {
            name,
            field_type,
            default,
        })
    }

    fn parse_enum(&mut self) -> Option<Enum> {
        self.expect_keyword("enum")?;
        let name = self.parse_word(Some(Case::Camel))?;
        self.advance_if(matcher!(Atom::BraceOpen))?;

        let mut body: Vec<EnumElement> = vec![];
        loop {
            match self.peek() {
                Some(Atom::BraceClose) => break, // This body has ended.
                Some(Atom::Comment(_)) => self.parse_comment().map(|c| EnumElement::Comment(c)),
                Some(Atom::At) => self.parse_annotation().map(|a| EnumElement::Annotation(a)),
                Some(Atom::Word(_)) => self.parse_enum_variant().map(|v| EnumElement::Variant(v)),
                _ => unimplemented!(), // TODO: throw
            }
            .map(|element| body.push(element));
        }
        Some(Enum { name, body })
    }

    fn parse_enum_variant(&mut self) -> Option<EnumVariant> {
        let name = self.parse_word(Some(Case::Dromedar))?;
        let associated_type = match self.advance_if(matcher!(Atom::Arrow)) {
            Some(Atom::Arrow) => Some(self.parse_type()?),
            _ => None,
        };
        Some(EnumVariant {
            name,
            associated_type,
        })
    }

    fn parse_alias(&mut self) -> Option<Alias> {
        self.expect_keyword("alias")?;
        let name = self.parse_word(Some(Case::Camel))?;
        self.advance_if(matcher!(Atom::EqualSign))?;
        let aliased_type = self.parse_type()?;
        Some(Alias { name, aliased_type })
    }

    /// Parses a `val something = value` statement. Returns `Some(Val)` or `None` if the statement
    /// was improperly formatted.
    fn parse_val(&mut self) -> Option<Val> {
        self.expect_keyword("val")?;
        let name = match self.parse_word(Some(Case::Camel)) {
            Ok(word) => word,
            Err(()) => {
                self.register(ParseError::expected_val_name(
                    self.peek_map(|atom| atom.position),
                ));
                None
            }
        };
        self.advance_if(matcher!(Atom::EqualSign))?;
        let value = self.parse_value()?;
        Some(Val { name, value })
    }

    /// Parses a type. Returns `Ok(Some(Type))` if a type was found, `Ok(None)` if an improperly
    /// formatted type was found, and `Err(())` if no type was found at all.
    fn parse_type(&mut self) -> Result<Option<Type>, ()> {
        unimplemented!();
    }

    /// Parses a value. Returns `Ok(Some(Value))` if a value was found, `Ok(None)` if it was
    /// improperly formatted, and `Err(())` if no value was found at all.
    fn parse_value(&mut self) -> Option<Value> {
        unimplemented!();
    }

    /// Parses a word. Returns `Ok(String)`, or `Err(())` if no word was found.
    fn parse_word(&mut self, case: Option<Case>) -> Result<String, ()> {
        match self.advance() {
            Some(Atom::Word(word)) => Ok(word.to_string()), // TODO: check casing
            _ => Err(()),
        }
    }

    /// Parses a string. Panics if no string was found.
    fn parse_string(&mut self) -> String {
        let mut string = match self.advance_if(matcher!(AnyPos!(Atom::String(_)))) {
            Some(Atom::String(string)) => string,
            _ => panic!("parse_string called but there is no string."),
        };
        loop {
            match self.advance_if(matcher!(Atom::String(_))) {
                Some(Atom::String(additional_string)) => string.push_str(&additional_string),
                _ => break string,
            }
        }
    }

    /// Parses a keyword. Returns `Some(())` if the specified keyword was found or `None` otherwise.
    fn expect_keyword(&mut self, keyword: &str) -> Option<()> {
        self.advance_if(|atom| match atom {
            AnyPos!(Atom::Word(word)) if word == keyword => true,
            _ => false,
        })
        .map(|_| {})
    }
}

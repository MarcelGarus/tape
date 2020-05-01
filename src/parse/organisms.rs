use crate::parse::atoms::Atom;
use crate::parse::error::ParseError;
use crate::parse::utils::CursorParser;
use crate::utils::Case;
use num::{BigInt, ToPrimitive};
use semver::Version;

#[derive(Debug)]
pub enum RootElement {
    Comment(Comment),
    Package(PackageName),
    Use(Use),
    Annotation(Annotation),
    Struct(Struct),
    Enum(Enum),
    Alias(Alias),
    Const(Const),
}

type PackageName = String;
type Comment = String;

#[derive(Debug)]
struct Use {
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
pub struct Const {
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

pub struct OrganismParser {
    parser: CursorParser<Atom>,
    pub errors: Vec<ParseError>,
}

impl OrganismParser {
    pub fn from_atoms(atoms: Vec<Atom>) -> Self {
        OrganismParser {
            parser: CursorParser::from(atoms),
            errors: vec![],
        }
    }

    pub fn parse(&mut self) -> Option<Vec<RootElement>> {
        let mut body: Vec<RootElement> = vec![];
        loop {
            match self.parser.peek() {
                None => break Some(body), // This body has ended.
                Some(Atom::Comment(_)) => self
                    .parse_comment()
                    .map(|comment| RootElement::Comment(comment)),
                Some(Atom::At) => self
                    .parse_annotation()
                    .map(|annotation| RootElement::Annotation(annotation)),
                Some(Atom::Word(word)) => match word.as_ref() {
                    "package" => self.parse_package().map(|name| RootElement::Package(name)),
                    "from" => self.parse_use().map(|u| RootElement::Use(u)),
                    "struct" => self.parse_struct().map(|s| RootElement::Struct(s)),
                    "enum" => self.parse_enum().map(|e| RootElement::Enum(e)),
                    "alias" => self.parse_alias().map(|alias| RootElement::Alias(alias)),
                    "val" => self.parse_const().map(|value| RootElement::Const(value)),
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
            match self.parser.peek() {
                Some(Atom::Comment(comment)) => {
                    text.push_str(&comment);
                    self.parser.advance();
                }
                _ => break Some(text), // We found something non-comment-y, so we're done here.
            }
        }
    }

    fn parse_annotation(&mut self) -> Option<Annotation> {
        self.expect_match(matcher!(Atom::At))?;
        match self.parse_word(None)?.as_ref() {
            "added" => {
                self.expect_match(matcher!(Atom::ParenOpen))?;
                let version = self.parse_version()?;
                self.expect_match(matcher!(Atom::ParenClose))?;
                Some(Annotation::Added { version })
            }
            "deprecated" => {
                self.expect_match(matcher!(Atom::ParenOpen))?;
                let version = self.parse_version()?;
                self.expect_match(matcher!(Atom::Comma))?;
                let reason = match self.parser.advance() {
                    Some(Atom::String(string)) => string.clone(),
                    _ => return None, // TODO:
                };
                self.expect_match(matcher!(Atom::ParenClose))?;
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
        self.expect_match(matcher!(Atom::Dot))?;
        let minor = self.parse_version_number()?;
        self.expect_match(matcher!(Atom::Dot))?;
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
        match self.parser.advance() {
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

    fn parse_use(&mut self) -> Option<Use> {
        self.expect_keyword("from")?;
        let source = self.parse_word(Some(Case::Kebab))?;
        self.expect_keyword("use")?;
        let mut imports = vec![self.parse_word(None)?];
        while matches!(self.parser.peek(), Some(Atom::Comma)) {
            self.parser.advance(); // Consume comma.
            imports.push(self.parse_word(None)?);
        }
        Some(Use { source, imports })
    }

    fn parse_struct(&mut self) -> Option<Struct> {
        self.expect_keyword("struct")?;
        let name = self.parse_word(Some(Case::Camel))?;
        self.expect_match(matcher!(Atom::BraceOpen))?;

        let mut body: Vec<StructElement> = vec![];
        loop {
            match self.parser.peek() {
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
        self.expect_match(matcher!(Atom::Colon))?;
        let field_type = self.parse_type()?;
        let default = match self.parser.peek() {
            Some(Atom::EqualSign) => {
                self.parser.advance(); // Consume sign.
                Some(self.parse_value()?)
            }
            _ => None,
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
        self.expect_match(matcher!(Atom::BraceOpen))?;

        let mut body: Vec<EnumElement> = vec![];
        loop {
            match self.parser.peek() {
                Some(Atom::BraceClose) => break, // This body has ended.
                Some(Atom::Comment(_)) => self
                    .parse_comment()
                    .map(|comment| EnumElement::Comment(comment)),
                Some(Atom::At) => self
                    .parse_annotation()
                    .map(|annotation| EnumElement::Annotation(annotation)),
                Some(Atom::Word(_)) => self
                    .parse_enum_variant()
                    .map(|variant| EnumElement::Variant(variant)),
                _ => unimplemented!(), // TODO: throw
            }
            .map(|element| body.push(element));
        }
        Some(Enum { name, body })
    }

    fn parse_enum_variant(&mut self) -> Option<EnumVariant> {
        let name = self.parse_word(Some(Case::Dromedar))?;
        let associated_type = match self.parser.peek() {
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
        self.expect_match(matcher!(Atom::EqualSign))?;
        let aliased_type = self.parse_type()?;
        Some(Alias { name, aliased_type })
    }

    fn parse_const(&mut self) -> Option<Const> {
        self.expect_keyword("const")?;
        let name = self.parse_word(Some(Case::Camel))?;
        self.expect_match(matcher!(Atom::EqualSign))?;
        let value = self.parse_value()?;
        Some(Const { name, value })
    }

    fn parse_type(&mut self) -> Option<Type> {
        unimplemented!();
    }

    fn parse_value(&mut self) -> Option<Value> {
        unimplemented!();
    }

    fn parse_word(&mut self, case: Option<Case>) -> Option<String> {
        match self.parser.advance() {
            Some(Atom::Word(word)) => Some(word.to_string()), // TODO: check casing
            _ => None,                                        // TODO: add error.
        }
    }

    fn expect_keyword(&mut self, keyword: &str) -> Option<()> {
        match self.parser.peek() {
            Some(Atom::Word(word)) if word == keyword => {
                self.parser.advance(); // Consume keyword.
                Some(())
            }
            _ => None, // TODO: add error
        }
    }

    fn expect_match<P>(&mut self, predicate: P) -> Option<()>
    where
        P: FnOnce(&Atom) -> bool,
    {
        match self.parser.peek() {
            Some(atom) if predicate(&atom) => {
                self.parser.advance();
                Some(())
            }
            _ => None, // TODO: add error
        }
    }
}

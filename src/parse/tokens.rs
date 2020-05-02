#![feature(or_patterns)]

use crate::parse::error::ParseError;
use crate::parse::utils::ErrorRegistry;
use crate::parse::utils::{CharUtils, CursorParser, MatchActions};
use crate::utils::IntoString;
use crate::utils::Span;
use num::bigint::BigUint;

/// A minimally higher representation of the source's characters.
/// Differentiates between comments, words, numbers, strings, etc. Represents either a single
/// character or a line of related characters of the same unit.
#[derive(Debug, Clone)]
pub struct Token {
    pub kind: TokenKind,
    pub span: Span,
}

#[derive(Debug, Clone)]
pub enum TokenKind {
    BraceOpen,       // {
    BraceClose,      // }
    TagOpen,         // <
    TagClose,        // >
    ParenOpen,       // (
    ParenClose,      // )
    BracketOpen,     // [
    BracketClose,    // ]
    Colon,           // :
    EqualSign,       // =
    Dot,             // .
    Comma,           // ,
    At,              // @
    Arrow,           // ->
    Plus,            // +, only used in versions
    Minus,           // -, only used before a number or in versions
    Number(BigUint), // e.g. 5 or 141847320417234732
    String(String),  // e.g. "Hi 😊"
    Comment(String), // single line comment e.g. // Hi.
    Word(String),    // A word (possibly keyword or identifier).
}

pub fn parse_tokens(source: &str, error_registry: &mut ErrorRegistry) -> Vec<Token> {
    let parser: TokenParser = TokenParser {
        cursor: CursorParser::from(source.chars().collect(), error_registry),
        offset: 0,
    };
    parser.parse()
}

/// Used for storing the current escaping state when parsing strings.
enum Escaping {
    Escaped,
    NotEscaped,
}
use Escaping::*;

struct TokenParser<'a> {
    cursor: CursorParser<'a, char>,
    offset: usize, // Offset in bytes.
}

impl TokenParser<'_> {
    fn advance(&mut self) -> Option<char> {
        let chr = self.cursor.advance();
        if let Some(c) = chr {
            self.offset += c.len_utf8();
        }
        chr
    }

    pub fn advance_while<P>(&mut self, predicate: P) -> Vec<char>
    where
        P: Fn(&char) -> bool,
    {
        self.advance_while(predicate)
    }

    pub fn register(&mut self, error: ParseError) {
        self.register(error)
    }

    pub fn peek(&mut self) -> Option<&char> {
        self.peek()
    }

    pub fn parse(&mut self) -> Vec<Token> {
        let mut tokens: Vec<Token> = vec![];
        while !self.cursor.is_done() {
            let start = self.offset;
            let maybe_kind = self.parse_token_kind();
            let end = self.offset;
            match maybe_kind {
                None => {}
                Some(kind) => tokens.push(Token {
                    kind,
                    span: start..end,
                }),
            }
        }
        tokens
    }

    /// Parses the next token on a best-effort basis. May also register [ParseError]s as a side
    /// effect.
    fn parse_token_kind(&mut self) -> Option<TokenKind> {
        let first_char = self.advance()?;
        match first_char {
            '{' => Some(TokenKind::BraceOpen),
            '}' => Some(TokenKind::BraceClose),
            '<' => Some(TokenKind::TagOpen),
            '>' => Some(TokenKind::TagClose),
            '(' => Some(TokenKind::ParenOpen),
            ')' => Some(TokenKind::ParenClose),
            '[' => Some(TokenKind::BracketOpen),
            ']' => Some(TokenKind::BracketClose),
            ':' => Some(TokenKind::Colon),
            '=' => Some(TokenKind::EqualSign),
            '.' => Some(TokenKind::Dot),
            ',' => Some(TokenKind::Comma),
            '@' => Some(TokenKind::At),
            '+' => Some(TokenKind::Plus),
            '-' => match self.cursor.peek() {
                Some('>') => {
                    self.advance();
                    Some(TokenKind::Arrow)
                }
                _ => Some(TokenKind::Minus),
            },
            c @ '0'..='9' => Some(TokenKind::Number(self.parse_number(c))),
            '"' => Some(TokenKind::String(self.parse_string())),
            '/' => Some(TokenKind::Comment(self.parse_comment())),
            c @ ('A'..='Z' | 'a'..='z' | '_') => Some(TokenKind::Word(self.parse_word(c))),
            _ => {
                self.register(ParseError::unsupported_character(
                    self.offset - first_char.len_utf8(),
                ));
                None
            }
        }
    }

    fn parse_number(&mut self, first_digit: char) -> BigUint {
        let mut digits = first_digit.to_string();
        loop {
            match self.cursor.peek() {
                Some(c @ '0'..='9') => digits.push(*c),
                // Parsing is guaranteed to succeed, because we know we have only digits.
                _ => break digits.parse().unwrap(),
            }
        }
    }

    fn parse_string(&mut self) -> String {
        // First '"' has already been parsed.
        let start_offset = self.offset;
        let mut string = String::new();
        let mut escaping = NotEscaped;
        loop {
            let mut next_escaping = NotEscaped;
            match (self.advance(), escaping) {
                (Some('\\'), NotEscaped) => next_escaping = Escaped,
                (Some('\\'), Escaped) => string.push('\\'),
                (Some('n'), Escaped) => string.push('\n'),
                (Some('"'), Escaped) => string.push('"'),
                (Some('"'), NotEscaped) => break string,
                (Some(chr), NotEscaped) => string.push(chr),
                (Some(chr), Escaped) => {
                    self.register(ParseError::invalid_escaping_in_string(self.offset));
                    // While this is an error, continue parsing the string. Add the faultily
                    // escaped character to the string as well.
                    string.push(chr);
                }
                (Some('\n'), _) => {
                    self.register(ParseError::newline_in_string(self.offset));
                    // While this is an error, continue parsing the string on the next line
                    // and strip all leading whitespace.
                    self.advance_while(|chr| chr.is_whitespace());
                }
                (None, _) => {
                    self.register(ParseError::unterminated_string(start_offset..self.offset))
                }
            }
            escaping = next_escaping;
        }
    }

    fn parse_comment(&mut self) -> String {
        // println!("This seems to be a comment.");
        if !matches!(self.advance(), Some('/')) {
            self.register(ParseError::lonely_slash(self.offset));
        }
        if !matches!(self.advance(), Some(' ')) {
            self.register(ParseError::no_space_after_double_slash(self.offset));
        }
        self.advance_while(|chr| chr != &'\n').into_string()
    }

    fn parse_word(&mut self, first_char: char) -> String {
        let mut word = first_char.to_string();
        loop {
            match self.peek() {
                Some(c @ ('A'..'Z' | 'a'..'z' | '0'..'9' | '_' | '-')) => {
                    self.advance();
                    word.push(*c);
                }
                _ => break word,
            }
        }
    }
}

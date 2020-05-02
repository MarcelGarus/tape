use crate::parse::error::ParseError;
use crate::parse::utils::{CursorParser, MatchActions};
use crate::utils::{IntoString, Positioned};
use num::bigint::BigUint;

/// A minimally higher representation of the source's characters, differentiating between
/// whitespace, punctuation, numbers, strings, comments and words. Represents either single
/// characters or a line of characters of the same type like "some string" and 123 – the notable
/// exception being comments, which are already grouped together to a single atom.
#[derive(Debug)]
pub enum Atom {
    BraceOpen,       // {
    BraceClose,      // }
    TagOpen,         // <
    TagClose,        // >
    ParenOpen,       // (
    ParenClose,      // )
    BracketOpen,     // [ TODO: parse
    BracketClose,    // ] TODO: parse
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

trait CharUtils {
    fn is_decimal_digit(&self) -> bool;
    fn is_word(&self) -> bool;
}

impl CharUtils for char {
    fn is_decimal_digit(&self) -> bool {
        self.is_digit(10)
    }
    fn is_word(&self) -> bool {
        matches!(self, 'a'..='z' | 'A'..='Z' | '0'..='9' | '_' | '-')
    }
}

pub type AtomParser<'a> = CursorParser<'a, char>;

impl AtomParser<'_> {
    pub fn parse(&mut self) -> Vec<Positioned<Atom>> {
        let mut atoms: Vec<Positioned<Atom>> = vec![];
        while !self.is_done() {
            let cursor_before = self.cursor();
            let maybe_atom = self.parse_atom();
            let cursor_after = self.cursor();
            match maybe_atom {
                None => {}
                Some(atom) => atoms.push(Positioned {
                    data: atom,
                    position: cursor_before..cursor_after,
                }),
            }
        }
        atoms
    }

    /// Parses the next atom on a best-effort basis.
    /// If no [ParseError]s occur, just returns the atom. Otherwise, register errors and possibly
    /// returns a best-effort guess of the atom.
    fn parse_atom(&mut self) -> Option<Atom> {
        // println!("Parsing atom. Next char is {}", next_char);
        match self.advance()? {
            '{' => Some(Atom::BraceOpen),
            '}' => Some(Atom::BraceClose),
            '<' => Some(Atom::TagOpen),
            '>' => Some(Atom::TagClose),
            '(' => Some(Atom::ParenOpen),
            ')' => Some(Atom::ParenClose),
            '[' => Some(Atom::BracketOpen),
            ']' => Some(Atom::BracketClose),
            ':' => Some(Atom::Colon),
            '=' => Some(Atom::EqualSign),
            '.' => Some(Atom::Dot),
            ',' => Some(Atom::Comma),
            '@' => Some(Atom::At),
            '+' => Some(Atom::Plus),
            '-' => Some(match self.advance_if(matcher!('>')) {
                Some(_) => Atom::Arrow,
                None => Atom::Minus,
            }),
            chr if chr.is_decimal_digit() => Some(Atom::Number(
                self.advance_while_with_initial(|chr| chr.is_decimal_digit(), vec![chr])
                    .into_string()
                    .parse()
                    .unwrap(), // Guaranteed to succeed, because we know we have only digits.
            )),
            '"' => {
                let start_offset = self.cursor();
                let mut string = String::new();
                let mut is_escaped = false;
                loop {
                    let mut escape_next = false;
                    match (self.advance(), is_escaped) {
                        (Some('\\'), false) => escape_next = true,
                        (Some('\\'), true) => string.push('\\'),
                        (Some('n'), true) => string.push('\n'),
                        (Some('\n'), _) => {
                            self.register(ParseError::newline_in_string(self.cursor()));
                            // While this is an error, continue parsing the string on the next line
                            // and strip all leading whitespace.
                            self.advance_while(|chr| chr.is_whitespace());
                        }
                        (Some('"'), true) => string.push('"'),
                        (Some('"'), false) => break Some(Atom::String(string)),
                        (Some(chr), true) => {
                            self.register(ParseError::invalid_escaping_in_string(self.cursor()));
                            // While this is an error, continue parsing the string. Add the faultily
                            // escaped character to the string as well.
                            string.push(chr);
                        }
                        (Some(chr), false) => string.push(chr),
                        (None, _) => self
                            .register(ParseError::unterminated_string(start_offset..self.cursor())),
                    }
                    is_escaped = escape_next;
                }
            }
            '/' => {
                // println!("This seems to be a comment.");
                self.advance_if(matcher!('/'))
                    .on_no_match(|| self.register(ParseError::lonely_slash(self.cursor())));
                self.advance_if(matcher!(' ')).on_no_match(|| {
                    self.register(ParseError::no_space_after_double_slash(self.cursor()))
                });
                // println!("Getting comment text.");
                Some(Atom::Comment(
                    self.advance_while(|chr| chr != &'\n').into_string(),
                ))
            }
            chr if chr.is_word() => Some(Atom::Word(
                self.advance_while_with_initial(|chr| chr.is_word(), vec![chr])
                    .into_string(),
            )),
            _ => {
                self.register(ParseError::unsupported_character(self.cursor()));
                None
            }
        }
    }
}

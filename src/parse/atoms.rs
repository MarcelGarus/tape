use crate::parse::error::ParseError;
use crate::parse::utils::{CursorParser, IntoString};
use crate::utils::Positioned;
use num::bigint::BigUint;

/// A minimally higher representation of the source's characters, differentiating between
/// whitespace, punctuation, numbers, strings, comments and words. Represents either single
/// characters or a line of characters of the same type like "some string" and 123 – the notable
/// exception being comments, which are already grouped together to a single atom.
#[derive(Debug)]
pub enum Atom {
    Newlines(usize), // newlines
    BraceOpen,       // {
    BraceClose,      // }
    TagOpen,         // <
    TagClose,        // >
    ParenOpen,       // (
    ParenClose,      // )
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
    Word(String),    // A word.
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
        match self {
            'a'..='z' => true,
            'A'..='Z' => true,
            '0'..='9' => true,
            '_' => true,
            _ => false,
        }
    }
}

pub type AtomParser = CursorParser<char>;

impl AtomParser {
    pub fn from_source(source: &str) -> Self {
        AtomParser::from(source.chars().collect())
    }

    pub fn parse(&self) -> (Vec<Positioned<Atom>>, Vec<ParseError>) {
        let mut atoms: Vec<Positioned<Atom>> = vec![];
        let mut errors: Vec<ParseError> = vec![];
        loop {
            let cursor_before = self.cursor;
            match self.next_atom() {
                None => break (atoms, errors), // We are done.
                Some(result) => {
                    let (maybe_atom, mut current_errors) = result;
                    match maybe_atom {
                        Some(atom) => atoms.push(Positioned {
                            data: atom,
                            position: cursor_before..self.cursor,
                        }),
                        _ => {}
                    }
                    errors.append(&mut current_errors);
                }
            }
        }
    }

    /// Parses the next atom on a best-effort basis.
    /// If no [ParseError]s occur, just returns the atom and an empty [Vec]. Otherwise, returns a
    /// best-effort guess of the atom as well as a [Vec] of [ParseError]s that occurred during
    /// parsing.
    fn next_atom(&mut self) -> Option<(Option<Atom>, Vec<ParseError>)> {
        let mut errors: Vec<ParseError> = vec![];
        // println!("Parsing atom. Next char is {}", next_char);
        let atom = match self.advance()? {
            chr if chr.is_whitespace() => {
                let num_newlines = self
                    .advance_while_with_initial(|chr| chr.is_whitespace(), vec![chr])
                    .iter()
                    .filter(|chr| **chr == '\n')
                    .count();
                if num_newlines > 0 {
                    Some(Atom::Newlines(num_newlines))
                } else {
                    None
                }
            }
            '{' => Some(Atom::BraceOpen),
            '}' => Some(Atom::BraceClose),
            '<' => Some(Atom::TagOpen),
            '>' => Some(Atom::TagClose),
            '(' => Some(Atom::ParenOpen),
            ')' => Some(Atom::ParenClose),
            ':' => Some(Atom::Colon),
            '=' => Some(Atom::EqualSign),
            '.' => Some(Atom::Dot),
            ',' => Some(Atom::Comma),
            '@' => Some(Atom::At),
            '+' => Some(Atom::Plus),
            '-' => {
                if let Some('>') = self.peek() {
                    self.advance();
                    Some(Atom::Arrow)
                } else {
                    Some(Atom::Minus)
                }
            }
            chr if chr.is_decimal_digit() => Some(Atom::Number(
                self.advance_while_with_initial(|chr| chr.is_decimal_digit(), vec![chr])
                    .into_string()
                    .parse()
                    .unwrap(),
            )),
            '"' => {
                let start_offset = self.cursor;
                let mut string = String::new();
                let mut is_escaped = false;
                loop {
                    let mut escape_next = false;
                    match (self.advance(), is_escaped) {
                        (Some('\\'), false) => escape_next = true,
                        (Some('\\'), true) => string.push('\\'),
                        (Some('"'), true) => string.push('"'),
                        (Some('"'), false) => break Some(Atom::String(string)),
                        (Some('n'), true) => string.push('\n'),
                        (Some('\n'), _) => {
                            errors.push(ParseError::newline_in_string(self.cursor));
                            // While this is an error, continue parsing the string on the next line
                            // and strip all leading whitespace.
                            self.advance_while(|chr| chr.is_whitespace());
                        }
                        (Some(chr), true) => {
                            errors.push(ParseError::invalid_escaping_in_string(self.cursor));
                            // While this is an error, continue parsing the string. Add the faultily
                            // escaped character to the string as well.
                            string.push(chr);
                        }
                        (Some(chr), false) => string.push(chr),
                        (None, _) => {
                            errors.push(ParseError::unterminated_string(start_offset..self.cursor))
                        }
                    }
                    is_escaped = escape_next;
                }
            }
            '/' => {
                // println!("This seems to be a comment.");
                if let Some('/') = self.advance() {
                } else {
                    errors.push(ParseError::lonely_slash(self.cursor));
                }
                if let Some(' ') = self.peek() {
                    self.advance(); // Consume space.
                } else {
                    errors.push(ParseError::no_space_after_double_slash(self.cursor));
                }
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
                errors.push(ParseError::unsupported_character(self.cursor));
                None
            }
        };
        // println!("Next atom is {:?}", atom);
        Some((atom, errors))
    }
}

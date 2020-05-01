use crate::utils::Positioned;
use semver::Version;
use std::iter::Peekable;

/// A minimally higher representation of the source's characters,
/// differentiating between whitespace, punctuation, numbers, strings, comments
/// and words.
pub enum Atom {
    Whitespace(String), // multiple of space, \t, \n. e.g. "\t \n\n   "
    BraceOpen,          // {
    BraceClose,         // }
    TagOpen,            // <
    TagClose,           // >
    Colon,              // :
    EqualSign,          // =
    Number(u64),        // e.g. 5 or 141847320417234732 TODO: support arbitrary big numbers
    String,             // e.g. "Hi 😊"
    Comment(String),    // single line comment e.g. // Hi.
    Word(String),       // A word.
}

pub trait Atomizable {
    fn atoms(&self) -> AtomIter;
}

impl Atomizable for str {
    fn atoms(&self) -> AtomIter {
        AtomIter::from_source(self)
    }
}

pub struct AtomIter<'a> {
    source: Peekable<std::str::Chars<'a>>,
    offset: usize,
    depth: u8,
}

impl AtomIter<'_> {
    fn from_source(source: &str) -> AtomIter {
        AtomIter {
            source: source.chars().peekable(),
            offset: 0,
            depth: 0,
        }
    }

    fn advance(&mut self) -> Option<char> {
        self.offset += 1;
        self.source.next()
    }
}

fn is_digit(chr: &char) -> bool {
    ('0'..='9').contains(&chr)
}

fn is_word(chr: &char) -> bool {
    match chr {
        'a'..='z' => true,
        'A'..='Z' => true,
        '0'..='9' => true,
        '_' => true,
        _ => false,
    }
}

impl<'a> Iterator for AtomIter<'a> {
    type Item = Positioned<Atom>;

    fn next(&mut self) -> Option<Positioned<Atom>> {
        let start = self.offset;
        let current = self.advance()?;
        let token = match current {
            chr if chr.is_whitespace() => {
                let mut whitespace = chr.to_string();
                loop {
                    match self.source.peek() {
                        Some(chr) if chr.is_whitespace() => {
                            whitespace.push(*chr);
                            self.advance();
                        }
                        _ => break Atom::Whitespace(whitespace),
                    }
                }
            }
            '{' => Atom::BraceOpen,
            '}' => Atom::BraceClose,
            '<' => Atom::TagOpen,
            '>' => Atom::TagClose,
            ':' => Atom::Colon,
            '=' => Atom::EqualSign,
            chr if is_digit(&chr) => {
                let mut digits = chr.to_string();
                loop {
                    match self.source.peek() {
                        Some(chr) if is_digit(&chr) => {
                            digits.push(*chr)
                            self.advance();
                        }
                        _ => {
                            let number = digits.parse();
                            break Atom::Number(number)
                        }
                    }
                }
            }
            '"' => {
                let mut string = String::new();
                let mut is_escaped = false;
                loop {
                    match self.advance() {
                        Some('\\') => {
                            if is_escaped {
                                string.push('\\');
                                is_escaped = false;
                            } else {
                                is_escaped = true;
                            }
                        }
                        Some('\"') => {
                            if is_escaped {
                                string.push('\"');
                                is_escaped = false;
                            } else {
                                break string;
                            }
                        }
                        Some(chr) => {
                            if is_escaped {
                                // TODO: Throw error; only \ and " need to be escaped.
                            } else {
                                string.push(chr);
                            }
                        }
                        None => {} // TODO: Throw error; unterminated string.
                    }
                }
            },
            '/' => {
                if let Some('/') = self.source.peek() {
                    self.advance();
                    if let Some(' ') = self.source.peek() {

                        let mut comment = "".to_string()
                        loop {
                            match self.source.peek() {
                                Some('\n') | None => break Atom::Comment(comment),
                                Some(chr) => comment.push(*chr)
                            }
                        }
                    } else {
                        // TODO: Throw error; there should be a space after the
                        // double slash.
                    }
                } else {
                    // TODO: Throw error; introduce comments with a double slash.
                }
            }
            chr if is_word(&chr) => {
                let mut word = "".to_string();
                loop {
                    match self.source.peek() {
                        chr if is_word(&chr) => {
                            word.push(*chr);
                            self.advance();
                        }
                        _ => break Atom::Word(word)
                    }
                }
            }
            _ => {} // TODO: Throw error; unsupported character.
        };
        Some(Positioned {
            data: token,
            position: start..self.offset,
        })
    }
}

// /// Context-sensitive detection of keywords and identifiers, semantic versions
// /// and types.
// pub enum Molecules {
//     // Special identifiers.
//     Package,
//     Tape,
//     Get,
//     Use,
//     Dot,
//     Struct,
//     Enum,
//     Type,
//     Const,
//     // Other content.
//     Whitespace(String),
//     Comment(String),
// }

/// A higher-level abstraction of the source.
// #[derive(Debug, Eq, PartialEq, Clone)]
// pub enum Token {
//     // Punctuation.
//     Whitespace(String), // multiple of space, \t, \n
//     BraceOpen,          // {
//     BraceClose,         // }
//     TagOpen,            // <
//     TagClose,           // >
//     Colon,              // :
//     EqualSign,          // =

//     // Parts.
//     Comment(String),  // Double slash followed by stuff.
//     Version(Version), // A semantic version.
//     Identifier,
//     IntegerNumber,
//     FloatingNumber,
//     String,

//     // Special identifiers.
//     Package,
//     Tape,
//     Get,
//     Use,
//     Dot,
//     Struct,
//     Enum,
//     Type,
//     Const,
// }

pub trait Tokenizable {
    /// Returns a higher-level representation of this source. Each [Token]
    /// represents a part of this source.
    fn tokens(&self) -> TokenIter;
}

impl Tokenizable for str {
    fn tokens(&self) -> TokenIter {
        TokenIter::from_source(self)
    }
}

pub struct TokenIter<'a> {
    source: Peekable<std::str::Chars<'a>>,
    offset: usize,
    depth: u8,
}

impl TokenIter<'_> {
    fn from_source(source: &str) -> TokenIter {
        TokenIter {
            source: source.chars().peekable(),
            offset: 0,
            depth: 0,
        }
    }

    fn advance(&mut self) -> Option<char> {
        self.offset += 1;
        self.source.next()
    }
}

impl<'a> Iterator for TokenIter<'a> {
    type Item = Positioned<Token>;

    fn next(&mut self) -> Option<Positioned<Token>> {
        let start = self.offset;
        let current = self.advance()?;
        let token = match (current, self.source.peek()) {
            ('{') => {
                self.advance();
                Token::Word("{".to_string())
            }
            ('}', Some('}')) => {
                self.advance();
                Token::Word("}".to_string())
            }
            ('{', _) => Token::Open,
            ('}', _) => Token::Close,
            (chr, _) if chr.is_whitespace() => {
                let mut whitespace = chr.to_string();
                loop {
                    match self.source.peek() {
                        Some(chr) if chr.is_whitespace() => {
                            whitespace.push(*chr);
                            self.advance();
                        }
                        _ => break Token::Whitespace(whitespace),
                    }
                }
            }
            _ => {
                fn belongs_to_word(chr: char) -> bool {
                    chr != '{' && chr != '}' && !chr.is_whitespace()
                }
                let mut word = "".to_string();
                word.push(current);
                while self
                    .source
                    .peek()
                    .map(|chr| belongs_to_word(*chr))
                    .unwrap_or(false)
                {
                    word.push(self.advance().expect("Scanning error")) // TODO
                }
                Token::Word(word)
            }
        };
        Some(Positioned {
            data: token,
            position: start..self.offset,
        })
    }
}

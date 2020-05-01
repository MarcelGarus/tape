use crate::parse::atoms::Atom;
use crate::parse::error::ParseError;
use crate::utils::Positioned;
use crate::parse::utils::CursorParser;
use crate::num::ToPrimitive;
use semver::Version;
use std::num::ParseFloatError;
use num::bigint::{BigInt, BigUint};

/// A moderately higher representation of the source's characters, differentiating between several
/// keywords, versions, numbers etc. Also merges adjacent strings and removes unnecessary whitespace
/// information.
#[derive(Debug)]
pub enum Molecule {
    Newlines(usize),    // \n. Saves the number of newlines.
    BraceOpen,          // {
    BraceClose,         // }
    TagOpen,            // <
    TagClose,           // >
    ParenOpen,          // (
    ParenClose,         // )
    Colon,              // :
    EqualSign,          // =
    Dot,                // .
    Comma,              // ,
    At,                 // @
    Arrow,              // ->
    IntNumber(BigInt),     // e.g. 5 or 141847320417234732
    FloatNumber(BigInt, BigUint), // e.g. 2.3 or 2.76
    Version(Version),   // e.g. 1.2.3 or 1.2.3-hi+5
    String(String),     // e.g. "Hi 😊"
    Comment(String),    // comment e.g. // Hi.
    Keyword(Keyword),   // A keyword.
    Identifier(String), // A word.
}

#[derive(Debug)]
pub enum Keyword {
    Package,
    Tape,
    Get,
    As,
    From,
    Use,
    Struct,
    Enum,
    Alias,
    Const,
}

pub type MoleculeParser = CursorParser<Positioned<Atom>>;

impl MoleculeParser {
    pub fn from_atoms(atoms: Vec<Positioned<Atom>>) -> Self {
        MoleculeParser::from(atoms)
    }

    fn parse(self) -> (Vec<Positioned<Molecule>>, Vec<ParseError>) {
        // Filter all whitespaces that don't contain a newline.
        let atoms: Vec<Positioned<Atom>> = self
            .items
            .into_iter()
            .filter(|pos_atom| match pos_atom.data {
                Atom::Whitespace(chrs) if !chrs.contains('\n') => false,
                _ => true,
            })
            .collect();
        let mut molecules: Vec<Positioned<Molecule>> = vec![];
        let mut errors: Vec<ParseError> = vec![];
        loop {
            match self.next_molecule() {
                None => break (molecules, errors), // We're done.
                Some(Ok(molecule)) => molecules.push(molecule),
                Some(Err(error)) => errors.push(error),
            }
        }
    }

    /// Parses the next molecule on a best-effort basis.
    /// If no [ParseError]s occur, just returns the molecule and an empty [Vec]. Otherwise, returns
    /// a best-effort guess of the molecule as well as a [Vec] of [ParseError]s that occurred during
    /// parsing.
    fn next_molecule(&mut self) -> Option<Result<Positioned<Molecule>, ParseError>> {
        // Keywords should only be detected based on the context. For example, there's the keyword
        // "from" in 'from github { ... }', but none in 'struct Range { from: Int to: Int }'.
        let molecule = match (
            self.advance(),
            self.peek_n(1),
            self.peek_n(2),
            self.peek_n(3),
        ) {
            (Some(AnyPos!(Atom::Whitespace(chrs))), _, _, _) => {
                // Ranges of whitespace that didn't contain any newlines already got filtered out.
                let num_newlines = chrs.chars().filter(|chr| chr == &'\n').count();
                Ok(Molecule::Newlines(num_newlines))
            }
            (Some(AnyPos!(Atom::BraceOpen)), _, _, _) => Ok(Molecule::BraceOpen),
            (Some(AnyPos!(Atom::BraceClose)), _, _, _) => Ok(Molecule::BraceClose),
            (Some(AnyPos!(Atom::TagOpen)), _, _, _) => Ok(Molecule::TagOpen),
            (Some(AnyPos!(Atom::TagClose)), _, _, _) => Ok(Molecule::TagClose),
            (Some(AnyPos!(Atom::ParenOpen)), _, _, _) => Ok(Molecule::ParenOpen),
            (Some(AnyPos!(Atom::ParenClose)), _, _, _) => Ok(Molecule::ParenClose),
            (Some(AnyPos!(Atom::Colon)), _, _, _) => Ok(Molecule::Colon),
            (Some(AnyPos!(Atom::EqualSign)), _, _, _) => Ok(Molecule::EqualSign),
            (Some(AnyPos!(Atom::Dot)), _, _, _) => Ok(Molecule::Dot),
            (Some(AnyPos!(Atom::Comma)), _, _, _) => Ok(Molecule::Comma),
            (Some(AnyPos!(Atom::At)), _, _, _) => Ok(Molecule::At),
            (Some(Pos!(Atom::Plus, pos)), _, _, _) => Err(ParseError::lonely_plus(pos.start)),
            // Negative floating point number.
            (Some(AnyPos!(Atom::Minus)), Some(AnyPos!(Atom::Number(before_dot))), Some(AnyPos!(Atom::Dot)), Some(AnyPos!(Atom::Number(after_dot)))) => {
                Ok(Molecule::FloatNumber(
                    before_dot * -1,
                    after_dot,
                ))
            }
            // Negative integer number.
            (Some(AnyPos!(Atom::Minus)), Some(AnyPos!(Atom::Number(num))), _, _) => Ok(Molecule::IntNumber(num * -1)),
            // Minus shouldn't occur AnyPos except before numbers and in versions.
            (Some(Pos!(Atom::Minus, pos)), _, _, _) => Err(ParseError::lonely_minus(pos.start)),
            // Version.
            (Some(Pos!(Atom::Number(major), major_pos)), Some(AnyPos!(Atom::Dot)), Some(Pos!(Atom::Number(minor), minor_pos)), Some(Pos!(Atom::Dot), second_dot_pos)) => {
                self.advance_n(3); // Consume dot, minor version number, and next dot.
                if let Some(Pos!(Atom::Number(patch), patch_pos)) = self.advance() {
                    let pre = match self.peek() {
                        Some(AnyPos!(Atom::Minus)) => self.advance_while(matcher!(
                            AnyPos!(Atom::Number(_)) | AnyPos!(Atom::Word(_)) | AnyPos!(Atom::Dot)))
                            .iter().filter(|atom| !matches!(atom, AnyPos!(Atom::Dot)))
                            .collect(),
                        _ => vec![],
                    };
                    let build = match self.peek() {
                        Some(AnyPos!(Atom::Plus)) => self.advance_while(matcher!(AnyPos!(Atom::Number(_)) | AnyPos!(Atom::Word(_)) | AnyPos!(Atom::Dot)))
                            .iter().filter(|atom| !matches!(atom, AnyPos!(Atom::Dot)))
                            .collect(),
                        _ => vec![],
                    };
                    let major = major.to_u64()?;
                    let minor = minor.to_u64()?;
                    let patch = patch.to_u64()?;
                    let pre = pre.iter().map(|atom| match atom {
                        AnyPos!(Atom::Word(word)) => semver::Identifier::AlphaNumeric(*word),
                        AnyPos!(Atom::Number(num)) => semver::Identifier::Numeric(num.to_u64().unwrap()), // TODO:
                        _ => panic!("Todo"),
                    }).collect();
                    let build = build.iter().map(|atom| match atom {
                        AnyPos!(Atom::Word(word)) => semver::Identifier::AlphaNumeric(*word),
                        AnyPos!(Atom::Number(num)) => semver::Identifier::Numeric(num.to_u64().unwrap()), // TODO:
                        _ => panic!("Todo"),
                    }).collect();
                    // if major.bits() > 64 {
                    //     return Err(ParseError::version_too_big(major_pos, major));
                    // }
                    // if minor.bits() > 64 {
                    //     return Err(ParseError::version_too_big(minor_pos, minor));
                    // }
                    // if patch.bits() > 64 {
                    //     return Err(ParseError::version_too_big(patch_pos, patch));
                    // }
                    Version {
                        major,
                        minor,
                        patch,
                        pre,
                        build,
                    }
                } else {
                    Err(ParseError::expected_patch_version(major_pos.start..second_dot_pos.end))
                }
            }
            // Floating point number.
            (Some(AnyPos!(Atom::Number(before_dot))), Some(AnyPos!(Atom::Dot)), Some(AnyPos!(Atom::Number(after_dot))), _) => Ok(Molecule::FloatNumber(BigInt::from(before_dot), after_dot)),
            // Integer number.
            (Some(AnyPos!(Atom::Number(num))), _, _, _) => Ok(Molecule::IntNumber(BigInt::from(num))),
            (Some(AnyPos!(Atom::String(string))), _, _, _) => {
                let mut string = string;
                let additional_strings = self.advance_while(matcher!(AnyPos!(Atom::String(_)) | AnyPos!(Atom::Newline(_)))).filter(matcher!(AnyPos!(Atom::String(_))));
                for additional_string in additional_strings {
                    string.push_str(additional_string);
                }
                Ok(Molecule::String(string))
            }
            // TODO: Comments.
            (Some(AnyPos!(Atom::String(string))), _, _, _) => {
                let mut string = string;
                let additional_strings = self.advance_while(matcher!(AnyPos!(Atom::String(_)) | AnyPos!(Atom::Newline(_)))).filter(matcher!(AnyPos!(Atom::String(_))));
                for additional_string in additional_strings {
                    string.push_str(additional_string);
                }
                Ok(Molecule::String(string))
            }
            // Keywords.
            (Some(AnyPos!(Atom::Word(possible_keyword))), Some(AnyPos!(Atom::Word(_))), Some(), _) => Ok(Molecule::Keyword(Keyword::Package)),

            _ => {
                errors.push(ParseError::unsupported_character(self.offset));
                None
            }
        };
        Positioned {
            data: molecule
            position: 0..0, // TODO,
        }
    }
}

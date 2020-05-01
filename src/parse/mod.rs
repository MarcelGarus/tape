//! This module implements functionality for parsing tape source files into more abstract
//! `TapeFile`s.
//!
//! ## Layers
//!
//! Parsing is complex and covers many abstraction layers. That's why the parsing is done in
//! multiple steps, each one increasing the abstraction of the representation. To signify the
//! increasing abstractions, the layers are named `atoms`, `molecules`, and `organisms` – names that
//! are common in the design community to describe UI elements of different abstraction layers.
//! - First, there's the atoms layer, which parses the source characters into more abstract `Atom`s.
//!   These are things like `Atom::Arrow` for `->` or `Atom::Number(number)` for representing a
//!   series of numbers.
//! - Next, there's the organisms layer, which turns the list of atoms into even more abstract
//!   structures like `RootElement`s. There is already a tree structure for structs and enums (the
//!   parts enclosed in curly braces), but inside each of these bodies, it's just a plain list of
//!   annotations, comments, struct fields, enum variants, "use"-imports and the like.
//! - Next, the list of organisms is turned into the most abstract representation of a source file.
//!   Instead of having a list of things, this is a basic abstract syntax tree (AST) without type
//!   lookup information. This syntax tree is the most abstracted version of the file. The order of
//!   imports, type definitions etc. is all abstracted away.
//! - Later, multiple of these `TapeFile`s are taken and put into a single namespace, allowing
//!   referencing types from other files and packages.
//!
//! ## Source recreation
//!
//! We want to be able to map the abstracted representation to individual characters of the original
//! source file. For example, we want to be able to format the file, highlight references of fields
//! for refactoring etc. That's why there's a `Positioned<T>` struct that can be wrapped around any
//! type and also adds positioning information. The position is a range indicating the start and end
//! byte in the original source file.
//!
//! ## Error handling
//!
//! In Rust, it's common to use the `Rusult` type for indicating possible failure. Sadly, that
//! doesn't translate well to parsers. `Result`s are intended to be handled by code, which can
//! efficiently handle many sequential failures one after another. `ParserError`s are also intended
//! to be shown to humans though and humans tend to like seeing all errors at once rather than just
//! one at a time – imagine seeing only the first syntax error in a program and having to fix it
//! before seeing the next one. That's why instead of relying on methods returning `Result`s,
//! there's an ephmeral error vector that all methods can add errors to. Even if they encounter an
//! error, they try to carry on and continue parsing on a best-effort basis. Sometimes though, the
//! source code is so messed up that it's impossible to continue parsing a piece of the code, so
//! most parsing methods you'll see have an `Option` as a return type.

use crate::parse::atoms::AtomParser;
use crate::parse::error::{DecideIfAbortParsing, ParseError};
use crate::parse::organisms::OrganismParser;
use crate::parse::organisms::RootElement;
use std::fmt;

mod atoms;
mod error;
// mod molecules;
mod organisms;
mod utils;

/// A parsed tape file.
pub struct TapeFile {
    pub elements: Vec<RootElement>,
}

#[derive(Debug)]
pub struct TapeParseFailure {
    pub errors: Vec<ParseError>,
}

impl fmt::Display for TapeParseFailure {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(
            &self
                .errors
                .iter()
                .map(|error| format!("{:?}", error))
                .collect::<Vec<String>>()
                .join("\n"),
        )
    }
}

impl std::error::Error for TapeParseFailure {}

type Result = std::result::Result<TapeFile, TapeParseFailure>;

impl std::str::FromStr for TapeFile {
    type Err = TapeParseFailure;
    fn from_str(source: &str) -> Result {
        let mut errors: Vec<ParseError> = vec![];
        // Parse atoms.
        println!("Parsing {} bytes…", source.len());
        let (atoms, mut atom_errors) = AtomParser::from_source(source).parse();
        errors.append(&mut atom_errors);
        if errors.should_abort_parsing() {
            return Err(TapeParseFailure { errors });
        }

        // Parse molecules.
        println!("Parsing {} atoms…", atoms.len());
        let mut parser =
            OrganismParser::from_atoms(atoms.into_iter().map(|pos_atom| pos_atom.data).collect());
        let elements = parser.parse();
        for error in &parser.errors {
            println!("Error: {:?}", error);
        }
        elements
            .map(|elements| TapeFile { elements })
            .ok_or(TapeParseFailure {
                errors: parser.errors,
            })
    }
}

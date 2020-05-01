// This module implements functionality for the parser.

use crate::parse::atoms::{Atom, AtomParser};
use crate::parse::error::{DecideIfAbortParsing, ParseError};
use crate::utils::Positioned;
use std::fmt;

mod atoms;
mod error;
// mod molecules;
mod organisms;
mod utils;

/// A parsed tape file.
pub struct TapeFile {
    pub atoms: Vec<Positioned<Atom>>,
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
        let (molecules, mut molecule_errors) = MoleculeParser::from_atoms(atoms).parse();
        Ok(TapeFile { atoms })
    }
}

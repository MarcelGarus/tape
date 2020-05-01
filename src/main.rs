extern crate num;
extern crate semver;

#[macro_use]
mod utils;

mod parse;

use crate::parse::TapeFile;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    println!("Hello world.");
    let source = fs::read_to_string("fruit.tape")?;
    println!("Source is {}", source);
    let program: TapeFile = source.parse()?;
    println!();
    for element in program.elements {
        println!("{:?}", element);
    }
    Ok(())
}

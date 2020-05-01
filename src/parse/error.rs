use crate::utils::SourceRange;
use num::BigUint;

#[derive(Debug)]
pub struct ParseError {
    pub id: &'static str,
    pub level: Level,
    pub summary: &'static str,
    pub description: String,
    pub suggestions: Vec<&'static str>,
    pub personalized_suggestions: Vec<String>,
    pub position: SourceRange,
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum Level {
    Warning, // Useful to know, but still results in a correct parse.
    Error,   // Parsing continues on best effort.
    Fatal,   // Abort parsing after this parsing stage.
}

pub trait DecideIfAbortParsing {
    fn should_abort_parsing(&self) -> bool;
}

impl DecideIfAbortParsing for Vec<ParseError> {
    fn should_abort_parsing(&self) -> bool {
        self.iter().any(|error| error.level >= Level::Fatal)
    }
}

// fn proceed_to_next_stage

impl ParseError {
    // Errors thrown during atom parsing.
    pub fn newline_in_string(newline_position: usize) -> Self {
        ParseError {
            id: "newline_in_string",
            level: Level::Error,
            summary: "There's a newline character in a string.",
            description: "Newlines in strings aren't directly supported, because it makes it less \
                obvious whether spaces from the indentation are included or not."
                .to_string(),
            suggestions: vec![
                "To make a string contain a newline character, just use '\\n'.",
                "To break the string across multiple lines for formatting reasons, just put a new \
                string in the next line; adjacent strings are automatically concatenated. For \
                example, \"ab\" \"cd\" is equivalent to \"abcd\".",
            ],
            personalized_suggestions: vec![],
            position: newline_position..newline_position,
        }
    }

    pub fn invalid_escaping_in_string(escaped_char_position: usize) -> Self {
        ParseError {
            id: "invalid_escaping_in_string",
            level: Level::Error,
            summary: "This character cannot be escaped.",
            description: "This escape sequence doesn't exist. Escape only backslashes ('\\\\'), \
                double quotes ('\\\"'), and newlines ('\\n')."
                .to_string(),
            suggestions: vec!["Remove the backslash."],
            personalized_suggestions: vec![],
            position: (escaped_char_position - 1)..escaped_char_position,
        }
    }

    pub fn unterminated_string(string_range: SourceRange) -> Self {
        ParseError {
            id: "unterminated_string",
            level: Level::Fatal,
            summary: "This string isn't terminated.",
            description: "Strings need to be terminated with a '\"'.".to_string(),
            suggestions: vec!["Add a '\"' at the end of the string."],
            personalized_suggestions: vec![],
            position: string_range,
        }
    }

    pub fn lonely_slash(slash_position: usize) -> Self {
        ParseError {
            id: "lonely_slash",
            level: Level::Fatal,
            summary: "This is a single slash.",
            description: "By design, tape isn't turing complete, so it doesn't need operands like \
                + or /."
                .to_string(),
            suggestions: vec![
                "If you tried to start a comment, use a double slash like this: '// Some comment.'",
            ],
            personalized_suggestions: vec![],
            position: slash_position..(slash_position + 1),
        }
    }

    pub fn no_space_after_double_slash(missing_space_position: usize) -> Self {
        ParseError {
            id: "no_space_after_double_slash",
            level: Level::Warning,
            summary: "There's no space after the double slash.",
            description: "Having a space after the double slash makes the comment more readable."
                .to_string(),
            suggestions: vec!["Add a space."],
            personalized_suggestions: vec![],
            position: (missing_space_position - 2)..missing_space_position,
        }
    }

    pub fn unsupported_character(char_position: usize) -> Self {
        ParseError {
            id: "unsupported_character",
            level: Level::Fatal,
            summary: "This is an unsupported character.",
            description: "Identifiers may only contain letters, numbers, and underscores. Note \
                that you can use any unicode characters in comments and strings. ✨🦄"
                .to_string(),
            suggestions: vec!["Remove this character."],
            personalized_suggestions: vec![],
            position: char_position..(char_position + 1),
        }
    }

    // Errors thrown during molecule parsing.

    pub fn lonely_plus(plus_position: usize) -> Self {
        ParseError {
            id: "lonely_plus",
            level: Level::Fatal,
            summary: "There's a lonely '+' standing around in the wild.",
            description: "By design, tape isn't turing complete, so it doesn't need operands like \
                + or *. Plus signs may only occur in versions to indicate build numbers, like in \
                1.2.3+6."
                .to_string(),
            suggestions: vec![
                "If you attempted to not change the sign of a number, just omit the '+'.",
            ],
            personalized_suggestions: vec![],
            position: plus_position..plus_position,
        }
    }

    pub fn lonely_minus(minus_position: usize) -> Self {
        ParseError {
            id: "lonely_minus",
            level: Level::Fatal,
            summary: "There's a lonely minus standing around in the wild.",
            description: "By design, tape isn't turing complete, so it doesn't need operands like \
                * or - (except maybe for negating numbers)."
                .to_string(),
            suggestions: vec![
                "If you attempted to negate a number, remove any newlines between the minus and \
                the number.",
                "Maybe you started typing an arrow ('->'), got distracted, went shopping, grabbed \
                a beer, and forgot about it? Then just add the missing '>'.",
                "Maybe you tried to use two minuses in a row to double-negate a number? Stop being \
                a smarta** and remove both of them.",
            ],
            personalized_suggestions: vec![],
            position: minus_position..minus_position,
        }
    }

    pub fn expected_patch_version(version_position: SourceRange) -> Self {
        ParseError {
            id: "expected_patch_version",
            level: Level::Error,
            summary: "Expected patch version of a semantic version.",
            description: "Semantic versions consist of three version numbers: A major version, a \
                minor version, and a patch version. You didn't provide a patch version though."
                .to_string(),
            suggestions: vec![
                "If this is supposed to be a semantic version, just add the patch version number.",
                "If this should be a floating point number, remove the last dot.",
            ],
            personalized_suggestions: vec![],
            position: version_position,
        }
    }

    pub fn version_too_big(version_position: SourceRange, version: BigUint) -> Self {
        ParseError {
            id: "version_too_big",
            level: Level::Error,
            summary: "The version number is too big.",
            description: format!(
                "The major, minor and patch version can each only be a 64-bit unsigned integer. \
                Because {} > 18446744073709551615 = 2^64 - 1, this version is invalid.",
                version
            ),
            suggestions: vec![
                "If this version is too big by accident, you're lucky.",
                "Otherwise, open an issue at ….", // TODO: add GitHub link
            ],
            personalized_suggestions: vec![],
            position: version_position,
        }
    }
}

use crate::utils::SourceRange;
use semver::Version;

pub enum Statement {
    Package {
        name: String,
        description: String,
        version: Version,
    },
    TapeVersion(Version),
    Get {
        name: String,
        alias: Option<String>,
        source: Source,
    },
    Use(Import),
    Definition(Element<Definition>),
}

pub enum Source {
    TapeFactory {
        version: Version,
    },
    GitHub {
        repo: String,
        branch: String,
        path: String,
    },
    Path(String),
}

pub enum Import {
    Package(Vec<Import>),
    Definition(String),
}

pub struct Element<T> {
    pub position: SourceRange,
    pub comment: String,
    pub annotations: Vec<Annotation>,
    pub name: String,
    pub data: T,
}

pub enum Annotation {
    Added {version: Version},
    Deprecated {version: Version, reason: String},
}

pub enum Definition {
    Struct(Vec<Field>),
    Enum {variants: Vec<String>},
    Alias{aliased_type: String},
    Const{struct_name: String, fields: Vec<InstanceField>}
}

struct Field {
    type: String,
    default: Option<String>,
}

struct InstanceField{
    name: String,
    value: String,
}

// ---

pub struct ParseResult {
    pub body: Body,
    pub errors: Vec<SsssError>,
}

impl ParseResult {
    pub fn has_errors(&self) -> bool {
        !self.errors.is_empty()
    }
}

pub fn parse(source: &str) -> ParseResult {
    let tokens: ScannedTokens = source
        .tokens()
        .skip_while(|token| matches!(token.data, Token::Whitespace(_)))
        .collect();
    for token in &tokens {
        println!("{:?}", token);
    }

    parse_body(&mut tokens.into_iter().peekable())
}

type State = Peekable<IntoIter<Positioned<Token>>>;

fn parse_body(state: &mut State) -> ParseResult {
    let mut token_buffer: ScannedTokens = vec![];
    let mut body: Vec<Node> = vec![];
    let mut errors: Vec<SsssError> = vec![];

    fn flush_buffer(body: &mut Vec<Node>, token_buffer: &mut ScannedTokens) {
        if let Some(text) = parse_text(token_buffer) {
            body.push(text);
        }
        token_buffer.clear();
    }

    // Strip leading whitespace.
    if let Some(Anywhere!(Token::Whitespace(_))) = state.peek() {
        state.next();
    }

    loop {
        let token_option = state.next();
        match token_option {
            None => break,
            Some(token) => match token.data {
                Token::Word(_) | Token::Whitespace(_) => token_buffer.push(token),
                Token::Open => {
                    let mut position = token.position;
                    // A new block begins. The name of the block is the last word
                    // in the buffer.
                    let block_name = loop {
                        match token_buffer.pop() {
                            None => {
                                errors.push(SsssError {
                                    id: "missing-block-name".to_string(),
                                    message: "Expected a block name, but found none.".to_string(),
                                    position: position.clone(),
                                });
                                break "".to_string();
                            }
                            Some(previous_token) => {
                                position.start = previous_token.position.start;
                                match previous_token.data {
                                    Token::Word(word) => break word, // We found a name!
                                    Token::Whitespace(_) => {} // Ignore any whitespace.
                                    Token::Open => panic!("No block name found, but an opening brace instead. This should never happen, because the opening brace always starts a new recursive parse_body call."),
                                    Token::Close => panic!("No block name found, but a closing brace instead. This should never happen, because if we find a closing brace, we should have stopped parsing the body and returned."),
                                }
                            }
                        }
                    };
                    flush_buffer(&mut body, &mut token_buffer);
                    // Note: parse_body already consumes the Close token.
                    let mut bodies: Vec<Body> = vec![];
                    loop {
                        let mut result = parse_body(state);
                        bodies.push(result.body);
                        errors.append(&mut result.errors);

                        // Go to the next token that's not whitespace.
                        while matches!(state.peek(), Some(Anywhere!(Token::Whitespace(_)))) {
                            token_buffer.push(state.next().unwrap());
                        }
                        if matches!(state.peek(), Some(Anywhere!(Token::Open))) {
                            // There's another body!
                            state.next();
                            token_buffer.clear();
                            continue; // Parse it!
                        } else {
                            break;
                        }
                    }
                    body.push(Node {
                        element: Element::Block {
                            name: block_name,
                            bodies,
                        },
                        metadata: Metadata {
                            position: position.clone(), //bodies.last().unwrap().data.end, // TODO:
                        },
                    });
                }
                Token::Close => {
                    // Stip trailing whitespace.
                    if let Some(Anywhere!(Token::Whitespace(_))) = token_buffer.last() {
                        token_buffer.pop();
                    }
                    flush_buffer(&mut body, &mut token_buffer);
                    return ParseResult { body, errors };
                }
            },
        }
    }
    flush_buffer(&mut body, &mut token_buffer);
    ParseResult { body, errors }
}

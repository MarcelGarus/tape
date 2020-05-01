use crate::parse::error::ParseError;
use std::mem;

/// Provides a cursor-based parsing environment and error handling.
///
/// This class is used by multiple parsers on different abstraction layers. It offers two features:
/// Consuming the source items piece by piece and registering errors.
/// Internally, it keeps a vector of items and a cursor position. All of the items before the cursor
/// position are empty, while the items at or after the cursor position are guaranteed to be
/// non-empty. By advancing the `CursorParser`, items are moved out of the `CursorParser` structure
/// and the cursor is advanced. Contrary it standard `Iterator`s or `Peekable`s, the `CursorParser`
/// allows peeking arbitrarily beyond the cursor position (peeking beyond the bounds of the vector
/// just results in returning None).
pub struct CursorParser<T> {
    items: Vec<Option<T>>,
    cursor: usize,
    errors: Vec<ParseError>,
}

impl<T> CursorParser<T> {
    /// Creates a new struct that contains the given items.
    pub fn from(items: Vec<T>) -> CursorParser<T> {
        CursorParser {
            items: items.into_iter().map(|item| Some(item)).collect(),
            cursor: 0,
        }
    }

    pub fn cursor(&self) -> usize {
        self.cursor
    }

    pub fn register(&mut self, error: ParseError) {
        self.errors.push(error);
    }

    /// Returns the nth item after the cursor.
    pub fn peek_n(&self, offset: usize) -> Option<&T> {
        let index = self.cursor + offset;
        if index < self.items.len() {
            Some(&self.items[index].unwrap())
        } else {
            None
        }
    }

    /// Returns the next item (the same that calling `advance()` would return).
    pub fn peek(&self) -> Option<&T> {
        self.peek_n(1)
    }

    /// Advances the cursor n times and returns the last item.
    pub fn advance_n(&mut self, n: usize) -> Option<T> {
        let mut last: Option<T>;
        for i in 0..n {
            last = self.advance();
        }
        last
    }

    /// Moves the current item out of the structure and advances the cursor.
    pub fn advance(&mut self) -> Option<T> {
        self.cursor += 1;
        if self.cursor <= self.items.len() {
            mem::replace(&mut self.items[self.cursor - 1], None)
        } else {
            None
        }
    }

    /// Advances the cursor multiple times until the predicate returns `false`. Then, returns a
    /// vector containing all of the removed items.
    pub fn advance_while<P>(&mut self, predicate: P) -> Vec<T>
    where
        P: Fn(&T) -> bool,
    {
        self.advance_while_with_initial(predicate, vec![])
    }

    /// Like advance while but also accepts an initial vector that the removed items are added to.
    pub fn advance_while_with_initial<P>(&mut self, predicate: P, initial: Vec<T>) -> Vec<T>
    where
        P: Fn(&T) -> bool,
    {
        let mut elements = initial;
        loop {
            match self.peek() {
                Some(item) if predicate(&item) => {
                    elements.push(*item);
                    self.advance();
                }
                _ => break elements,
            }
        }
    }
}

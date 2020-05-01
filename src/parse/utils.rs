pub trait IntoString {
    fn into_string(self) -> String;
}

impl IntoString for Vec<char> {
    fn into_string(self) -> String {
        self.into_iter().collect()
    }
}

pub struct CursorParser<T> {
    pub items: Vec<T>,
    pub cursor: usize,
}

impl<T> CursorParser<T> {
    pub fn from(items: Vec<T>) -> CursorParser<T> {
        CursorParser { items, cursor: 0 }
    }

    pub fn peek_n(&mut self, offset: usize) -> Option<T> {
        let index = self.cursor + offset;
        if index > self.items.len() {
            None
        } else {
            Some(self.items[index])
        }
    }

    pub fn advance_n(&mut self, n: usize) -> Option<T> {
        self.cursor += n;
        self.peek_n(0)
    }

    pub fn peek(&mut self) -> Option<T> {
        self.peek_n(1)
    }

    pub fn advance(&mut self) -> Option<T> {
        self.advance_n(1)
    }

    pub fn advance_while_with_initial<P>(&mut self, predicate: P, initial: Vec<T>) -> Vec<T>
    where
        P: Fn(&T) -> bool,
    {
        let mut elements = initial;
        loop {
            match self.peek() {
                Some(item) if predicate(&item) => {
                    elements.push(item);
                    self.advance();
                }
                _ => break elements,
            }
        }
    }

    pub fn advance_while<P>(&mut self, predicate: P) -> Vec<T>
    where
        P: Fn(&T) -> bool,
    {
        self.advance_while_with_initial(predicate, vec![])
    }
}

use std::ops::Range;

pub trait Single<T> {
    fn single(&self) -> Option<&T>;
}

impl<T> Single<T> for [T] {
    fn single(&self) -> Option<&T> {
        if self.len() == 1 {
            Some(&self[0])
        } else {
            None
        }
    }
}

/// Shortcut for being able to use `.into_string()` on a `Vec<char>`.
pub trait IntoString {
    fn into_string(self) -> String;
}

impl IntoString for Vec<char> {
    fn into_string(self) -> String {
        self.into_iter().collect()
    }
}

/// Returns a lambda that returns `true` for elements that match the given pattern and `false` for
/// the rest.
#[macro_export]
macro_rules! matcher {
    ($p:pat) => {
        |value| matches!(value, $p)
    };
}

// TODO: Move this into a package.
pub enum Case {
    Camel,     // CamelCase
    Dromedar,  // dromedarCase
    Kebab,     // kebab-case
    Snake,     // snake_case
    Screaming, // SCREAMING_CASE
}

/// Position in the source file in bytes.
pub type Span = Range<usize>;

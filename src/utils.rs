use std::ops::Deref;
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
pub type SourceRange = Range<usize>;

/// Wraps an arbitrary type with position data.
#[derive(Debug, Eq, PartialEq)]
pub struct Positioned<T> {
    pub data: T,
    pub position: SourceRange,
}

impl<T> Deref for Positioned<T> {
    type Target = T;
    fn deref(&self) -> &T {
        &self.data
    }
}

/// Pattern that applies the given pattern `p` to the `data` of a `Positioned`, making the matching
/// independent from the `position`.
#[macro_export]
macro_rules! AnyPos {
    ($p:pat) => {
        crate::utils::Positioned { data: $p, .. }
    };
}

#[macro_export]
macro_rules! Pos {
    ($data: pat, $pos: pat) => {
        crate::utils::Positioned {
            data: $data,
            position: $pos,
        }
    };
}

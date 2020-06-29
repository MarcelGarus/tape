Tape's values determine design decisions.
The values are in this particular order:

* **Provide a type-safe encoding of all possible Dart objects:** Developers should be able to use tape for all their serilaization needs that might come up in Dart.
* **Usability / great developer experience:** There should be rock-solid tooling for helping developers get up-to-speed. This also includes extensive documentation of the underlying layers, example use-cases etc.
* **Encoding speed:** The encoding should be relatively fast to allow using tape in more scenarios where speed is important.
* **Encoding size:** Encoding size is explicitly listed after the other values. Smaller encodings are nice, but if encoding size really matters, users should apply general-purpose compression like zip to the output anyway. Especially, long ranges of consecutive zeroes or 255s are no problem, because they are easy to compress.

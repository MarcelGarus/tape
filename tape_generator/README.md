Several files come into play when generating code (aka running `pub run build_runner build` in the project root):

* **Your source files** that contain the `@TapeType()` annotations at top-level.
* The **lock file** is a `tape.lock` file that'll be generated in your project root.
* The **generated source file** are files of the naming scheme `some_file.g.dart` that are created next to the hand-written source files.

Here's what the responsibilities of each of those are:

* **Your source files:** They are the interface to the rest of your code and contain the actual type definitions. All tape types are annotated with `@TapeType()`. Each defined type has a tracking code, which is randomly derived by tape and *inserted into the source code written by you*, like this: `@TapeType("cd7a510b82")`
* **Lock file:** This file gets generated in your project root and contains information about the the types (id, name) and what fields they have (id, name, type). This can be used to prevent users from making backwards-incompatible changes. The lock file can always be deleted by the user to override this functionality.
* **Generated source files:** These are ephmeral files that get deleted for every code generation. That makes sense because modifying or parsing them is dangerous — they might contain other code from codegen packages unrelated to tape.

Here's the steps of the code generation, which is executed for every `@TapeType()`:

1. Parse the type into a `ConcreteTapeType` that has `ConcreteTypeField`s.
2. Parse the lock file, if it exists.
3. Does the code have a tracking code? And if so, does it exist in the lock file?
   1. No: Generate a new one that doesn't conflict with any existing one.
   2. Yes: Check compatibility with the existing type. Abort if they are incompatible.
4. Add/update the type in the lock file.
5. Generate the code.

---
name: "🐞 Bug"
about: Something is not quite working as expected.
title: ''
labels: bug
assignees: ''

---

<!-- Welcome to the tape repo! Thanks for filing an issue. Have a cookie! 🍪 -->

Insert a clear and concise description of what the bug is.

**Steps to reproduce**

```dart
insert minimal reproducible example code
```

<!-- Describe the issue here. -->

<!--
Some useful snippets:

I expected … to happen, but … happened.

---

I thought the block encoding would be
```dart
TypedBlock(
  typeId: 0,
  child: Uint8Block(42),
),
```
but it actually was
```dart
Uint16Block(12345),
```

---

I thought the encoding would be  
`0 0 0 12 23 0`,  
but it was actually  
`42 42 42 42 42 42 42`.

-->

There are already some pretty cool protocol formats, like json, or Protobuf.
Some protocol formats are already widely adopted, so why do we need a new one?

Let's have a look at a few interesting aspects of APIs and how json and Protobuf try to deliver on that.

## Discoverability

You can just go to a browser and type in the API endpoint. The result is human-readable, so you can inspect and explore the API hands on.

Protobuf is not intended to be read by humans, so you need to consult external documentation to find out what the API endpoint might answer. Especially when you're experimenting and wondering what the meaning of a concrete response is, it might become a hassle to have to switch back and forth between the documentation and the response to find out what the fields mean.

## Efficiency

Protobuf is amazingly efficient. The specification tries to squeeze out every single byte to make the messages as small as possible. That's really great for high-performance applications.

JSON is by nature a much more verbose format. While there exist interesting (de-)serialization solutions that make use of SIMD-instructions to parse multiple bytes in a single CPU cycle, it's still fundamentally slower than something like Protobuf. Also, the messages are larger, so if network throughput is the bottleneck rather than CPU (which is often the case), it might take longer to transfer JSON messages than Protobuf messages.

## Typedness

> Types are great! They make large projects more stable, so it's not surprising most of the industry fancies languages that use them – just to name a few, Dart, Rust, Kotlin are all languages with types. And even in the web type-safe languages like TypeScript and Elm are gaining popularity.

Protobuf is strongly typed. That means, there's no way a dynamic or unknown type is returned from an API – all types are specified before and each type can only contain pre-defined known other types. That makes it easy to automatically generate the corresponding types for all major languages. The types are somewhat limited though – for example, they can't represent generics, a concept found in most typed languages.

JSON is dynamically typed. There are no user-defined types, it's just a tree of pre-defined types like numbers, strings, maps, and lists.

## Maintainability & Versioning

Major: New API endpoint.
Minor: Generated code changes, compatible with differently versioned endpoint.
Patch: Generated code doesn't change.

## Ease of use



---

Protobuf marrying JSON's discoverability, Rust-like types, and great package-tooling, Kotlin's semicolons (none).

There has to be a middle ground somewhere!
That's why I'm introducing **The API Package Ecosystem** (TAPE for short).

Obviously, some of the tradeoffs are in direct conflict to each other. Having a humand-readable documented API of course results in larger messages. So how can we deal with the different optimization objectives during development and release of an API?
Turns out, this problem was already saved by languages the likes of Rust and Dart. They support different modes of compilation for development and release with different optimization criteria chosen for each.
Tape applies the sample principle to API serialization. By default, navigating to an API endpoint results in a rich API response with human-readable fields and documentation about what the fields mean. Release apps can just request an optimized version, getting a highly space-optimized chunk of bytes.

What's also great about Rust, Dart, and several other modern languages is that they come with a ready-to-use package management that makes it easy to create and publish packages for others to use. You don't need to copy files to some places or configure URLs most of the time, because there's a central place where packages can be retrieved from.
Tape aims to make it similarly easy to share API data definitions between multiple APIs. For example, there exist ready-for-production currency, locale and URL packages that can be used in your own tape files by adding one line.
Further benefits of a central place for packages is that it's easy to verify certain aspects of packages, for example that they don't break the contracts of semantic versioning.

Other tooling, like formatters, language servers, documentation generators, code generators etc. will also all be provided.



Like other

Structs, Enums, Aliases
Generics
Constants
Debug Mode
Package Management
Optional dynamic typing
Easy dependency Management
Enforced semantic versioning
Deprecation

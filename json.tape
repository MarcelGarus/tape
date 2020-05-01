@added(0.1.0)
enum Json {
    number -> Int
    string -> String
    list -> List<Json>
    object -> Map<String, Json>
}

val jsonSample = Json.object({
    "hi": number(4),
    "foo": string("Hello"),
    "list": list([
        string("Blub"),
        string("Blob"),
    ]),
})

val jsonSample2 = Json {
    "hi": 4,
    "foo": "Hello",
    "list": [
        "Blub",
        "Blub",
    ],
}

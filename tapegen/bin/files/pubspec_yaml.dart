import '../utils.dart';

final pubspecYamlFile = File('pubspec.yaml');

extension PubspecYamlFile on File {
  Future<void> setDescriptionTo(String description) async {
    assert(this == pubspecYamlFile);

    var content = await read();
    content = content.split('\n').map((line) {
      if (line.startsWith('description:')) {
        return 'description: $description';
      } else {
        return line;
      }
    }).join('\n');
    await write(content);
  }
}

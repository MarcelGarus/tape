import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tapegen/src/concrete_data.dart';

// class LockFile {
//   LockFile({
//     @required this.version,
//     @required this.types,
//   });

//   final Version version;

//   /// Map from tracking codes to concrete types.
//   final Map<String, ConcreteTapeClass> types;

//   factory LockFile.fromJson(Map<String, dynamic> data) {
//     return LockFile(
//       version: Version.parse(data['version'] as String),
//       types: {
//         for (final entry in (data['types'] as Map<String, dynamic>).entries)
//           entry.key: ConcreteTapeClass.fromJson(entry.value),
//       },
//     );
//   }
// }

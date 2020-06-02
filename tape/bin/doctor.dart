import 'tape.dart';

final doctor = Command(
  names: ['doctor', 'doc', 'dr'],
  description: 'information about the usage of tape in your project',
  action: _doctor,
);

Future<int> _doctor(List<String> args) async {
  print('Running the doctor...');

  return 0;
}

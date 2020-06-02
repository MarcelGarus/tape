import 'tape.dart';

final help = Command(
  names: ['help', 'h', '--help', '-h', '-?', '?'],
  description: 'displays help',
  action: _help,
);

Future<int> _help(List<String> args) async {
  print('Welcome to tape!');
  print('For information about what tape is and how to use it, consult '
      'https://pub.dev/packages/tape');
  print('This help page will only focus on the command line tool.');
  print('');
  print('Usage:');
  print('  pub run tape <command> [<options>]');
  print('');
  print('Commands:');
  for (final command in commands) {
    print('  ${command.name.padRight(10)} ${command.description}');
  }
  print('');
  print('Global options:');
  print('  --simple-ouptut   for output without ansi colors or replacement');
  print('');
  print('More help: tape help <command>'); // TODO: implement more help
  print('Questions? Issues? https://github.com/marcelgarus/tape/issues/new');

  // print('Advanced functionality:');
  // print('tape assist <file>  adds annotations in the given file and ');
  // print('                    registers adapters that are not registered yet');
  // print('tape assist --once  the same, but for all files in the project');
  // print('tape init --taped-package   initializes boilerplate for a ');
  // print('                            taped-package');
  // print('');
  // print('Most of the tape commands are intended to be run in the project ');
  // print('root of an existing project.');
  // print('');
  // print('OPTIONS');
  // print('');
  // print('EXAMPLES');
  // print('  tape ');
  return 0;
}
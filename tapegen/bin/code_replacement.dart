import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

class Replacement {
  Replacement({
    @required this.offset,
    @required this.length,
    @required this.replaceWith,
  });
  Replacement.forNode(AstNode node, this.replaceWith)
      : offset = node.offset,
        length = node.length;
  Replacement.insert({@required this.offset, @required this.replaceWith})
      : length = 0;

  final int offset;
  final int length;
  final String replaceWith;
}

extension ModifyCode on String {
  String applyAll(List<Replacement> replacements) {
    // We now got a list of replacements. The order in which we apply them is
    // important so that we don't mess up the offsets.
    replacements = replacements.sortedBy((replacement) => replacement.offset);
    var cursor = 0;
    var buffer = StringBuffer();
    for (final replacement in replacements) {
      buffer.write(substring(cursor, replacement.offset));
      buffer.write(replacement.replaceWith);
      cursor = replacement.offset + replacement.length;
    }
    buffer.write(substring(cursor));
    return buffer.toString();
  }

  String apply(Replacement replacement) => applyAll([replacement]);
}

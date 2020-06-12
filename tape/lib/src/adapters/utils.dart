import '../blocks/blocks.dart';
import 'errors.dart';

extension BlockCast on Block {
  B as<B extends Block>() =>
      this is B ? this : (throw UnexpectedBlockError(this, B));
}

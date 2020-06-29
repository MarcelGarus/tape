import 'package:tape/custom.dart';
import 'package:test/test.dart';

extension TestableAdapter<T> on TapeAdapter<T> {
  T roundtripValue(T value) => fromBlock(toBlock(value));
  void expectSameValueAfterRoundtrip(T value) =>
      expect(roundtripValue(value), equals(value));

  void expectEncoding(T value, Block block) =>
      expect(toBlock(value), equals(block));
  void expectDecoding(Block block, T value) =>
      expect(fromBlock(block), equals(value));
}

void main() {
  group('dart:core adapters', () {
    group('AdapterForNull', () {
      test('encoding works', () {
        AdapterForNull().expectSameValueAfterRoundtrip(null);
      });

      test('produces expected encoding', () {
        AdapterForNull().expectEncoding(null, Uint8Block(0));
      });

      test('is compatible with all versions', () {
        AdapterForNull().expectDecoding(Uint8Block(0), null);
      });
    });

    group('AdapterForBool', () {
      test('encoding works', () {
        AdapterForBool()
          ..expectSameValueAfterRoundtrip(true)
          ..expectSameValueAfterRoundtrip(false);
      });

      test('produces expected encoding', () {
        AdapterForBool()
          ..expectEncoding(true, Uint8Block(1))
          ..expectEncoding(false, Uint8Block(0));
      });

      test('is compatible with all versions', () {
        AdapterForBool()
          ..expectDecoding(Uint8Block(1), true)
          ..expectDecoding(Uint8Block(0), false);
      });
    });

    group('AdapterForString', () {
      test('encoding works', () {
        AdapterForString()
          ..expectSameValueAfterRoundtrip('')
          ..expectSameValueAfterRoundtrip('Foo')
          ..expectSameValueAfterRoundtrip('Hello world! 👋🏻')
          ..expectSameValueAfterRoundtrip('!@#\$%^&*()`~')
          ..expectSameValueAfterRoundtrip('')
          ..expectSameValueAfterRoundtrip('	              ​    　')
          // This string shifts things from the left to the right, so don't be
          // confused why the parenthesis is on the left.
          ..expectSameValueAfterRoundtrip(
              '۝܏᠎​‌‍‎‏‪‫‬‭‮⁠⁡⁢⁣⁤⁦⁧⁨⁩⁪⁫⁬⁭⁮⁯﻿￹￺￻𑂽𛲠𛲡𛲢𛲣𝅳𝅴𝅵𝅶𝅷𝅸𝅹𝅺󠀁󠀠󠀡󠀢󠀣󠀤󠀥󠀦󠀧󠀨󠀩󠀪󠀫󠀬󠀭󠀮󠀯󠀰󠀱󠀲󠀳󠀴󠀵󠀶󠀷󠀸󠀹󠀺󠀻󠀼󠀽󠀾󠀿󠁀󠁁󠁂󠁃󠁄󠁅󠁆󠁇󠁈󠁉󠁊󠁋󠁌󠁍󠁎󠁏󠁐󠁑󠁒󠁓󠁔󠁕󠁖󠁗󠁘󠁙󠁚󠁛󠁜󠁝󠁞󠁟󠁠󠁡󠁢󠁣󠁤󠁥󠁦󠁧󠁨󠁩󠁪󠁫󠁬󠁭󠁮󠁯󠁰󠁱󠁲󠁳󠁴󠁵󠁶󠁷󠁸󠁹󠁺󠁻󠁼󠁽󠁾󠁿')
          ..expectSameValueAfterRoundtrip('ÍÎÏ˝ÓÔÒÚÆ☃')
          ..expectSameValueAfterRoundtrip(
              'ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็ ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็ ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็')
          // Two byte characters.
          ..expectSameValueAfterRoundtrip('찦차를 타고 온 펲시맨과 쑛다리 똠방각하')
          ..expectSameValueAfterRoundtrip('(ﾉಥ益ಥ）ﾉ﻿ ┻━┻')
          ..expectSameValueAfterRoundtrip(
              '❤️ 💔 💌 💕 💞 💓 💗 💖 💘 💝 💟 💜 💛 💚 💙')
          ..expectSameValueAfterRoundtrip('１２３')
          ..expectSameValueAfterRoundtrip(
              'בְּרֵאשִׁית, בָּרָא אֱלֹהִים, אֵת הַשָּׁמַיִם, וְאֵת הָאָרֶץ')
          ..expectSameValueAfterRoundtrip('᚛ᚄᚓᚐᚋᚒᚄ ᚑᚄᚂᚑᚏᚅ᚜')
          ..expectSameValueAfterRoundtrip(
              'I̗̘̦͝n͇͇͙v̮̫ok̲̫̙͈i̖͙̭̹̠̞n̡̻̮̣̺g̲͈͙̭͙̬͎ ̰t͔̦h̞̲e̢̤ ͍̬̲͖f̴̘͕̣è͖ẹ̥̩l͖͔͚i͓͚̦͠n͖͍̗͓̳̮g͍ ̨o͚̪͡f̘̣̬ ̖̘͖̟͙̮c҉͔̫͖͓͇͖ͅh̵̤̣͚͔á̗̼͕ͅo̼̣̥s̱͈̺̖̦̻͢.̛̖̞̠̫̰')
          ..expectSameValueAfterRoundtrip('ʇǝɯɐ ʇᴉs ɹolop ɯnsdᴉ ɯǝɹo˥')
          ..expectSameValueAfterRoundtrip(
              'Ｔｈｅ 𝐪𝐮𝐢𝐜𝐤 𝖇𝖗𝖔𝖜𝖓 𝒇𝒐𝒙 𝓳𝓾𝓶𝓹𝓼 𝕠𝕧𝕖𝕣 𝚝𝚑𝚎 ⒧⒜⒵⒴ dog.')
          ..expectSameValueAfterRoundtrip('hey\0there');
      });

      test('produces expected encoding', () {
        AdapterForString()
          ..expectEncoding('Foo', BytesBlock([1, 2, 3]))
          ..expectEncoding('❤️', BytesBlock([1, 2]))
          ..expectEncoding('hi\0you', BytesBlock([1, 2, 0, 3, 4, 5]));
      });

      test('is compatible with all versions', () {
        AdapterForString()
          ..expectDecoding(BytesBlock([1, 2]), '❤️')
          ..expectDecoding(BytesBlock([]), '');
      });
    });

    group('AdapterForUint8', () {
      test('encoding works', () {
        AdapterForUint8()
          ..expectSameValueAfterRoundtrip(Uint8(42))
          ..expectSameValueAfterRoundtrip(Uint8(200))
          ..expectSameValueAfterRoundtrip(Uint8(0));
      });

      test('produces expected encoding', () {
        AdapterForUint8()
          ..expectEncoding(Uint8(42), Uint8Block(42))
          ..expectEncoding(Uint8(100), Uint8Block(100));
      });

      test('is compatible with all versions', () {
        AdapterForUint8()
          ..expectDecoding(Uint8Block(42), Uint8(42))
          ..expectDecoding(Uint8Block(100), Uint8(100));
      });
    });

    group('AdapterForUint16', () {
      test('encoding works', () {
        AdapterForUint16()
          ..expectSameValueAfterRoundtrip(Uint16(42))
          ..expectSameValueAfterRoundtrip(Uint16(200000))
          ..expectSameValueAfterRoundtrip(Uint16(0));
      });

      test('produces expected encoding', () {
        AdapterForUint16()
          ..expectEncoding(Uint16(42), Uint16Block(42))
          ..expectEncoding(Uint16(1000000), Uint16Block(1000000));
      });

      test('is compatible with all versions', () {
        AdapterForUint16()
          ..expectDecoding(Uint16Block(42), Uint16(42))
          ..expectDecoding(Uint16Block(1000000), Uint16(1000000));
      });
    });

    group('AdapterForUint32', () {
      test('encoding works', () {
        AdapterForUint32()
          ..expectSameValueAfterRoundtrip(Uint32(42))
          ..expectSameValueAfterRoundtrip(Uint32(200000000000))
          ..expectSameValueAfterRoundtrip(Uint32(0));
      });

      test('produces expected encoding', () {
        AdapterForUint32()
          ..expectEncoding(Uint32(42), Uint32Block(42))
          ..expectEncoding(Uint32(10000000000000), Uint32Block(10000000000000));
      });

      test('is compatible with all versions', () {
        AdapterForUint32()
          ..expectDecoding(Uint32Block(42), Uint32(42))
          ..expectDecoding(Uint32Block(10000000000000), Uint32(10000000000000));
      });
    });

    group('AdapterForInt8', () {
      test('encoding works', () {
        AdapterForInt8()
          ..expectSameValueAfterRoundtrip(Int8(42))
          ..expectSameValueAfterRoundtrip(Int8(-100))
          ..expectSameValueAfterRoundtrip(Int8(0));
      });

      test('produces expected encoding', () {
        AdapterForInt8()
          ..expectEncoding(Int8(42), Int8Block(42))
          ..expectEncoding(Int8(-100), Int8Block(-100));
      });

      test('is compatible with all versions', () {
        AdapterForInt8()
          ..expectDecoding(Int8Block(42), Int8(42))
          ..expectDecoding(Int8Block(-100), Int8(-100));
      });
    });

    group('AdapterForInt16', () {
      test('encoding works', () {
        AdapterForInt16()
          ..expectSameValueAfterRoundtrip(Int16(42))
          ..expectSameValueAfterRoundtrip(Int16(-200000000000))
          ..expectSameValueAfterRoundtrip(Int16(0));
      });

      test('produces expected encoding', () {
        AdapterForInt16()
          ..expectEncoding(Int16(42), Int16Block(42))
          ..expectEncoding(Int16(-10000000000000), Int16Block(-10000000000000));
      });

      test('is compatible with all versions', () {
        AdapterForInt16()
          ..expectDecoding(Int16Block(42), Int16(42))
          ..expectDecoding(Int16Block(-10000000000000), Int16(-10000000000000));
      });
    });

    group('AdapterForInt32', () {
      test('encoding works', () {
        AdapterForInt32()
          ..expectSameValueAfterRoundtrip(Int32(42))
          ..expectSameValueAfterRoundtrip(Int32(-200000000000))
          ..expectSameValueAfterRoundtrip(Int32(0));
      });

      test('produces expected encoding', () {
        AdapterForInt32()
          ..expectEncoding(Int32(42), Int32Block(42))
          ..expectEncoding(Int32(-10000000000000), Int32Block(-10000000000000));
      });

      test('is compatible with all versions', () {
        AdapterForInt32()
          ..expectDecoding(Int32Block(42), Int32(42))
          ..expectDecoding(Int32Block(-10000000000000), Int32(-10000000000000));
      });
    });

    group('AdapterForInt', () {
      test('encoding works', () {
        AdapterForInt()
          ..expectSameValueAfterRoundtrip(42)
          ..expectSameValueAfterRoundtrip(-1234567)
          ..expectSameValueAfterRoundtrip(0);
      });

      test('produces expected encoding', () {
        AdapterForInt()
          ..expectEncoding(42, IntBlock(42))
          ..expectEncoding(
              -1234567891234567891, IntBlock(-1234567891234567891));
      });

      test('is compatible with all versions', () {
        AdapterForInt()
          ..expectDecoding(IntBlock(42), 42)
          ..expectDecoding(
              IntBlock(-1234567891234567891), -1234567891234567891);
      });
    });

    group('AdapterForFloat32', () {
      test('encoding works', () {
        AdapterForFloat32()
          ..expectSameValueAfterRoundtrip(Float32(42.123))
          ..expectSameValueAfterRoundtrip(Float32(-20.999))
          ..expectSameValueAfterRoundtrip(Float32(123000000101001))
          ..expectSameValueAfterRoundtrip(Float32(0));
      });

      test('produces expected encoding', () {
        AdapterForFloat32()
          ..expectEncoding(Float32(42), Float32Block(42))
          ..expectEncoding(
              Float32(-10000000000000), Float32Block(-10000000000000));
      });

      test('is compatible with all versions', () {
        AdapterForFloat32()
          ..expectDecoding(Float32Block(42), Float32(42))
          ..expectDecoding(
              Float32Block(-10000000000000), Float32(-10000000000000));
      });
    });
  });
}

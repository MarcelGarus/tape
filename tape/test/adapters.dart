import 'package:tape/test.dart';
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

extension TestableClassAdapter<T> on TapeClassAdapter<T> {
  void expectFieldsEncoding(T value, Fields fields) => expect(
      toBlock(value),
      equals(FieldsBlock({
        for (final field in fields) field.id: adapters.encode(field.value),
      })));
  void expectFieldsDecoding(Fields fields, T value) =>
      expect(fromFields(fields), equals(value));
}

void main() {
  Tape
    ..registerDartCoreAdapters()
    ..registerDartMathAdapters()
    ..registerDartTypedDataAdapters();

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
          ..expectEncoding('Foo', BytesBlock([70, 111, 111]))
          ..expectEncoding('❤️', BytesBlock([226, 157, 164, 239, 184, 143]))
          ..expectEncoding('F\x00oo', BytesBlock([70, 0, 111, 111]));
      });

      test('is compatible with all versions', () {
        AdapterForString()
          ..expectDecoding(BytesBlock([226, 157, 164, 239, 184, 143]), '❤️')
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
          ..expectSameValueAfterRoundtrip(Uint16(2000))
          ..expectSameValueAfterRoundtrip(Uint16(0));
      });

      test('produces expected encoding', () {
        AdapterForUint16()
          ..expectEncoding(Uint16(42), Uint16Block(42))
          ..expectEncoding(Uint16(10000), Uint16Block(10000));
      });

      test('is compatible with all versions', () {
        AdapterForUint16()
          ..expectDecoding(Uint16Block(42), Uint16(42))
          ..expectDecoding(Uint16Block(10000), Uint16(10000));
      });
    });

    group('AdapterForUint32', () {
      test('encoding works', () {
        AdapterForUint32()
          ..expectSameValueAfterRoundtrip(Uint32(42))
          ..expectSameValueAfterRoundtrip(Uint32(200000000))
          ..expectSameValueAfterRoundtrip(Uint32(0));
      });

      test('produces expected encoding', () {
        AdapterForUint32()
          ..expectEncoding(Uint32(42), Uint32Block(42))
          ..expectEncoding(Uint32(1000000000), Uint32Block(1000000000));
      });

      test('is compatible with all versions', () {
        AdapterForUint32()
          ..expectDecoding(Uint32Block(42), Uint32(42))
          ..expectDecoding(Uint32Block(1000000000), Uint32(1000000000));
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
          ..expectSameValueAfterRoundtrip(Int16(-20000))
          ..expectSameValueAfterRoundtrip(Int16(0));
      });

      test('produces expected encoding', () {
        AdapterForInt16()
          ..expectEncoding(Int16(42), Int16Block(42))
          ..expectEncoding(Int16(-10000), Int16Block(-10000));
      });

      test('is compatible with all versions', () {
        AdapterForInt16()
          ..expectDecoding(Int16Block(42), Int16(42))
          ..expectDecoding(Int16Block(-10000), Int16(-10000));
      });
    });

    group('AdapterForInt32', () {
      test('encoding works', () {
        AdapterForInt32()
          ..expectSameValueAfterRoundtrip(Int32(42))
          ..expectSameValueAfterRoundtrip(Int32(-2000000))
          ..expectSameValueAfterRoundtrip(Int32(0));
      });

      test('produces expected encoding', () {
        AdapterForInt32()
          ..expectEncoding(Int32(42), Int32Block(42))
          ..expectEncoding(Int32(-1000000000), Int32Block(-1000000000));
      });

      test('is compatible with all versions', () {
        AdapterForInt32()
          ..expectDecoding(Int32Block(42), Int32(42))
          ..expectDecoding(Int32Block(-1000000000), Int32(-1000000000));
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

    group('AdapterForDouble', () {
      test('encoding works', () {
        AdapterForDouble()
          ..expectSameValueAfterRoundtrip(42.123)
          ..expectSameValueAfterRoundtrip(-20.999)
          ..expectSameValueAfterRoundtrip(123000000101001)
          ..expectSameValueAfterRoundtrip(0);
      });

      test('produces expected encoding', () {
        AdapterForDouble()
          ..expectEncoding(42, DoubleBlock(42))
          ..expectEncoding(-10000000000000, DoubleBlock(-10000000000000));
      });

      test('is compatible with all versions', () {
        AdapterForDouble()
          ..expectDecoding(DoubleBlock(42), 42)
          ..expectDecoding(DoubleBlock(-10000000000000), -10000000000000);
      });
    });

    group('AdapterForBigInt', () {
      test('encoding works', () {
        AdapterForBigInt()
          ..expectSameValueAfterRoundtrip(BigInt.from(42.123))
          ..expectSameValueAfterRoundtrip(BigInt.from(-20.999))
          ..expectSameValueAfterRoundtrip(BigInt.from(123000000101001))
          ..expectSameValueAfterRoundtrip(BigInt.from(0));
      });

      test('produces expected encoding', () {
        AdapterForBigInt()
          ..expectEncoding(
            BigInt.from(42),
            FieldsBlock({
              0: adapters.encode(false),
              1: adapters.encode(Uint8List.fromList([42])),
            }),
          )
          ..expectEncoding(
            BigInt.parse('-123456789123456789123456789123456789123456789'),
            FieldsBlock({
              0: adapters.encode(true),
              1: adapters.encode(Uint8List.fromList([
                ...[21, 95, 4, 132, 182, 80, 241, 131, 38, 187, 250, 254, 154],
                ...[19, 61, 229, 54, 137, 5],
              ])),
            }),
          );
      });

      test('is compatible with all versions', () {
        AdapterForBigInt()
          ..expectDecoding(
            FieldsBlock({
              0: TypedBlock(typeId: -2, child: Uint8Block(0)),
              1: TypedBlock(typeId: -80, child: BytesBlock([42])),
            }),
            BigInt.from(42),
          )
          ..expectDecoding(
            FieldsBlock({
              0: TypedBlock(
                typeId: -2,
                child: Uint8Block(1),
              ),
              1: TypedBlock(
                typeId: -80,
                child: BytesBlock([
                  ...[21, 95, 4, 132, 182, 80, 241, 131, 38, 187, 250, 254],
                  ...[154, 19, 61, 229, 54, 137, 5],
                ]),
              ),
            }),
            BigInt.parse('-123456789123456789123456789123456789123456789'),
          );
      });
    });

    group('AdapterForDateTime', () {
      test('encoding works', () {
        AdapterForDateTime()
          ..expectSameValueAfterRoundtrip(DateTime(2020, 1, 15))
          ..expectSameValueAfterRoundtrip(DateTime(2000, 1, 15))
          ..expectSameValueAfterRoundtrip(DateTime(1990, 1, 1))
          ..expectSameValueAfterRoundtrip(DateTime(3090, 8, 28));
      });

      test('produces expected encoding', () {
        AdapterForDateTime()
          ..expectEncoding(DateTime(2000, 1, 15), IntBlock(947890800000000))
          ..expectEncoding(DateTime(3090, 8, 28), IntBlock(35364463200000000));
      });

      test('is compatible with all versions', () {
        AdapterForDateTime()
          ..expectDecoding(IntBlock(947890800000000), DateTime(2000, 1, 15))
          ..expectDecoding(IntBlock(35364463200000000), DateTime(3090, 8, 28));
      });
    });

    group('AdapterForDuration', () {
      test('encoding works', () {
        AdapterForDuration()
          ..expectSameValueAfterRoundtrip(Duration(days: 1234))
          ..expectSameValueAfterRoundtrip(Duration(minutes: 8, seconds: 46))
          ..expectSameValueAfterRoundtrip(Duration(microseconds: 42))
          ..expectSameValueAfterRoundtrip(Duration(hours: 3));
      });

      test('produces expected encoding', () {
        AdapterForDuration()
          ..expectEncoding(Duration(hours: 3), IntBlock(10800000000))
          ..expectEncoding(Duration(microseconds: 42), IntBlock(42));
      });

      test('is compatible with all versions', () {
        AdapterForDuration()
          ..expectDecoding(IntBlock(10800000000), Duration(hours: 3))
          ..expectDecoding(IntBlock(42), Duration(microseconds: 42));
      });
    });

    group('AdapterForRegExp', () {
      test('encoding works', () {
        AdapterForRegExp()
          ..expectSameValueAfterRoundtrip(RegExp('a-zA-Z'))
          ..expectSameValueAfterRoundtrip(RegExp('a-zA-Z0-9', multiLine: true))
          ..expectSameValueAfterRoundtrip(RegExp('a-z', caseSensitive: false))
          ..expectSameValueAfterRoundtrip(RegExp('a-z', unicode: false))
          ..expectSameValueAfterRoundtrip(
              RegExp('a-z', multiLine: true, unicode: true))
          ..expectSameValueAfterRoundtrip(RegExp('a-z', dotAll: false))
          ..expectSameValueAfterRoundtrip(RegExp('world', dotAll: true));
      });

      test('produces expected encoding', () {
        AdapterForRegExp()
          ..expectEncoding(
            RegExp('a-zA-Z0-9', multiLine: true),
            FieldsBlock({
              0: adapters.encode('a-zA-Z0-9'),
              1: adapters.encode(true),
              2: adapters.encode(true),
              3: adapters.encode(false),
              4: adapters.encode(false),
            }),
          )
          ..expectEncoding(
            RegExp('a-z', caseSensitive: false, unicode: true, dotAll: false),
            FieldsBlock({
              0: adapters.encode('a-z'),
              1: adapters.encode(false),
              2: adapters.encode(false),
              3: adapters.encode(true),
              4: adapters.encode(false),
            }),
          );
      });

      test('is compatible with all versions', () {
        AdapterForRegExp()
          ..expectDecoding(
            FieldsBlock({
              0: TypedBlock(
                typeId: -3,
                child: BytesBlock([97, 45, 122, 65, 45, 90, 48, 45, 57]),
              ),
              1: TypedBlock(typeId: -2, child: Uint8Block(1)),
              2: TypedBlock(typeId: -2, child: Uint8Block(1)),
              3: TypedBlock(typeId: -2, child: Uint8Block(0)),
              4: TypedBlock(typeId: -2, child: Uint8Block(0)),
            }),
            RegExp('a-zA-Z0-9', multiLine: true),
          )
          ..expectDecoding(
            FieldsBlock({
              0: TypedBlock(typeId: -3, child: BytesBlock([97, 45, 122])),
              1: TypedBlock(typeId: -2, child: Uint8Block(0)),
              2: TypedBlock(typeId: -2, child: Uint8Block(0)),
              3: TypedBlock(typeId: -2, child: Uint8Block(1)),
              4: TypedBlock(typeId: -2, child: Uint8Block(0)),
            }),
            RegExp('a-z', caseSensitive: false, unicode: true, dotAll: false),
          );
      });
    });

    group('AdapterForList', () {
      test('encoding works', () {
        AdapterForList<int>()
          ..expectSameValueAfterRoundtrip(<int>[1, 2, 3])
          ..expectSameValueAfterRoundtrip(<int>[0, -1, 12345, 123456789123456]);
        AdapterForList<String>()
          ..expectSameValueAfterRoundtrip(<String>['foo', 'bar', 'blub'])
          ..expectSameValueAfterRoundtrip(<String>['', '', '', '', 'boo'])
          ..expectSameValueAfterRoundtrip(<String>[
            for (var i = 0; i < 1000; i++) 'hello',
          ]);
      });

      test('produces expected encoding', () {
        AdapterForList<int>()
          ..expectEncoding(
            <int>[1, 2, 3],
            ListBlock([
              adapters.encode(1),
              adapters.encode(2),
              adapters.encode(3),
            ]),
          )
          ..expectEncoding(<int>[], ListBlock([]));
        AdapterForList<String>().expectEncoding(
          <String>['hello', 'world'],
          ListBlock([
            adapters.encode('hello'),
            adapters.encode('world'),
          ]),
        );
      });

      test('is compatible with all versions', () {
        AdapterForList<int>()
          ..expectDecoding(
            ListBlock([
              TypedBlock(typeId: -10, child: IntBlock(1)),
              TypedBlock(typeId: -10, child: IntBlock(2)),
              TypedBlock(typeId: -10, child: IntBlock(3)),
            ]),
            <int>[1, 2, 3],
          )
          ..expectDecoding(ListBlock([]), <int>[]);
      });
    });

    group('AdapterForSet', () {
      test('encoding works', () {
        AdapterForSet<int>()
          ..expectSameValueAfterRoundtrip(<int>{1, 2, 3})
          ..expectSameValueAfterRoundtrip(<int>{0, -1, 12345, 123456789123456});
        AdapterForSet<String>()
          ..expectSameValueAfterRoundtrip(<String>{'foo', 'bar', 'blub'})
          ..expectSameValueAfterRoundtrip(<String>{'', 'boo'})
          ..expectSameValueAfterRoundtrip(<String>{
            for (var i = 0; i < 1000; i++) 'hello',
          });
      });

      test('produces expected encoding', () {
        AdapterForSet<int>()
          ..expectEncoding(
            <int>{1, 2, 3},
            ListBlock([
              adapters.encode(1),
              adapters.encode(2),
              adapters.encode(3),
            ]),
          )
          ..expectEncoding(<int>{}, ListBlock([]));
        AdapterForSet<String>().expectEncoding(
          <String>{'hello', 'world'},
          ListBlock([
            adapters.encode('hello'),
            adapters.encode('world'),
          ]),
        );
      });

      test('is compatible with all versions', () {
        AdapterForSet<int>()
          ..expectDecoding(
            ListBlock([
              TypedBlock(typeId: -10, child: IntBlock(1)),
              TypedBlock(typeId: -10, child: IntBlock(2)),
              TypedBlock(typeId: -10, child: IntBlock(3)),
            ]),
            <int>{1, 2, 3},
          )
          ..expectDecoding(ListBlock([]), <int>{});
      });
    });

    group('AdapterForMapEntry', () {
      test('encoding works', () {
        // MapEntry doesn't implement ==, so we need to compare the entries.
        final a = AdapterForMapEntry<int, int>().roundtripValue(MapEntry(3, 9));
        expect(a.key, equals(3));
        expect(a.value, equals(9));

        final b = AdapterForMapEntry<String, String>().roundtripValue(
          MapEntry('foo', 'bar'),
        );
        expect(b.key, equals('foo'));
        expect(b.value, equals('bar'));
      });

      test('produces expected encoding', () {
        AdapterForMapEntry<String, String>()
          ..expectEncoding(
            MapEntry('name', 'Marcel'),
            FieldsBlock({
              0: adapters.encode('name'),
              1: adapters.encode('Marcel'),
            }),
          )
          ..expectEncoding(
            MapEntry('foo', 'bar'),
            FieldsBlock({
              0: TypedBlock(typeId: -3, child: BytesBlock([102, 111, 111])),
              1: TypedBlock(typeId: -3, child: BytesBlock([98, 97, 114])),
            }),
          );
        AdapterForMapEntry<int, int>().expectEncoding(
          MapEntry(5, 25),
          FieldsBlock({
            0: adapters.encode(5),
            1: adapters.encode(25),
          }),
        );
      });

      test('is compatible with all versions', () {
        final a = AdapterForMapEntry<int, int>().fromBlock(FieldsBlock({
          0: TypedBlock(typeId: -10, child: IntBlock(4)),
          1: TypedBlock(typeId: -10, child: IntBlock(16)),
        }));
        expect(a.key, equals(4));
        expect(a.value, equals(16));

        final b = AdapterForMapEntry<String, String>().fromBlock(
          FieldsBlock({
            0: TypedBlock(typeId: -3, child: BytesBlock([110, 97, 109, 101])),
            1: TypedBlock(
              typeId: -3,
              child: BytesBlock([77, 97, 114, 99, 101, 108]),
            ),
          }),
        );
        expect(b.key, equals('name'));
        expect(b.value, equals('Marcel'));
      });
    });

    group('AdapterForMap', () {
      test('encoding works', () {
        // Map doesn't implement ==, so we need to compare the entries manually.
        final a = AdapterForMap<String, int>().roundtripValue({
          'sample': 6,
          'foo': 3,
        });
        expect(a['sample'], equals(6));
        expect(a['foo'], equals(3));

        final b = AdapterForMap<int, String>().roundtripValue({
          1: 'one',
          2: 'two',
          3: 'three',
        });
        expect(b[1], equals('one'));
        expect(b[2], equals('two'));
        expect(b[3], equals('three'));
      });

      test('produces expected encoding', () {
        AdapterForMap<int, String>().expectEncoding(
          {1: 'one', 2: 'two', 3: 'three'},
          ListBlock([
            FieldsBlock({0: adapters.encode(1), 1: adapters.encode('one')}),
            FieldsBlock({0: adapters.encode(2), 1: adapters.encode('two')}),
            FieldsBlock({0: adapters.encode(3), 1: adapters.encode('three')}),
          ]),
        );
        AdapterForMap<int, int>().expectEncoding(
          {1: 1, 2: 4, 3: 9, 4: 16, 5: 25},
          ListBlock([
            FieldsBlock({0: adapters.encode(1), 1: adapters.encode(1)}),
            FieldsBlock({0: adapters.encode(2), 1: adapters.encode(4)}),
            FieldsBlock({0: adapters.encode(3), 1: adapters.encode(9)}),
            FieldsBlock({0: adapters.encode(4), 1: adapters.encode(16)}),
            FieldsBlock({0: adapters.encode(5), 1: adapters.encode(25)}),
          ]),
        );
      });

      test('is compatible with all versions', () {
        final a = AdapterForMap<int, int>().fromBlock(ListBlock([
          FieldsBlock({0: adapters.encode(1), 1: adapters.encode(1)}),
          FieldsBlock({0: adapters.encode(2), 1: adapters.encode(4)}),
          FieldsBlock({0: adapters.encode(3), 1: adapters.encode(9)}),
          FieldsBlock({0: adapters.encode(4), 1: adapters.encode(16)}),
        ]));
        expect(a[1], equals(1));
        expect(a[2], equals(4));
        expect(a[3], equals(9));
        expect(a[4], equals(16));

        final b = AdapterForMap<String, String>().fromBlock(
          ListBlock([
            FieldsBlock({
              0: TypedBlock(
                typeId: -3,
                child: BytesBlock([110, 97, 109, 101]),
              ),
              1: TypedBlock(
                typeId: -3,
                child: BytesBlock([77, 97, 114, 99, 101, 108]),
              ),
            }),
          ]),
        );
        expect(b['name'], equals('Marcel'));
      });
    });
  });

  group('dart:math adapters', () {});
}

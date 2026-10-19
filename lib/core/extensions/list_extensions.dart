/// Nyongeza (extensions) za orodha — `Iterable`, `List` na `Set`.
///
/// Kwa nini faili hili lipo: Hadithi Studio huonyesha orodha ndefu mara kwa
/// mara — maktaba ya hadithi, makundi 14, mafanikio, historia ya malipo,
/// rasimu za creator. Orodha hizo hutoka kwenye API au Hive, hivyo zinaweza
/// kuwa `null`, tupu, au na vipengele vinavyorudiwa. Badala ya kuandika
/// `if (list.isNotEmpty)` na `try/catch` kila mahali, tunaweka sheria moja hapa.
///
/// MUHIMU: faili hili halina extension yoyote ya `String` — zile ziko kwenye
/// [string_extensions]. Kuweka `extension StringX on String` hapa pia
/// kungesababisha mgongano wa declaration wakati faili zote mbili
/// zinaimportiwa pamoja (kosa la compile: "ambiguous extension").
library;

extension IterableX<T> on Iterable<T> {
  // ---------------------------------------------------------------------------
  // Ukaguzi salama (bila exception)
  // ---------------------------------------------------------------------------

  /// `true` kama orodha haina kipengele chochote.
  bool get isNullOrEmpty => isEmpty;

  /// `true` kama orodha ina kipengele kimoja au zaidi.
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Kipengele cha kwanza, au `null` kama orodha ni tupu.
  ///
  /// Hutumika badala ya `list.first` ambayo hurusha `StateError` kwenye
  /// orodha tupu — jambo linalotokea sana wakati API inarudisha `[]`.
  T? get nullableFirst => isEmpty ? null : first;

  /// Kipengele cha mwisho, au `null` kama orodha ni tupu.
  T? get nullableLast => isEmpty ? null : last;

  /// Kipengele cha nafasi [index], au `null` kama nafasi hiyo haipo.
  T? nullableElementAt(int index) =>
      (index < 0 || index >= length) ? null : elementAt(index);

  /// Kipengele cha kwanza kinachokidhi [test], au `null`.
  T? firstWhereOrNull(bool Function(T item) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Hesabu na muhtasari
  // ---------------------------------------------------------------------------

  /// Idadi ya vipengele vinavyokidhi [test].
  int countWhere(bool Function(T item) test) {
    var count = 0;
    for (final item in this) {
      if (test(item)) count++;
    }
    return count;
  }

  /// Jumla ya thamani zinazorudishwa na [value] (mfano jumla ya TZS).
  num sumBy(num Function(T item) value) {
    var total = 0.0;
    for (final item in this) {
      total += value(item);
    }
    return total;
  }

  /// Wastani wa thamani zinazorudishwa na [value] (0 kama orodha ni tupu).
  double averageBy(num Function(T item) value) {
    if (isEmpty) return 0;
    return sumBy(value) / length;
  }

  /// `true` kama angalau kipengele kimoja kinakidhi [test].
  bool anyWhere(bool Function(T item) test) => any(test);

  // ---------------------------------------------------------------------------
  // Kubadilisha umbo
  // ---------------------------------------------------------------------------

  /// `map` inayorudisha `List` moja kwa moja — bila `.toList()` kila mahali.
  List<R> mapList<R>(R Function(T item) convert) =>
      map(convert).toList(growable: false);

  /// `map` inayojua nafasi (index) ya kipengele.
  ///
  /// Inatumika kwa kurasa za hadithi (`pageNumber`) na orodha za washirika.
  List<R> mapIndexed<R>(R Function(int index, T item) convert) {
    final result = <R>[];
    var index = 0;
    for (final item in this) {
      result.add(convert(index, item));
      index++;
    }
    return List<R>.unmodifiable(result);
  }

  /// Vipengele visivyorudiwa, kwa kutumia [key] kama kitambulishi.
  ///
  /// Mfano: `stories.distinctBy((s) => s.id)` — API mara nyingi hurudisha
  /// hadithi ile ile kwenye kurasa mbili za pagination.
  List<T> distinctBy<K>(K Function(T item) key) {
    final seen = <K>{};
    final result = <T>[];
    for (final item in this) {
      if (seen.add(key(item))) result.add(item);
    }
    return List<T>.unmodifiable(result);
  }

  /// Vipengele visivyorudiwa kwa kulinganisha kipengele chenyewe.
  List<T> distinct() => distinctBy<T>((item) => item);

  /// Kugawanya orodha katika vipande vya ukubwa [size].
  ///
  /// Hii ndiyo injini ya pagination ya maktaba: `libraryPageSize` ni 20,
  /// hivyo `stories.chunked(20)` hutupa kurasa za grid moja kwa moja.
  List<List<T>> chunked(int size) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'Ukubwa wa kipande lazima uwe > 0');
    }
    if (isEmpty) return <List<T>>[];
    final chunks = <List<T>>[];
    final buffer = <T>[];
    for (final item in this) {
      buffer.add(item);
      if (buffer.length == size) {
        chunks.add(List<T>.unmodifiable(buffer));
        buffer.clear();
      }
    }
    if (buffer.isNotEmpty) chunks.add(List<T>.unmodifiable(buffer));
    return List<List<T>>.unmodifiable(chunks);
  }

  /// Kupanga kwa thamani ya [key].
  ///
  /// Kipengele cha `descending: true` hutumika kwa "Zinazopendwa" (trending)
  /// na kwa orodha ya mafanikio mapya kwanza.
  List<T> sortedBy<K extends Comparable<K>>(
    K Function(T item) key, {
    bool descending = false,
  }) {
    final copy = toList();
    copy.sort((a, b) {
      final result = key(a).compareTo(key(b));
      return descending ? -result : result;
    });
    return List<T>.unmodifiable(copy);
  }

  /// Kuunganisha majina kwa Kiswahili: `"Baraka, Neema na Juma"`.
  ///
  /// Kiswahili hutumia "na" kama kiunganishi cha mwisho, si "and" wala
  /// koma ya Oxford. Hii hutumika kwenye muhtasari wa wahusika.
  /// `label` hutumika pale vipengele visivyo `String` (mfano
  /// `List<CharacterProfile>`) — hivyo hatusahau `.map()` kabla ya kuunganisha.
  String joinWithAnd({
    String conjunction = 'na',
    String Function(T item)? label,
  }) {
    final items = map((item) => (label?.call(item) ?? item).toString()).toList();
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items[0]} $conjunction ${items[1]}';
    final head = items.sublist(0, items.length - 1).join(', ');
    return '$head $conjunction ${items.last}';
  }
}

extension NullableIterableX<T> on Iterable<T?> {
  /// Kuondoa `null` na kurudisha aina isiyo na `null`.
  ///
  /// Hutumika sana kwa `Map` za JSON: `json['tags'].map(...).whereNotNull`.
  Iterable<T> get whereNotNull => where((item) => item != null).cast<T>();

  /// Orodha ya vipengele visivyo `null`.
  List<T> nonNullToList() => whereNotNull.toList(growable: false);
}

extension ListX<T> on List<T> {
  /// `true` kama nafasi [index] ipo kwenye orodha hii.
  bool hasIndex(int index) => index >= 0 && index < length;

  /// Kubadilisha kipengele kimoja kwa nafasi yake bila kubadilisha urefu.
  ///
  /// Haiburushi kosa kama nafasi haipo — inarudisha orodha ile ile.
  void replaceAt(int index, T value) {
    if (!hasIndex(index)) return;
    this[index] = value;
  }

  /// Kuhamisha kipengele kutoka nafasi moja kwenda nyingine.
  ///
  /// Hii ni injini ya `page_arranger.dart` kwenye Creator Studio, ambapo
  /// mwandishi huvuta ukurasa kwenda nafasi nyingine.
  List<T> reordered(int oldIndex, int newIndex) {
    if (!hasIndex(oldIndex)) return this;
    final copy = toList();
    final item = copy.removeAt(oldIndex);
    final target = newIndex.clamp(0, copy.length);
    copy.insert(target, item);
    return List<T>.unmodifiable(copy);
  }

  /// Kukata orodha kwa usalama — bila `RangeError` kama mipaka imepitiliza.
  List<T> safeSublist(int start, [int? end]) {
    final from = start.clamp(0, length);
    final to = (end ?? length).clamp(from, length);
    return List<T>.unmodifiable(sublist(from, to));
  }

  /// Kuongeza [item] kama haipo, au kuiondoa kama ipo (favorites/bookmarks).
  ///
  /// Hii hutumika kwa kitufe cha "Alama" (bookmark) na "Penda" (favorite):
  /// mtumiaji anagusa mara moja anaongeza, mara ya pili anaondoa.
  List<T> toggled(T item, {bool Function(T a, T b)? equals}) {
    final isEqual = equals ?? (T a, T b) => a == b;
    final exists = any((existing) => isEqual(existing, item));
    if (exists) {
      return List<T>.unmodifiable(
        where((existing) => !isEqual(existing, item)),
      );
    }
    return List<T>.unmodifiable(<T>[...this, item]);
  }

  /// Orodha ya map ya JSON — rahisi kwa Hive na kwa request bodies.
  List<Map<String, dynamic>> toJsonList(
    Map<String, dynamic> Function(T item) toJson,
  ) =>
      map(toJson).toList(growable: false);
}

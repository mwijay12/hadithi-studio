/// Hali ya orodha ya hadithi — hutumika Maktaba, rafu na utafutaji.
///
/// Hali moja inashughulikia nyuso tatu kwa makusudi:
///
/// * **Rafu** (`/category/:id`) — orodha iliyochujwa kwa [StoryShelf].
/// * **Utafutaji** — orodha iliyochujwa kwa [query].
/// * **Zote** — orodha kamili.
///
/// Kwa nini si hali tatu: mzigo wa kuonyesha ni sawa kabisa (gridi ya kadi +
/// hali tupu + hali ya kosa). Kutenganisha kungezalisha widget tatu
/// zinazofanana na sehemu tatu za kuhifadhi ujinga mmoja.
///
/// **Tofauti muhimu (kanuni ya 12):** orodha tupu SI kosa. Kwa hivyo
/// [StoryListStatus] haina thamani ya `empty` — UI hupima
/// `status == success && stories.isEmpty` na kuonyesha [AppEmptyState],
/// wakati kosa la kweli huonyesha [AppErrorWidget]. Kuchanganya hizi mbili
/// kungeonyesha "kosa" kwa rafu ambayo haina hadithi bado — jambo la kawaida
/// wakati wa kujenga maktaba ya hadithi mpya.
library;

import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_shelf.dart';

/// Hatua ya mzigo wa orodha.
enum StoryListStatus {
  /// Bado hakuna kitu kimeombwa.
  initial,

  /// Ombi linaendelea — UI huonyesha [AppLoading] au shimmer.
  loading,

  /// Data imefika (inaweza kuwa tupu — tazama doc ya faili hili).
  success,

  /// Kosa la kweli — UI huonyesha [AppErrorWidget] na [StoryListState.failure].
  failure,
}

/// Hali ya orodha ya hadithi.
class StoryListState extends Equatable {
  const StoryListState({
    this.status = StoryListStatus.initial,
    this.stories = const <Story>[],
    this.query = '',
    this.shelf,
    this.failure,
  });

  /// Hatua ya sasa.
  final StoryListStatus status;

  /// Hadithi zinazoonyeshwa sasa.
  final List<Story> stories;

  /// Hoja ya utafutaji ya sasa (`''` = hakuna utafutaji).
  final String query;

  /// Rafu iliyochujwa, kama orodha hii inatoka kwenye rafu.
  ///
  /// `null` = orodha haijachujwa kwa rafu (Maktaba yote au utafutaji).
  final StoryShelf? shelf;

  /// Kosa lililotokea — si `null` tu wakati [status] ni
  /// [StoryListStatus.failure].
  final Failure? failure;

  /// `true` = ombi linaendelea.
  bool get isLoading => status == StoryListStatus.loading;

  /// `true` = data imefika lakini orodha haina kitu.
  ///
  /// Tazama doc ya faili hili kwa nini hii haitengenezi `Failure`.
  bool get isEmpty =>
      status == StoryListStatus.success && stories.isEmpty;

  /// `true` = kosa la kweli linaonyeshwa.
  bool get hasFailure => status == StoryListStatus.failure;

  /// `true` = mtumiaji ameandika kitu kwenye utafutaji.
  bool get isSearching => query.trim().isNotEmpty;

  /// Nakala mpya yenye mabadiliko.
  ///
  /// `clearFailure` na `clearShelf` zipo kwa sababu `failure: null`
  /// haiwezi kutofautishwa na "acha kama ilivyo" kwenye `copyWith` ya
  /// kawaida — hivyo kuanza ombi jipya kungeacha kosa la zamani
  /// likiangaliwa.
  StoryListState copyWith({
    StoryListStatus? status,
    List<Story>? stories,
    String? query,
    StoryShelf? shelf,
    Failure? failure,
    bool clearFailure = false,
    bool clearShelf = false,
  }) {
    return StoryListState(
      status: status ?? this.status,
      stories: stories ?? this.stories,
      query: query ?? this.query,
      shelf: clearShelf ? null : (shelf ?? this.shelf),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, stories, query, shelf, failure];
}

/// Hali ya ukurasa wa Nyumbani — hadithi tatu kwa mpangilio mmoja.
///
/// Nyumbani haina orodha moja bali **makundi matatu** yenye kanuni tofauti
/// (`getFeaturedStories`, `getTrendingStories`, na hadithi ya leo). Kwa hivyo
/// hali hii ni tofauti na [StoryListState] — si kuchujwa, ni makundi.
///
/// **Hadithi ya leo ni ya kudumu kwa siku moja.** Kuchagua hadithi kwa
/// `DateTime.now().day % count` kunabadilika usiku wa manane bila app
/// kufunguliwa — mtoto anarudi asubuhi na hadithi nyingine, jambo ambalo
/// hufanya "Hadithi ya Leo" isiaminike. Kwa hivyo tunaichagua **mara moja**
/// na kuihifadhi kwenye hali hii.
library;

import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/story.dart';

/// Hatua ya mzigo wa Nyumbani.
enum HomeStoriesStatus { initial, loading, success, failure }

/// Hali ya ukurasa wa Nyumbani.
class HomeStoriesState extends Equatable {
  const HomeStoriesState({
    this.status = HomeStoriesStatus.initial,
    this.daily,
    this.featured = const <Story>[],
    this.trending = const <Story>[],
    this.failure,
  });

  /// Hatua ya sasa.
  final HomeStoriesStatus status;

  /// "Hadithi ya Leo" — kadi kubwa ya juu.
  final Story? daily;

  /// "Hadithi Bora" — orodha ya usawa.
  final List<Story> featured;

  /// "Zinazopendwa" — zinazoongoza kwa wasomaji.
  final List<Story> trending;

  /// Kosa lililotokea.
  final Failure? failure;

  /// `true` = ombi linaendelea.
  bool get isLoading => status == HomeStoriesStatus.loading;

  /// `true` = kosa la kweli.
  bool get hasFailure => status == HomeStoriesStatus.failure;

  /// `true` = hakuna hadithi hata moja ya kuonyesha.
  ///
  /// Hii ni tofauti na orodha tupu ya rafu: Nyumbani tupu inamaanisha
  /// maktaba yote haina kitu, hivyo tunahitaji hali ya kipekee ya UI.
  bool get isEmpty =>
      status == HomeStoriesStatus.success &&
      daily == null &&
      featured.isEmpty &&
      trending.isEmpty;

  /// Nakala mpya yenye mabadiliko.
  HomeStoriesState copyWith({
    HomeStoriesStatus? status,
    Story? daily,
    List<Story>? featured,
    List<Story>? trending,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return HomeStoriesState(
      status: status ?? this.status,
      daily: daily ?? this.daily,
      featured: featured ?? this.featured,
      trending: trending ?? this.trending,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, daily, featured, trending, failure];
}

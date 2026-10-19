/// Kuhamia kwenye kurasa za hadithi — mahali **pamoja** pa kuandika njia.
///
/// ## Kwa nini faili la pekee
///
/// Kadi za hadithi zinaonekana Nyumbani, Maktaba, Rafu Yangu, ukurasa wa rafu
/// na utafutaji. Kila moja ina kitufe cha kufungua hadithi. Bila faili hili,
/// kila skrini ingeandika `context.pushNamed('…', pathParameters: {'id': …})`
/// yake — na siku moja mmoja wao atasahau `extra` au atakosea jina, na mguso
/// utaanguka **runtime** (ambapo hakuna mkusanyaji anayekusaidia).
///
/// Hapa kuna kazi nne. Kila moja inaweka `extra` ile ile: **kitu cha hadithi
/// tulichokuwa nacho tayari**. Hii ndiyo inayofanya ukurasa wa maelezo
/// kuonekana **mara moja** — bila spinner, bila ombi la mtandao — kwa sababu
/// kadi tuliyogusa ilikuwa na hadithi kamili ndani yake.
///
/// ## Kwa nini `push` na si `go`
///
/// `push` huongeza ukurasa **juu** ya shell: tabu ya chini inabaki nyuma, na
/// kitufe cha "Rudi" hukurudisha kwenye tabu ile ile iliyotumika — pamoja na
/// scroll yake. `go` ingebadilisha eneo lote na kupoteza mahali mtumiaji
/// alikuwa.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/app_routes.dart';
import '../domain/entities/story.dart';
import '../domain/entities/story_shelf.dart';

/// Hufungua ukurasa wa maelezo ya [story].
void openStory(BuildContext context, Story story) {
  context.pushNamed(
    AppRoutes.storyDetailName,
    pathParameters: <String, String>{'id': story.id},
    extra: story,
  );
}

/// Hufungua ukurasa wa maelezo kwa `id` pekee (kiungo kilichoshirikiwa).
void openStoryById(BuildContext context, String storyId) {
  context.pushNamed(
    AppRoutes.storyDetailName,
    pathParameters: <String, String>{'id': storyId},
  );
}

/// Hufungua **STORY READER** kwa [story].
///
/// [autoPlay] ni `true` tunapoingia kwa "Sikiliza" badala ya "Soma Sasa":
/// reader huanza kusoma ukurasa wa kwanza mara moja.
void openReader(BuildContext context, Story story, {bool autoPlay = false}) {
  context.pushNamed(
    AppRoutes.readerName,
    pathParameters: <String, String>{'id': story.id},
    queryParameters: autoPlay
        ? const <String, String>{'auto': '1'}
        : const <String, String>{},
    extra: story,
  );
}

/// Hufungua orodha ya hadithi za [shelf].
void openShelf(BuildContext context, StoryShelf shelf) {
  context.pushNamed(
    AppRoutes.shelfName,
    pathParameters: <String, String>{'id': shelf.id},
  );
}

/// Hufungua orodha ya hadithi **zote** (Maktaba kamili + utafutaji).
void openAllStories(BuildContext context) {
  context.pushNamed(AppRoutes.allStoriesName);
}

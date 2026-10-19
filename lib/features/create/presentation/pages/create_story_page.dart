/// **TENGENEZA** — ukurasa wa kuandika hadithi yako mwenyewe.
///
/// ## Kwa nini ukurasa huu upo
///
/// Tabu ya "Tengeneza" ilikuwa **imekufa**: ilikuwa na mistari mitatu ya
/// mapambo na hakuna kitufe hata kimoja. Mtoto aliyegusa "Tengeneza" —
/// nia kuu ya app — hakupata njia yoyote ya kuandika. Ukurasa huu ndiyo njia
/// hiyo: kichwa, kurasa, na kuhifadhi kwenye kifaa.
///
/// ## Kwa nini ni maandishi pekee
///
/// Tuna uhifadhi wa rasimu (`LibraryStore.addDraft`) na modeli
/// `DraftStory` yenye kichwa na kurasa za maandishi. **Hakuna** picha,
/// jalada, sauti wala utengenezaji wa AI kwenye msimbo. Kwa hivyo hatuonyeshi
/// vitufe vya "Tengeneza picha kwa AI" — kitufe kisichofanya kitu ni
/// udanganyifu, na mtoto hasamehewi uongo huo. Ukurasa unaeleza hilo wazi
/// kwenye notisi ndogo.
///
/// ## Kwa nini rangi zinatoka theme
///
/// `themeMode` ni `ThemeMode.system`. Ukurasa uliowekwa cream kwa mkono
/// ungekuwa na maandishi yasiyoonekana kwenye dark mode. Hapa kila rangi ni
/// `scheme.surface` / `scheme.onSurface` / `scheme.onSurfaceVariant`.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/library_store.dart';
import '../../../../core/widgets/leo_mascot.dart';
import '../widgets/draft_page_editor.dart';
import 'my_stories_page.dart';

/// Ukurasa wa kuandika rasimu mpya.
class CreateStoryPage extends StatefulWidget {
  /// Huunda ukurasa.
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final TextEditingController _titleSwController = TextEditingController();
  final TextEditingController _titleEnController = TextEditingController();

  /// Kila ukurasa una controller yake ili `dispose` iwe ya wazi.
  final List<TextEditingController> _pageControllers =
      <TextEditingController>[TextEditingController()];

  /// Ujumbe wa kosa unaoonekana **ndani ya ukurasa**, sivyo snack bar pekee.
  ///
  /// Snack bar hupotea baada ya sekunde tatu; mtoto anayeandika polepole
  /// anahitaji kuona kinachokosekana akiwa bado kwenye fomu.
  String? _error;

  /// `true` wakati rasimu inahifadhiwa — kuzuia kugusa mara mbili.
  bool _saving = false;

  @override
  void dispose() {
    _titleSwController.dispose();
    _titleEnController.dispose();
    for (final TextEditingController controller in _pageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Huongeza ukurasa mpya tupu.
  void _addPage() {
    setState(() {
      _pageControllers.add(TextEditingController());
      _error = null;
    });
  }

  /// Hufuta ukurasa mmoja — **kamwe** haachi orodha tupu.
  void _removePage(int index) {
    if (_pageControllers.length <= 1) return;
    final TextEditingController removed = _pageControllers.removeAt(index);
    setState(() => _error = null);
    // `TextField` ya ukurasa huu bado iko kwenye mti hadi fremu ijayo;
    // kuifuta controller mara moja kungezua "used after being disposed".
    // Kwa hivyo tunaisubiria fremu moja, kisha tunaifuta.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      removed.dispose();
    });
  }

  /// Huhifadhi rasimu, au hueleza **kwa usahihi** kinachokosekana.
  Future<void> _save() async {
    if (_saving) return;

    final String titleSw = _titleSwController.text.trim();
    final String titleEn = _titleEnController.text.trim();
    final List<String> pages = _pageControllers
        .map((TextEditingController controller) => controller.text.trim())
        // Kurasa tupu hutolewa: ukurasa usio na maandishi si ukurasa.
        .where((String text) => text.isNotEmpty)
        .toList(growable: false);

    final String message;
    if (titleSw.isEmpty && pages.isEmpty) {
      message = context.isSwahili
          ? 'Kichwa cha Kiswahili hakipo, na hakuna ukurasa wenye '
              'maandishi. Jaza vyote viwili.'
          : 'The Swahili title is empty and no page has text. '
              'Fill in both.';
    } else if (titleSw.isEmpty) {
      message = context.isSwahili
          ? 'Kichwa cha Kiswahili hakipo. Andika kichwa kabla ya kuhifadhi.'
          : 'The Swahili title is empty. Write a title before saving.';
    } else if (pages.isEmpty) {
      message = context.isSwahili
          ? 'Hakuna ukurasa wenye maandishi. Andika angalau ukurasa mmoja.'
          : 'No page has text. Write at least one page.';
    } else {
      message = '';
    }

    if (message.isNotEmpty) {
      setState(() => _error = message);
      context.showSnackBar(message, isError: true);
      return;
    }

    final DraftStory draft = DraftStory(
      // `microsecondsSinceEpoch` ni ya kipekee vya kutosha kwa kifaa kimoja
      // na haiitaji huduma ya nje.
      id: 'draft-${DateTime.now().microsecondsSinceEpoch}',
      titleSw: titleSw,
      // Kiingereza ni hiari: bila hicho tunarudi kwenye Kiswahili, sivyo
      // kubuni kichwa cha Kiingereza ambacho mtumiaji hakukiandika.
      titleEn: titleEn.isEmpty ? titleSw : titleEn,
      pagesSw: pages,
      // Hatuulizi maandishi ya Kiingereza kwa kila ukurasa; kuyaiga kutoka
      // Kiswahili kungeonekana kama tafsiri ambayo haipo.
      pagesEn: const <String>[],
      createdAt: DateTime.now(),
    );

    setState(() {
      _saving = true;
      _error = null;
    });

    final bool stored = await LibraryStore.instance.addDraft(draft);
    if (!mounted) return;
    setState(() => _saving = false);

    if (!stored) {
      // Rasimu iko kwenye kumbukumbu lakini kifaa kimeshindwa kuandika.
      // Tunamwambia mtumiaji ukweli badala ya kudai imehifadhiwa.
      context.showSnackBar(
        context.isSwahili
            ? 'Rasimu imeundwa, lakini kifaa kimeshindwa kuihifadhi. '
                'Itapotea ukifunga app.'
            : 'The draft was created, but the device could not save it. '
                'It will be lost when you close the app.',
        isError: true,
      );
    }

    context.pop();
  }

  /// Mapambo ya uwanja wa maandishi — rangi zote zinatoka theme.
  InputDecoration _decoration({
    required String label,
    required String hint,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: scheme.onSurface.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSm,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSm,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSm,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    // Skrini ya 320dp (Tecno/Itel) haina nafasi ya padding ya 24 kwa kila
    // upande pamoja na uwanja — tunapunguza hadi 16.
    final double side = context.isCompact ? AppSpacing.lg : AppSpacing.xxl;

    return Scaffold(
      // Theme pekee: cream iliyowekwa kwa mkono + maandishi ya theme =
      // maandishi yasiyoonekana kwenye dark mode.
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: context.isSwahili ? 'Rudi' : 'Back',
        ),
        title: Text(
          context.isSwahili ? 'Tengeneza Hadithi' : 'Create a Story',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.library_books_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const MyStoriesPage(),
              ),
            ),
            tooltip: context.isSwahili ? 'Hadithi zangu' : 'My stories',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            side,
            AppSpacing.md,
            side,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Leo anadokeza — ukurasa wa kuandika ni mahali pa kujaribu,
              // sivyo shangwe. `curious` inafaa zaidi ya `wave`.
              const Center(
                child: LeoMascot(pose: LeoPose.curious, height: 96),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.isSwahili
                    ? 'Andika hadithi yako mwenyewe'
                    : 'Write your own story',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.isSwahili
                    ? 'Anza na kichwa, kisha andika kurasa. Unaweza kuhifadhi '
                        'na kuendelea baadaye.'
                    : 'Start with a title, then write your pages. You can save '
                        'and keep going later.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Ukweli kuhusu kile ukurasa huu unachofanya — na kisichofanya.
              const _DraftOnlyNotice(),
              const SizedBox(height: AppSpacing.xl),

              TextField(
                controller: _titleSwController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: TextStyle(fontSize: 16, color: scheme.onSurface),
                decoration: _decoration(
                  label: context.isSwahili
                      ? 'Kichwa kwa Kiswahili *'
                      : 'Title in Swahili *',
                  hint: context.isSwahili ? 'Mfano: Simba Jasiri' : 'e.g. Simba Jasiri',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _titleEnController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: TextStyle(fontSize: 16, color: scheme.onSurface),
                decoration: _decoration(
                  label: context.isSwahili
                      ? 'Kichwa kwa Kiingereza (hiari)'
                      : 'Title in English (optional)',
                  hint: context.isSwahili
                      ? 'Bila hiki, kichwa cha Kiswahili hutumika'
                      : 'If empty, the Swahili title is used',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.isSwahili ? 'Kurasa' : 'Pages',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    context.isSwahili
                        ? 'kurasa ${_pageControllers.length}'
                        : _pageControllers.length == 1
                            ? '1 page'
                            : '${_pageControllers.length} pages',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              for (int i = 0; i < _pageControllers.length; i++)
                DraftPageEditor(
                  // `ValueKey` hulinda hali ya uwanja wakati ukurasa wa kati
                  // unafutwa: bila hiyo, maandishi yangerukia ukurasa
                  // unaofuata kwa sababu `TextField` huchukua state kwa nafasi.
                  key: ValueKey<TextEditingController>(_pageControllers[i]),
                  index: i + 1,
                  controller: _pageControllers[i],
                  onDelete:
                      _pageControllers.length > 1 ? () => _removePage(i) : null,
                ),

              OutlinedButton.icon(
                onPressed: _addPage,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  context.isSwahili ? 'Ongeza Ukurasa' : 'Add Page',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.buttonHeightSmall),
                  foregroundColor: scheme.onSurface,
                  side: BorderSide(color: scheme.outline),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (_error != null) ...<Widget>[
                _ErrorBanner(message: _error ?? ''),
                const SizedBox(height: AppSpacing.md),
              ],

              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  _saving
                      ? (context.isSwahili ? 'Inahifadhi…' : 'Saving…')
                      : (context.isSwahili ? 'Hifadhi Hadithi' : 'Save Story'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const MyStoriesPage(),
                  ),
                ),
                icon: const Icon(Icons.library_books_rounded, size: 18),
                label: Text(
                  context.isSwahili ? 'Hadithi Zangu' : 'My Stories',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notisi inayoeleza **kwa uwazi** kwamba hii ni rasimu ya maandishi pekee.
class _DraftOnlyNotice extends StatelessWidget {
  const _DraftOnlyNotice();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // `onSurface` hafifu hufanya "kadi ya habari" ionekane kwenye
        // mandhari zote mbili bila rangi ya brand iliyowekwa kwa mkono.
        color: scheme.onSurface.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: AppSpacing.iconSm,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.isSwahili
                  ? 'Hii ni rasimu ya maandishi pekee. Picha, jalada, sauti na '
                      'utengenezaji wa AI bado hazipo — hatuzionyeshi kana '
                      'kwamba zinafanya kazi.'
                  : 'This is a text-only draft. Images, covers, narration and '
                      'AI generation are not available yet — we do not show '
                      'them as if they worked.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kosa la uthibitishaji — linaonekana hadi mtumiaji atakaporekebisha.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.error.withOpacity(0.10),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: scheme.error.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline_rounded, size: AppSpacing.iconSm, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: scheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

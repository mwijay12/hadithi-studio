/// Ukurasa wa **Nyimbo za Watoto**.
///
/// ## Hali ya ukweli
///
/// Kwa sasa hakuna faili yoyote kwenye `assets/audio/songs/`. Ukurasa
/// **hauonyeshi nyimbo za kubuni** — unaonyesha hali tupu inayoeleza
/// wazi kwamba nyimbo hazijawekwa bado, na inaeleza jinsi ya kuziweka.
///
/// Mara tu faili za kwanza zikiwekwa na app ikajengwa upya, orodha
/// inaonekana na kichezaji kinafanya kazi — hakuna msimbo wa kubadilisha.
library;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/song_catalog.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final AudioPlayer _player = AudioPlayer();

  List<Song> _songs = const <Song>[];
  bool _loading = true;
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _load();
    _player.playerStateStream.listen((PlayerState state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() => _playingId = null);
      }
    });
  }

  Future<void> _load() async {
    final List<Song> songs = await SongCatalog.discover();
    if (!mounted) return;
    setState(() {
      _songs = songs;
      _loading = false;
    });
  }

  Future<void> _toggle(Song song) async {
    try {
      if (_playingId == song.id && _player.playing) {
        await _player.pause();
        if (mounted) setState(() => _playingId = null);
        return;
      }
      if (_playingId != song.id) {
        await _player.setAsset(song.asset);
      }
      await _player.play();
      if (mounted) setState(() => _playingId = song.id);
    } catch (_) {
      // Faili mbovu au isiyosomeka: usiangushe app.
      if (mounted) setState(() => _playingId = null);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool sw = context.isSwahili;
    final Color surface = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(sw ? 'Nyimbo za Watoto' : 'Songs for Children'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? _EmptySongs(swahili: sw)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  itemCount: _songs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final Song song = _songs[index];
                    final bool playing = _playingId == song.id;
                    return Material(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: AppSpacing.borderRadiusLg,
                      child: InkWell(
                        borderRadius: AppSpacing.borderRadiusLg,
                        onTap: () => _toggle(song),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.zanzibarTurquoise,
                                ),
                                child: Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      sw ? song.titleSw : song.titleEn,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    if (song.artistSw != null)
                                      Text(
                                        sw
                                            ? song.artistSw!
                                            : (song.artistEn ??
                                                song.artistSw!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

/// Hali tupu — inasema ukweli na inaeleza jinsi ya kuongeza nyimbo.
class _EmptySongs extends StatelessWidget {
  const _EmptySongs({required this.swahili});

  final bool swahili;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.zanzibarTurquoise.withValues(alpha: 0.14),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 44,
                color: AppColors.zanzibarTurquoise,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              swahili ? 'Nyimbo bado hazijawekwa' : 'No songs added yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              swahili
                  ? 'Nafasi hii iko tayari. Weka faili za nyimbo kwenye '
                      'folda ya `assets/audio/songs/` kisha jenga app upya — '
                      'nyimbo zitaonekana hapa zenyewe, kwa mpangilio wa '
                      'nambari ya jina la faili.'
                  : 'This space is ready. Put the song files in '
                      '`assets/audio/songs/` and rebuild — they appear here '
                      'automatically, ordered by the number in the filename.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'assets/audio/songs/01_kichwa.mp3',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

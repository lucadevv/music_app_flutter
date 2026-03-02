import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/player/domain/entities/lyric_line.dart';
import 'package:music_app/main.dart';


class LyricsWidget extends StatefulWidget {
  final String videoId;

  const LyricsWidget({
    required this.videoId, super.key,
  });

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends State<LyricsWidget> {
  bool _isLoading = true;
  String? _lyrics;
  String? _source;
  bool _hasTimestamps = false;
  List<LyricLine> _parsedLyrics = [];
  
  // Para auto-scroll
  final ScrollController _scrollController = ScrollController();
  int _currentLineIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void didUpdateWidget(LyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _loadLyrics();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLine() {
    if (_currentLineIndex >= 0 && _scrollController.hasClients) {
      // Calcular posición aproximada de la línea
      const lineHeight = 50.0; // Altura estimada por línea
      final targetOffset = _currentLineIndex * lineHeight - 100; // Centrar un poco
      
      if (_scrollController.position.maxScrollExtent >= targetOffset) {
        _scrollController.animateTo(
          targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Future<void> _loadLyrics() async {
    setState(() {
      _isLoading = true;
      _parsedLyrics = [];
      _currentLineIndex = -1;
    });

    try {
      final libraryService = getIt<LibraryService>();
      final response = await libraryService.getLyrics(widget.videoId);

      if (mounted) {
        // Parsear lyrics
        final lyricsText = response.lyrics;
        
        setState(() {
          _isLoading = false;
          _lyrics = lyricsText;
          _source = response.source;
          // Detectar timestamps de forma más flexible: [MM:SS] o [MM:SS.xx]
          _hasTimestamps = lyricsText != null && RegExp(r'\[\d{1,2}:\d{2}').hasMatch(lyricsText);
          
          // Parsear lyrics con timestamps
          _parsedLyrics = LyricLine.parseLyrics(lyricsText);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar BlocBuilder con selector para solo reconstruir cuando cambia la posición
    return BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
      buildWhen: (previous, current) {
        // Solo reconstruir cuando cambie la posición
        if (previous is PlayerBlocLoaded && current is PlayerBlocLoaded) {
          return previous.position != current.position;
        }
        return true;
      },
      builder: (context, playerState) {
        if (playerState is PlayerBlocLoaded) {
          // Calcular índice de línea actual
          final newIndex = LyricLine.getCurrentLineIndex(_parsedLyrics, playerState.position);
          
          // Solo actualizar y hacer scroll si cambió la línea
          if (newIndex != _currentLineIndex) {
            _currentLineIndex = newIndex;
            // Auto-scroll cuando cambia la línea
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToCurrentLine();
            });
          }
        }

        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColorsDark.primary,
          ),
        ),
      );
    }

    // Si no hay lyrics o está vacío
    if (_lyrics == null || _lyrics!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lyrics_outlined,
                color: Colors.white.withValues(alpha: 0.3),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No lyrics available for this song',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadLyrics,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Si tenemos timestamps, mostrar karaoke
    if (_hasTimestamps && _parsedLyrics.isNotEmpty) {
      return _buildKaraokeView();
    }

    // Sin timestamps - mostrar texto normal
    return _buildNormalView();
  }

  Widget _buildKaraokeView() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        itemCount: _parsedLyrics.length,
        itemBuilder: (context, index) {
          final line = _parsedLyrics[index];
          final isCurrentLine = index == _currentLineIndex;
          final isPastLine = index < _currentLineIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isCurrentLine ? 20 : 16,
                fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
                color: isCurrentLine 
                    ? AppColorsDark.primary 
                    : (isPastLine
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.8)),
                height: 1.4,
              ),
              child: Text(
                line.text,
                textAlign: isCurrentLine ? TextAlign.center : TextAlign.left,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNormalView() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_source != null) ...[
            Text(
              'Source: $_source',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _lyrics!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

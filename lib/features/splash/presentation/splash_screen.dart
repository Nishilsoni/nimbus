import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/navigation/circular_reveal_route.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/features/splash/presentation/widgets/animated_logo.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_screen.dart';

/// A disc rises out of the surface, the sun and cloud settle into it, and
/// the name appears letter by letter. Then the weather screen is revealed
/// through a circle growing out of the sun.
///
/// The splash doesn't pretend to load anything: cached weather is read
/// synchronously when the weather screen opens, so it appears on the first
/// frame after the reveal and refreshes live from there.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _logoKey = GlobalKey();

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: _reduceMotion
        ? const Duration(milliseconds: 400)
        : const Duration(milliseconds: 2200),
  );

  late final Animation<double> _discRise = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 0.35, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _logo = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.15, 0.85),
  );

  late final Animation<double> _tagline = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.78, 1, curve: Curves.easeOut),
  );

  bool get _reduceMotion => WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;

  @override
  void initState() {
    super.initState();
    _intro
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _goToWeather();
      })
      ..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _goToWeather() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CircularRevealRoute<void>(
        page: const WeatherScreen(),
        center: _sunPosition(),
      ),
    );
  }

  /// The sun's centre in global coordinates.
  Offset _sunPosition() {
    final box = _logoKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return MediaQuery.sizeOf(context).center(Offset.zero);
    }
    return box.localToGlobal(AnimatedLogo.sunAlignment.alongSize(box.size));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    // Scales with the screen, so it fits a small phone on its side too.
    final discSize = (MediaQuery.sizeOf(context).shortestSide * 0.52).clamp(
      150.0,
      240.0,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyleFor(palette),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _discRise,
                builder: (context, child) => Transform.scale(
                  scale: 0.9 + 0.1 * _discRise.value,
                  child: TactileSurface(
                    circle: true,
                    depth: _discRise.value,
                    distance: 16,
                    duration: Duration.zero,
                    child: child,
                  ),
                ),
                child: SizedBox.square(
                  dimension: discSize,
                  child: Center(
                    child: AnimatedLogo(
                      key: _logoKey,
                      progress: _logo,
                      size: discSize * 0.73,
                    ),
                  ),
                ),
              ),
              SizedBox(height: discSize * 0.2),
              _LetterByLetter(
                text: l10n.appName.toUpperCase(),
                progress: _intro,
                style: AppTextStyles.wordmark,
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _tagline,
                child: Text(
                  l10n.appTagline,
                  style: AppTextStyles.body.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Each letter floats up and fades in slightly after the previous one.
class _LetterByLetter extends StatelessWidget {
  const _LetterByLetter({
    required this.text,
    required this.progress,
    required this.style,
  });

  final String text;
  final Animation<double> progress;
  final TextStyle style;

  static const _start = 0.45;
  static const _perLetter = 0.05;
  static const _letterDuration = 0.3;

  @override
  Widget build(BuildContext context) {
    final letters = text.characters.toList();
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < letters.length; i++)
              _Letter(
                letter: letters[i],
                style: style,
                animation: CurvedAnimation(
                  parent: progress,
                  curve: Interval(
                    _start + i * _perLetter,
                    (_start + i * _perLetter + _letterDuration).clamp(0, 1),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({
    required this.letter,
    required this.style,
    required this.animation,
  });

  final String letter;
  final TextStyle style;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(animation),
        child: Text(letter, style: style),
      ),
    );
  }
}

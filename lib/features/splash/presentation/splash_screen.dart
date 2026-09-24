import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/navigation/circular_reveal_route.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/widgets/gradient_background.dart';
import 'package:nimbus/features/splash/presentation/widgets/animated_logo.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_screen.dart';

/// Plays the logo animation, then reveals the weather screen through a
/// circle that grows out of the logo's sun.
///
/// The splash doesn't pretend to load anything. The weather cubit starts
/// reading the cache the moment the app launches, so by the time the
/// animation ends the weather screen usually has data to show.
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
        : const Duration(milliseconds: 1900),
  );

  late final Animation<double> _wordmark = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.50, 0.90, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _tagline = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.65, 1, curve: Curves.easeOut),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemOverlayStyle,
      child: Scaffold(
        body: GradientBackground(
          colors: AppColors.brandGradient,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedLogo(key: _logoKey, progress: _intro),
                const SizedBox(height: 24),
                _FadeSlideIn(
                  animation: _wordmark,
                  child: Text(
                    AppStrings.appName.toUpperCase(),
                    style: AppTextStyles.wordmark,
                  ),
                ),
                const SizedBox(height: 8),
                _FadeSlideIn(
                  animation: _tagline,
                  child: const Text(
                    AppStrings.appTagline,
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

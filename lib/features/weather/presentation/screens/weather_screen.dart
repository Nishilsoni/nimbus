import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/widgets/gradient_background.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
import 'package:nimbus/features/weather/presentation/screens/city_search_screen.dart';
import 'package:nimbus/features/weather/presentation/utils/condition_visuals.dart';
import 'package:nimbus/features/weather/presentation/utils/failure_display.dart';
import 'package:nimbus/features/weather/presentation/widgets/empty_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/error_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/loading_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/refresh_status_banner.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_content.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_header.dart';

/// The main screen. It maps [WeatherState] to widgets and user actions to
/// [WeatherCubit] calls; it holds no logic of its own.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WeatherCubit>();

    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final report = state.report;
        final skyColors =
            report?.weather.condition.skyGradient(
              isDay: report.weather.isDay,
            ) ??
            AppColors.brandGradient;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemOverlayStyle,
          child: Scaffold(
            body: GradientBackground(
              colors: skyColors,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    WeatherHeader(
                      city: report?.city,
                      fetchedAt: report?.fetchedAt,
                      isRefreshing: state.isBusy,
                      onSearch: () => _openSearch(context),
                      onUseLocation: cubit.useCurrentLocation,
                      onRefresh: state.status == WeatherStatus.initial
                          ? null
                          : cubit.refresh,
                    ),
                    _RefreshProgressBar(visible: state.isRefreshing),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: cubit.refresh,
                        // Nothing to refresh before a city has been chosen.
                        notificationPredicate: (notification) =>
                            state.status != WeatherStatus.initial &&
                            defaultScrollNotificationPredicate(notification),
                        child: _AlwaysScrollable(
                          resetKey: report?.city,
                          builder: (viewportHeight) =>
                              _buildBody(context, state, viewportHeight),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherState state,
    double viewportHeight,
  ) {
    final cubit = context.read<WeatherCubit>();
    final report = state.report;
    final failure = state.failure;

    final Widget body;
    if (report != null) {
      body = Column(
        key: ValueKey(report.city),
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: failure == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RefreshStatusBanner(
                      failure: failure,
                      lastUpdated: report.fetchedAt,
                      onAction: () => _handleFailureAction(context, state),
                      onDismiss: cubit.dismissFailure,
                    ),
                  ),
          ),
          WeatherContent(report: report),
        ],
      );
    } else if (state.status == WeatherStatus.loading) {
      body = const LoadingView(key: ValueKey('loading'));
    } else {
      body = SizedBox(
        key: ValueKey(failure ?? 'empty'),
        height: viewportHeight,
        child: Center(
          child: failure == null
              ? EmptyView(
                  onSearch: () => _openSearch(context),
                  onUseLocation: cubit.useCurrentLocation,
                )
              : ErrorView(
                  failure: failure,
                  onAction: () => _handleFailureAction(context, state),
                  onSearch: () => _openSearch(context),
                ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: body,
    );
  }

  void _handleFailureAction(BuildContext context, WeatherState state) {
    final cubit = context.read<WeatherCubit>();
    switch (state.failure?.action) {
      case FailureAction.openSettings:
        unawaited(cubit.openLocationSettings());
      case FailureAction.retryLocation:
        unawaited(cubit.useCurrentLocation());
      case FailureAction.retry || null:
        unawaited(cubit.refresh());
    }
  }

  void _openSearch(BuildContext context) {
    unawaited(Navigator.of(context).push(CitySearchScreen.route()));
  }
}

/// A thin progress line under the header while data on screen is being
/// refreshed.
class _RefreshProgressBar extends StatelessWidget {
  const _RefreshProgressBar({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        height: 2,
        child: visible ? const LinearProgressIndicator(minHeight: 2) : null,
      ),
    );
  }
}

/// Makes its content scrollable even when it's shorter than the screen, so
/// pull-to-refresh works in every state, including the error view.
class _AlwaysScrollable extends StatefulWidget {
  const _AlwaysScrollable({required this.builder, required this.resetKey});

  /// Receives the height available for content, for centring short views.
  final Widget Function(double viewportHeight) builder;

  /// When this changes (e.g. a different city loads), scroll back to the
  /// top so the new weather is seen from its headline.
  final Object? resetKey;

  @override
  State<_AlwaysScrollable> createState() => _AlwaysScrollableState();
}

class _AlwaysScrollableState extends State<_AlwaysScrollable> {
  static const _padding = EdgeInsets.fromLTRB(20, 12, 20, 32);

  final _controller = ScrollController();

  @override
  void didUpdateWidget(_AlwaysScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetKey != widget.resetKey && _controller.hasClients) {
      unawaited(
        _controller.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight =
            constraints.maxHeight - _padding.vertical - bottomInset;
        return SingleChildScrollView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _padding.copyWith(bottom: _padding.bottom + bottomInset),
          child: widget.builder(viewportHeight.clamp(0, double.infinity)),
        );
      },
    );
  }
}

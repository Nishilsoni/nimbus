import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/tactile/tactile_progress_bar.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
import 'package:nimbus/features/weather/presentation/screens/city_search_screen.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyleFor(context.palette),
      child: Scaffold(
        body: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            final report = state.report;
            return SafeArea(
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                    child: TactileProgressBar(isVisible: state.isRefreshing),
                  ),
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
            );
          },
        ),
      ),
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
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: SmoothSwitcher(
              alignment: Alignment.topCenter,
              child: failure == null
                  ? const SizedBox(
                      key: ValueKey('no-banner'),
                      width: double.infinity,
                    )
                  : Padding(
                      key: ValueKey(failure),
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: RefreshStatusBanner(
                        failure: failure,
                        lastUpdated: report.fetchedAt,
                        onAction: () => _handleFailureAction(context, state),
                        onDismiss: cubit.dismissFailure,
                      ),
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

    return SmoothSwitcher(
      duration: const Duration(milliseconds: 450),
      alignment: Alignment.topCenter,
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
  /// Generous side padding: the soft shadows need room to fall.
  static const _padding = EdgeInsets.fromLTRB(24, 12, 24, 40);

  final _controller = ScrollController();

  @override
  void didUpdateWidget(_AlwaysScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetKey != widget.resetKey && _controller.hasClients) {
      unawaited(
        _controller.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
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
          // A soft bounce on every platform suits the tactile design.
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: _padding.copyWith(bottom: _padding.bottom + bottomInset),
          child: widget.builder(viewportHeight.clamp(0, double.infinity)),
        );
      },
    );
  }
}

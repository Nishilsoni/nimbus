import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/layout/breakpoints.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/tactile/tactile_progress_bar.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
import 'package:nimbus/features/weather/presentation/screens/city_search_screen.dart';
import 'package:nimbus/features/weather/presentation/utils/failure_display.dart';
import 'package:nimbus/features/weather/presentation/widgets/error_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/loading_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/refresh_status_banner.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_content.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_header.dart';

/// One place's weather. It maps the page's [WeatherState] to widgets and
/// user actions to [WeatherCubit] calls; it holds no logic of its own.
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key, this.bottomInset = 0});

  /// Extra space below the content, e.g. for the page dots.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<WeatherCubit>();
    final isLocationPage = cubit.place is CurrentLocationPlace;

    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final report = state.report;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              WeatherHeader(
                city: report?.city,
                fetchedAt: report?.fetchedAt,
                placeholderTitle: isLocationPage ? l10n.myLocation : null,
                showsLocationIcon: isLocationPage,
                isRefreshing: state.isBusy,
                onSearch: () => openCitySearch(context),
                // On the location page this takes a fresh fix; elsewhere it
                // goes to the location page, adding it if needed.
                onUseLocation: isLocationPage
                    ? cubit.refresh
                    : context.read<PlacesCubit>().showCurrentLocation,
                onRefresh: cubit.refresh,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                child: TactileProgressBar(isVisible: state.isRefreshing),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: _AlwaysScrollable(
                    resetKey: report?.city,
                    bottomInset: bottomInset,
                    builder: (viewportHeight) =>
                        _buildBody(context, state, viewportHeight),
                  ),
                ),
              ),
            ],
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
                      child: MaxWidth(
                        maxWidth: Breakpoints.maxFormWidth,
                        child: RefreshStatusBanner(
                          failure: failure,
                          lastUpdated: report.fetchedAt,
                          onAction: () => _handleFailureAction(context, state),
                          onDismiss: cubit.dismissFailure,
                        ),
                      ),
                    ),
            ),
          ),
          WeatherContent(report: report),
        ],
      );
    } else if (failure == null) {
      body = const LoadingView(key: ValueKey('loading'));
    } else {
      body = SizedBox(
        key: ValueKey(failure),
        height: viewportHeight,
        child: MaxWidth(
          maxWidth: Breakpoints.maxFormWidth,
          alignment: Alignment.center,
          child: Center(
            child: ErrorView(
              failure: failure,
              onAction: () => _handleFailureAction(context, state),
              onSearch: () => openCitySearch(context),
            ),
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
      case FailureAction.retry || null:
        unawaited(cubit.refresh());
    }
  }
}

/// Opens the search screen, where a city is added as a new page.
void openCitySearch(BuildContext context) {
  unawaited(Navigator.of(context).push(CitySearchScreen.route()));
}

/// Makes its content scrollable even when it's shorter than the screen, so
/// pull-to-refresh works in every state, including the error view.
class _AlwaysScrollable extends StatefulWidget {
  const _AlwaysScrollable({
    required this.builder,
    required this.resetKey,
    required this.bottomInset,
  });

  /// Receives the height available for content, for centring short views.
  final Widget Function(double viewportHeight) builder;

  /// When this changes (e.g. the location page moves to a new city),
  /// scroll back to the top so the new weather is seen from its headline.
  final Object? resetKey;
  final double bottomInset;

  @override
  State<_AlwaysScrollable> createState() => _AlwaysScrollableState();
}

class _AlwaysScrollableState extends State<_AlwaysScrollable> {
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
    final bottomInset =
        MediaQuery.paddingOf(context).bottom + widget.bottomInset;
    // Generous side padding: the soft shadows need room to fall. Wider on
    // big screens, where edge-to-edge content would feel stretched.
    final horizontal = MediaQuery.sizeOf(context).width < 380 ? 18.0 : 24.0;
    final padding = EdgeInsets.fromLTRB(horizontal, 12, horizontal, 40);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight =
            constraints.maxHeight - padding.vertical - bottomInset;
        return SingleChildScrollView(
          controller: _controller,
          // A soft bounce on every platform suits the tactile design.
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: padding.copyWith(bottom: padding.bottom + bottomInset),
          child: MaxWidth(
            maxWidth: Breakpoints.maxContentWidth,
            child: widget.builder(viewportHeight.clamp(0, double.infinity)),
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/layout/breakpoints.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_look_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_page.dart';
import 'package:nimbus/features/weather/presentation/widgets/empty_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/page_dots.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_header.dart';

/// The user's places as pages to swipe between, or a welcome view when
/// none are saved yet.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final PageController _pages;

  /// What the pager last followed, to tell additions from removals.
  late SavedPlaces _lastPlaces;

  /// Room kept below each page's content for the page dots.
  static const _dotsSpace = 64.0;

  @override
  void initState() {
    super.initState();
    _lastPlaces = context.read<PlacesCubit>().state;
    _pages = PageController(initialPage: _lastPlaces.selectedIndex);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Keeps the pager in step with [PlacesCubit] when a place is added,
  /// removed or chosen from the search screen. Runs after the frame, once
  /// the pager knows about any new page.
  void _followSelection(SavedPlaces previous, SavedPlaces current) {
    if (current.isEmpty) {
      context.read<WeatherLookCubit>().show(null);
      return;
    }
    final wasRemoval = previous.places.length > current.places.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pages.hasClients) return;
      final target = current.selectedIndex;
      if (_pages.page?.round() == target) return;
      if (wasRemoval) {
        // After a removal, sliding past other pages would be confusing.
        _pages.jumpToPage(target);
      } else {
        unawaited(
          _pages.animateToPage(
            target,
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeInOutCubic,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyleFor(context.palette),
      child: Scaffold(
        body: BlocConsumer<PlacesCubit, SavedPlaces>(
          listenWhen: (before, after) =>
              before.selectedIndex != after.selectedIndex ||
              before.places.length != after.places.length,
          listener: (context, places) {
            _followSelection(_lastPlaces, places);
            _lastPlaces = places;
          },
          builder: (context, saved) {
            if (saved.isEmpty) return const _NoPlaces();

            final places = saved.places;
            final showsDots = places.length > 1;
            return Stack(
              children: [
                PageView.builder(
                  controller: _pages,
                  itemCount: places.length,
                  onPageChanged: context.read<PlacesCubit>().select,
                  // Lets pages keep their state when a place is inserted
                  // before them (the location page is always first).
                  findChildIndexCallback: (key) {
                    final index = places.indexWhere(
                      (place) => ValueKey(place.id) == key,
                    );
                    return index == -1 ? null : index;
                  },
                  itemBuilder: (context, index) => _PlacePage(
                    key: ValueKey(places[index].id),
                    place: places[index],
                    isShowing: index == saved.selectedIndex,
                    bottomInset: showsDots ? _dotsSpace : 0,
                  ),
                ),
                if (showsDots)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.paddingOf(context).bottom + 14,
                    child: Center(
                      child: PageDots(
                        count: places.length,
                        index: saved.selectedIndex,
                        firstIsLocation: saved.includesCurrentLocation,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Owns one place's [WeatherCubit] and keeps it alive while the user
/// swipes elsewhere, so coming back doesn't refetch. While it's the page on
/// screen, it tells the app which weather to theme itself after.
class _PlacePage extends StatefulWidget {
  const _PlacePage({
    super.key,
    required this.place,
    required this.isShowing,
    required this.bottomInset,
  });

  final Place place;
  final bool isShowing;
  final double bottomInset;

  @override
  State<_PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<_PlacePage>
    with AutomaticKeepAliveClientMixin {
  late final WeatherCubit _cubit = WeatherCubit(
    place: widget.place,
    weatherRepository: context.read<WeatherRepository>(),
    locationRepository: context.read<LocationRepository>(),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    unawaited(_cubit.refresh());
    _reportLookAfterFrame();
  }

  @override
  void didUpdateWidget(_PlacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShowing && !oldWidget.isShowing) _reportLookAfterFrame();
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  /// The theme can't change while widgets are building, so wait a frame.
  void _reportLookAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isShowing) _reportLook();
    });
  }

  void _reportLook() =>
      context.read<WeatherLookCubit>().show(_cubit.state.report?.weather);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<WeatherCubit, WeatherState>(
        listenWhen: (before, after) =>
            before.report?.weather != after.report?.weather,
        listener: (_, _) {
          if (widget.isShowing) _reportLook();
        },
        child: WeatherPage(bottomInset: widget.bottomInset),
      ),
    );
  }
}

/// First launch: nothing saved, so invite the user to add a place.
class _NoPlaces extends StatelessWidget {
  const _NoPlaces();

  @override
  Widget build(BuildContext context) {
    final places = context.read<PlacesCubit>();
    return SafeArea(
      child: Column(
        children: [
          WeatherHeader(
            city: null,
            fetchedAt: null,
            isRefreshing: false,
            onSearch: () => openCitySearch(context),
            onUseLocation: places.showCurrentLocation,
            onRefresh: null,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: MaxWidth(
                    maxWidth: Breakpoints.maxFormWidth,
                    alignment: Alignment.center,
                    child: Center(
                      child: EmptyView(
                        onSearch: () => openCitySearch(context),
                        onUseLocation: places.showCurrentLocation,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

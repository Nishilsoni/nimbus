import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/layout/breakpoints.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/country_flag.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/core/widgets/status_message.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/core/widgets/tactile/tactile_progress_bar.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/core/widgets/tactile/tactile_text_field.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/city_search_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/city_search_state.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';
import 'package:nimbus/features/weather/presentation/utils/failure_display.dart';
import 'package:nimbus/features/weather/presentation/widgets/city_result_tile.dart';
import 'package:nimbus/features/weather/presentation/widgets/search_hero.dart';

/// Finds cities to add as pages, and manages the saved ones.
class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  /// The search cubit lives only as long as this route. The page fades and
  /// settles into place while the search button morphs into the field.
  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        final languageCode = context.l10n.localeName;
        return BlocProvider(
          create: (context) => CitySearchCubit(
            weatherRepository: context.read<WeatherRepository>(),
            languageCode: languageCode,
          ),
          child: const CitySearchScreen(),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.97, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _addCity(City city) {
    unawaited(context.read<PlacesCubit>().addCity(city));
    Navigator.of(context).pop();
  }

  void _showCurrentLocation() {
    unawaited(context.read<PlacesCubit>().showCurrentLocation());
    Navigator.of(context).pop();
  }

  void _openPlace(int index) {
    unawaited(context.read<PlacesCubit>().select(index));
    Navigator.of(context).pop();
  }

  void _clearQuery() {
    _queryController.clear();
    context.read<CitySearchCubit>().queryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final searchCubit = context.read<CitySearchCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyleFor(context.palette),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: MaxWidth(
            maxWidth: Breakpoints.maxFormWidth,
            child: BlocBuilder<CitySearchCubit, CitySearchState>(
              builder: (context, state) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 24, 0),
                    child: Row(
                      children: [
                        TactileIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SearchHero(
                            child: TactileTextField(
                              controller: _queryController,
                              hintText: l10n.searchHint,
                              autofocus: true,
                              onChanged: searchCubit.queryChanged,
                              onSubmitted: searchCubit.submit,
                              onClear: _clearQuery,
                              clearTooltip: l10n.clearSearch,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    child: TactileProgressBar(
                      isVisible:
                          state.status == CitySearchStatus.loading &&
                          state.results.isNotEmpty,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: StaggeredEntrance(
                      index: 1,
                      child: CityResultTile(
                        title: l10n.currentLocation,
                        subtitle: l10n.currentLocationSubtitle,
                        leading: Icon(
                          Icons.my_location_rounded,
                          color: context.palette.accent,
                        ),
                        onTap: _showCurrentLocation,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SmoothSwitcher(
                      alignment: Alignment.topCenter,
                      child: _SearchResults(
                        key: ValueKey(_viewKey(state)),
                        state: state,
                        onCitySelected: _addCity,
                        onPlaceSelected: _openPlace,
                        onRetry: searchCubit.retry,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Which view is showing. The switcher animates only when this changes,
  /// not on every keystroke.
  Object _viewKey(CitySearchState state) => switch (state.status) {
    CitySearchStatus.idle => 'places',
    CitySearchStatus.loading when state.results.isEmpty => 'loading',
    CitySearchStatus.failure => state.failure ?? 'failure',
    _ => 'results',
  };
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    super.key,
    required this.state,
    required this.onCitySelected,
    required this.onPlaceSelected,
    required this.onRetry,
  });

  final CitySearchState state;
  final ValueChanged<City> onCitySelected;
  final ValueChanged<int> onPlaceSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    return switch (state.status) {
      CitySearchStatus.idle => _SavedPlacesList(onSelected: onPlaceSelected),
      CitySearchStatus.loading when state.results.isEmpty =>
        const _LoadingIndicator(),
      CitySearchStatus.failure when failure != null => _FailureMessage(
        failure: failure,
        onRetry: onRetry,
      ),
      _ => _ResultList(cities: state.results, onCitySelected: onCitySelected),
    };
  }
}

/// Before anything is typed: the saved places, to jump to or remove. With
/// none saved yet, a hint about how to search.
class _SavedPlacesList extends StatelessWidget {
  const _SavedPlacesList({required this.onSelected});

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;

    return BlocBuilder<PlacesCubit, SavedPlaces>(
      builder: (context, saved) {
        if (saved.isEmpty) {
          return Align(
            alignment: const Alignment(0, -0.5),
            child: SingleChildScrollView(
              child: StatusMessage(
                visual: const StatusIcon(Icons.travel_explore_rounded),
                title: l10n.searchHint,
                message: l10n.searchIdleMessage,
              ),
            ),
          );
        }

        final places = saved.places;
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: places.length + 1,
          separatorBuilder: (_, index) =>
              SizedBox(height: index == 0 ? 12 : 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                l10n.yourPlaces.toUpperCase(),
                style: AppTextStyles.tileLabel.copyWith(
                  color: palette.textMuted,
                ),
              );
            }
            final place = places[index - 1];
            final (title, subtitle, leading) = switch (place) {
              CurrentLocationPlace() => (
                l10n.myLocation,
                l10n.currentLocationSubtitle,
                Icon(Icons.near_me_rounded, color: palette.accent),
              ),
              CityPlace(:final city) => (
                city.name,
                city.subtitle.isEmpty ? null : city.subtitle,
                _flagOrIcon(city, palette),
              ),
            };
            return StaggeredEntrance(
              key: ValueKey(place.id),
              index: index,
              step: const Duration(milliseconds: 45),
              child: CityResultTile(
                title: title,
                subtitle: subtitle,
                leading: leading,
                onTap: () => onSelected(index - 1),
                trailing: TactileIconButton(
                  icon: Icons.close_rounded,
                  tooltip: l10n.removePlace(title),
                  onPressed: () => context.read<PlacesCubit>().remove(place),
                  size: 32,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _flagOrIcon(City city, SurfacePalette palette) {
    final flag = countryFlag(city.countryCode);
    return flag == null
        ? Icon(Icons.location_city_rounded, color: palette.accent)
        : Text(flag, style: const TextStyle(fontSize: 22));
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0, -0.5),
      child: TactileSurface(
        circle: true,
        child: SizedBox.square(
          dimension: 64,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}

class _FailureMessage extends StatelessWidget {
  const _FailureMessage({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: const Alignment(0, -0.5),
      child: SingleChildScrollView(
        child: StatusMessage(
          visual: StatusIcon(failure.icon, color: context.palette.warning),
          title: failure.title(l10n),
          message: failure.message(l10n),
          // Retrying a search with no matches would give the same answer.
          actions: [
            if (failure is! CityNotFoundFailure)
              TactileButton(
                label: failure.actionLabel(l10n),
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                isPrimary: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.cities, required this.onCitySelected});

  final List<City> cities;
  final ValueChanged<City> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: cities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final city = cities[index];
        // Keyed by city: new results cascade in, ones already shown stay.
        return StaggeredEntrance(
          key: ValueKey(city),
          index: index,
          step: const Duration(milliseconds: 45),
          child: CityResultTile.city(
            city: city,
            onTap: () => onCitySelected(city),
          ),
        );
      },
    );
  }
}

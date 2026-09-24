import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/widgets/gradient_background.dart';
import 'package:nimbus/core/widgets/status_message.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/city_search_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/city_search_state.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/utils/failure_display.dart';
import 'package:nimbus/features/weather/presentation/widgets/city_result_tile.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  /// The search cubit lives only as long as this route.
  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
        create: (context) => CitySearchCubit(
          weatherRepository: context.read<WeatherRepository>(),
        ),
        child: const CitySearchScreen(),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
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

  void _selectCity(City city) {
    unawaited(context.read<WeatherCubit>().selectCity(city));
    Navigator.of(context).pop();
  }

  void _useCurrentLocation() {
    unawaited(context.read<WeatherCubit>().useCurrentLocation());
    Navigator.of(context).pop();
  }

  void _clearQuery() {
    _queryController.clear();
    context.read<CitySearchCubit>().queryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<CitySearchCubit>();

    return Scaffold(
      body: GradientBackground(
        colors: AppColors.brandGradient,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
                child: Row(
                  children: [
                    const BackButton(),
                    Expanded(
                      child: _SearchField(
                        controller: _queryController,
                        onChanged: searchCubit.queryChanged,
                        onSubmitted: searchCubit.submit,
                        onClear: _clearQuery,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: CityResultTile(
                  title: AppStrings.currentLocation,
                  subtitle: AppStrings.currentLocationSubtitle,
                  leading: const Icon(Icons.my_location_rounded),
                  onTap: _useCurrentLocation,
                ),
              ),
              Expanded(
                child: BlocBuilder<CitySearchCubit, CitySearchState>(
                  builder: (context, state) => _SearchResults(
                    state: state,
                    onCitySelected: _selectCity,
                    onRetry: searchCubit.retry,
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      autocorrect: false,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: AppStrings.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        // Rebuilds only the clear button as the text changes.
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: AppStrings.clearSearch,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.state,
    required this.onCitySelected,
    required this.onRetry,
  });

  final CitySearchState state;
  final ValueChanged<City> onCitySelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    return switch (state.status) {
      CitySearchStatus.idle => const _Hint(),
      CitySearchStatus.loading when state.results.isEmpty => const Center(
        child: CircularProgressIndicator(),
      ),
      CitySearchStatus.failure when failure != null => _FailureMessage(
        failure: failure,
        onRetry: onRetry,
      ),
      _ => _ResultList(
        cities: state.results,
        isLoading: state.status == CitySearchStatus.loading,
        onCitySelected: onCitySelected,
      ),
    };
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0, -0.4),
      child: StatusMessage(
        visual: StatusIcon(Icons.travel_explore_rounded),
        title: AppStrings.searchHint,
        message: AppStrings.searchIdleMessage,
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
    return Align(
      alignment: const Alignment(0, -0.4),
      child: SingleChildScrollView(
        child: StatusMessage(
          visual: StatusIcon(failure.icon),
          title: failure.title,
          message: failure.message,
          // Retrying a search with no matches would give the same answer.
          actions: [
            if (failure is! CityNotFoundFailure)
              FilledButton(
                onPressed: onRetry,
                child: Text(failure.actionLabel),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.cities,
    required this.isLoading,
    required this.onCitySelected,
  });

  final List<City> cities;
  final bool isLoading;
  final ValueChanged<City> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 2,
          child: isLoading ? const LinearProgressIndicator(minHeight: 2) : null,
        ),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              20 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: cities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final city = cities[index];
              return CityResultTile.city(
                key: ValueKey(city),
                city: city,
                onTap: () => onCitySelected(city),
              );
            },
          ),
        ),
      ],
    );
  }
}

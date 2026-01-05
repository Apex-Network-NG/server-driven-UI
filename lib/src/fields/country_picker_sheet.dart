import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:sdui/src/config/country/country.dart';
import 'package:sdui/src/config/country/country_service.dart';
import 'package:sdui/src/fields/search_field.dart';
import 'package:sdui/src/util/sdui_form.dart';

class CountryPickerSheet extends StatefulWidget {
  final SDUIField field;
  final Country? selectedCountry;

  const CountryPickerSheet({
    super.key,
    required this.field,
    this.selectedCountry,
  });

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final countries = ValueNotifier<List<Country>>([]);
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _searchedCountries = ValueNotifier<List<Country>>([]);
  final _scrollController = ScrollController();

  @override
  void initState() {
    final allCountries = CountryService().getAll();
    final allowedCountries = widget.field.constraints?.allowedCountries ?? [];
    final excludedCountries =
        widget.field.constraints?.disallowedCountries ?? [];
    final codeType = widget.field.constraints?.codeType ?? "";

    countries.value = allCountries.where((x) {
      final xIso = x.countryCode;
      final xIso3 = x.iso3Code;
      final type = codeType == 'alpha_2' ? xIso : xIso3;
      if (allowedCountries.isNotEmpty && excludedCountries.isNotEmpty) {
        return allowedCountries.contains(type);
      } else {
        if (allowedCountries.isNotEmpty) {
          return allowedCountries.contains(type);
        } else if (excludedCountries.isNotEmpty) {
          return !excludedCountries.contains(type);
        } else {
          return true;
        }
      }
    }).toList();
    super.initState();
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      final codeType = widget.field.constraints?.codeType ?? "";
      final searchedCountries = countries.value.where((country) {
        final name = country.name.toLowerCase();
        final isoCode = country.countryCode.toLowerCase();
        final iso3Code = country.iso3Code.toLowerCase();
        final type = codeType == 'alpha_2' ? isoCode : iso3Code;
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || type.contains(searchQuery);
      }).toList();
      _searchedCountries.value = searchedCountries;
    } else {
      _searchedCountries.value = [];
    }
  }

  @override
  void dispose() {
    countries.dispose();
    _searchController.dispose();
    _searchedCountries.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * .8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListenableBuilder(
            listenable: Listenable.merge([
              _searchedCountries,
              countries,
              _searchController,
            ]),
            builder: (context, _) {
              final isSearching = _searchController.text.trim().isNotEmpty;
              final searched = _searchedCountries.value;
              final originalList = this.countries.value;
              final countries = isSearching ? searched : originalList;
              final selectedCountry = widget.selectedCountry;
              final searchEmpty = isSearching && countries.isEmpty;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Topbar(title: 'Select Country'),
                  _SearchField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: switch (searchEmpty) {
                        true => EmptyDetailComponent(
                          header: 'No Country Found',
                          label:
                              "We found no country that matches your search query",
                        ),
                        _ => RawScrollbar(
                          thickness: 5,
                          thumbVisibility: true,
                          controller: _scrollController,
                          thumbColor: theme.colorScheme.surfaceContainerHighest,
                          minThumbLength: 85,
                          radius: const Radius.circular(3),
                          padding: const EdgeInsets.only(right: 4),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            controller: _scrollController,
                            itemCount: countries.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12),
                            itemBuilder: (_, index) {
                              final country = countries[index];
                              bool isSelected = false;
                              if (widget.field.constraints?.codeType ==
                                  'alpha_2') {
                                final code = country.countryCode;
                                isSelected =
                                    selectedCountry?.countryCode == code;
                              } else {
                                final code = country.iso3Code;
                                isSelected = selectedCountry?.iso3Code == code;
                              }

                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context, country);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleFlag(country.countryCode, size: 24),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          country.name,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: theme.colorScheme.primary,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class Topbar extends StatelessWidget {
  final String title;
  const Topbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.cancel,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchField(
      hintText: 'Search Country',
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }
}

class EmptyDetailComponent extends StatelessWidget {
  final String header;
  final String label;

  const EmptyDetailComponent({
    super.key,
    required this.header,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, con) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.dangerous, size: 70),
              SizedBox(height: 16),
              Text(
                header,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eam/features/8_location/presentation/bloc/location_bloc.dart';
import 'package:searchfield/searchfield.dart';

import '../../../../core/utils/extensions/widget_extension.dart';
import '../../../../core/utils/methods.dart';
import '../../../7_assets/presentation/bloc/single_asset_cubit.dart';
import '../bloc/service_request/name_bloc.dart';

class NameDropDownSearchField extends StatefulWidget {
  final TextEditingController controller;
  final dynamic Function(SearchFieldListItem<String>) onSuggestionTap;
  final SearchFieldListItem<String>? initialValue;
 // final String assetId;

  const NameDropDownSearchField(
      {super.key,
        required this.controller,
        required this.onSuggestionTap,
        this.initialValue,
        //required this.assetId
      });

  @override
  State<NameDropDownSearchField> createState() => _NameDropDownSearchFieldState();
}

class _NameDropDownSearchFieldState extends State<NameDropDownSearchField> {
  final NameBloc _nameBloc = NameBloc();
  //final SingleAssetCubit _assetBloc = SingleAssetCubit();

  @override
  void initState() {
    _nameBloc.fetchName();
    // _assetBloc.fetchAssetsById(widget.assetId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NameBloc(),
        ),
        // BlocProvider(
        //   create: (context) => SingleAssetCubit(),
        // ),
      ],
      child: Column(
        children: [
          BlocBuilder<NameBloc, NameState>(
            bloc: _nameBloc,
            builder: (context, state) {
              if (state is NameLoadingState) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              if (state is NameLoadedState) {
                return SearchField(
                  controller: widget.controller,
                  initialValue: widget.initialValue,
                  // textInputAction: TextInputAction.next,
                  searchInputDecoration: const InputDecoration(
                    label: Text("ServiceRequestName"),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                    border: OutlineInputBorder(),
                  ),
                  suggestions: state.name
                      .map(
                        (e) => SearchFieldListItem(
                      "${e.Name?.capitalize()}",
                      item: e.id,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "${e.Name}",
                          style:
                          const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                  onSuggestionTap: widget.onSuggestionTap,
                  suggestionsDecoration: SuggestionDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), //color of shadow
                        spreadRadius: 2, //spread radius
                        blurRadius: 5, // blur radius
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  validator: (x) {
                    final name = state.name
                        .map((e) => "${e.Name?.capitalize()}")
                        .toList();
                    print("name are : $name");
                    print("Loaca field x is $x");
                    if (x!.isEmpty || isNotContained(name, x)) {
                      return 'Please Enter a Valid Name';
                    }
                    return null;
                  },
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}

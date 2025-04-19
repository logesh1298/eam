import 'dart:core';

import 'package:eam/features/4_service_request/service_request_data/work_type.dart';
import 'package:eam/features/4_service_request/service_request_presentation/bloc/service_request/worktypes_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eam/core/utils/extensions/widget_extension.dart';
import 'package:eam/features/10_work_type/presentation/bloc/work_type_cubit.dart';
import 'package:searchfield/searchfield.dart';

import '../../../../core/utils/methods.dart';
import '../../../10_work_type/data/workType.dart';

class WorkTypesDropDownSearchField extends StatefulWidget {
  final TextEditingController controller;
  final dynamic Function(SearchFieldListItem<String>) onSuggestionTap;
  const WorkTypesDropDownSearchField(
      {super.key, required this.controller, required this.onSuggestionTap});

  @override
  State<WorkTypesDropDownSearchField> createState() => _WorkTypesDropDownSearchFieldState();
}

class _WorkTypesDropDownSearchFieldState extends State<WorkTypesDropDownSearchField> {
  final WorkTypesBloc _workTypesBloc = WorkTypesBloc();

  @override
  void initState() {
    _workTypesBloc.fetchWorkTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkTypesBloc(),
      child: BlocBuilder<WorkTypesBloc, WorkTypesState>(
        bloc: _workTypesBloc,
        builder: (context, state) {
          if (state is WorkTypesLoadingState) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (state is WorkTypesLoadedState) {
            List<WorkTypes> list = state.workType;
            List<WorkTypes> filteredList =
            list.whereIndexed((index, element) => index == 1 || index == 3).toList();

            return SearchField<String>(
              controller: widget.controller,
              textInputAction: TextInputAction.done,
              searchInputDecoration: const InputDecoration(
                label: Text("Work Type"),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: OutlineInputBorder(),
              ),
              suggestions: filteredList
                  .map(
                    (e) => SearchFieldListItem(
                  e.workTypeName ?? "",
                  item: e.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      e.workTypeName ?? "",
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
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
                final workTypes = state.workType.map((e) => e.workTypeName).toList();
                if (x!.isEmpty || isNotContained(workTypes, x)) {
                  return 'Please Enter a Valid WorkType';
                }
                return null;
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}

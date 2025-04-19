import 'package:eam/core/utils/extensions/build_context/local.dart';
import 'package:eam/features/13_parts/presentation/bloc/parts_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../2_workorder/3_wo_presentation/view/calender_page.dart';
import '../../../4_service_request/service_request_presentation/widgets/appbar_search_filed.dart';
import '../widget/part_sort_by_widget.dart';

class PartsPage extends StatefulWidget {
  const PartsPage({super.key});

  @override
  State<PartsPage> createState() => _PartsPageState();
}

class _PartsPageState extends State<PartsPage> {

  List<CheckBoxListTileModel> checkBoxListTileModel = CheckBoxListTileModel.getUsers();

  final PartsBloc _bloc = PartsBloc();


  @override
  void initState() {
    _bloc.fetchParts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartsBloc(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Material(
            elevation: 2,
            child: Container(
              decoration: const BoxDecoration(),
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      context.local.parts,
                      style: const TextStyle(color: Colors.black),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),

                  /* ------------------ 1_Search Field ------------------ */

                  const AppBarSearchField(title: "Search all Parts"),
                  const SizedBox(
                    height: 10,
                  ),
                  /* ------------------ Sort By Section ------------------ */

                  BlocBuilder<PartsBloc, PartsState>(
                    bloc: _bloc,
                    builder: (context, state) {
                      if (state is PartsLoadingState) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }
                      if (state is PartsLoadedState) {
                        return PartSortByWidget(
                          checkBoxListTileModel: checkBoxListTileModel,
                          results: state.parts.length > 1
                              ? " ${state.parts.length} Results"
                              : " ${state.parts.length} Result",
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: BlocConsumer<PartsBloc, PartsState>(
          bloc: _bloc,
          listener: (BuildContext context, PartsState state) {
            if (state is PartsErrorState) {
              SnackBar snackBar = SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          builder: (BuildContext context, state) {
            if (state is PartsLoadingState) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            if (state is PartsLoadedState) {
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    /////////////////////////// SERVICE REQUEST LISTS \\\\\\\\\\\\\\\\\\\\\\
                    Expanded(
                      child: Scrollbar(
                        child: ListView.separated(
                          itemCount: state.parts.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                context.push('/PartDetail', extra: state.parts[index]);


                              },
                              child: Card(
                                margin: const EdgeInsets.all(4),
                                semanticContainer: false,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      /////////////////////////// SERVICE REQUEST TITLE \\\\\\\\\\\\\\\\\\\\\\
                                      Text(
                                        state.parts[index].partName ?? "",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.qr_code_2_outlined,
                                            color: Colors.grey.shade600,
                                            size: 18,
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            state.parts[index].code ?? "PartCode",
                                            style: TextStyle(color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      // Row(
                                      //   children: [
                                      //     Icon(
                                      //       Icons.location_on_outlined,
                                      //       color: Colors.grey.shade600,
                                      //       size: 18,
                                      //     ),
                                      //     const SizedBox(
                                      //       width: 6,
                                      //     ),
                                      //     Text(
                                      //       state.parts[index].partId ?? "MaxQuantity",
                                      //       style: TextStyle(color: Colors.grey.shade600),
                                      //     ),
                                      //   ],
                                      // ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: Text("An error Occurred!"),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eam/features/4_service_request/service_request_domain/worktypeapi.dart';
import 'package:eam/features/4_service_request/service_request_presentation/widgets/worktypedropdown_field.dart';
import 'package:http/http.dart' as http;

import 'package:eam/features/4_service_request/service_request_presentation/widgets/sr_details_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eam/core/utils/extensions/build_context/local.dart';
import 'package:eam/core/utils/extensions/widget_extension.dart';
import 'package:eam/core/utils/gaps.dart';
import 'package:eam/features/11_problem/presentation/bloc/problem_bloc.dart';
import 'package:eam/features/11_problem/presentation/bloc/problem_cubit.dart';
import 'package:eam/features/4_1_service_request_details/service_request_details_presentation/view/service_request_details_page.dart';
import 'package:eam/features/4_service_request/service_request_domain/service_request_repo.dart';
import 'package:eam/features/4_service_request/service_request_presentation/widgets/failure_class_dropdown_search_field.dart';
import 'package:eam/features/4_service_request/service_request_presentation/widgets/mobile_scanner.dart';
import 'package:eam/features/4_service_request/service_request_presentation/widgets/problem_code_dropdown_search_field.dart';
import 'package:eam/features/4_service_request/service_request_presentation/widgets/work_type_dropdown_search_field.dart';
import 'package:eam/features/7_assets/presentation/bloc/asset_cubit.dart';
import 'package:eam/features/7_assets/presentation/bloc/single_asset_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/dependency_injection/di_container.dart';
import '../../../2_workorder/domain/entities/workorder.dart';
import '../../../7_assets/domain/asset_repo.dart';
import '../../service_request_data/service_request.dart';
import '../../service_request_data/work_type.dart';
import '../../service_request_domain/add_service_request_api.dart';
import '../bloc/service_request/service_request_bloc.dart';
import '../bloc/service_request/service_request_state.dart';
import '../widgets/asset_dropdown_field.dart';
import '../widgets/location_dropdown_field.dart';
import '../widgets/name_dropdown_field.dart';

class ServiceRequestPage extends StatefulWidget {
  // final ServiceRequest id;
  //
  // const ServiceRequestPage({super.key, required this.id});
  const ServiceRequestPage({super.key});

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  List<Map<String, dynamic>> serviceRequestDocuments = [];
  bool isLoadingDocuments = false;
  int filesCount = 0;

// Add this method to fetch documents for a service request
  Future<void> fetchServiceRequestDocuments(String serviceRequestId) async {
    if (mounted) setState(() => isLoadingDocuments = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? bearerToken = prefs.getString('bearer_token');

      final response = await http.get(
        Uri.parse('https://demoapi.orienseam.com/api/servicerequest/getdocumentbysrid/$serviceRequestId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            serviceRequestDocuments = List<Map<String, dynamic>>.from(data['result'] ?? []);
            filesCount = serviceRequestDocuments.length;
          });
        }
      }
    } catch (e) {
      print('Error fetching service request documents: $e');
    } finally {
      if (mounted) setState(() => isLoadingDocuments = false);
    }
  }




  //edit
  // void _openEditDialog(BuildContext context, ServiceRequest request) {
  //   // Initialize controllers with existing values
  //   nameController.text = request.serviceRequestName ?? '';
  //   descriptionController.text = request.description ?? '';
  //   assetController.text = request.assetName ?? '';
  //   locationController.text = request.locationName ?? '';
  //   failureClassController.text = request.failureClassName ?? '';
  //   problemController.text = request.problemName ?? '';
  //   //workTypeController.text = request.workTypeName ?? '';
  //   requestedDateController.text = request.requestedDate?.toIso8601String() ?? '';
  //   stopBeginDateController.text = request.stopBeginDate?.toIso8601String() ?? '';
  //   AddServiceRequestApi UpdateServiceRequest =
  //   AddServiceRequestApi(dioManager: sl());
  //
  //   // Store the request ID for updating
  //   String serviceRequestId = request.id ?? '';
  //   String servicerequestnameId = request.servicerequestNameId??'';
  //   String Code = request.code??'';
  //   String failureClassId= request.failureClassId??'';
  //   String problemId =request.problemId??'';
  //   String locationId =request.locationId??'';
  //   String assetId =request.assetId??'';
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Edit Service Request'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextFormField(
  //                 controller: nameController,
  //                 decoration: const InputDecoration(labelText: 'Service Request Name'),
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: descriptionController,
  //                 decoration: const InputDecoration(labelText: 'Description'),
  //                 maxLines: 3,
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: assetController,
  //                 decoration: const InputDecoration(labelText: 'Asset'),
  //                 readOnly: true,
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: locationController,
  //                 decoration: const InputDecoration(labelText: 'Location'),
  //                 readOnly: true,
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: failureClassController,
  //                 decoration: const InputDecoration(labelText: 'Failure Class'),
  //                 readOnly: true,
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: problemController,
  //                 decoration: const InputDecoration(labelText: 'Problem'),
  //                 readOnly: true,
  //               ),
  //               // const SizedBox(height: 10),
  //               // TextFormField(
  //               //   controller: workTypeController,
  //               //   decoration: const InputDecoration(labelText: 'Work Type'),
  //               //   readOnly: true,
  //               // ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: requestedDateController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Requested Date',
  //                   suffixIcon: Icon(Icons.calendar_today),
  //                 ),
  //                 readOnly: true,
  //                 onTap: () async {
  //                   DateTime? pickedDate = await showDatePicker(
  //                     context: context,
  //                     initialDate: DateTime.now(),
  //                     firstDate: DateTime(2000),
  //                     lastDate: DateTime(2100),
  //                   );
  //                   if (pickedDate != null) {
  //                     requestedDateController.text = pickedDate.toIso8601String();
  //                   }
  //                 },
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: stopBeginDateController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Stop Begin Date',
  //                   suffixIcon: Icon(Icons.calendar_today),
  //                 ),
  //                 readOnly: true,
  //                 onTap: () async {
  //                   DateTime? pickedDate = await showDatePicker(
  //                     context: context,
  //                     initialDate: DateTime.now(),
  //                     firstDate: DateTime(2000),
  //                     lastDate: DateTime(2100),
  //                   );
  //                   if (pickedDate != null) {
  //                     stopBeginDateController.text = pickedDate.toIso8601String();
  //                   }
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               final data = {
  //                 "id": serviceRequestId,
  //                 "serviceRequestName": nameController.text,
  //                 "code":Code,
  //
  //                 "status": "NEW",
  //               "failureClassId": failureClassId,
  //               "problemId": problemId,
  //               "assetId": assetId,
  //               "locationId":locationId,
  //               "serviceRequestNameId":servicerequestnameId,
  //
  //               "description": descriptionController.text,
  //                 "requestedDate": requestedDateController.text,
  //                 "stopBeginDate": stopBeginDateController.text,
  //               };
  //
  //               try {
  //                 await UpdateServiceRequest.updateServiceRequest(data);
  //
  //                 if (context.mounted) {
  //                   Navigator.pop(context);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('Service request updated successfully')),
  //                   );
  //                   // Refresh the list
  //
  //                   _bloc.fetchServiceRequest();
  //                 }
  //               } catch (e) {
  //                 if (context.mounted) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Error updating service request: $e')),
  //                   );
  //                 }
  //               }
  //             },
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //
  //   );
  // }


//edit
  final ServiceRequestBloc _bloc = ServiceRequestBloc(sl<ServiceRequestRepo>());

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController failureClassController = TextEditingController();
  TextEditingController problemController = TextEditingController();
  TextEditingController workTypeController = TextEditingController();
  TextEditingController requestedDateController = TextEditingController();
  TextEditingController stopBeginDateController = TextEditingController();
  TextEditingController cmController = TextEditingController(text: "CM");

  AddServiceRequestApi createServiceRequest =
      AddServiceRequestApi(dioManager: sl());

  // AddServiceRequestApi createServiceRequestdoc =
  // AddServiceRequestApi(dioManager: sl());


  final FocusNode focusNode = FocusNode();
  final FocusScopeNode _node = FocusScopeNode();
  List<ServiceRequest> serviceReq = [];
  List<ServiceRequest> filteredServiceReq = [];
  final TextEditingController _searchController = TextEditingController();

  List<String> sortOptions = ["New", "Wocreated","Can"];
  String? selectedServiceRequest;

  void _onFilterApplied(List<ServiceRequest> filteredOrders) {
    setState(() {
      filteredServiceReq = filteredOrders;
    });
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Column(
              children: [Text("Please Choose an option"), Divider()],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          _getImageFromCamera();
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text("Camera")),
                    ElevatedButton.icon(
                        onPressed: () {
                          _getImageFromGallery();
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: const Text("Gallery")),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    _bloc.fetchServiceRequest();

    super.initState();
    fetchServiceRequestDocuments;


  }

  @override
  void dispose() {
    _bloc.close();
    focusNode.dispose();
    _node.dispose();

    //Clear
    nameController.clear();
    descriptionController.clear();
    assetController.clear();
    locationController.clear();
    failureClassController.clear();
    problemController.clear();
    workTypeController.clear();
    //Dispose
    nameController.dispose();
    descriptionController.dispose();
    assetController.dispose();
    locationController.dispose();
    failureClassController.dispose();
    problemController.dispose();
    workTypeController.dispose();
    cmController.dispose();
    super.dispose();
  }

  void filterRequests(String status) {
    setState(() {
      if (status == "All") {
        filteredServiceReq = serviceReq;
      } else {
        if (selectedServiceRequest == "All") {
          filteredServiceReq = filteredServiceReq
              .where((request) => request.status == status)
              .toList();
        } else {
          filteredServiceReq =
              serviceReq.where((request) => request.status == status).toList();
        }
      }
      selectedServiceRequest = status.capitalize();
    });
  }

  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getUsers();

  int differenceInDays(int? index, state) {
    final date = DateFormat("yyyy-MM-dd")
        .format(state.serviceRequests[index].createdDate);
    final createdDate = DateTime.parse(date);
    final currentDate = DateTime.now();
    final days = (currentDate.difference(createdDate).inDays).round();
    return days;
  }

  int differenceInWeeks(int? index, state) {
    final date = DateFormat("yyyy-MM-dd")
        .format(state.serviceRequests[index].requestedDate);
    final requestedDate = DateTime.parse(date);
    final currentDate = DateTime.now();
    final weeks = (currentDate.difference(requestedDate).inDays / 7).round();
    return weeks;
  }

/////////////////////////// BUILD METHOD \\\\\\\\\\\\\\\\\\\\\\\\\\
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey.shade200,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(240),
            child: Material(
              elevation: 4,
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      context.local.service_request,
                      style: const TextStyle(color: Colors.black),
                    ),
                    // actions: [
                    //   IconButton(
                    //     icon: const Icon(Icons.refresh_rounded),
                    //     onPressed: () {_searchController.clear();
                    //     setState(() {
                    //       filteredServiceReq = [];
                    //       selectedServiceRequest = null;
                    //     });
                    //     // Trigger refresh
                    //     _bloc.fetchServiceRequest();}
                    //   ),
                    // ],
                    centerTitle: true,
                    backgroundColor: Colors.white,
                  ),

                  /* ------------------ 1_Search Field ------------------ */
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _searchSearvice(value, serviceReq),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                          // Added this
                          contentPadding: const EdgeInsets.all(8),
                          hintText: "Search By SR Name or Code",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        suffixIcon: _searchController.text.isNotEmpty // Check controller text
                            ? IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: _clearSearch,
                          color: Colors.grey.shade400,
                        )
                            : null,
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 30,
                          ),
                          prefixIconColor: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 10),
                  /* ------------------ 2_Filters Section ------------------ */
                  Row(
                    children: sortOptions
                        .map(
                          (category) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: selectedServiceRequest == category,
                              onSelected: (selected) {
                                setState(() {
                                  filterRequests(selected
                                      ? category.toUpperCase()
                                      : "All");
                                });
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  /* ------------------ Sort By Section ------------------ */
                  SortBySection(
                    checkBoxListTileModel: checkBoxListTileModel,
                    filteredReq: filteredServiceReq,
                    onFiltered: _onFilterApplied,
                  ),
                  const SizedBox(height: 5),
                ],

              ),
            ),
          ),
          floatingActionButton: Align(
            alignment: const Alignment(1, 0.95),
            child: FloatingActionButton.small(
              onPressed: () {
                buildAddRequestPopUp(context);
              },
              child: const Icon(Icons.add),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          /////////////////////////// BODY \\\\\\\\\\\\\\\\\\\\\\\\\\
          body: BlocConsumer<ServiceRequestBloc, ServiceRequestState>(

            bloc: _bloc,
            listener: (BuildContext context, ServiceRequestState state) {
              if (state is ServiceRequestErrorState) {
                SnackBar snackBar = SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              if (state is ServiceRequestLoadingState) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }

              if (state is ServiceRequestLoadedState) {
                serviceReq = state.serviceRequests;
                if (filteredServiceReq.isEmpty) {
                  filteredServiceReq = state.serviceRequests;
                }
                if (filteredServiceReq.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      children: [
                        /////////////////////////// SERVICE REQUEST LISTS \\\\\\\\\\\\\\\\\\\\\\\\\\
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredServiceReq.length,
                            itemBuilder: (context, index) {

                              int days = differenceInDays(index, state);
                              int weeks = differenceInWeeks(index, state);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ServiceRequestDetailsPage(
                                        serviceRequest:
                                            state.serviceRequests[index],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.all(10),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green[400]!,
                                                Colors.green[600]!
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: Text(
                                            filteredServiceReq[index].status ??
                                                "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.5,
                                              child: Text(
                                                filteredServiceReq[index]
                                                        .serviceRequestName ??
                                                    "",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'Aeon',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "#${filteredServiceReq[index].code?.trim()}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Aeon',
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(color: Colors.grey[300]),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.75,
                                          child: Text(
                                            filteredServiceReq[index]
                                                        .description ==
                                                    null
                                                ? ""
                                                : filteredServiceReq[index]
                                                        .description ??
                                                    "",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Aeon',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),



                                        /* ------------------ Other Details - First Line ------------------ */
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${filteredServiceReq[index].locationName ?? ""} ",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Aeon',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        /* ------------------ Other Details - Second Line ------------------ */

                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.business_center,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width:
                                              MediaQuery.sizeOf(context).width * 0.75,
                                              child: Text(
                                                "${filteredServiceReq[index].assetName ?? ""} ",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Aeon',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),


                                        /* ------------------ Other Details - Last Line ------------------ */
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              (() {
                                                if (days <= 1) {
                                                  return "$days Day ago";
                                                } else if (days > 1 &&
                                                    days <= 7) {
                                                  return "$days Days ago";
                                                } else if (days >= 7) {
                                                  return "$weeks Week ago";
                                                } else if (days >= 14) {
                                                  return "$weeks Weeks ago";
                                                } else {
                                                  return "";
                                                }
                                              })(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // Container(
                                            //   decoration: BoxDecoration(
                                            //     gradient: LinearGradient(
                                            //       colors: [Colors.green[400]!, Colors.green[600]!],
                                            //       begin: Alignment.topLeft,
                                            //       end: Alignment.bottomRight,
                                            //     ),
                                            //     borderRadius: BorderRadius.circular(6),
                                            //   ),
                                            //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            //   // child: Text(
                                            //   //   filteredServiceReq[index].status ?? "",
                                            //   //   style: const TextStyle(
                                            //   //     color: Colors.white,
                                            //   //     fontWeight: FontWeight.bold,
                                            //   //     fontSize: 10,
                                            //   //   ),
                                            //   // ),
                                            // ),
                                            if (filteredServiceReq[index].status == "NEW")
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 20), // Reduce icon size
                                                onPressed: () async {
                                                  await fetchServiceRequestDocuments(filteredServiceReq[index].id!);
                                                  buildAddRequestPopUp(context, requestToEdit: filteredServiceReq[index]);
                                                },
                                              ),


                                          ],
                                        ),


                                        // Container(
                                        //   constraints: const BoxConstraints(
                                        //     maxWidth: 250, // Set maximum width
                                        //     maxHeight: 120, // Set maximum height
                                        //   ),
                                        //   child: Card(
                                        //     margin: const EdgeInsets.all(6), // Reduce margin
                                        //     elevation: 6, // Lower elevation
                                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.all(6), // Reduce padding
                                        //       child: Column(
                                        //         mainAxisSize: MainAxisSize.min,
                                        //         crossAxisAlignment: CrossAxisAlignment.start,
                                        //         children: [
                                        //           Row(
                                        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //             children: [
                                        //               // Container(
                                        //               //   decoration: BoxDecoration(
                                        //               //     gradient: LinearGradient(
                                        //               //       colors: [Colors.green[400]!, Colors.green[600]!],
                                        //               //       begin: Alignment.topLeft,
                                        //               //       end: Alignment.bottomRight,
                                        //               //     ),
                                        //               //     borderRadius: BorderRadius.circular(6),
                                        //               //   ),
                                        //               //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        //               //   // child: Text(
                                        //               //   //   filteredServiceReq[index].status ?? "",
                                        //               //   //   style: const TextStyle(
                                        //               //   //     color: Colors.white,
                                        //               //   //     fontWeight: FontWeight.bold,
                                        //               //   //     fontSize: 10,
                                        //               //   //   ),
                                        //               //   // ),
                                        //               // ),
                                        //               if (filteredServiceReq[index].status == "NEW")
                                        //                 IconButton(
                                        //                   icon: const Icon(Icons.edit, size: 16), // Reduce icon size
                                        //                   onPressed: () {
                                        //                     _openEditDialog(context, filteredServiceReq[index]);
                                        //                   },
                                        //                 ),
                                        //             ],
                                        //           ),
                                        //           // Other card content...
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // )




                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  const Center(
                    child: Text("No Data Available"),
                  );
                }
              }
              return const Center(
                child: Icon(Icons.refresh),
              );
            },
          ),
        ),
      ),
    );
  }

  /////////////////////////// BUILD ADD REQUEST POP UP \\\\\\\\\\\\\\\\\\\\\\\\\\
  // Replace your buildAddRequestPopUp method with this updated version
  Future<dynamic> buildAddRequestPopUp(BuildContext context, {ServiceRequest? requestToEdit}) {
    BarcodeCapture? barcode;
    String scanValue;
    FilePickerResult? result;
    List<String> fileStr = [];
    List<Map<String, dynamic>> serviceRequestDocuments = [];
    //int filesCount = 0;

    // If editing, fetch documents
    if (requestToEdit != null && requestToEdit.id != null) {
      fetchServiceRequestDocuments(requestToEdit.id!).then((_) {
        setState(() {
          serviceRequestDocuments = this.serviceRequestDocuments;
          filesCount = this.filesCount;
        });
      });
    }

    List<Map<String, dynamic>> uploadedFiles = [];

    final _formKey = GlobalKey<FormState>();
    Future<List<WorkTypes>> fetchWorkTypes() async {
      final workTypeRepo = WorkTypeRepository(dioManager: sl());
      return await workTypeRepo.getWorkTypes();
    };
    // Future<List<WorkTypes>> fetchWorkTypes() async {
    //   // Hardcoded EM and CM work types
    //   final hardcodedWorkTypes = [
    //     WorkTypes(
    //       id: 'd707dbff-d08f-42a8-afa1-12b2e48c266c',
    //       workTypeName: 'CM',
    //       description: 'Corrective Maintenance',
    //       code: 'CM01',
    //     ),
    //     WorkTypes(
    //       id: 'c181e39f-66e9-45ae-89ba-7fd45edfabf0',
    //       workTypeName: 'EM',
    //       description: 'Emergency Maintenance',
    //       code: 'CM01',
    //     ),
    //   ];
    //
    //   try {
    //     // Fetch work types from API if needed
    //     final workTypeRepo = WorkTypeRepository(dioManager: sl());
    //     final apiWorkTypes = await workTypeRepo.getWorkTypes();
    //
    //     // Combine hardcoded and API work types
    //     return [...hardcodedWorkTypes, ...apiWorkTypes];
    //   } catch (e) {
    //     // If API fails, return just the hardcoded types
    //     return hardcodedWorkTypes;
    //   }
    // }

    // Initialize controllers based on edit mode
    if (requestToEdit != null) {
      nameController.text = requestToEdit.serviceRequestName ?? '';
      descriptionController.text = requestToEdit.description ?? '';
      assetController.text = requestToEdit.assetName ?? '';
      locationController.text = requestToEdit.locationName ?? '';
      failureClassController.text = requestToEdit.failureClassName ?? '';
      problemController.text = requestToEdit.problemName ?? '';
      requestedDateController.text = requestToEdit.requestedDate?.toIso8601String() ?? '';
      stopBeginDateController.text = requestToEdit.stopBeginDate?.toIso8601String() ?? '';

      // Initialize IDs for edit mode
      String assetID = requestToEdit.assetId ?? '';
      String locationID = requestToEdit.locationId ?? '';
      String failureClassID = requestToEdit.failureClassId ?? '';
      String problemID = requestToEdit.problemId ?? '';
      String servicerequestnameId = requestToEdit.servicerequestNameId ?? '';
    }

    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AssetBloc(),
              ),
              BlocProvider(
                create: (context) => SingleAssetCubit(),
              ),
              BlocProvider(
                create: (context) => ProblemCubit(),
              ),
            ],
            child: BlocConsumer<AssetBloc, AssetsState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                final ProblemCubit problemCubit =
                BlocProvider.of<ProblemCubit>(context);

                final SingleAssetCubit singleAssetCubit =
                BlocProvider.of<SingleAssetCubit>(context);

                bool isAssetSelected = requestToEdit != null;
                bool isLocationSelected = requestToEdit != null;
                bool isNameSelected = requestToEdit != null;

                String failureClassID = requestToEdit?.failureClassId ?? "";
                String problem = requestToEdit?.problemId ?? "";
                String assetID = requestToEdit?.assetId ?? "";
                String locationID = requestToEdit?.locationId ?? "";
                String servicerequestnameId = requestToEdit?.servicerequestNameId ?? "";
                String servicerequestId = requestToEdit?.id ?? "";
                String workTypeValue = "";
                workTypeValue = requestToEdit?.workTypeId ?? '';
                workTypeController.text = requestToEdit?.workTypeName ?? '';

                String? singleAssetLocationCode = requestToEdit?.locationName;
                String? singleAssetFailureClassID = requestToEdit?.failureClassName;

                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        child: SizedBox(
                          height: 740,
                          child: Scaffold(
                            body: CupertinoPopupSurface(
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            nameController.clear();
                                            descriptionController.clear();
                                            assetController.clear();
                                            locationController.clear();
                                            failureClassController.clear();
                                            problemController.clear();
                                            workTypeController.clear();
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(Icons.close),
                                        ),
                                        Text(
                                          requestToEdit != null
                                              ? 'Edit Request'
                                              : 'New Request',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // IconButton(
                                        //   onPressed: () async {
                                        //     final assetValue =
                                        //     await Navigator.of(context).push(
                                        //       MaterialPageRoute(
                                        //         builder: (BuildContext context) =>
                                        //         const Scanner(),
                                        //       ),
                                        //     );
                                        //     setState(() {
                                        //       assetController.text = assetValue;
                                        //     });
                                        //   },
                                        //   icon: const Icon(
                                        //     Icons.qr_code_scanner_outlined,
                                        //     color: Colors.blue,
                                        //   ),
                                        // )
                                        // In your buildAddRequestPopUp method, modify the QR scanner icon button:
                                        IconButton(
                                          onPressed: () async {
                                            final assetValue = await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (BuildContext context) => const Scanner(),
                                              ),
                                            );

                                            if (assetValue != null && assetValue.isNotEmpty) {
                                              try {
                                                // Show loading indicator
                                                setState(() {
                                                  assetController.text = "Loading asset...";
                                                  locationController.text = "";
                                                  failureClassController.text = "";
                                                });

                                                // Fetch asset details
                                                final assetResponse = await AssetRepo.getAssetsById(assetValue);

                                                if (assetResponse.data?.result != null) {
                                                  final asset = assetResponse.data!.result!;

                                                  setState(() {
                                                    // Update all form fields with asset data
                                                    assetID = asset.id ?? '';
                                                    assetController.text = asset.assetName ?? assetValue;
                                                    locationID = asset.locationId ?? '';
                                                    locationController.text = asset.locationName ?? '';
                                                    failureClassID = asset.failureClassesId ?? '';
                                                    failureClassController.text = asset.failureClassName ?? '';

                                                    // Automatically fetch problems for this failure class
                                                    final problemCubit = BlocProvider.of<ProblemCubit>(context);
                                                    problemCubit.fetchProblems(failureClassID);
                                                  });
                                                } else {
                                                  setState(() {
                                                    assetController.text = assetValue;
                                                    assetID = assetValue;
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Asset not found')),
                                                  );
                                                }
                                              } catch (e) {
                                                setState(() {
                                                  assetController.text = assetValue;
                                                  assetID = assetValue;
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error fetching asset: $e')),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.qr_code_scanner_outlined,
                                            color: Colors.blue,
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(
                                      thickness: 2,
                                      height: 0,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Form(
                                        key: _formKey,
                                        child: FocusScope(
                                          node: _node,
                                          child: ListView(
                                            children: [
                                              NameDropDownSearchField(
                                                controller: nameController,
                                                onSuggestionTap:
                                                    (SearchFieldListItem<String> x) {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode);
                                                  setState(() {
                                                    servicerequestnameId = x.item ?? '';
                                                    isNameSelected = true;
                                                  });
                                                },
                                              ),
                                              gapH12,

                                              // Description Field
                                              TextFormField(
                                                controller: descriptionController,
                                                maxLength: 100,
                                                onEditingComplete: _node.nextFocus,
                                                decoration: const InputDecoration(
                                                  counterText: "",
                                                  label: Text("Description"),
                                                  hintText: "Description",
                                                  border: OutlineInputBorder(),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                              ),
                                              gapH12,

                                              TextFormField(
                                                readOnly: true,
                                                controller: TextEditingController(
                                                  text: requestToEdit?.status ?? "NEW", // Use existing status or default to "NEW"
                                                ),
                                                decoration: const InputDecoration(
                                                  label: Text("Status"),
                                                  border: OutlineInputBorder(),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.blue),
                                                  ),
                                                ),
                                              ),
                                              gapH12,

                                              // TextFormField(
                                              //   controller: cmController,
                                              //   readOnly: true, // Make it read-only since it's static
                                              //   decoration: const InputDecoration(
                                              //     label: Text("WorkType"),
                                              //     border: OutlineInputBorder(),
                                              //     focusedBorder: OutlineInputBorder(
                                              //       borderSide: BorderSide(color: Colors.blue),
                                              //     ),
                                              //   ),
                                              // ),
                                              // gapH12,


                                          // ... existing code ...

                                          // Replace the WorkTypeDropDownSearchField widget with this:
                                    //       FutureBuilder<List<WorkTypes>>(
                                    //       future: fetchWorkTypes(),
                                    //   builder: (context, snapshot) {
                                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                                    //       return Text('LOADING');
                                    //     } else if (snapshot.hasError) {
                                    //       return Text('Error: ${snapshot.error}');
                                    //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    //       return const Text('No work types available');
                                    //     } else {
                                    //       final workTypes = snapshot.data!;
                                    //       return DropdownButtonFormField<String>(
                                    //         value: workTypeValue.isNotEmpty ? workTypeValue : null,
                                    //         decoration: const InputDecoration(
                                    //           labelText: 'Work Type',
                                    //           border: OutlineInputBorder(),
                                    //         ),
                                    //         items: workTypes.map((workType) {
                                    //           return DropdownMenuItem<String>(
                                    //             value: workType.id,
                                    //             child: Text(workType.workTypeName),
                                    //           );
                                    //         }).toList(),
                                    //         onChanged: (value) {
                                    //           setState(() {
                                    //             workTypeValue = value ?? '';
                                    //             // You might want to store the entire work type object if needed
                                    //             final selectedWorkType = workTypes.firstWhere(
                                    //                   (type) => type.id == value,
                                    //               orElse: () => WorkTypes(
                                    //                 id: '',
                                    //                 workTypeName: '',
                                    //                 description: '',
                                    //                 code: '',
                                    //               ),
                                    //             );
                                    //             workTypeController.text = selectedWorkType.workTypeName;
                                    //           });
                                    //         },
                                    //         validator: (value) {
                                    //           if (value == null || value.isEmpty) {
                                    //             return 'Please select a work type';
                                    //           }
                                    //           return null;
                                    //         },
                                    //       );
                                    //     }
                                    //   },
                                    // ),
                                              FutureBuilder<List<WorkTypes>>(
                                                future: fetchWorkTypes(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return Text('LOADING');
                                                  } else if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                    return const Text('No work types available');
                                                  } else {
                                                    final workTypes = snapshot.data!;
                                                    return DropdownButtonFormField<String>(
                                                      value: workTypeValue.isNotEmpty ? workTypeValue : null,
                                                      decoration: const InputDecoration(
                                                        labelText: 'Work Type',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      items: workTypes.map((workType) {
                                                        return DropdownMenuItem<String>(
                                                          value: workType.id,
                                                          child: Text(workType.workTypeName),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          workTypeValue = value ?? '';
                                                          // Store the entire work type object if needed
                                                          final selectedWorkType = workTypes.firstWhere(
                                                                (type) => type.id == value,
                                                            orElse: () => WorkTypes(
                                                              id: '',
                                                              workTypeName: '',
                                                              description: '',
                                                              code: '',
                                                            ),
                                                          );
                                                          workTypeController.text = selectedWorkType.workTypeName;
                                                        });
                                                      },
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Please select a work type';
                                                        }
                                                        return null;
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                              gapH12,
                                              gapH12,
                                              // Asset Field
                                              AssetNameDropDownSearchField(
                                                controller: assetController,
                                                onSuggestionTap:
                                                    (SearchFieldListItem<String> x) async {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode);
                                                  setState(() {
                                                    assetID = x.item!;
                                                  });

                                                  AssetRepo.getAssetsById(assetID)
                                                      .then((value) {
                                                    setState(() {
                                                      isAssetSelected = true;
                                                      singleAssetLocationCode =
                                                          value.data?.result?.locationName;
                                                      locationID = value.data?.result?.locationId ?? "";
                                                      locationController.text =
                                                          singleAssetLocationCode ?? "...";
                                                      singleAssetFailureClassID =
                                                          value.data?.result?.failureClassName ?? "";
                                                      failureClassID =
                                                          value.data?.result?.failureClassesId ?? "";
                                                      failureClassController.text =
                                                          singleAssetFailureClassID ?? "...";
                                                    });
                                                    problemCubit.fetchProblems(failureClassID);
                                                  }, onError: (error, stacktrace) {
                                                    print('Error getting value: #error');
                                                  });
                                                },
                                              ),
                                              gapH12,
                                              // WorkTypesDropDownSearchField(
                                              //   controller: workTypeController,
                                              //   onSuggestionTap: (SearchFieldListItem<String> x) {
                                              //     FocusScope.of(context).requestFocus(focusNode);
                                              //     setState(() {
                                              //       workTypeValue = x.item!;
                                              //       workTypeController.text = x.searchKey;
                                              //     });
                                              //   },
                                              // ),
                                              //
                                              // gapH12,



                                              // Location Field
                                              !isAssetSelected
                                                  ? LocationDropDownSearchField(
                                                controller: locationController,
                                                onSuggestionTap:
                                                    (SearchFieldListItem<String> x) {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode);
                                                  setState(() {
                                                    locationID = x.item ?? '';
                                                    isLocationSelected = true;
                                                  });
                                                },
                                                assetId: assetID,
                                              )
                                                  : TextFormField(
                                                readOnly: true,
                                                controller: locationController,
                                                maxLength: 100,
                                                onEditingComplete: _node.nextFocus,
                                                decoration: const InputDecoration(
                                                  counterText: "",
                                                  label: Text("Location"),
                                                  hintText: "Location",
                                                  border: OutlineInputBorder(),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                              ),
                                              gapH12,



                                              // Failure Class Field
                                              !isAssetSelected
                                                  ? FailureClassDropDownSearchField(
                                                onChanged: (string) async {},
                                                controller: failureClassController,
                                                onSuggestionTap:
                                                    (SearchFieldListItem<String> x) async {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode);
                                                  setState(() {
                                                    failureClassID = x.item!;
                                                  });
                                                  problemCubit.fetchProblems(failureClassID);
                                                },
                                              )
                                                  : TextFormField(
                                                readOnly: true,
                                                controller: failureClassController,
                                                maxLength: 100,
                                                onEditingComplete: _node.nextFocus,
                                                decoration: const InputDecoration(
                                                  counterText: "",
                                                  label: Text("Failure Class"),
                                                  hintText: "Failure Class",
                                                  border: OutlineInputBorder(),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                              ),
                                              gapH12,

                                              // Problem Field
                                              BlocBuilder<ProblemCubit, OldWayProblemState>(
                                                bloc: problemCubit,
                                                builder: (context, state) {
                                                  if (state is OldWayProblemLoadingState) {
                                                    return SearchField(
                                                      hint: "Select Failure Class",
                                                      searchInputDecoration:
                                                      const InputDecoration(
                                                        label: Text("Problem"),
                                                        border: OutlineInputBorder(),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Colors.blue)),
                                                      ),
                                                      suggestions: []
                                                          .map((e) =>
                                                          SearchFieldListItem(e,
                                                              child: Text(e)))
                                                          .toList(),
                                                      onSuggestionTap: (x) {
                                                        FocusScope.of(context)
                                                            .requestFocus(focusNode);
                                                      },
                                                    );
                                                  }

                                                  if (state is OldWayProblemLoadedState) {
                                                    return ProblemsDropDownSearchField(
                                                      controller: problemController,
                                                      onSuggestionTap:
                                                          (SearchFieldListItem<String> x) {
                                                        FocusScope.of(context).unfocus();
                                                        setState(() {
                                                          problem = x.item!;
                                                        });
                                                      },
                                                      failureClassId: failureClassID,
                                                    );
                                                  }

                                                  return SearchField(
                                                    hint: "No Problem Available",
                                                    searchInputDecoration: const InputDecoration(
                                                      label: Text("Problem"),
                                                      border: OutlineInputBorder(),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.blue)),
                                                    ),
                                                    suggestions: ["No Problem Available"]
                                                        .map((e) =>
                                                        SearchFieldListItem(e,
                                                            child: Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  10.0),
                                                              child: Text(
                                                                e,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                            )))
                                                        .toList(),
                                                    onSuggestionTap: (x) {
                                                      FocusScope.of(context)
                                                          .requestFocus(focusNode);
                                                    },
                                                    suggestionsDecoration:
                                                    SuggestionDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.grey.shade400),
                                                      borderRadius:
                                                      const BorderRadius.only(
                                                        bottomRight:
                                                        Radius.circular(8),
                                                        bottomLeft:
                                                        Radius.circular(8),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 5,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    validator: (x) {
                                                      final problem = [
                                                        "No Problem Available"
                                                      ].map((e) => e).toList();

                                                      if (x!.isEmpty ||
                                                          x.contains(
                                                              "No Problem Available")) {
                                                        return 'Please Enter a Valid Problem';
                                                      }
                                                      return null;
                                                    },
                                                  );
                                                },
                                              ),
                                              gapH12,

                                              // Date Fields
                                              // Column(
                                              //   crossAxisAlignment: CrossAxisAlignment.start,
                                              //   children: [
                                              //     const Text("Requested Date"),
                                              //     TextFormField(
                                              //       controller: requestedDateController,
                                              //       readOnly: true,
                                              //       decoration: const InputDecoration(
                                              //         hintText: "Select Requested Date",
                                              //         border: OutlineInputBorder(),
                                              //         suffixIcon: Icon(Icons.calendar_today),
                                              //       ),
                                              //       onTap: () async {
                                              //         DateTime? pickedDate = await showDatePicker(
                                              //           context: context,
                                              //           initialDate: DateTime.now(),
                                              //           firstDate: DateTime(2000),
                                              //           lastDate: DateTime(2100),
                                              //         );
                                              //
                                              //         if (pickedDate != null) {
                                              //           DateTime finalDateTime = DateTime(
                                              //             pickedDate.year,
                                              //             pickedDate.month,
                                              //             pickedDate.day,
                                              //             DateTime.now().hour,
                                              //             DateTime.now().minute,
                                              //             DateTime.now().second,
                                              //           );
                                              //           requestedDateController.text =
                                              //               finalDateTime.toUtc().toIso8601String();
                                              //         }
                                              //       },
                                              //     ),
                                              //     const SizedBox(height: 16),
                                              //     const Text("Stop Begin Date"),
                                              //     TextFormField(
                                              //       controller: stopBeginDateController,
                                              //       readOnly: true,
                                              //       decoration: const InputDecoration(
                                              //         hintText: "Select Stop Begin Date",
                                              //         border: OutlineInputBorder(),
                                              //         suffixIcon: Icon(Icons.calendar_today),
                                              //       ),
                                              //       onTap: () async {
                                              //         DateTime? pickedDate = await showDatePicker(
                                              //           context: context,
                                              //           initialDate: DateTime.now(),
                                              //           firstDate: DateTime(2000),
                                              //           lastDate: DateTime(2100),
                                              //         );
                                              //
                                              //         if (pickedDate != null) {
                                              //           DateTime finalDateTime = DateTime(
                                              //             pickedDate.year,
                                              //             pickedDate.month,
                                              //             pickedDate.day,
                                              //             DateTime.now().hour,
                                              //             DateTime.now().minute,
                                              //             DateTime.now().second,
                                              //           );
                                              //           stopBeginDateController.text =
                                              //               finalDateTime.toUtc().toIso8601String();
                                              //         }
                                              //       },
                                              //     ),
                                              //   ],
                                              // ),
                                              // Date Fields with Time
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Requested Date"),
                                                  TextFormField(
                                                    controller: requestedDateController,
                                                    readOnly: true,
                                                    decoration: const InputDecoration(
                                                      hintText: "Select Requested Date & Time",
                                                      border: OutlineInputBorder(),
                                                      suffixIcon: Icon(Icons.calendar_today),
                                                    ),
                                                    onTap: () async {
                                                      DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2000),
                                                        lastDate: DateTime(2100),
                                                      );

                                                      if (pickedDate != null) {
                                                        TimeOfDay? pickedTime = await showTimePicker(
                                                          context: context,
                                                          initialTime: TimeOfDay.now(),
                                                        );

                                                        if (pickedTime != null) {
                                                          DateTime finalDateTime = DateTime(
                                                            pickedDate.year,
                                                            pickedDate.month,
                                                            pickedDate.day,
                                                            pickedTime.hour,
                                                            pickedTime.minute,
                                                          );
                                                          requestedDateController.text =
                                                              finalDateTime.toUtc().toIso8601String();
                                                        }
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text("Stop Begin Date"),
                                                  TextFormField(
                                                    controller: stopBeginDateController,
                                                    readOnly: true,
                                                    decoration: const InputDecoration(
                                                      hintText: "Select Stop Begin Date & Time",
                                                      border: OutlineInputBorder(),
                                                      suffixIcon: Icon(Icons.calendar_today),
                                                    ),
                                                    onTap: () async {
                                                      DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2000),
                                                        lastDate: DateTime(2100),
                                                      );

                                                      if (pickedDate != null) {
                                                        TimeOfDay? pickedTime = await showTimePicker(
                                                          context: context,
                                                          initialTime: TimeOfDay.now(),
                                                        );

                                                        if (pickedTime != null) {
                                                          DateTime finalDateTime = DateTime(
                                                            pickedDate.year,
                                                            pickedDate.month,
                                                            pickedDate.day,
                                                            pickedTime.hour,
                                                            pickedTime.minute,
                                                          );
                                                          stopBeginDateController.text =
                                                              finalDateTime.toUtc().toIso8601String();
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),

                                              gapH12,

                                              //Work Type Field
                                              // WorkTypeDropDownSearchField(
                                              //   controller: workTypeController,
                                              //   onSuggestionTap:
                                              //       (SearchFieldListItem<String> x) {
                                              //     FocusScope.of(context)
                                              //         .requestFocus(focusNode);
                                              //     setState(() {
                                              //       workTypeValue = x.item!;
                                              //     });
                                              //   },
                                              // ),
                                              // gapH12,

                                              // Files Section
                                              // GestureDetector(
                                              //   onTap: () {
                                              //     buildWOFilesModelPopup(context, serviceRequestDocuments);
                                              //   },
                                              //   child: WoFilesCard(
                                              //     firstLine: 'Files',
                                              //     secondLine: (filesCount) != 0
                                              //         ? "${filesCount} Files"
                                              //         : 'No Files',
                                              //     buttonTitle: 'Add Files',
                                              //     icon: null,
                                              //     onPressed: () async {
                                              //       showModalBottomSheet(
                                              //         context: context,
                                              //         builder: (context) {
                                              //           return Wrap(
                                              //             children: [
                                              //               ListTile(
                                              //                 leading: const Icon(Icons.photo_camera),
                                              //                 title: const Text('Capture Image'),
                                              //                 onTap: () async {
                                              //                   Navigator.pop(context);
                                              //                   final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                              //                   if (pickedFile != null) {
                                              //                     File imageFile = File(pickedFile.path);
                                              //                     List<int> imageBytes = await imageFile.readAsBytes();
                                              //                     String base64String = base64Encode(imageBytes);
                                              //
                                              //                     setState(() {
                                              //                       uploadedFiles.add({
                                              //                         "documentName": pickedFile.name,
                                              //                         "documentData": base64String,
                                              //                         "documentcategory": "TechnicalSpecification",
                                              //                         "documenttype": "Image"
                                              //                       });
                                              //                     });
                                              //                   }
                                              //                 },
                                              //               ),
                                              //               ListTile(
                                              //                 leading: const Icon(Icons.folder),
                                              //                 title: const Text('Pick Files (Images/PDFs)'),
                                              //                 onTap: () async {
                                              //                   Navigator.pop(context);
                                              //                   final result = await FilePicker.platform.pickFiles(
                                              //                     allowMultiple: true,
                                              //                     type: FileType.custom,
                                              //                     allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                                              //                     withData: true,
                                              //                   );
                                              //
                                              //                   if (result != null) {
                                              //                     for (var file in result.files) {
                                              //                       String base64String = base64Encode(file.bytes!);
                                              //                       String docType = file.extension == 'pdf' ? "PDF" : "Image";
                                              //
                                              //                       setState(() {
                                              //                         uploadedFiles.add({
                                              //                           "documentName": file.name,
                                              //                           "documentData": base64String,
                                              //                           "documentcategory": "TechnicalSpecification",
                                              //                           "documenttype": docType,
                                              //                         });
                                              //                       });
                                              //                     }
                                              //                   }
                                              //                 },
                                              //               ),
                                              //             ],
                                              //           );
                                              //         },
                                              //       );
                                              //     },
                                              //     serviceRequestId: '',
                                              //   ),
                                              // ),

                                              // Files Section
                                              GestureDetector(
                                                onTap: () {
                                                  buildWOFilesModelPopup(context, serviceRequestDocuments);
                                                },
                                                child: WoFilesCard(
                                                  firstLine: 'Files',
                                                  secondLine: (filesCount) != 0
                                                      ? "${filesCount} Files"
                                                      : 'No Files',
                                                  buttonTitle: 'Add Files',
                                                  icon: null,
                                                  onPressed: () async {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return Wrap(
                                                          children: [
                                                            ListTile(
                                                              leading: const Icon(Icons.photo_camera),
                                                              title: const Text('Capture Image'),
                                                              onTap: () async {
                                                                Navigator.pop(context);
                                                                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                                                if (pickedFile != null) {
                                                                  File imageFile = File(pickedFile.path);
                                                                  List<int> imageBytes = await imageFile.readAsBytes();
                                                                  String base64String = base64Encode(imageBytes);

                                                                  setState(() {
                                                                    serviceRequestDocuments.add({
                                                                      "documentName": pickedFile.name,
                                                                      "documentData": base64String,
                                                                      "documentcategory": "TechnicalSpecification",
                                                                      "documenttype": "Image"
                                                                    });
                                                                    filesCount = serviceRequestDocuments.length;
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            ListTile(
                                                              leading: const Icon(Icons.folder),
                                                              title: const Text('Pick Files (Images/PDFs)'),
                                                              onTap: () async {
                                                                Navigator.pop(context);
                                                                final result = await FilePicker.platform.pickFiles(
                                                                  allowMultiple: true,
                                                                  type: FileType.custom,
                                                                  allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                                                                  withData: true,
                                                                );

                                                                if (result != null) {
                                                                  for (var file in result.files) {
                                                                    String base64String = base64Encode(file.bytes!);
                                                                    String docType = file.extension == 'pdf' ? "PDF" : "Image";

                                                                    setState(() {
                                                                      serviceRequestDocuments.add({
                                                                        "documentName": file.name,
                                                                        "documentData": base64String,
                                                                        "documentcategory": "TechnicalSpecification",
                                                                        "documenttype": docType,
                                                                      });
                                                                      filesCount = serviceRequestDocuments.length;
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  serviceRequestId: requestToEdit?.id ?? '',
                                                ),
                                              ),
                                              // Submit Button
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    fixedSize: Size(
                                                      MediaQuery.of(context).size.width,
                                                      40,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final data = {
                                                      if (requestToEdit != null) "id": servicerequestId,
                                                      "serviceRequestName": nameController.text,
                                                      "description": descriptionController.text,
                                                      "assetId": assetID,
                                                      "locationId": locationID,
                                                      "failureClassId": failureClassID,
                                                      "problemId": problem,
                                                      "workTypeId": workTypeValue,
                                                      "status": "NEW",
                                                      "requestedDate": requestedDateController.text,
                                                      "stopBeginDate": stopBeginDateController.text,
                                                      "closingDate": requestedDateController.text,
                                                      "serviceRequestNameId": servicerequestnameId,
                                                      "serviceRequestDocumentsList": serviceRequestDocuments,
                                                    };

                                                    try {
                                                      if (requestToEdit != null) {
                                                        // Update existing request
                                                        await createServiceRequest.updateServiceRequest(data);
                                                        _bloc.fetchServiceRequest();
                                                      } else {
                                                        // Create new request
                                                        await createServiceRequest.addServiceRequest(data);
                                                      }


                                                      // Clear form
                                                      nameController.clear();
                                                      descriptionController.clear();
                                                      assetController.clear();
                                                      locationController.clear();
                                                      failureClassController.clear();
                                                      problemController.clear();
                                                      workTypeController.clear();

                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              requestToEdit != null
                                                                  ? "Service request updated successfully"
                                                                  : "A new service request has been created successfully.",
                                                            ),
                                                          ),
                                                        );
                                                        Future.delayed(const Duration(seconds: 1))
                                                            .then((value) => Navigator.of(context).pop());
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              requestToEdit != null
                                                                  ? "Error updating service request: "
                                                                  : "Error creating service request:",
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Text(
                                                    requestToEdit != null ? "Update" : "Submit",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
                    });
              },
            ),
          );
        });
  }

  Widget buildSegment(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }

  void _getImageFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
  }

  void _getImageFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  /// Function used for search functionality
  void _searchSearvice(
      String enteredKeyword, List<ServiceRequest>? serviceReq) {
    List<ServiceRequest>? results = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        filteredServiceReq = serviceReq!;
      });
    } else {
      results = serviceReq
          ?.where(
            (element) => element.serviceRequestName!
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()),
          )
          .toList();
      setState(() {
        filteredServiceReq = results!;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear(); // Clear the text field
    _searchSearvice('', serviceReq); // Refresh the list with all work orders
  }
}

/////////////////////////// SORT BY SECTION  \\\\\\\\\\\\\\\\\\\\\\\\\\
class SortBySection extends StatefulWidget {
  final List<CheckBoxListTileModel> checkBoxListTileModel;
  final List<ServiceRequest> filteredReq;
  final Function(List<ServiceRequest>) onFiltered;

  const SortBySection(
      {super.key,
      required this.checkBoxListTileModel,
      required this.filteredReq,
      required this.onFiltered});

  @override
  State<SortBySection> createState() => _SortBySectionState();
}

class _SortBySectionState extends State<SortBySection> {
  String selectedTitle = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  buildShowModalBottomSheet(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.sort_outlined),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(selectedTitle.isNotEmpty
                        ? selectedTitle
                        : "Sort By"), // Show selected title or default text
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(" ${widget.filteredReq.length} Results"),
        ],
      ),
    );
  }

  /////////////////////////// SHOW MODAL BOTTOM SHEET \\\\\\\\\\\\\\\\\\\\\\\\\\
  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 3,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Text(
                  context.local.sort_by,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),

                /* ------------------ List View ------------------ */
                Expanded(
                  child: ListView.separated(
                      itemCount: widget.checkBoxListTileModel.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider();
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          child: Center(
                            child: ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              title: Text(
                                widget.checkBoxListTileModel[index].title,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              trailing:
                                  widget.checkBoxListTileModel[index].isCheck
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.blue,
                                        )
                                      : null,
                              selectedColor: Colors.blue,
                              onTap: () {
                                _updateSelectedTitle(
                                    index); // Update selected tile
                                _filterReqOrder(
                                    widget.checkBoxListTileModel[index].title,
                                    widget.filteredReq);
                                Navigator.pop(context);
                              },
                              onLongPress: () {},
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        });
  }

  void _updateSelectedTitle(int index) {
    setState(() {
      // Unselect all tiles first
      for (var tile in widget.checkBoxListTileModel) {
        tile.isCheck = false;
      }
      // Select the tapped tile
      widget.checkBoxListTileModel[index].isCheck = true;
      selectedTitle = widget.checkBoxListTileModel[index].title;
    });
  }

  /// Function used for search functionality
  void _filterReqOrder(
      String filteredKeyword, List<ServiceRequest>? serviceRequest) {
    if (filteredKeyword == "Created at") {
      serviceRequest?.sort((a, b) {
        if (a.createdDate == null && b.createdDate == null) return 0;
        if (a.createdDate == null) return 1; // Null names go last
        if (b.createdDate == null) return -1; // Null names go last
        return a.createdDate!.compareTo(b.createdDate!);
      });
    } else if (filteredKeyword == "Request Name") {
      serviceRequest?.sort((a, b) {
        if (a.serviceRequestName == null && b.serviceRequestName == null)
          return 0;
        if (a.serviceRequestName == null) return 1; // Null names go last
        if (b.serviceRequestName == null) return -1; // Null names go last
        return a.serviceRequestName!.compareTo(b.serviceRequestName!);
      });
    }
    else if (filteredKeyword == "Asset") {
      serviceRequest?.sort((a, b) {
        if (a.assetName == null && b.assetName == null)
          return 0;
        if (a.assetName == null) return 1; // Null names go last
        if (b.assetName == null) return -1; // Null names go last
        return a.assetName!.compareTo(b.assetName!);
      });
    }
    else if (filteredKeyword == "Location") {
      serviceRequest?.sort((a, b) {
        if (a.locationId == null && b.locationId == null)
          return 0;
        if (a.locationId == null) return 1; // Null names go last
        if (b.locationId == null) return -1; // Null names go last
        return a.locationId!.compareTo(b.locationId!);
      });
    }
    else if (filteredKeyword == "Requested Plan Start Date") {
      serviceRequest?.sort((a, b) {
        if (a.requestedDate == null && b.requestedDate == null)
          return 0;
        if (a.requestedDate == null) return 1; // Null names go last
        if (b.requestedDate == null) return -1; // Null names go last
        return a.requestedDate!.compareTo(b.requestedDate!);
      });
    }
    else if (filteredKeyword == "Status") {
      serviceRequest?.sort((a, b) {
        if (a.status == null && b.status == null)
          return 0;
        if (a.status == null) return 1; // Null names go last
        if (b.status == null) return -1; // Null names go last
        return a.status!.compareTo(b.status!);
      });
    }

    else {}
    widget.onFiltered(serviceRequest!);
  }
}

class CheckBoxListTileModel {
  String title;
  bool isCheck;

  CheckBoxListTileModel({required this.title, required this.isCheck});

  static List<CheckBoxListTileModel> getUsers() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(title: "Created at", isCheck: false),
      CheckBoxListTileModel(title: "Request Name", isCheck: false),
      CheckBoxListTileModel(title: "Location", isCheck: false),
      CheckBoxListTileModel(title: "Asset", isCheck: false),
      CheckBoxListTileModel(title: "Requested Plan Start Date", isCheck: false),
      CheckBoxListTileModel(title: "Status", isCheck: false),


    ];
  }
}

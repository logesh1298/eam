import 'dart:convert';

import 'package:eam/features/4_service_request/service_request_presentation/widgets/servicerequestdetailscard.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eam/features/4_service_request/service_request_data/service_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../3_workorder_details/3_wod_presentation/widgets/wo_details_card.dart';
import '../../../4_service_request/service_request_presentation/widgets/servicerequestdetailscard.dart';

class ServiceRequestDetailsPage extends StatefulWidget {
  final ServiceRequest serviceRequest;

  const ServiceRequestDetailsPage({super.key, required this.serviceRequest});

  @override
  State<ServiceRequestDetailsPage> createState() =>
      _ServiceRequestDetailsPageState();
}
bool isLoadingDocuments = false;
class _ServiceRequestDetailsPageState extends State<ServiceRequestDetailsPage> {
  List<Map<String, dynamic>> serviceRequestDocuments = [];
  bool isLoadingDocuments = false;

  int  filesCount = 0;
  Future<void> fetchServiceRequestDocuments() async {
    if (mounted) setState(() => isLoadingDocuments = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? bearerToken = prefs.getString('bearer_token');

      final response = await http.get(
        Uri.parse('https://demoapi.orienseam.com/api/servicerequest/getdocumentbysrid/${widget.serviceRequest.id}'),
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
      print('Error fetching work order documents: $e');
    } finally {
      if (mounted) setState(() => isLoadingDocuments = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchServiceRequestDocuments();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          widget.serviceRequest.serviceRequestName ?? '',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            /////////////////////////// WORK ORDER Code \\\\\\\\\\\\\\\\\\\\\\\\\\
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '#${widget.serviceRequest.code}' ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                const Text(
                  "Description: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.serviceRequest.description ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(),

            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* ------------------ Status & date ------------------ */
                // Row(
                //   children: [
                //     const Text(
                //       "Status: ",
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //     const Spacer(),
                //     Text(
                //       widget.serviceRequest.status ?? '',
                //       style: TextStyle(color: Colors.grey.shade600),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 5),

                Row(
                  children: [
                    const Text(
                      "Request Date: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat.yMMMd()
                          .format(widget.serviceRequest.requestedDate!),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(),
            /////////////////////////// Primary Information (Key Details)  \\\\\\\\\\\\\\\\\\\\\\\\\\
            Row(
              children: [
                const Text(
                  "Work Type: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.serviceRequest.workType ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.serviceRequest.status ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Location: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.serviceRequest.locationName ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),


            Row(
              children: [
                const Text(
                  "Asset Name: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.serviceRequest.assetName ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Failure Class: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.serviceRequest.failureClassName ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Problem: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.serviceRequest.problemName ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(),
            ///////////////////////////  Problem Summary \\\\\\\\\\\\\\\\\\\\\\\\\\

            // Row(
            //   children: [
            //     const Text(
            //       "Description: ",
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     Text(
            //       widget.serviceRequest.description ?? "",
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //   ],
            // ),
            // const Divider(),
            /////////////////////////// Dates \\\\\\\\\\\\\\\\\\\\\\\\\\
            Row(
              children: [
                const Text(
                  "Requested Date: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd()
                      .add_Hms()
                      .format(widget.serviceRequest.requestedDate!),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Start Date: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd()
                      .add_Hms()
                      .format(widget.serviceRequest.stopBeginDate!),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "End Date: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd()
                      .add_Hms()
                      .format(widget.serviceRequest.closingDate!),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(),
            /////////////////////////// ID's \\\\\\\\\\\\\\\\\\\\\\\\\\

            // Row(
            //   children: [
            //     const Text(
            //       "Failure Class ID: ",
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     Text(
            //       widget.serviceRequest.failureClassId ?? "",
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //   ],
            // ),
            // Row(
            //   children: [
            //     const Text(
            //       "Problem ID: ",
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     Expanded(
            //       child: Text(
            //         widget.serviceRequest.problemId ?? "",
            //         style: TextStyle(color: Colors.grey.shade600),
            //         overflow: TextOverflow.ellipsis,
            //         softWrap: false,
            //       ),
            //     ),
            //   ],
            // ),
            // Row(
            //   children: [
            //     const Text(
            //       "Location ID: ",
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     Text(
            //       widget.serviceRequest.locationId ?? "",
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //   ],
            // ),
            // Row(
            //   children: [
            //     const Text(
            //       "Asset ID: ",
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     Text(
            //       widget.serviceRequest.assetId ?? "",
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //   ],
            // ),
            // const Divider(),
            // /////////////////////////// Last status \\\\\\\\\\\\\\\\\\\\\\\\\\
            Row(
              children: [
                const Text(
                  "Created Date: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd()
                      .add_Hms()
                      .format(widget.serviceRequest.createdDate!),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     const Text(
            //       "Active: ",
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     Text(
            //       widget.serviceRequest.isActive ?? false ? "yes" : "No",
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //   ],
            // ),
            // Row(
            //   children: [
            //     const Text(
            //       "Deleted: ",
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     Text(
            //       widget.serviceRequest.isDeleted ?? false ? "yes" : "No",
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //   ],
            // ),
            const Divider(),
            GestureDetector(
              onTap: () {

                  buildWOFilesModelPopup(context, serviceRequestDocuments);

              },
              child: srCard(

                firstLine: 'Files',
                secondLine: (filesCount) != 0
                    ? "$filesCount Files"
                    : 'No Files',
                buttonTitle: '',
                //icon: null,
                // onPressed: isWorkOrderClosed ? null : () async {
                //   showModalBottomSheet(
                //     context: context,
                //     builder: (context) {
                //       return Wrap(
                //         children: [
                //           ListTile(
                //             leading: const Icon(Icons.photo_camera),
                //             title: const Text('Capture Image'),
                //             onTap: () async {
                //               Navigator.pop(context); // Close the bottom sheet
                //               final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                //               if (pickedFile != null) {
                //                 setState(() {
                //                   fileStr.add(pickedFile.name);
                //                   filesCount = fileStr.length;
                //                 });
                //                 print("Captured Image: ${pickedFile.name}");
                //               } else {
                //                 print("No image captured");
                //               }
                //             },
                //           ),
                //
                //           ListTile(
                //             leading: const Icon(Icons.folder),
                //             title: const Text('Pick Files'),
                //             onTap: () async {
                //               Navigator.pop(context); // Close the bottom sheet
                //               final result = await FilePicker.platform.pickFiles(allowMultiple: false);
                //               if (result != null && result.files.isNotEmpty) {
                //                 File selectedFile = File(result.files.first.path!);
                //                 try {
                //                   String responseMessage = await WorkOrderStatusUpdateApi.createworkorderdoc(
                //                     widget.workOrder.workOrderId!,
                //                     selectedFile,
                //                   );
                //                   print("Response: $responseMessage");
                //                   setState(() {
                //                     fileStr.add(result.files.first.name);
                //                     filesCount = fileStr.length;
                //                     print("Updated filesCount: $filesCount");
                //                   });
                //                 } catch (e) {
                //                   print("Error uploading file: $e");
                //                 }
                //
                //               } else {
                //                 print("No file selected");
                //               }
                //             },
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // },
                serviceRequestId: widget.serviceRequest.id ?? "",
              ),
            ),


          ],
        ),
      ),

    );

  }
}
Future<dynamic> buildWOFilesModelPopup(
    BuildContext context, List<Map<String, dynamic>> documents) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext builder) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              ),
            ),
            child: CupertinoPopupSurface(
              child: Container(
                color: CupertinoColors.white,
                alignment: Alignment.center,
                width: double.infinity,
                height: 730,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                          const Text(
                            "ServiceRequest Documents",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 50),
                        ],
                      ),
                      const Divider(thickness: 1.5),
                      Expanded(
                        child: isLoadingDocuments
                            ? const Center(child: CircularProgressIndicator())
                            : documents.isEmpty
                            ? const Center(child: Text("No documents found"))
                            : ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(doc['documentName']?.split('/').last ?? 'Document'),
                              subtitle: Text(
                                "Uploaded: ${DateFormat.yMMMd().format(DateTime.parse(doc['createdDate']))}",
                              ),
                              // trailing: IconButton(
                              //   icon: const Icon(Icons.download),
                              //   onPressed: () {
                              //     // Implement download functionality
                              //     _downloadDocument(doc['documentName']);
                              //   },
                              // ),
                              // onTap: () {
                              //   // Implement view functionality
                              //   _viewDocument(doc['documentName']);
                              // },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

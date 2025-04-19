import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:eam/core/route/route_constants.dart';
import 'package:eam/features/7_assets/asset_files/presentation/bloc/asset_file_bloc.dart';
import 'package:eam/features/7_assets/data/model/asset_details.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:eam/core/utils/constants.dart';
import 'package:eam/features/12_workorder_task/presentation/bloc/work_order_task_cubit.dart';
import 'package:eam/features/13_parts/asset_parts/presentation/bloc/asset_parts_bloc.dart';
import 'package:eam/features/13_parts/asset_parts/presentation/view/asset_parts_tab.dart';
import 'package:eam/features/2_workorder/domain/entities/workorder.dart';
import 'package:eam/features/3_1_asset_workorder/presentation/bloc/asset_work_order_bloc.dart';
import 'package:eam/features/3_workorder_details/1_wod_domain/workorder_status_repo.dart';
import 'package:eam/features/3_workorder_details/1_wod_domain/workorder_update_api.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/bloc/work_order_status_cubit.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/AssetDetailsTab.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/asset_file_tab.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/asset_workorder_tab.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/build_List_tile_methods.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/status_update_bottom_sheet.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/timer_card.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/wo_details_card.dart';
import 'package:eam/features/3_workorder_details/3_wod_presentation/widgets/wo_task_card.dart';
import 'package:eam/features/7_assets/asset_files/presentation/bloc/asset_file_bloc.dart';
import 'package:eam/features/7_assets/domain/asset_repo.dart';
import 'package:eam/features/7_assets/presentation/bloc/asset_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/DBHelper.dart';
import '../../../../core/dependency_injection/di_container.dart';
import '../../../../core/route/route_constants.dart';
import '../../../13_parts/asset_parts/data/models/asset_parts_model.dart';
import '../../../13_parts/workorder_parts/presentation/bloc/workorder_parts_bloc.dart';
import '../../../13_parts/workorder_parts/presentation/bloc/workorder_parts_event.dart';
import '../../../13_parts/workorder_parts/presentation/bloc/workorder_parts_state.dart';
import '../../../2_workorder/1_wo_domain/workorder_repo.dart';
import '../../../2_workorder/2_wo_data/workorders.dart';
import '../../../2_workorder/presentation/bloc/workorder_bloc.dart';
import '../../../7_assets/presentation/bloc/single_asset_cubit.dart';
import '../../2_wod_data/workorder_per.dart';
import '../bloc/work_order_status_state.dart';
import 'package:eam/features/7_assets/asset_files/presentation/bloc/asset_file_bloc.dart' as fileBloc;

import '../bloc/work_order_task_parts_cubit.dart';
import '../widgets/wo_task_parts_card.dart';
/////////////////////////////////////////////////////////////
///  WORK ORDER DETAILS PAGE
/////////////////////////////////////////////////////////////

class WorkorderDetailsPage extends StatefulWidget {
  /// WorkOrder is from WorkOrder Page
  final WorkorderEntity workOrder;
  final Function(bool)? onBookmarkChanged;
  const WorkorderDetailsPage({super.key, required this.workOrder,this.onBookmarkChanged,});

  @override
  State<WorkorderDetailsPage> createState() => _WorkorderDetailsPageState();
}

class _WorkorderDetailsPageState extends State<WorkorderDetailsPage> {
  // Add these at the top with other properties
  List<Map<String, dynamic>> workOrderDocuments = [];
  bool isLoadingDocuments = false;

// Add this method to fetch documents
  Future<void> fetchWorkOrderDocuments() async {
    if (mounted) setState(() => isLoadingDocuments = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? bearerToken = prefs.getString('bearer_token');

      final response = await http.get(
        Uri.parse('https://demoapi.orienseam.com/api/workorder/getdocumentbyworkorderid/${widget.workOrder.workOrderId}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            workOrderDocuments = List<Map<String, dynamic>>.from(data['result'] ?? []);
            filesCount = workOrderDocuments.length;
          });
        }
      }
    } catch (e) {
      print('Error fetching work order documents: $e');
    } finally {
      if (mounted) setState(() => isLoadingDocuments = false);
    }
  }

// Call this in initState



  Future<TaskProgress?> fetchTaskProgress(String workOrderId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');
    try {
      final response = await http.get(
        Uri.parse('https://demoapi.orienseam.com/api/workordertask/getallpercentage/$workOrderId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TaskProgress.fromJson(data['result']);
      }
      return null;
    } catch (e) {
      print('Error fetching task progress: $e');
      return null;
    }
  }


  Widget _buildBookmarkIcon() {
    return IconButton(
      icon: Icon(
        widget.workOrder.isFavouriteWO!
            ? Icons.bookmark
            : Icons.bookmark_border,
        color: widget.workOrder.isFavouriteWO! ? Colors.green : Colors.black,
      ),
      onPressed: () async {
        final newBookmarkState = !widget.workOrder.isFavouriteWO!;

        try {
          // Update API
          await WorkOrderStatusUpdateApi.saveWorkOrder(
            widget.workOrder.workOrderId!,
            newBookmarkState,
            widget.workOrder.assetId!,
          );

          // Update local state
          if (mounted) {
            setState(() {
              widget.workOrder.isFavouriteWO = newBookmarkState;
            });
          }

          // Notify parent (WorkOrdersPage) of the change
          if (widget.onBookmarkChanged != null) {
            widget.onBookmarkChanged!(newBookmarkState);
          }
        } catch (e) {
          // Handle error (e.g., show a snackbar)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update bookmark: $e')),
          );
        }
      },
    );
  }

  /////////////////////////// BLOC INITIALIZATION \\\\\\\\\\\\\\\\\\\\\\\\\\
  final WorkOrderStatusCubit _workOrderStatusCubit =
      WorkOrderStatusCubit(sl<WorkOrderStatusRepo>());
  final WorkOrderTaskCubit _workOrderTaskCubit = WorkOrderTaskCubit();

  DBHelper database = DBHelper.instance;
  bool isSelectedData =  false;
  List<String> fileStr = [];
  int  filesCount = 0;
  TaskProgress? taskProgress;
  bool isLoadingProgress = false;




  bool isFlagSet = false;

  void toggleFlag() {
    setState(() {
      isFlagSet = !isFlagSet;
    });
  }
  /////////////////////////// PROPERTIES \\\\\\\\\\\\\\\\\\\\\\\\\\
  int partsCount = 0;

  String? selectedValue;
  // final double _progressValue = 0.2;

  List<WorkOrderStatusUpdateModel> checkBoxListTileModel =
      WorkOrderStatusUpdateModel.getUsers();
  List<WorkOrderStatusUpdateModel2> workorderStatus =
      WorkOrderStatusUpdateModel2.getUsers();

  late final String assetId;

  List<String> options = [];

  String selectedString = "";

  late String _selected = widget.workOrder.status ?? "";
  late String _selectedForPost = "";

  bool isTimerRunning = false;
  bool workCompleted = false;
  int seconds = 0;
  bool TimerOn = false;

  static var countdownDuration = const Duration(minutes: 10);
  Duration duration = const Duration();
  Timer? timer;
  bool countDown = true;
  dynamic hours;
  dynamic mints;
  dynamic secs;
  dynamic secondsec;
  final SingleAssetCubit _assetBloc = SingleAssetCubit();

  var id;
  late String AssetTypeId,
      AssetName,
      PriorityId,
      AssetsDesc,
      CriticalId,
      ParentId,
      FailureClassesId,
      LocationId,
      Rotating,
      AssetCategoryId;
  late List<AssetPartsModel> assetParts;
  late List<WorkOrder> WorkOrderList;
/////////////////////////// START TIMER \\\\\\\\\\\\\\\\\\\\\\\\\\
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  /////////////////////////// ADD TIME \\\\\\\\\\\\\\\\\\\\\\\\\\
  Future<void> addTime() async {
    const addSeconds = 1;
    var seconds = 00;

    if (secs == "00") {
      seconds = duration.inSeconds + addSeconds;
    } else {
      seconds = int.parse(secs) + addSeconds;
    }

    print("hoursssss${hours}");
    print("mintssss${mints}");
    print("secssss${secs}");
    setState(() {
      hours = duration.inHours;
      mints = duration.inMinutes;
      secs = duration.inSeconds;
      if (!isTimerRunning) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });

    if (TimerOn) {
      Map<String, dynamic> row = {
        'workorder': "${widget.workOrder.workOrderId!}",
        'hours': "${duration.inHours}",
        'minutes': "${duration.inMinutes}",
        'seconds': "${duration.inSeconds}"
      };
      id = await DBHelper.instance.insertTime(row);
      print('Inserted row id: $id');
      TimerOn = !TimerOn;
    } else {
      print('Inserted row id: $id');
      await DBHelper.instance.updateTime(
          id!,
          "${widget.workOrder.workOrderId!}",
          "${duration.inHours}",
          "${duration.inMinutes}",
          "${duration.inSeconds}");
    }
  }

/////////////////////////// TOGGLE TIMER METHOD \\\\\\\\\\\\\\\\\\\\\\\\\\
  void toggleTimer() {
    setState(() {
      isTimerRunning = !isTimerRunning;
    });
    if (isTimerRunning) {
      startTimer();
    }
  }
  late bool isWorkOrderClosed;
/////////////////////////// INIT STATE METHOD \\\\\\\\\\\\\\\\\\\\\\\\\\
  @override
  void initState() {
    _workOrderStatusCubit.fetchWorkOrderStatus();
    _workOrderTaskCubit.fetchWorkOrderTasks("${widget.workOrder.id}");

    AssetRepo.getAssetsById("${widget.workOrder.assetId}").then((value) {
      print("testinggggprocess${value.data!.result}");
      AssetTypeId = value.data!.result?.assetTypeName ?? "";
      AssetName = value.data!.result?.assetName ?? "";
      PriorityId = value.data!.result?.priorityName ?? "";
      AssetsDesc = value.data!.result?.assetTypeName ?? "";
      CriticalId = value.data!.result?.criticalityName ?? "";
      ParentId = value.data!.result?.parentAssetName ?? "";
      FailureClassesId = value.data!.result?.failureClassName ?? "";
      LocationId = value.data!.result?.locationName ?? "";
      Rotating = value.data!.result?.ownerName ?? "";
      AssetCategoryId = value.data!.result?.assetCategoryId ?? "";
    });

    AssetRepo.getAssetsPartsById("${widget.workOrder.assetId}").then((value) {
      assetParts = value.data!;
      print("assetPartsss${assetParts.length}");
    });
    AssetRepo.getSpecifyById("${widget.workOrder.assetId}").then((value) {
      print("value${value}");
    });

    WorkOrderRepo.getWorkorderListByAssetId("${widget.workOrder.assetId}")
        .then((value) {
      WorkOrderList = value;
      print("assetPartsss${WorkOrderList.length}");
    });

    // Map<String, dynamic>? times = dbHelper.getTimeById(widget.workOrder.workOrderId!);
    hours = duration.inHours;
    mints = duration.inMinutes;
    secs = duration.inSeconds;
    countdownDuration = Duration(hours: hours, minutes: mints, seconds: secs);
    // startTimer();
    // reset();
    BlocProvider.of<WorkOrderPartsBloc>(context)
        .add(WorkorderPartFetchEvent(widget.workOrder.workOrderId!));
    super.initState();
    isWorkOrderClosed = widget.workOrder.isClosed;
    _fetchTaskProgress();
    fetchWorkOrderDocuments();
  }
  Future<void> _fetchTaskProgress() async {
    if (mounted) setState(() => isLoadingProgress = true);
    try {
      final progress = await fetchTaskProgress(widget.workOrder.workOrderId!);
      if (mounted) setState(() => taskProgress = progress);
    } finally {
      if (mounted) setState(() => isLoadingProgress = false);
    }
  }
  /////////////////////////// EDIT TIMER DIALOG BOX \\\\\\\\\\\\\\\\\\\\\\\\\\
  /// FOR EDITING TIME
  _showEditTimeDialog() async {
    // TextEditingController controller = TextEditingController(text: timerText);
    var hoursController = TextEditingController();
    var minutesController = TextEditingController();
    var secondsController = TextEditingController();

    hoursController.text = twoDigits(duration.inHours);
    minutesController.text = twoDigits(duration.inMinutes.remainder(60));
    secondsController.text = twoDigits(duration.inSeconds.remainder(60));

    await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              title: const Column(
                children: [
                  Text("Edit time"),
                  Divider(),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              content: Builder(builder: (context) {
                return SizedBox(
                    width: 200,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEditTimeCard(
                          controller: hoursController,
                          labelText: 'Hrs',
                          unitName: 'Hrs',
                          maxValue: 24,
                          validation: (value) =>
                              _validateTimeUnit(value, 'Hours', 24),
                        ),
                        const SizedBox(width: 8),
                        _buildEditTimeCard(
                          controller: minutesController,
                          labelText: 'Mins',
                          unitName: 'Mins',
                          maxValue: 59,
                          validation: (value) =>
                              _validateTimeUnit(value, 'Minutes', 59),
                        ),
                        const SizedBox(width: 8),
                        _buildEditTimeCard(
                          controller: secondsController,
                          labelText: 'Sec',
                          unitName: 'Sec',
                          maxValue: 59,
                          validation: (value) =>
                              _validateTimeUnit(value, 'Seconds', 59),
                        ),
                      ],
                    ));
              }),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade500),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                      ),
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () {
                            if (_validateInput(
                              hoursController.text,
                              minutesController.text,
                              secondsController.text,
                            )) {
                              int hours = int.parse(hoursController.text);
                              int minutes = int.parse(minutesController.text);
                              int seconds = int.parse(secondsController.text);

                              setState(() {
                                countdownDuration = Duration(
                                  hours: hours,
                                  minutes: minutes,
                                  seconds: seconds,
                                );
                                reset();
                              });

                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }
  //widget for percentage
  Widget _buildTaskProgressIndicator() {
    if (isLoadingProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskProgress == null) {
      return const SizedBox(); // Return empty widget if no progress data
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  taskProgress!.formattedSummary,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              taskProgress!.percentage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////// BUILD TIME \\\\\\\\\\\\\\\\\\\\\\\\\\

  Widget buildTime() {
    if (!TimerOn) {
      DBHelper.instance
          .getTimeById(widget.workOrder.workOrderId!)
          .then((value) {
        if (value != null) {
          print("valueeeeee ${value}");
          id = value['id'];
          String hour = value['hours'];
          String min = value['minutes'];
          String sec = value['seconds'];
          print("valueeeeee ${hour}");
          print("valueeeeee ${min}");
          print("valueeeeee ${sec}");

          setState(() {
            hours = hour;
            mints = twoDigits(int.parse(min));
            secs = twoDigits(int.parse(sec));
            secondsec = int.parse(secs).remainder(60);
          });
        } else {
          setState(() {
            TimerOn = true;
          });
        }
      });
    } else {
      setState(() {
        hours = twoDigits(duration.inHours);
        mints = twoDigits(duration.inMinutes.remainder(60));
        secs = twoDigits(duration.inSeconds.remainder(60));
        secondsec = int.parse(secs).remainder(60);
        TimerOn = true;
      });
    }
    print("valueeeeee ${duration.inHours}");
    print("valueeeeee ${twoDigits(duration.inMinutes.remainder(60))}");
    print("valueeeeee ${twoDigits(duration.inSeconds.remainder(60))}");

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildTimeCard(time: "${hours}", header: 'Hrs'),
        const SizedBox(width: 5),
        buildTimeCard(time: "${mints}", header: 'Mins'),
        const SizedBox(width: 5),
        buildTimeCard(time: "${secondsec}", header: 'Sec'),
      ],
    );
  }

/////////////////////////// BUILD TIME CARD \\\\\\\\\\\\\\\\\\\\\\\\\\
  Widget buildTimeCard({required String time, required String header}) =>
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                time,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18),
              ),
            ),
            Text(header, style: const TextStyle(color: Colors.black45)),
          ],
        ),
      );

  /////////////////////////// VALIDATE TIME UNIT \\\\\\\\\\\\\\\\\\\\\\\\\\
  String? _validateTimeUnit(String? value, String unitName, int maxValue) {
    if (value == null || value.isEmpty) {
      return '$unitName is required';
    }

    final intVal = int.tryParse(value);

    if (intVal == null || intVal < 0 || intVal > maxValue) {
      return '$unitName must be a valid number between 0 and $maxValue';
    }

    if (value.length > 2) {
      return '$unitName cannot be more than 2 digits';
    }

    return null;
  }

/////////////////////////// VALIDATE INPUT \\\\\\\\\\\\\\\\\\\\\\\\\\
  bool _validateInput(String hours, String minutes, String seconds) {
    return _validateField(hours, 'Hours') &&
        _validateField(minutes, 'Minutes') &&
        _validateField(seconds, 'Seconds');
  }

/////////////////////////// VALIDATE FIELD \\\\\\\\\\\\\\\\\\\\\\\\\\
  bool _validateField(String value, String fieldName) {
    if (value.isEmpty) {
      _showValidationError('$fieldName is required');
      return false;
    }

    final intVal = int.tryParse(value);

    if (intVal == null) {
      _showValidationError('$fieldName must be a valid number');
      return false;
    }

    return true;
  }

/////////////////////////// SHOW VALIDATE ERROR \\\\\\\\\\\\\\\\\\\\\\\\\\
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

/////////////////////////// RESET \\\\\\\\\\\\\\\\\\\\\\\\\\
  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = const Duration());
    }
  }

/////////////////////////// BUILD TIME CARD \\\\\\\\\\\\\\\\\\\\\\\\\\

  /// Method is used in  Edit time Dialog
  Widget _buildEditTimeCard({
    required TextEditingController controller,
    String? initialValue,
    required String labelText,
    required String unitName,
    required int maxValue,
    required String? Function(String?) validation,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade50),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '00',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              counterText: "",
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLength: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            onChanged: (value) {
              if (value.length == 2) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(unitName, style: const TextStyle(color: Colors.black45)),
      ],
    );
  }

/////////////////////////// START WORKING FAB \\\\\\\\\\\\\\\\\\\\\\\\\\
  Widget showSingleFAB() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor:
              isTimerRunning ? Colors.red.shade700 : Colors.green.shade700,
          onPressed: () {
            !workCompleted ? toggleTimer() : null;

            String Strval = "";

            if (!workCompleted ||
                _selected != "COMP" ||
                widget.workOrder.status != "COMP") {
              if (_selected == "INPRG") {
                _selected = "In Progrss";
                Strval = "INPRG";
              } else if (_selected == "STP") {
                _selected = "Stop";
                Strval = "STP";
              } else if (_selected == "New") {
                _selected = "New";
                Strval = "New";
              }

              print(widget.workOrder.workOrderId);
              print(_selected);
              setState(() {});
            } else {
              _selected = "COMP";
              Strval = "COMP";

              print(widget.workOrder.workOrderId);
              print(_selected);
              setState(() {});
            }



            WorkOrderStatusUpdateApi.updateWorkOrder(
                widget.workOrder.workOrderId!,'${hours}.${mints}',widget.workOrder.assetId!);

            BlocProvider.of<WorkorderBloc>(context).add(
              WorkOrderStatusUpDateEvent(
                  workOrderId: widget.workOrder.workOrderId!, status: Strval),
            );
          },
          icon: Icon(
            workCompleted ||
                    _selected == "COMP" ||
                    widget.workOrder.status == "COMP"
                ? Icons.done_rounded
                : Icons.play_arrow_rounded,
            size: 24,
            color: Colors.white,
          ),
          label: Text(
            workCompleted ||
                    _selected == "COMP" ||
                    widget.workOrder.status == "COMP"
                ? 'Work Completed'
                : 'Start Working',

            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

/////////////////////////// STOP & COMPLETE WORK FAB \\\\\\\\\\\\\\\\\\\\\\\\\\
  Widget showTwoFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.5),
            child: FloatingActionButton.extended(
              elevation: 0,
              backgroundColor: Colors.red.shade700,
              onPressed: () {

                WorkOrderStatusUpdateApi.updateWorkOrder(
                    widget.workOrder.workOrderId!,'${hours}.${mints}',widget.workOrder.assetId!);

                toggleTimer();
              },
              icon: const Icon(
                Icons.pause_rounded,
                size: 17,
                color: Colors.white,
              ),
              label: Text(
                'Stop Working',
                textScaleFactor: ScaleSize.textScaleFactor(context),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.5),
            child: FloatingActionButton.extended(
              elevation: 0,
              backgroundColor: Colors.green.shade700,
              onPressed: () {
                toggleTimer();
                setState(() {
                  workCompleted = true;
                  _selectedForPost = "COMP";
                  _selected = "Completed";
                });

                WorkOrderStatusUpdateApi.updateWorkOrder(
                    widget.workOrder.workOrderId!,'${hours}.${mints}',widget.workOrder.assetId!);

                BlocProvider.of<WorkorderBloc>(context).add(
                  WorkOrderStatusUpDateEvent(
                      workOrderId: widget.workOrder.workOrderId!,
                      status: _selectedForPost),
                );
              },
              icon: const Icon(
                Icons.done_all_outlined,
                size: 17,
                color: Colors.white,
              ),
              label: Text(
                'Complete Work',
                textScaleFactor: ScaleSize.textScaleFactor(context),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

/////////////////////////// DISPOSE  \\\\\\\\\\\\\\\\\\\\\\\\\\
  @override
  void dispose() {
    _workOrderStatusCubit.close();
    super.dispose();
  }

/////////////////////////// BUILD METHOD \\\\\\\\\\\\\\\\\\\\\\\\\\
  @override
  Widget build(BuildContext context) {
    // FilePickerResult? result;
    // List<String> fileStr = [];
    // //int  filesCount = fileStr.length;
    // final ImagePicker _picker = ImagePicker();
    //
    //
     //String workOrderId = "";

    //final wosUpdateBloc = BlocProvider.of<WorkorderBloc>(context);
    List<String> fileStr = [];
    int  filesCount = fileStr.length;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WorkOrderStatusCubit(sl<WorkOrderStatusRepo>()),
        ),
        BlocProvider(
          create: (context) => AssetBloc(),
        ),
        // BlocProvider(
        //   create: (BuildContext context) => WorkOrderPartsBloc(),
        // ),

      ],


      child: Scaffold(
        /////////////////////////// APP BAR \\\\\\\\\\\\\\\\\\\\\\\\\\
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottomOpacity: 0.0,
          automaticallyImplyLeading: false,
          elevation: 0,
          leadingWidth: 90,
          leading: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
                onPressed: () {
                  context.pop();
                },
              ),
              const Text(
                'Back',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            _buildBookmarkIcon(), // <-- Replace the old bookmark icon with this
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz_outlined, color: Colors.grey),
            ),
          ],
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.info_outlined),
          //     color: Colors.grey,
          //   ),
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.more_horiz_outlined, color: Colors.grey),
          //   ),
          // ],
        ),

        /////////////////////////// "START WORKING" FAB \\\\\\\\\\\\\\\\\\\\\\\\\\

       // floatingActionButton: !isTimerRunning ? showSingleFAB() : showTwoFAB(),
        floatingActionButton: isWorkOrderClosed ? null : (!isTimerRunning ? showSingleFAB() : showTwoFAB()),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        /////////////////////////// BODY \\\\\\\\\\\\\\\\\\\\\\\\\\

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              /////////////////////////// WORK ORDER NAME \\\\\\\\\\\\\\\\\\\\\\\\\\
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${widget.workOrder.code} - ${widget.workOrder.workOrderName}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),

              /////////////////////////// WORKORDER NO.- PRIORITY - WORK ORDER DATE \\\\\\\\\\\\\\\\\\\\\\\\\\
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // /* ------------------ 1_Workorder Number ------------------ */
                      // Text(
                      //   widget.workOrder.code ?? '',
                      //   style: TextStyle(color: Colors.grey.shade400),
                      // ),
                      // const SizedBox(width: 5),
                      // /* ------------------ 2_ Dot ------------------ */
                      // Align(
                      //   alignment: Alignment.bottomCenter,
                      //   child: Container(
                      //     width: 5,
                      //     height: 5,
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       color: Colors.grey.shade600,
                      //     ),
                      //   ),
                      // ),
                      // /* ------------------ 3_Flag Icon ------------------ */
                      // const Icon(
                      //   Icons.flag,
                      //   color: Colors.orange,
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /////////////////////////// WORK ORDER STATUS FIELD \\\\\\\\\\\\\\\\\\\\\\\\\\
                  BlocBuilder<WorkOrderStatusCubit, WorkOrderStatusState>(
                    bloc: _workOrderStatusCubit,
                    builder: (context, state) {
                      if (state is WorkOrderStatusLoadedState) {
                        final workOrderStatus =
                            state.workOrderStatues.map((e) => e.text).toList();
                        return buildDropDownField(workOrderStatus);
                      }
                      return const SizedBox();
                    },
                  ),

                  const SizedBox(height: 20),
                  /* ------------------ 5_Date ------------------ */
                  Row(
                    children: [
                      const Text(
                        "Actual Start Date: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.workOrder.actualStartDate != null
                            ? DateFormat.yMMMd()
                                .format(widget.workOrder.actualStartDate!)
                            : "",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      /////////////////////////// BOOKMARK \\\\\\\\\\\\\\\\\\\\\\\\\\
                      // SizedBox(
                      //   height: 20,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       IconButton(
                      //         icon: Icon(
                      //           widget.workOrder.isFavouriteWO!
                      //               ? Icons.bookmark
                      //               : Icons.bookmark_border,
                      //           color: widget.workOrder.isFavouriteWO!
                      //               ? Colors.green
                      //               : Colors.black,
                      //         ),
                      //         onPressed: () async {
                      //           // Toggle the bookmark state
                      //           final newBookmarkState = !widget.workOrder.isFavouriteWO!;
                      //
                      //           // Update API
                      //           try {
                      //             await WorkOrderStatusUpdateApi.saveWorkOrder(
                      //               widget.workOrder.workOrderId!,
                      //               newBookmarkState,
                      //               widget.workOrder.assetId!,
                      //             );
                      //
                      //             // Update the parent widget's state by passing the new value back
                      //             if (mounted) {
                      //               setState(() {
                      //                 widget.workOrder.isFavouriteWO = newBookmarkState;
                      //               });
                      //             }
                      //           } catch (e) {
                      //             // Show error if needed
                      //           }
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        "Planned Start Date: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat.yMMMd()
                            .format(widget.workOrder.targetStartDate!),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        "Planned End Date: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat.yMMMd()
                            .format(widget.workOrder.targetEndDate!),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  /* ------------------Priority ------------------ */

                  Text(
                    widget.workOrder.priorityName == null
                        ? "${widget.workOrder.priorityName}"
                        : "",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(),

              /////////////////////////// WORK DESCRIPTION FIELD  \\\\\\\\\\\\\\\\\\\\\\\\\\
              buildListTile(
                heading: "Work Description",
                subtitle: widget.workOrder.description ?? "",
                icon: null,
              ),
              const Divider(),

              /////////////////////////// WORK DESCRIPTION FIELD  \\\\\\\\\\\\\\\\\\\\\\\\\\
              buildListTile(
                heading: "Work Type",
                subtitle: widget.workOrder.workTypeName ?? "",
                icon: null,
              ),
              const Divider(),
/////////////////////////// work priority  \\\\\\\\\\\\\\\\\\\\\\\\\\
              buildListTile(
                heading: "Work Priority",
                subtitle: widget.workOrder.priorityName ?? "",
                icon: null,
              ),
              const Divider(),


              ///////////////////////////  LOCATION FIELD \\\\\\\\\\\\\\\\\\\\\\\\\\
              buildListTile2(
                heading: "Location",
                subtitle: widget.workOrder.locationName ?? "",
              ),
              const Divider(),

              /////////////////////////// ASSET FIELD \\\\\\\\\\\\\\\\\\\\\\\\\\

               buildListTile(
                 heading: "Asset",
                 subtitle: widget.workOrder.assetName ?? "",
                 subtitle1: "Barcode: ${widget.workOrder.code}",
                 // onTap: () {
                 //   print("AssetTypeId${AssetTypeId}");
                 //   _showBottomSheet(
                 //       context,
                 //      AssetTypeId,
                 //       AssetName,
                 //       PriorityId,
                 //       AssetsDesc,
                 //       CriticalId,
                 //       ParentId,
                 //       FailureClassesId,
                 //       LocationId,
                 //       Rotating,
                 //       AssetCategoryId);
                 //    buildAssetDetailsBottomSheet(context);
                 // },
                 onTap: () {
                   buildAssetDetailsBottomSheet(context);
                    //buildWOAssetsModalPopup(context);
                 },
               ),



              // GestureDetector(
              //   onTap: () {
              //     buildAssetDetailsBottomSheet(context);
              //    // buildWOAssetsModalPopup(context);
              //   },
              //   child: BlocBuilder<AssetFileBloc, fileBloc.AssetFileState>(
              //     builder: (context, state) {
              //       if (state is fileBloc.AssetFileErrorState) {
              //        // assetsCount = state.assetFiles.length;
              //       }
              //       return WoPartsCard(
              //         firstLine: 'Parts',
              //         secondLine: partsCount > 1
              //             ? "$partsCount Parts Available"
              //             : "$partsCount Part Available",
              //         buttonTitle: '',
              //         icon: null,
              //         onPressed: () {},
              //         workOrderId: widget.workOrder.workOrderId ?? "",
              //       );
              //     },
              //   ),
              // ),
              // const SizedBox(
              //   height: 15,
              // ),

              // Add this above the TasksCard:
             //_buildTaskProgressIndicator(),






              /////////////////////////// TASK CARD  \\\\\\\\\\\\\\\\\\\\\\\\\\

              TasksCard(


                cubit: _workOrderTaskCubit,
                workOrderId: widget.workOrder.workOrderId ?? "",


                //isEditable: !isWorkOrderClosed,
              ),
              const SizedBox(
                height: 15,
              ),


              WorkOrderTaskPartsCard(
                workOrderId: widget.workOrder.workOrderId ?? "",
              ),
              const SizedBox(height: 15),

              // TasksPartsCard(
              //   cubit: _workOrderTaskCubit,
              //   workOrderId: widget.workOrder.workOrderId ?? "",
              //   fetchParts: fetchWorkOrderTaskParts,
              // ),

              /////////////////////////// TIME CARD \\\\\\\\\\\\\\\\\\\\\\\\\\
              TimerCard(
                firstLine: 'Time',
                timeFields: buildTime(),
                buttonTitle: "Edit Total Time",
                icon: Icons.more_horiz_outlined,
                // onPressed: !isTimerRunning
                //     ? () async {
                //         await _showEditTimeDialog();
                //       }
                //     : null,
                onPressed: isWorkOrderClosed ? null : () async {
                  await _showEditTimeDialog();
                },


              ),
              const SizedBox(
                height: 15,
              ),

              /////////////////////////// PARTS CARD \\\\\\\\\\\\\\\\\\\\\\\\\\
              // GestureDetector(
              //   onTap: () {
              //     buildWOPartsModalPopup(context);
              //   },
              //   child: BlocBuilder<WorkOrderPartsBloc, WorkOrderPartsState>(
              //     builder: (context, state) {
              //       if (state is WorkOrderPartsLoadedState) {
              //         partsCount = state.workorderParts.length;
              //       }
              //       return WoPartsCard(
              //         firstLine: 'Parts',
              //         secondLine: partsCount > 1
              //             ? "$partsCount Parts Available"
              //             : "$partsCount Part Available",
              //         buttonTitle: '',
              //         icon: null,
              //         onPressed: () {},
              //         workOrderId: widget.workOrder.workOrderId ?? "",
              //       );
              //     },
              //   ),
              // ),
              const SizedBox(
                height: 15,
              ),

              /////////////////////////// FILES CARD \\\\\\\\\\\\\\\\\\\\\\\\\\
              // GestureDetector(
              //   onTap: () {
              //     buildWOFilesModelPopup(context, fileStr);
              //   },
              //
              //   child: WoPartsCard(
              //     firstLine: 'Files',
              //     secondLine:
              //         filesCount != 0 ? "${filesCount} Files" : 'No Files',
              //     buttonTitle: 'Add Files',
              //     icon: null,
              //     onPressed: () async {
              //       result = await FilePicker.platform
              //           .pickFiles(allowMultiple: true);
              //
              //
              //       if (result == null) {
              //         print("No file selected");
              //       } else {
              //         setState(() {
              //           for (var element in result!.files) {
              //             fileStr.add(element.name);
              //           }
              //           filesCount = fileStr.length;
              //         });
              //
              //
              //         print("fileStr${filesCount}");
              //       }
              //     },
              //     workOrderId: widget.workOrder.workOrderId ?? "",
              //   ),
              // ),
              //create to add files at orginal
              GestureDetector(
                onTap: () {
                  if (!isWorkOrderClosed) {
                    buildWOFilesModelPopup(context, workOrderDocuments);
                  }
                },
                child: WoPartsCard(

                  firstLine: 'Files',
                  secondLine: (filesCount + workOrderDocuments.length) != 0
                      ? "${filesCount + workOrderDocuments.length} Files"
                      : 'No Files',
                  buttonTitle: 'Add Files',
                  icon: null,
                  onPressed: isWorkOrderClosed ? null : () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Capture Image'),
                              onTap: () async {
                                Navigator.pop(context); // Close the bottom sheet
                                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                if (pickedFile != null) {
                                  setState(() {
                                    fileStr.add(pickedFile.name);
                                    filesCount = fileStr.length;
                                  });
                                  print("Captured Image: ${pickedFile.name}");
                                } else {
                                  print("No image captured");
                                }
                              },
                            ),

                            ListTile(
                              leading: const Icon(Icons.folder),
                              title: const Text('Pick Files'),
                              onTap: () async {
                                Navigator.pop(context); // Close the bottom sheet
                                final result = await FilePicker.platform.pickFiles(allowMultiple: false);
                                if (result != null && result.files.isNotEmpty) {
                                  File selectedFile = File(result.files.first.path!);
                                  try {
                                    String responseMessage = await WorkOrderStatusUpdateApi.createworkorderdoc(
                                      widget.workOrder.workOrderId!,
                                      selectedFile,
                                    );
                                    print("Response: $responseMessage");
                                    setState(() {
                                      fileStr.add(result.files.first.name);
                                      filesCount = fileStr.length;
                                      print("Updated filesCount: $filesCount");
                                    });
                                  } catch (e) {
                                    print("Error uploading file: $e");
                                  }

                                } else {
                                  print("No file selected");
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  workOrderId: widget.workOrder.workOrderId ?? "",
                ),
              ),

    //     GestureDetector(
    //     onTap: () {
    //   if (!isWorkOrderClosed) {
    //     buildWOFilesModelPopup(context, fileStr);
    //   }
    // },
    // child: WoPartsCard(
    // firstLine: 'Files',
    // secondLine: filesCount != 0 ? "$filesCount Files" : 'No Files',
    // buttonTitle: 'Add Files',
    // icon: null,
    // onPressed: isWorkOrderClosed ? null : _pickFile, // Use the file picker function
    // workOrderId: widget.workOrder.workOrderId ?? "",
    // ),
    // ),
                const SizedBox(
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }



  //////////////////////////////////////////////////////////////////////////////////////////////////
  /// WIDGETS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  /////////////////////////// PARTS - MODAL POP UP \\\\\\\\\\\\\\\\\\\\\\\\\\
  Future<dynamic> buildWOPartsModalPopup(BuildContext context) {
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
                    bottomRight: Radius.zero)),
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          const Text(
                            "Workorder Parts",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 50,
                          )
                        ],
                      ),
                      const Divider(
                        thickness: 1.5,
                      ),
                      Expanded(
                        child: BlocConsumer<WorkOrderPartsBloc,
                            WorkOrderPartsState>(
                          listener: (context, state) {
                            if (state is WorkorderPartsErrorState) {
                              SnackBar snackBar = SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: Colors.red,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                          builder: (context, state) {
                            if (state is WorkOrderPartsLoadingState) {
                              return const Center(
                                child: CupertinoActivityIndicator(),
                              );
                            }
                            if (state is WorkOrderPartsLoadedState) {
                              return Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
                                  children: [
                                    /////////////////////////// PARTS LISTS \\\\\\\\\\\\\\\\\\\\\\\\\\
                                    Expanded(
                                      child: Scrollbar(
                                        child: ListView.separated(
                                          itemCount:
                                              state.workorderParts.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              color: Colors.grey.shade200,
                                              // margin: const EdgeInsets.all(2),
                                              semanticContainer: false,
                                              elevation: 0,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    /////////////////////////// SERVICE REQUEST TITLE \\\\\\\\\\\\\\\\\\\\\\\\\\
                                                    Text(
                                                      "${index + 1}.${state.workorderParts[index].partName}",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),

                                                    Row(
                                                      children: [
                                                        const Text(
                                                          "Part Code: ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                        // Icon(
                                                        //   Icons.code,
                                                        //   color: Colors.grey.shade600,
                                                        //   size: 18,
                                                        // ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          state
                                                                  .workorderParts[
                                                                      index]
                                                                  .code ??
                                                              "",
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade600),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 6,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          "Part Id: ",
                                                          style: TextStyle(color: Colors.grey),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Expanded(  // Prevents overflow
                                                          child: Text(
                                                            state.workorderParts[index].partId ?? "",
                                                            style: TextStyle(color: Colors.grey.shade600),
                                                            overflow: TextOverflow.ellipsis,  // Adds "..." if text overflows
                                                            maxLines: 1,  // Ensures single-line display
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(
                                                      height: 6,
                                                    ),
                                                  ],
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
                              child: Text("No Parts found "),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /////////////////////////// Assets - MODAL POP UP \\\\\\\\\\\\\\\\\\\\\\\\\\
  Future<dynamic> buildWOAssetsModalPopup(BuildContext context) {
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
                        bottomRight: Radius.zero)),
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                              ),
                              const Text(
                                "WorkOrderAssets Parts",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 50,
                              )
                            ],
                          ),
                          const Divider(
                            thickness: 1.5,
                          ),
                          Expanded(
                            child: BlocConsumer<AssetFileBloc,
                                fileBloc.AssetFileState>(
                              listener: (context, state) {
                                if (state is AssetFileErrorState) {
                                  SnackBar snackBar = SnackBar(
                                    content: Text(state.errorMessage),
                                    backgroundColor: Colors.red,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              builder: (context, state) {
                                if (state is AssetFileLoadedState) {
                                  return const Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                }
                                if (state is AssetFileLoadedState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      children: [
                                        /////////////////////////// PARTS LISTS \\\\\\\\\\\\\\\\\\\\\\\\\\
                                        Expanded(
                                          child: Scrollbar(
                                            child: ListView.separated(
                                              itemCount:
                                              state.assetFiles.length,
                                              itemBuilder: (context, index) {
                                                return Card(
                                                  color: Colors.grey.shade200,
                                                  // margin: const EdgeInsets.all(2),
                                                  semanticContainer: false,
                                                  elevation: 0,
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        /////////////////////////// SERVICE REQUEST TITLE \\\\\\\\\\\\\\\\\\\\\\\\\\
                                                        Text(
                                                          "${index + 1}.${state.assetFiles[index].assetId}",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                              FontWeight.bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),

                                                        Row(
                                                          children: [
                                                            const Text(
                                                              "Asset Code: ",
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.grey),
                                                            ),
                                                            // Icon(
                                                            //   Icons.code,
                                                            //   color: Colors.grey.shade600,
                                                            //   size: 18,
                                                            // ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              state
                                                                  .assetFiles[
                                                              index]
                                                                  .assetId ??
                                                                  "",
                                                              style: TextStyle(
                                                                  color: Colors.grey
                                                                      .shade600),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              "Asset ID: ",
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.grey),
                                                            ),
                                                            // Icon(
                                                            //   Icons.numbers_sharp,
                                                            //   color: Colors.grey.shade600,
                                                            //   size: 18,
                                                            // ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              state
                                                                  .assetFiles[
                                                              index]
                                                                  .assetId ??
                                                                  "",
                                                              style: TextStyle(
                                                                  color: Colors.grey
                                                                      .shade600),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                      ],
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
                                  child: Text("No ASSETS found "),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ],
                      ),
                    ),
                  ),



                ),
              );
            });
      },
    );
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
                              "Work Order Documents",
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

// Helper methods for download/view (you'll need to implement these)
  void _downloadDocument(String documentPath) async {
    // Implement download logic using the documentPath
    print("Downloading: $documentPath");
  }

  void _viewDocument(String documentPath) async {
    // Implement view logic using the documentPath
    print("Viewing: $documentPath");
  }


  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      File selectedFile = File(result.files.first.path!);

      try {
        // Upload the file to the server
        String responseMessage = await WorkOrderStatusUpdateApi.createworkorderdoc(
          widget.workOrder.workOrderId!,
          selectedFile,
        );

        // Update the state with the new file
        setState(() {
          fileStr.add(result.files.first.name);
          filesCount = fileStr.length;
        });

        print("Response: $responseMessage");
      } catch (e) {
        print("Error uploading file: $e");
      }
    } else {
      print("No file selected");
    }
  }


  // Future<dynamic> buildWOFilesModelPopup(
  //     BuildContext context, List<String>? fileStr) {
  //   print("result${fileStr}");
  //   return showCupertinoModalPopup(
  //     context: context,
  //     builder: (BuildContext builder) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //         return Card(
  //           shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(16),
  //                   topRight: Radius.circular(16),
  //                   bottomLeft: Radius.zero,
  //                   bottomRight: Radius.zero)),
  //           child: CupertinoPopupSurface(
  //             child: Container(
  //               color: CupertinoColors.white,
  //               alignment: Alignment.center,
  //               width: double.infinity,
  //               height: 730,
  //               child: Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         IconButton(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           icon: const Icon(Icons.close),
  //                         ),
  //                         const Text(
  //                           "Added Files",
  //                           style: TextStyle(
  //                               fontSize: 18, fontWeight: FontWeight.bold),
  //                         ),
  //                         const SizedBox(
  //                           width: 50,
  //                         )
  //                       ],
  //                     ),
  //                     const Divider(
  //                       thickness: 1.5,
  //                     ),
  //                     Expanded(
  //                       child: ListView.builder(
  //                           shrinkWrap: true,
  //                           itemCount: fileStr?.length ?? 0,
  //                           itemBuilder: (context, index) {
  //                             return Text(fileStr?[index] ?? '',
  //                                 style: const TextStyle(
  //                                     fontSize: 14,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.bold));
  //
  //
  //
  //                           }),
  //                     ),
  //                     SizedBox(
  //                       height: MediaQuery.of(context).viewInsets.bottom,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

/////////////////////////// DROP DOWN FIELD \\\\\\\\\\\\\\\\\\\\\\\\\\

  Widget buildDropDownField(List<String> dropDownValues) {
    return GestureDetector(
      onTap: () {
        _selected.toLowerCase() == 'close'
            ? null
            : showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.only(top: 30, left: 8, right: 8),
                    height: 200,
                    alignment: Alignment.center,
                    child: ListView.separated(
                      itemCount: workorderStatus.length,
                      separatorBuilder: (context, ints) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: SizedBox(
                            child: Row(
                              children: [
                                workorderStatus[index].icon,
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  workorderStatus[index].title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selected = workorderStatus[index].title;
                              _selectedForPost = workorderStatus[index].value;
                              print("_selectedForPost${_selectedForPost}");
                            });
                            // _workOrderStatusUpdateCubit.updateWorkOrderStatus(
                            //     widget.workOrder.id!, _selectedForPost);
                            BlocProvider.of<WorkorderBloc>(context).add(
                              WorkOrderStatusUpDateEvent(
                                  workOrderId: widget.workOrder.workOrderId!,
                                  status: _selectedForPost),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "WorkOrder Status Updated Successfully"),
                              ),
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  );
                },
              );
      },
      child: Opacity(
        opacity: _selected.toLowerCase() == 'close' ? 0.3 : 1.0,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -3),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          // title: Text(widget.workOrder.status ?? ""),
          title: Text(
            _selected,
          ),
          leading: const Icon(Icons.circle_outlined),
          trailing: const Icon(Icons.keyboard_arrow_down_outlined),
        ),
      ),
    );
  }

  /////////////////////////// BOTTOM SHEET FOR STATUS UPDATE \\\\\\\\\\\\\\\\\\\\\\\\\\
  Future<dynamic> buildUpdateStatusBottomSheet(
      BuildContext context, List<WorkOrderStatusUpdateModel2> status) {
    void updateSelectedString(String newString) {
      setState(() {
        selectedString = newString;
        WorkOrderStatusUpdateApi.updateWorkOrderStatus(
            widget.workOrder.workOrderId!, selectedString);
      });
    }

    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              bottom: Radius.zero, top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return StatusUpdateSheetBottom2(
            selectedStatus: widget.workOrder.status!,
            checkBoxListTileModel: status,
            selectedItem: (String newString) {
              setState(() {});
              updateSelectedString(newString);
            },
          );
        });
  }

  /////////////////////////// BOTTOM SHEET FOR ASSET DETAILS \\\\\\\\\\\\\\\\\\\\\\\\\\
  Future<dynamic> buildAssetDetailsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              bottom: Radius.zero, top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return AssetSheetBottom(
            checkBoxListTileModel: checkBoxListTileModel,
            workOrder: widget.workOrder,
          );
        });
  }

  void _showBottomSheet(
    BuildContext context,
    String assetTypeId,
    String assetName,
    String priorityId,
    String assetsDesc,
    String criticalId,
    String parentId,
    String failureClassesId,
    String locationId,
    String rotating,
    String assetCategoryId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.gas_meter_rounded), text: 'General'),
                    Tab(icon: Icon(Icons.settings_applications), text: 'Parts'),
                    Tab(icon: Icon(Icons.work), text: 'Work'),
                    Tab(icon: Icon(Icons.type_specimen), text: 'Specification'),
                  ],
                ),
              ),
              Container(
                height: 390,
                child: TabBarView(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          children: [
                            _buildInfoItem('Asset Type Id', assetTypeId),
                            _buildInfoItem('Asset Name', assetName),
                            _buildInfoItem('Priority Id', priorityId),
                            _buildInfoItem('Asset Desc', assetsDesc),
                            _buildInfoItem('Criticality Id', criticalId),
                            _buildInfoItem('Parent Id', parentId),
                            _buildInfoItem(
                                'Failure Classes Id', FailureClassesId),
                            _buildInfoItem('Location Id', LocationId),
                            _buildInfoItem('Rotating', Rotating),
                            _buildInfoItem(
                                'Asset Category Id', AssetCategoryId),
                          ],
                        )),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PartsTable(assetParts: assetParts))),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: WorkTable(WorkOrderList: WorkOrderList))),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SpecifictionTable())),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/////////////////////////// BOTTOM SHEET FOR ASSET \\\\\\\\\\\\\\\\\\\\\\\\\\
// Future<dynamic> buildViewAssetBottomSheet(BuildContext context) {
//   return showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(bottom: Radius.zero, top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return SizedBox(
//           height: MediaQuery.of(context).size.height * .20,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(
//                   height: 6,
//                 ),
//                 Center(
//                   child: Container(
//                     height: 3,
//                     width: 30,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.grey.shade400,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 15),
//                   child: TextButton(
//                     onPressed: () => [
//                       buildAssetDetailsBottomSheet(context),
//                       // Navigator.of(context).pop()
//                     ],
//                     child: const Text(
//                       "View Asset",
//                       style: TextStyle(color: Colors.black, fontSize: 16),
//                     ),
//                   ),
//                 ),
//                 const Divider(),
//
//                 /* ------------------ List View ------------------ */
//               ],
//             ),
//           ),
//         );
//       });
// }

/////////////////////////// BUILD FAB \\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////////////  \\\\\\\\\\\\\\\\\\\\\\\\\\
// Widget buildFAB(
//     Duration timerDuration, String timerText, Function(Duration duration) formatDuration) {
//   bool isTimerRunning = false;
//
//   void startTimer() {
//     const oneSecond = Duration(seconds: 1);
//     Timer.periodic(oneSecond, (Timer timer) {
//       if (!isTimerRunning) {
//         timer.cancel();
//       } else {
//         setState(() {
//           seconds++;
//           timerDuration = Duration(seconds: seconds);
//           timerText = formatDuration(timerDuration);
//         });
//       }
//     });
//   }
//
//   void toggleTimer() {
//     setState(() {
//       isTimerRunning = !isTimerRunning;
//     });
//
//     if (isTimerRunning) {
//       startTimer();
//     }
//   }
//
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//     child: SizedBox(
//       width: double.infinity,
//       child: FloatingActionButton.extended(
//         elevation: 0,
//         backgroundColor: Colors.green.shade700,
//         onPressed: toggleTimer,
//         icon: const Icon(
//           Icons.play_arrow_rounded,
//           size: 34,
//         ),
//         label: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Text(isTimerRunning ? 'Stop Working' : 'Start Working'),
//             Text(
//               timerText,
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

/*|----------------------- STATUS UPDATE BOTTOM SHEET WIDGET -----------------------|*/

class StatusUpdateSheetBottom extends StatelessWidget {
  const StatusUpdateSheetBottom({
    super.key,
    required this.checkBoxListTileModel,
  });

  final List<WorkOrderStatusUpdateModel> checkBoxListTileModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .38,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 6,
            ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                "Update Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(),

            /* ------------------ List View ------------------ */

            Expanded(
              child: ListView.separated(
                  itemCount: checkBoxListTileModel.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 35,
                      child: Center(
                        child: ListTile(
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: checkBoxListTileModel[index].icon,
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Text(
                            checkBoxListTileModel[index].title,
                            style: const TextStyle(
                                fontSize: 14,
                                // fontWeight:
                                //     FontWeight
                                //         .w600,
                                letterSpacing: 0.5),
                          ),
                          trailing: checkBoxListTileModel[index].isCheck
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                )
                              : null,
                          selectedColor: Colors.blue,
                          onTap: () {},
                          onLongPress: () {},
                        ),
                      ),
                      // CheckboxListTile(
                      //     activeColor: Colors.pink[300],
                      //     dense: true,
                      //     //font change
                      //     title:  Text(
                      //       checkBoxListTileModel[index].title,
                      //       style: const TextStyle(
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w600,
                      //           letterSpacing: 0.5),
                      //     ),
                      //     value: checkBoxListTileModel[index].isCheck,
                      //
                      //     onChanged: (bool? val) => itemChange(val!, index)),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

/////////////////////////// ASSET BOTTOM SHEET WIDGET \\\\\\\\\\\\\\\\\\\\\\\\\\

class AssetSheetBottom extends StatefulWidget {
  const AssetSheetBottom({
    super.key,
    required this.checkBoxListTileModel,
    required this.workOrder,

  });

  final List<WorkOrderStatusUpdateModel> checkBoxListTileModel;

  final WorkorderEntity workOrder;


  @override
  State<AssetSheetBottom> createState() => _AssetSheetBottomState();
}

class _AssetSheetBottomState extends State<AssetSheetBottom> {
  @override
  void initState() {
    BlocProvider.of<AssetWorkOrderBloc>(context)
        .add(AssetWorkorderFetchEvent(assetId: widget.workOrder.assetId!));

    // "8296b767-7e59-47ee-9c19-ec9a796f04e8" - This asset Contains parts
    BlocProvider.of<AssetPartsBloc>(context)
        .add(AssetPartFetchEvent(widget.workOrder.assetId!));

    BlocProvider.of<AssetFileBloc>(context)
        .add(AssetFileFetchEvent(widget.workOrder.assetId!));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 660,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.zero),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                  Flexible(
                    child: Text(
                      widget.workOrder.assetName ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 80,
                  )
                ],
              ),
              /////////////////////////// TAB VIEW \\\\\\\\\\\\\\\\\\\\\\\\\\
              DefaultTabController(
                // initialIndex: 1,
                length: 4,
                child: Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        child: TabBar(
                          dividerColor: Colors.grey,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                            color: Colors.blue,
                          ),
                          labelColor: Colors.white,
                          tabs: const [
                            FittedBox(
                                fit: BoxFit.none, child: Tab(text: 'Details')),
                            // FittedBox(
                            //     fit: BoxFit.none, child: Tab(text: 'Files')),
                            // FittedBox(
                            //     fit: BoxFit.none,
                            //     child: Tab(text: 'WorkOrders')),
                            // FittedBox(
                            //     fit: BoxFit.none, child: Tab(text: 'Parts')),
                          ],
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: TabBarView(
                          children: [
                            /////////////////////////// TAB # 1 - ASSET DETAILS TAB \\\\\\\\\\\\\\\\\\\\\\\\\\
                            AssetDetailsTab(workOrder: widget.workOrder),

                            /////////////////////////// TAB # 2 - ASSET FILES TAB \\\\\\\\\\\\\\\\\\\\\\\\\\
                            const AssetFilesTab(),

                            /////////////////////////// TAB # 3 - ASSET WORKORDERS TAB \\\\\\\\\\\\\\\\\\\\\\\\\\
                            const AssetWorkOrderTab(),

                            /////////////////////////// TAB # 4 - ASSET PARTS TAB \\\\\\\\\\\\\\\\\\\\\\\\\\
                            const AssetPartsTab(),
                          ],
                        ),
                      ),
                    ],
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

/////////////////////////////////////////////////////////////
/// WIDGETS
/////////////////////////////////////////////////////////////

/*|-----------------------  -----------------------|*/

/*|----------------------- DUMMY DATA -----------------------|*/

class WorkOrderStatusUpdateModel {
  String title;
  bool isCheck;
  Icon icon;

  WorkOrderStatusUpdateModel(
      {required this.title, required this.isCheck, required this.icon});

  static List<WorkOrderStatusUpdateModel> getUsers() {
    return <WorkOrderStatusUpdateModel>[
      WorkOrderStatusUpdateModel(
        title: "Open",
        isCheck: true,
        icon: const Icon(
          Icons.circle_outlined,
          color: Colors.purple,
        ),
      ),
      WorkOrderStatusUpdateModel(
        title: "Progress",
        isCheck: false,
        icon: const Icon(
          Icons.play_circle_outline_outlined,
          color: Colors.blue,
        ),
      ),
      WorkOrderStatusUpdateModel(
        title: "On Hold",
        isCheck: false,
        icon: const Icon(
          Icons.pause_circle_outline_outlined,
          color: Colors.green,
        ),
      ),
      WorkOrderStatusUpdateModel(
        title: "Complete",
        isCheck: false,
        icon: const Icon(
          Icons.check_circle_outline_outlined,
          color: Colors.red,
        ),
      ),
    ];
  }
}

Widget _buildInfoItem(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(value),
    ],
  );
}

class PartsTable extends StatefulWidget {
  final List<AssetPartsModel> assetParts;

  const PartsTable({super.key, required this.assetParts});

  @override
  State<PartsTable> createState() => _PartsTableState();
}

class _PartsTableState extends State<PartsTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blue,
          child: const Row(
            children: [
              Expanded(
                  child:
                      Text('PartCode', style: TextStyle(color: Colors.white))),
              Expanded(
                  child:
                      Text('PartName', style: TextStyle(color: Colors.white))),
              Expanded(
                  child: Text('Qty', style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.assetParts.length,
            itemBuilder: (context, index) {
              print("assetsss${widget.assetParts.length}");
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                child: Row(
                  children: [
                    Expanded(child: Text(widget.assetParts[index].partCode!)),
                    Expanded(child: Text(widget.assetParts[index].partName!)),
                    Expanded(
                        child: Text(
                            widget.assetParts[index].partQuantity.toString())),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class WorkTable extends StatefulWidget {
  final List<WorkOrder> WorkOrderList;

  const WorkTable({super.key, required this.WorkOrderList});
  @override
  State<WorkTable> createState() => _WorkTableState();
}

class _WorkTableState extends State<WorkTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blue,
          child: const Row(
            children: [
              Expanded(
                  child: Text('Code', style: TextStyle(color: Colors.white))),
              Expanded(
                  child: Text('Description',
                      style: TextStyle(color: Colors.white))),
              Expanded(
                  child:
                      Text('StatusId', style: TextStyle(color: Colors.white))),
              Expanded(
                  child: Text('Plan Start Date',
                      style: TextStyle(color: Colors.white))),
              Expanded(
                  child: Text('Plan End Date',
                      style: TextStyle(color: Colors.white))),
              Expanded(
                  child: Text('Actual Start Date',
                      style: TextStyle(color: Colors.white))),
              Expanded(
                  child: Text('Actual End Date',
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.WorkOrderList.length,
            itemBuilder: (context, index) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                            widget.WorkOrderList[index]!.workOrderCode ?? "")),
                    Expanded(
                        child: Text(
                            widget.WorkOrderList[index]!.description ?? "")),
                    Expanded(
                        child: Text(widget.WorkOrderList[index]!.status ?? "")),
                    Expanded(
                        child: Text(widget
                                .WorkOrderList[index]!.plannedStartDate
                                .toString() ??
                            "")),
                    Expanded(
                        child: Text(widget.WorkOrderList[index]!.plannedEndDate
                                .toString() ??
                            "")),
                    Expanded(
                        child: Text(widget.WorkOrderList[index]!.actualStartDate
                                .toString() ??
                            "")),
                    Expanded(
                        child: Text(widget.WorkOrderList[index]!.actualEndDate
                                .toString() ??
                            ""))
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SpecifictionTable extends StatelessWidget {
  final List<Map<String, dynamic>> specifications = [
    // {"techcode": "P001", "techname": "Widget"},
    // {"techcode": "P001", "techname": "Widget"},
    // {"techcode": "P001", "techname": "Widget"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blue,
          child: const Row(
            children: [
              Expanded(
                  child: Text('Technical Code',
                      style: TextStyle(color: Colors.white))),
              Expanded(
                  child: Text('Technical Name',
                      style: TextStyle(color: Colors.white)))
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: specifications.length,
            itemBuilder: (context, index) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                child: Row(
                  children: [
                    Expanded(child: Text(specifications[index]['techcode'])),
                    Expanded(child: Text(specifications[index]['techname'])),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

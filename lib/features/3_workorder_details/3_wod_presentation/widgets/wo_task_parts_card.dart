import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../2_wod_data/workorder_task_parts.dart';
import '../bloc/work_order_task_parts_cubit.dart';

class WorkOrderTaskPartsCard extends StatefulWidget {
  final String workOrderId;

  const WorkOrderTaskPartsCard({super.key, required this.workOrderId});

  @override
  State<WorkOrderTaskPartsCard> createState() => _WorkOrderTaskPartsCardState();
}

class _WorkOrderTaskPartsCardState extends State<WorkOrderTaskPartsCard> {
  List<WorkOrderTaskPart> parts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    setState(() => isLoading = true);
    try {
      final fetchedParts = await fetchWorkOrderTaskParts(widget.workOrderId);
      setState(() => parts = fetchedParts);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showPartsModal(context);
      },

      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12.0), // Customize the border radius
          side: const BorderSide(
            color: Colors.grey, // Customize the border color
            width: 1.0, // Customize the border width
          ),
        ),

        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Parts',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  // Text(
                  //   '${parts.length} ${parts.length == 1 ? 'Part' : 'Parts'}',
                  //   style: TextStyle(
                  //     color: Colors.grey.shade600,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    '${parts.length} ${parts.length == 1 ? 'Part' : 'Parts Available'}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),

              // if (isLoading)
              //   const Center(child: CircularProgressIndicator())
              // else if (parts.isEmpty)
              //   const Text(
              //     'No parts assigned to tasks',
              //     style: TextStyle(color: Colors.grey),
              //   )
              // else
              //   Column(
              //     children: parts
              //         .take(3) // Show only first 3 parts in the card
              //         .map((part) => _buildPartItem(part))
              //         .toList(),
              //   ),
              // if (parts.length > 3)
              //   Align(
              //     alignment: Alignment.centerRight,
              //     child: Text(
              //       '+ ${parts.length - 3} more',
              //       style: TextStyle(
              //         color: Colors.blue.shade700,
              //         fontSize: 12,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartItem(WorkOrderTaskPart part) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              part.partName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              'Task: ${part.taskNo}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              'Qty: ${part.quantity}',
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPartsModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Parts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (parts.isEmpty)
                const Center(child: Text('No parts assigned to tasks'))
              else
                Expanded(
                  child: ListView(
                    children: parts.map((part) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            part.partName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Task: ${part.taskNo}'),
                          Text('Quantity: ${part.quantity}'),
                          Text('Code: ${part.code}'),
                          const Divider(),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
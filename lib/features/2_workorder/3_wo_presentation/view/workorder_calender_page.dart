import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkOrderScreen extends StatefulWidget {
  @override
  _WorkOrderScreenState createState() => _WorkOrderScreenState();
}

class _WorkOrderScreenState extends State<WorkOrderScreen> {
  List<dynamic> allWorkOrders = [];
  List<dynamic> filteredWorkOrders = [];
  bool isLoading = true;
  //DateTime? selectedDate;
  DateTime? selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    fetchWorkOrders();
  }




  Future<void> fetchWorkOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? bearerToken = prefs.getString('bearer_token');
      final response = await http.get(
          Uri.parse('https://demoapi.orienseam.com/api/workorder/getall'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $bearerToken',
          }
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          allWorkOrders = jsonResponse["result"];
          _filterWorkOrdersByDate(selectedDate ?? DateTime.now());// Extracting the result object
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _filterWorkOrdersByDate(picked);
      });
    }
  }

  void _filterWorkOrdersByDate(DateTime date) {
    final dateString = dateFormat.format(date);
    setState(() {
      filteredWorkOrders = allWorkOrders.where((order) {
        final orderDate = order['plannedStartDate'] ?? ''; // Adjust this field based on your API response
        return orderDate.contains(dateString);
      }).toList();
    });
  }

  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
      filteredWorkOrders = allWorkOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Orders'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          if (selectedDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearDateFilter,
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredWorkOrders.isEmpty
          ? Center(child: Text('No work orders found'))
          : ListView.builder(
        itemCount: filteredWorkOrders.length,
        itemBuilder: (context, index) {
          final order = filteredWorkOrders[index];
          return Card(

            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(''),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('Status: ${order['status'] ?? 'Unknown'}'),
                  // Text('Created: ${order['createdDate'] ?? 'Unknown'}'),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Text(
                      ' ${order['status'] ?? 'Unknown'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width:
                    MediaQuery.sizeOf(context).width * 0.5,
                    child: Text(
                      order['workOrderName'] ?? 'No Number'
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
                  const SizedBox(width: 8),
                  Text(

                    order['code'] ?? 'No Number',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Aeon',
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  /* ------------------ Other Details - First Line ------------------ */
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        order['locationName'] ?? 'No Number',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Aeon',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

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
                          "${order['assetCode'] ?? 'No Number'} - ${order['assetName'] ?? 'No Number'}",
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
                  Text(

                    'PlannedStartDate: ${order['plannedStartDate'] ?? 'Unknown'}',

                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Aeon',
                      color: Colors.grey[600],
                    ),
                  ),
                  // Add more fields as needed
                ],
              ),

              onTap: () {
                // Handle work order tap
              },
            ),
          );
        },
      ),
    );
  }
}
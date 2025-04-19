import 'dart:convert';
import 'package:eam/features/13_parts/presentation/data/parts.dart';
import 'package:eam/features/7_assets/data/model/asset.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../2_workorder/domain/entities/workorder.dart';
import '../data/parts.dart';

class PartDetailsTab extends StatefulWidget {
  const PartDetailsTab({
    super.key,
    required this.part,
  });

  final Part part;

  @override
  _PartDetailsTabState createState() => _PartDetailsTabState();
}

class _PartDetailsTabState extends State<PartDetailsTab> {
  Map<String, dynamic>? partDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssetDetails();
  }

  Future<void> _fetchAssetDetails() async {
    final String Id = widget.part.id ?? "";
    if (Id.isEmpty) return;

    final String apiUrl = "https://demoapi.orienseam.com/api/inventory/getbyid/$Id";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        partDetails = jsonResponse["result"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (partDetails == null) {
      return const Center(child: Text("No asset details available."));
    }

    return Padding(

      padding: const EdgeInsets.all(16.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(
              child: Text(
                "Parts Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: Colors.lightBlue[50],
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildAssetDetailRow("Part Name", partDetails?["partName"]),
                  _buildAssetDetailRow("Stock Room Name", partDetails?["stockRoomName"]),
                  _buildAssetDetailRow("Bin Name", partDetails?["binName"]),
                  _buildAssetDetailRow("Aisle Name", partDetails?["aisleName"]),
                  _buildAssetDetailRow("Supplier", partDetails?["supplierName"]),
                  _buildAssetDetailRow("Code", partDetails?["code"]),
                  _buildAssetDetailRow("Active Status", partDetails?["isActive"] == true ? "Active" : "Inactive"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetDetailRow(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const Divider(),
      ],
    );
  }
}
import 'dart:convert';
import 'package:eam/features/7_assets/data/model/asset.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../2_workorder/domain/entities/workorder.dart';

class addrequest extends StatefulWidget {
  const addrequest({
    super.key,
    required this.asset,
  });

  final Asset asset;

  @override
  _addrequestState createState() => _addrequestState();
}

class _addrequestState extends State<addrequest> {
  Map<String, dynamic>? assetDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssetDetails();
  }

  Future<void> _fetchAssetDetails() async {
    final String assetId = widget.asset.id ?? "";
    if (assetId.isEmpty) return;

    final String apiUrl = "https://demoapi.orienseam.com/api/assets/getbyid/$assetId"; // Update API URL

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
        assetDetails = jsonResponse["result"]; // Extracting the result object
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

    if (assetDetails == null) {
      return const Center(child: Text("No asset details available."));
    }


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildAssetDetailRow("Asset Name", assetDetails?["assetName"]),
              _buildAssetDetailRow("Model", assetDetails?["model"]),
              _buildAssetDetailRow("Serial Number", assetDetails?["serialNumber"]),
              _buildAssetDetailRow("Manufacturer", assetDetails?["manufacturerName"]),
              _buildAssetDetailRow("Supplier", assetDetails?["supplierName"]),
              _buildAssetDetailRow("Category", assetDetails?["categoryName"]),
              _buildAssetDetailRow("Asset Type", assetDetails?["assetTypeName"]),
              _buildAssetDetailRow("Location Code", assetDetails?["locationCode"]),
              _buildAssetDetailRow("Location Name", assetDetails?["locationName"]),
              _buildAssetDetailRow("Status", assetDetails?["statusName"]),
              _buildAssetDetailRow("Criticality", assetDetails?["criticalityName"]),
              _buildAssetDetailRow("Failure Class", assetDetails?["failureClassName"]),
              _buildAssetDetailRow("Priority", assetDetails?["priorityName"]),
              _buildAssetDetailRow("Purchase Price", "\$${assetDetails?["purchasePrice"] ?? 0}"),
              _buildAssetDetailRow("Installation Date", _formatDate(assetDetails?["installationDate"])),
              _buildAssetDetailRow("Start Date", _formatDate(assetDetails?["startDate"])),
              _buildAssetDetailRow("Expiration Date", _formatDate(assetDetails?["expirationDate"])),
              _buildAssetDetailRow("Warranty Name", assetDetails?["warrantyName"]),
              _buildAssetDetailRow("Warranty Type", assetDetails?["warrantyType"]),
              _buildAssetDetailRow("Warranty Status", assetDetails?["warrantyStatus"]),
              _buildAssetDetailRow("Starting Usage", assetDetails?["startingUsage"]),
              _buildAssetDetailRow("Expiration Usage", assetDetails?["expirationUsage"]),
              _buildAssetDetailRow("Code", assetDetails?["code"]),
              _buildAssetDetailRow("Active Status", assetDetails?["isActive"] == true ? "Active" : "Inactive"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetDetailRow(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink(); // Hide empty values
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

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.year}-${parsedDate.month}-${parsedDate.day}";
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import '../../db/database_helper.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, int> tableCounts = {};
  List<String> tableNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final counts = await _dbHelper.getTableCounts();
      final names = await _dbHelper.getAllTableNames();
      
      setState(() {
        tableCounts = counts;
        tableNames = names;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load database information: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          'Database Tables',
          style: titleTextStyle(),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrowLeft2),
        ),
        actions: [
          IconButton(
            onPressed: _loadTableData,
            icon: Icon(IconlyLight.swap),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading database information...',
                    style: descriptionTextStyle(),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Summary Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(IconlyBold.folder, color: primaryColor, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Database Summary',
                            style: titleTextStyle(
                              size: 18,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Total Tables: ${tableNames.length}',
                        style: titleTextStyle(size: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total Records: ${tableCounts.values.fold(0, (sum, count) => sum + count)}',
                        style: descriptionTextStyle(size: 14),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Tables List
                Text(
                  'Tables & Record Counts',
                  style: titleTextStyle(
                    size: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                SizedBox(height: 12),
                
                ...tableNames.map((tableName) => _buildTableCard(tableName)).toList(),
              ],
            ),
    );
  }

  Widget _buildTableCard(String tableName) {
    final count = tableCounts[tableName] ?? 0;
    final isApiTable = tableName.startsWith('api_');
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isApiTable ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isApiTable 
                ? Colors.blue.withOpacity(0.1) 
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isApiTable ? IconlyBold.download : IconlyBold.document,
            color: isApiTable ? Colors.blue : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          _formatTableName(tableName),
          style: titleTextStyle(size: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isApiTable ? 'Reference Data Table' : 'Local Data Table',
          style: descriptionTextStyle(size: 12),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: count > 0 
                ? Colors.green.withOpacity(0.1) 
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count records',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: count > 0 ? Colors.green : Colors.orange,
            ),
          ),
        ),
        onTap: () => _viewTableData(tableName),
      ),
    );
  }

  String _formatTableName(String tableName) {
    // Convert snake_case to Title Case
    return tableName
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _viewTableData(String tableName) {
    Get.to(() => TableDataScreen(tableName: tableName));
  }
}

class TableDataScreen extends StatefulWidget {
  final String tableName;
  
  const TableDataScreen({super.key, required this.tableName});

  @override
  State<TableDataScreen> createState() => _TableDataScreenState();
}

class _TableDataScreenState extends State<TableDataScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _dbHelper.getTableData(widget.tableName, limit: 100);
      setState(() {
        tableData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load table data: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          _formatTableName(widget.tableName),
          style: titleTextStyle(),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrowLeft2),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : tableData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconlyLight.document,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No data found',
                        style: titleTextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This table is empty',
                        style: descriptionTextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: tableData.length,
                  itemBuilder: (context, index) {
                    final row = tableData[index];
                    return _buildDataCard(row, index);
                  },
                ),
    );
  }

  Widget _buildDataCard(Map<String, dynamic> row, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record ${index + 1}',
            style: titleTextStyle(
              size: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 12),
          ...row.entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${entry.key}:',
                    style: descriptionTextStyle(
                      fontWeight: FontWeight.w600,
                      size: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${entry.value ?? 'null'}',
                    style: descriptionTextStyle(size: 13),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  String _formatTableName(String tableName) {
    return tableName
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
}

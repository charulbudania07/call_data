import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:call_management/provider/connected_call_provider.dart';
import 'custom_drawer.dart';

class ConnectedScreen extends StatefulWidget {
  final String username;

  const ConnectedScreen({super.key, required this.username});

  @override
  State<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends State<ConnectedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ConnectedCallProvider>(context, listen: false);
    provider.fetchCalls();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          provider.isLoading == false) {
        provider.loadMore();
      }
    });
  }


  void _showDateFilterDialog() {
    final provider = Provider.of<ConnectedCallProvider>(context, listen: false);
    DateTime fromDate = provider.fromDate ?? DateTime.now();
    DateTime toDate = provider.toDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),

                  /// FROM DATE
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fromDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          fromDate = picked;
                          if (toDate.isBefore(picked)) {
                            toDate = picked;
                          }
                        });
                      }
                    },
                    child: _buildDateTile("From Date", fromDate),
                  ),

                  const SizedBox(height: 12),

                  /// TO DATE
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: toDate.isBefore(fromDate) ? fromDate : toDate,
                        firstDate: fromDate,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => toDate = picked);
                      }
                    },
                    child: _buildDateTile("To Date", toDate),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          provider.resetFilter();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.setDateRange(fromDate, toDate);
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildDateTile(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(DateFormat('dd MMM yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showActionTypeDialog() {
    final provider = Provider.of<ConnectedCallProvider>(context, listen: false);
    String selected = provider.pendingFilter;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Action Type'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: ['All', 'Answer', 'Verification', 'Cancel']
                    .map((type) => RadioListTile<String>(
                  title: Text(type),
                  value: type,
                  groupValue: selected,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selected = val);
                    }
                  },
                ))
                    .toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.resetFilter();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.applyActionType(selected);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConnectedCallProvider>(context);
    final calls = provider.filteredCalls;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Filter by Date",
            onPressed: _showDateFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: "Filter by Action Type",
            onPressed: _showActionTypeDialog,
          ),
        ],
      ),
      drawer: CustomDrawer(username: widget.username),
      body: Column(
        children: [
          if (provider.isLoading && calls.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  provider.refresh();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: calls.length + 1,
                  itemBuilder: (context, index) {
                    if (index == calls.length) {
                      return provider.isLoading
                          ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()))
                          : const SizedBox();
                    }

                    final call = calls[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Info
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(call.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4,),
                                      Text(call.userPhone),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(call.consultantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4,),
                                      Text(call.consultantPhone),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Call Details
                            const SizedBox(height: 8),
                            if (call.feedComments != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 20),
                                  Text(call.feedComments!.commentText),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        call.feedCreatedAt,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          call.feedComments!.actionType!=null? call.feedComments!.actionType:"",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}


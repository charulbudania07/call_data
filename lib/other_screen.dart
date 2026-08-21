import 'package:call_management/add_comment_screen.dart';
import 'package:call_management/custom_drawer.dart';
import 'package:call_management/provider/others_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OthersScreen extends StatefulWidget {
  final String username;

  const OthersScreen({super.key, required this.username});

  @override
  State<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends State<OthersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OthersProvider>(context, listen: false);
    provider.fetchOtherCalls();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !provider.isLoading) {
        provider.loadMore();
      }
    });
  }

  void _callNow(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }


  void _showDateFilterDialog() {
    final provider = Provider.of<OthersProvider>(context, listen: false);
    DateTime fromDate = provider.fromDate ?? DateTime.now();
    DateTime toDate = provider.toDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Date Range',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
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
                          if (toDate.isBefore(picked)) toDate = picked;
                        });
                      }
                    },
                    child: _buildDateTile("From Date", fromDate),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: toDate.isBefore(fromDate) ? fromDate : toDate,
                        firstDate: fromDate,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => toDate = picked);
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
          Text(DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OthersProvider>(context);
    final calls = provider.otherCalls;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Others'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Filter by Date",
            onPressed: _showDateFilterDialog,
          ),
        ],
      ),
      drawer: CustomDrawer(username: widget.username),
      body: provider.isLoading && calls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : calls.isEmpty
          ? const Center(child: Text('No records found'))
          : RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: calls.length + 1,
          itemBuilder: (context, index) {
            if (index == calls.length) {
              return provider.isLoading
                  ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
                  : const SizedBox();
            }

            final call = calls[index];
            final userName = call.userName.isNotEmpty ? call.userName : 'Unknown';
            final consultantName = call.consultantName.isNotEmpty ? call.consultantName : '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER ROW
                    Row(
                      children: [
                        Expanded(
                          child: Text(userName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(consultantName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(
                            call.callStatus.isNotEmpty ? call.callStatus : '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    /// CONTENT ROW
                    Row(
                      children: [
                        Expanded(child: Text(call.userPhone)),
                        Expanded(child: Text(call.consultantPhone)),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.call, color: Colors.green),
                                onPressed: () => _callNow(
                                    call.userPhone.replaceFirst(RegExp(r'^91'), '')),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.note_add, color: Colors.blue),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddCommentScreen(
                                        id: call.id,
                                        actionType: "other",
                                        screenType: "other",
                                        name: call.userName,
                                        fromVerification: false,
                                      ),
                                    ),
                                  );
                                  if (result != null && result is int) {
                                    provider.removeRecordById(result);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Comment added for ${call.userName}')),
                                    );
                                  }
                                },
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Text(_formatDate(call.callDate)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
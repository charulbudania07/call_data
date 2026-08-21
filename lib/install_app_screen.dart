import 'package:call_management/add_comment_screen.dart';
import 'package:call_management/custom_drawer.dart';
import 'package:call_management/provider/install_app_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallAppScreen extends StatefulWidget {
  final String username;

  const InstallAppScreen({required this.username, super.key});

  @override
  State<InstallAppScreen> createState() => _InstallAppScreenState();
}

class _InstallAppScreenState extends State<InstallAppScreen> {
  final ScrollController _scrollController = ScrollController();

  void _callNow(String number) async {
    print("number$number");
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }



  @override
  void initState() {
    super.initState();

    final provider = Provider.of<InstallAppProvider>(context, listen: false);
    provider.fetchInstallApp();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !provider.isLoading &&
          provider.hasMore) {
        provider.fetchInstallApp(loadMore: true);
      }
    });
  }

  void _showDateFilterDialog() {
    final provider = Provider.of<InstallAppProvider>(context, listen: false);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Install App Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateFilterDialog,
          ),
        ],
      ),
      drawer: CustomDrawer(username: widget.username),
      body: Consumer<InstallAppProvider>(
        builder: (context, provider, _) {
          final data = provider.installApps;

          if (provider.isLoading && data.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                    provider.isLoading == false) {
                  provider.fetchInstallApp(); // 👈 Load more
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async => provider.fetchInstallApp(),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: data.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == data.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final record = data[index];
                    return ListTile(
                      title: Text(record.contactPerson ?? 'No Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: ${record.contactNo ?? '-'}"),
                          SizedBox(height: 4),
                          Text("Address: ${record.address ?? '-'}"),
                          SizedBox(height: 4),
                          Text("Created At: ${record.createdAt ?? '-'}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min, // ✅ Prevent Row from taking full width
                        children: [
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () => _callNow(
                              record.contactNo?.replaceFirst(RegExp(r'^91'), '') ?? '',
                            ),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.note_add, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddCommentScreen(
                                    id: record.id,
                                    actionType: "Install",
                                    name: widget.username,
                                    fromVerification: false,
                                  ),
                                ),
                              );
                              if (result != null && result is int) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Comment added for ${widget.username}')),
                                );
                              }
                            },
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

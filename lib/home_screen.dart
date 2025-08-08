import 'package:call_management/add_comment_screen.dart';
import 'package:call_management/custom_drawer.dart';
import 'package:call_management/model/call_Record.dart';
import 'package:call_management/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = ['Cancel', 'Answer', 'Verification'];

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      provider.fetchDataForTab(
        tabs[0],
        offset: 0,
        limit: 15,
        applyFilter: false, // 🚫 Not saving as filter
      );
    });

    super.initState();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final provider = Provider.of<HomeProvider>(context, listen: false);
    provider.fetchDataForTab(tabs[_tabController.index]);
  }

  void _callNow(String number) async {
    print("number$number");
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }


  void _showDateFilterDialog() {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentTab = tabs[_tabController.index];
    DateTime tempFromDate = provider.getFromDate(currentTab) ?? DateTime.now();
    DateTime tempToDate = provider.getToDate(currentTab) ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Date Range',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    /// From Date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempFromDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            tempFromDate = picked;
                            if (tempToDate.isBefore(picked)) {
                              tempToDate = picked;
                            }
                          });
                        }
                      },
                      child: _buildDateTile("From Date", tempFromDate),
                    ),
                    const SizedBox(height: 12),

                    /// To Date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempToDate.isBefore(tempFromDate) ? tempFromDate : tempToDate,
                          firstDate: tempFromDate,
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => tempToDate = picked);
                        }
                      },
                      child: _buildDateTile("To Date", tempToDate),
                    ),
                    const SizedBox(height: 24),

                    /// Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            provider.resetFilter(currentTab);
                            Navigator.pop(context);
                          },
                          child: Text('Reset'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.updateFilterDates(tempFromDate, tempToDate, currentTab);
                            Navigator.pop(context);
                          },
                          child: Text('Apply'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildDateTile(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                _formatDate(date),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
        ),
        actions: [
          Consumer<HomeProvider>(
            builder: (context, provider, _) {
              final currentTab = tabs[_tabController.index];
              final hasFilter = provider.getFromDate(currentTab) != null &&
                  provider.getToDate(currentTab) != null;

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: _showDateFilterDialog,
                  ),
                  if (hasFilter)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(username: widget.username),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) {
          final records = provider.getByTab(tab);
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (records.isEmpty) {
              return Center(child: Text("No Record found"));
            } else {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                      provider.isLoading == false) {
                    provider.loadMore(tab); // 👈 Load more
                  }
                  return true;
                },
                child: RefreshIndicator(
                  onRefresh: () async => provider.fetchDataForTab(tabs[_tabController.index]),
                  child: ListView.builder(
                              itemCount: records.length,
                              itemBuilder: (_, index) {
                  CallRecord record = records[index];
                  final userName =  tab == 'Verification' ?record.fullName:record.userName;
                  final userPhone =  tab == 'Verification' ?record.phoneNumber:record.userPhone;
                  final consultantName = record.consultantName;
                  final consultantPhone = record.consultantPhone;
                  final status = record.callStatus;
                  final duration = record.callDuration;
                  final callDate = tab == 'Verification' ? DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(record.createdDate)):DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(record.callDate));
                  final id = record.id;
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text(consultantName, style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text(tab == "Answered" ? "${duration.toString()} min" : status, style: TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),

                          /// CONTENT ROW
                          Row(
                            children: [
                              Expanded(
                                child: Text(userPhone),
                              ),
                              Expanded(
                                child: Text(consultantPhone),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.call, color: Colors.green),
                                      onPressed: () => _callNow(userPhone.replaceFirst(RegExp(r'^91'), '')),
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
                                              id: id,
                                              actionType: tab,
                                              name: userName,
                                              fromVerification: tab == 'Verification',
                                            ),
                                          ),
                                        );
                                        if (result != null && result is int) {
                                          provider.removeRecordById(tab, result); // ✅ Call a method to remove the record
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Comment added for $userName')),
                                          );
                                        }
                                      },
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Text(callDate)
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
        }).toList(),
      ),
    );
  }
}
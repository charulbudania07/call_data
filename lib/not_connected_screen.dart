import 'package:call_management/provider/connected_call_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom_drawer.dart';

class NotConnectedScreen extends StatelessWidget {
  final String username;

  const NotConnectedScreen({super.key, required this.username});

  void _callNow(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConnectedCallProvider>(context);
    final calls = provider.filteredCalls;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Connected'),
        actions: [
          Consumer<ConnectedCallProvider>(
            builder: (context, provider, _) {
              final isFiltered = provider.currentFilter != 'All';
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => FilterDialog(),
                      );
                    },
                  ),
                  if (isFiltered)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(username: username),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: calls.length,
                itemBuilder: (context, index) {
                  final call = calls[index];
                  return Card(
                    child: ListTile(
                      title: Text(call.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(call.type),
                          Text(call.comment),
                        ],
                      ),
                      trailing:IconButton(icon: Icon(Icons.call, color: Colors.green),onPressed: (){
                        _callNow(call.number);
                      },),
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

class FilterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConnectedCallProvider>(context);

    String tempFilter = provider.pendingFilter;

    return AlertDialog(
      title: const Text('Filter Calls'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return DropdownButton<String>(
            value: tempFilter,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() => tempFilter = value);
              }
            },
            items: ['All', 'Cancelled', 'Answered', 'Verified']
                .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
                .toList(),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            provider.resetFilter();
            Navigator.of(context).pop();
          },
          child: const Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            provider.setPendingFilter(tempFilter);
            provider.applyFilter();
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}


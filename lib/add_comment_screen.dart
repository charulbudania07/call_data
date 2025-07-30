import 'package:call_management/provider/comment_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AddCommentScreen extends StatefulWidget {
  final int id;
  final String name;
  final String actionType;
  final bool fromVerification;

  const AddCommentScreen({super.key,
    required this.name,
    required this.id,
    required this.actionType,
    this.fromVerification = false,
  });

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? selectedStatus;
  String? selectedProfile;
  bool needFollowUp = false;
  PlatformFile? attachedRecording;

  @override
  Widget build(BuildContext context) {
    final statuses = ['Connected', 'Not Connected'];
    final profileTypes = ['User', 'Consultant'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comment - ${widget.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Call Status
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => selectedStatus = val),
              decoration: InputDecoration(
                labelText: 'Call Status',
                border: OutlineInputBorder(),
              ),
              hint: Text('Select Status'),
              validator: (value) => value == null ? 'Please select a status' : null,
            ),
            const SizedBox(height: 10),

            /// Profile Type (Verification tab only)
            if (widget.fromVerification)
              DropdownButtonFormField<String>(
                value: selectedProfile,
                items: profileTypes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => selectedProfile = val),
                decoration: InputDecoration(
                  labelText: 'Profile Type',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select Profile Type'),
              ),
            const SizedBox(height: 10),

            /// Comment Field
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your comment...',
                border: OutlineInputBorder(),
              ),
            ),

            /// Follow Up Checkbox
            CheckboxListTile(
              title: Text('Need follow up'),
              value: needFollowUp,
              onChanged: (val) => setState(() => needFollowUp = val!),
              contentPadding: EdgeInsets.zero, // removes horizontal padding
              visualDensity: VisualDensity.compact, // reduces vertical padding
            ),

            const SizedBox(height: 10),

            /// Attach Call Recording
           /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  attachedRecording != null ? attachedRecording!.name : 'No file selected',
                  style: TextStyle(fontSize: 14),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.attach_file),
                  label: Text('Attach Recording'),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['mp3', 'm4a', 'aac', 'wav'],
                    );

                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        attachedRecording = result.files.first;
                      });
                    }
                  },
                ),
              ],
            ),*/

            const SizedBox(height: 20),

            /// Submit Button
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Submit'),
              onPressed: () async {
                final comment = _commentController.text.trim();
                if (comment.isEmpty || selectedStatus == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter comment and select a status')),
                  );
                  return;
                }

                final provider = Provider.of<CommentProvider>(context, listen: false);

                /// Submit to API
                final success = await provider.submitCommentToServer(
                  id: widget.id,
                  actionType: widget.actionType,
                  callStatus: selectedStatus!,
                  profileType: selectedProfile,
                  comment: comment,
                  isFollowUp: needFollowUp,
                );

                if (success) {
                  Navigator.pop(context, widget.id); // ✅ Return the ID instead of just `true`
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit comment to server')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

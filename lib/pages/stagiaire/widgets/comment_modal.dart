import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../../constants.dart';

class CommentModal extends StatefulWidget {
  final String voyageId;

  const CommentModal({super.key, required this.voyageId});

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final supabase = Supabase.instance.client;
  final TextEditingController _commentController = TextEditingController();
  File? _selectedImage;
  final String _bucketName = 'comments';
  bool isLoading = true;
  List<dynamic> comments = [];
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = supabase.auth.currentUser!.id;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final response = await supabase
        .from('Commentaire')
        .select('id, text, image_url, stagiaire_id, profiles(name, image_url)')
        .eq('voyage_id', widget.voyageId)
        .order('created_at', ascending: false);

    setState(() {
      comments = response;
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final fileExtension = path.extension(_selectedImage!.path);
      final fileName =
          'trip_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      await supabase.storage
          .from(_bucketName)
          .upload(
            fileName,
            _selectedImage!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );

      return supabase.storage.from(_bucketName).getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitComment() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final text = _commentController.text.trim();

    if (text.isEmpty && _selectedImage == null) {
      Flushbar(
        message: 'Please add some text or attach an image before submitting.',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orangeAccent,
      ).show(context);
      return;
    }

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) return;
      }

      await supabase.from('Commentaire').insert({
        'stagiaire_id': user.id,
        'voyage_id': widget.voyageId,
        'text': text,
        'image_url': imageUrl,
      });

      _commentController.clear();
      _selectedImage = null;
      FocusScope.of(context).unfocus();
      _fetchComments();

      Flushbar(
        message: 'Comment added!',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ).show(context);
    } catch (e) {
      Flushbar(
        message: 'Error uploading image!',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ).show(context);
    }
  }

  Future<void> _confirmDelete(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Delete Comment'),
            content: const Text(
              'Are you sure you want to delete your comment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await supabase.from('Commentaire').delete().eq('id', commentId);
      _fetchComments();
      Flushbar(
        message: 'Comment deleted!',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ).show(context);
    }
  }

  Future<void> _reportComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Report Comment'),
            content: const Text('Do you want to report this comment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Report',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await supabase
          .from('Commentaire')
          .update({'is_signaled': true})
          .eq('id', commentId);
      Flushbar(
        message: 'Comment reported!',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child:
                        isLoading
                            ? const Center(
                              child: CupertinoActivityIndicator(
                                color: kPrimaryColor,
                              ),
                            )
                            : ListView.builder(
                              controller: scrollController,
                              itemCount: comments.length,
                              itemBuilder: (ctx, index) {
                                final comment = comments[index];
                                final profileImg = supabase.storage
                                    .from('profile-images')
                                    .getPublicUrl(
                                      comment['profiles']?['image_url'],
                                    );
                                final String? commentImg = comment['image_url'];

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              profileImg != null
                                                  ? NetworkImage(profileImg)
                                                  : null,
                                          radius: 24,
                                          child:
                                              profileImg == null
                                                  ? const Icon(Icons.person)
                                                  : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    comment['profiles']['name'] ??
                                                        'User',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: kPrimaryColor,
                                                    ),
                                                  ),
                                                  comment['stagiaire_id'] ==
                                                          currentUserId
                                                      ? IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed:
                                                            () =>
                                                                _confirmDelete(
                                                                  comment['id'],
                                                                ),
                                                      )
                                                      : IconButton(
                                                        icon: const Icon(
                                                          Icons.flag_outlined,
                                                          color: Colors.orange,
                                                        ),
                                                        onPressed:
                                                            () =>
                                                                _reportComment(
                                                                  comment['id'],
                                                                ),
                                                      ),
                                                ],
                                              ),
                                              if (comment['text'] != null &&
                                                  comment['text']
                                                      .toString()
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    comment['text'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              if (commentImg != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: Image.network(
                                                      commentImg,
                                                      height: 160,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  const Divider(height: 16, color: kPrimaryColor),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                      top: 8,
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _commentController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: 'Write a comment...',
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.image),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: kPrimaryColor,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _submitComment,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

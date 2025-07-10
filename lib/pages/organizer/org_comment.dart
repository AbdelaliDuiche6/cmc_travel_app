import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:another_flushbar/flushbar.dart';

class OrgCommentPage extends StatefulWidget {
  const OrgCommentPage({super.key});

  @override
  State<OrgCommentPage> createState() => _OrgCommentPageState();
}

class _OrgCommentPageState extends State<OrgCommentPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final String _bucketName = 'comments';

  List<Map<String, dynamic>> completedTripsWithReservations = [];
  List<Map<String, dynamic>> comments = [];
  Map<String, dynamic>? currentUserProfile;
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserProfile();
    _fetchCompletedTripsWithReservations();
  }

  Future<void> _fetchCurrentUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profileResponse =
          await supabase
              .from('profiles')
              .select('name, image_url')
              .eq('id', user.id)
              .single();

      if (profileResponse != null) {
        final imageUrl = profileResponse['image_url'];
        String fullImageUrl = '';

        if (imageUrl != null && imageUrl.isNotEmpty) {
          fullImageUrl = supabase.storage
              .from('profile-images')
              .getPublicUrl(imageUrl);
        }

        setState(() {
          currentUserProfile = {
            'name': profileResponse['name'],
            'image_url': fullImageUrl,
          };
        });
      }
    } catch (e) {
      print('Error fetching current user profile: $e');
    }
  }

  Future<void> _fetchCompletedTripsWithReservations() async {
    try {
      setState(() => isLoading = true);

      final user = supabase.auth.currentUser;
      if (user == null) return;

      final reservationsResponse = await supabase
          .from('Reservation')
          .select(''' 
            *,
            voyage:voyage_id(*),
            stagiaire:stagiaire_id(*)
          ''')
          .eq('voyage.organizer_id', user.id)
          .eq('status', 'Completed');

      final List<Map<String, dynamic>> reservations =
          List<Map<String, dynamic>>.from(reservationsResponse);

      final Map<String, Map<String, dynamic>> tripsMap = {};
      for (var reservation in reservations) {
        final voyage = reservation['voyage'];
        if (voyage != null) {
          final voyageId = voyage['id'];
          if (!tripsMap.containsKey(voyageId)) {
            tripsMap[voyageId] = {
              ...voyage,
              'reservations': <Map<String, dynamic>>[],
            };
          }
          tripsMap[voyageId]!['reservations'].add(reservation);
        }
      }

      setState(() {
        completedTripsWithReservations = tripsMap.values.toList();
      });

      if (completedTripsWithReservations.isNotEmpty) {
        await _fetchCommentsForAllReservations();
      }
    } catch (e) {
      print('Error fetching completed trips: $e');
      _showErrorSnackbar('Error loading trips: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCommentsForAllReservations() async {
    try {
      final voyageIds =
          completedTripsWithReservations.map((trip) => trip['id']).toList();
      if (voyageIds.isEmpty) return;

      final commentsResponse = await supabase
          .from('Commentaire')
          .select(''' 
            *,
            stagiaire:stagiaire_id(*),
            voyage:voyage_id(*)
          ''')
          .inFilter('voyage_id', voyageIds);

      final List<Map<String, dynamic>> commentsWithUserDetails = [];
      final currentUserId = supabase.auth.currentUser?.id;

      for (var comment in commentsResponse) {
        final stagiaireId = comment['stagiaire_id'];

        if (stagiaireId == currentUserId && currentUserProfile != null) {
          comment['user'] = {
            'name': currentUserProfile!['name'],
            'image_url': currentUserProfile!['image_url'],
          };
          commentsWithUserDetails.add(comment);
        } else {
          try {
            final userResponse =
                await supabase
                    .from('profiles')
                    .select('name, image_url')
                    .eq('id', stagiaireId)
                    .single();

            if (userResponse != null) {
              final imageUrl = userResponse['image_url'];
              String fullImageUrl = '';
              if (imageUrl != null && imageUrl.isNotEmpty) {
                fullImageUrl = supabase.storage
                    .from('profile-images')
                    .getPublicUrl(imageUrl);
              }

              comment['user'] = {
                'name': userResponse['name'],
                'image_url': fullImageUrl,
              };
              commentsWithUserDetails.add(comment);
            }
          } catch (e) {
            print(
              'Error fetching user profile for stagiaire_id $stagiaireId: $e',
            );
            comment['user'] = {'name': 'Unknown User', 'image_url': ''};
            commentsWithUserDetails.add(comment);
          }
        }
      }

      setState(() {
        comments = commentsWithUserDetails;
      });
    } catch (e) {
      print('Error fetching comments: $e');
      _showErrorSnackbar('Error loading comments: $e');
    }
  }

  Future<void> _banComment(String commentId) async {
    try {
      await supabase
          .from("Commentaire")
          .update({'is_signaled': true})
          .eq('id', commentId);
      _showSuccessSnackbar('Comment signaled');
      await _fetchCommentsForAllReservations();
    } catch (e) {
      print('Error signale comment: $e');
      _showErrorSnackbar('Failed to signale comment');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await supabase.from('Commentaire').delete().eq('id', commentId);
      _showSuccessSnackbar('Comment deleted');
      await _fetchCommentsForAllReservations();
    } catch (e) {
      print('Error deleting comment: $e');
      _showErrorSnackbar('Failed to delete comment');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final fileExtension = path.extension(_selectedImage!.path);
      final fileName =
          'comment_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      await supabase.storage
          .from(_bucketName)
          .upload(fileName, _selectedImage!);

      return supabase.storage.from(_bucketName).getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorSnackbar('Error uploading image');
      return null;
    }
  }

  Future<void> _sendComment(String voyageId, String stagiaireId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final text = _commentController.text.trim();
      if (text.isEmpty && _selectedImage == null) {
        _showErrorSnackbar('Please add a comment or image');
        return;
      }

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) return;
      }

      await supabase.from('Commentaire').insert({
        'voyage_id': voyageId,
        'stagiaire_id': user.id,
        'text': text.isNotEmpty ? text : null,
        'image_url': imageUrl,
      });

      _commentController.clear();
      setState(() => _selectedImage = null);
      await _fetchCommentsForAllReservations();
      _showSuccessSnackbar('Comment sent successfully');

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error sending comment: $e');
      _showErrorSnackbar('Failed to send comment: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    ).show(context);
  }

  void _showErrorSnackbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
    ).show(context);
  }

  List<Map<String, dynamic>> _getCommentsForVoyage(String voyageId) {
    return comments
        .where((comment) => comment['voyage_id'] == voyageId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Comments'),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : completedTripsWithReservations.isEmpty
              ? const Center(
                child: Text(
                  'No completed trips found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: completedTripsWithReservations.length,
                itemBuilder: (context, index) {
                  final trip = completedTripsWithReservations[index];
                  return _buildTripCard(trip);
                },
              ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final voyageId = trip['id'];
    final reservations = List<Map<String, dynamic>>.from(
      trip['reservations'] ?? [],
    );
    final tripComments = _getCommentsForVoyage(voyageId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      trip['image_url'] != null
                          ? Image.network(
                            trip['image_url'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                          : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(DateTime.parse(trip['date'] ?? '0000-01-01')),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        '${reservations.length} participant(s)',
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Display comments with ban option
          if (tripComments.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...tripComments.map(
              (comment) => _buildCommentBubble(comment),
            ), // Use _buildCommentBan to include ban functionality
          ],

          // Display reservation sections
          ...reservations.map(
            (reservation) => _buildReservationSection(reservation, trip),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBubble(Map<String, dynamic> comment) {
    final user = comment['user'] ?? {};
    final currentUserId = supabase.auth.currentUser?.id;
    final isCurrentUser = comment['stagiaire_id'] == currentUserId;
    final profileImageUrl = user['image_url'];
    final fullName = user['name'] ?? 'Unknown';
    final commentId = comment['id'];

    if (isCurrentUser) {
      return Dismissible(
        key: Key('comment_$commentId'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete Comment"),
                content: const Text(
                  "Are you sure you want to delete this comment?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          _deleteComment(commentId);
        },
        child: _buildCommentContent(
          comment,
          isCurrentUser,
          profileImageUrl,
          fullName,
        ),
      );
    } else {
      return _buildCommentContent(
        comment,
        isCurrentUser,
        profileImageUrl,
        fullName,
      );
    }
  }

  Widget _buildCommentContent(
    Map<String, dynamic> comment,
    bool isCurrentUser,
    String? profileImageUrl,
    String fullName,
  ) {
    final commentId = comment['id'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            _buildProfileAvatar(profileImageUrl, fullName),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue[500] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentUser ? '${fullName} (Organizer)' : fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color:
                              isCurrentUser ? Colors.white : Colors.grey[700],
                        ),
                      ),

                      if (comment['text'] != null &&
                          comment['text'].isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          comment['text'],
                          style: TextStyle(
                            color:
                                isCurrentUser ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],

                      if (comment['image_url'] != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            comment['image_url'],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Add ban button for non-current user comments
                if (!isCurrentUser)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.flag, color: Colors.red[400], size: 18),
                      onPressed: () => _showBanConfirmationDialog(commentId),
                    ),
                  ),
              ],
            ),
          ),

          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            _buildProfileAvatar(profileImageUrl, fullName),
          ],
        ],
      ),
    );
  }

  void _showBanConfirmationDialog(String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Comment"),
          content: const Text(
            "Are you sure you want to report this comment as inappropriate?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _banComment(commentId);
              },
              child: const Text("Report", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar(String? profileImageUrl, String fullName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        child:
            (profileImageUrl != null && profileImageUrl.isNotEmpty)
                ? Image.network(
                  profileImageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[200],
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      ),
                    );
                  },
                )
                : Container(
                  width: 40,
                  height: 40,
                  color: Colors.blue[100],
                  child: Center(
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildReservationSection(
    Map<String, dynamic> reservation,
    Map<String, dynamic> trip,
  ) {
    final stagiaire = reservation['stagiaire'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      stagiaire?['full_name']?.substring(0, 1) ?? 'S',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stagiaire?['full_name'] ?? 'Participant',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _buildCommentInput(trip['id'], reservation['stagiaire_id']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput(String voyageId, String stagiaireId) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: Colors.blue),
                onPressed: _pickImage,
                iconSize: 20,
              ),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Type your reply...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () => _sendComment(voyageId, stagiaireId),
                iconSize: 20,
              ),
            ],
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() => _selectedImage = null);
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

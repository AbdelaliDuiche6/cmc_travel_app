import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportedCommentsPage extends StatefulWidget {
  const ReportedCommentsPage({Key? key}) : super(key: key);

  @override
  State<ReportedCommentsPage> createState() => _ReportedCommentsPageState();
}

class _ReportedCommentsPageState extends State<ReportedCommentsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    setState(() => isLoading = true);

    final response = await supabase
        .from('commentaire')
        .select()
        .eq('is_signaled', true);

    setState(() {
      comments = response;
      isLoading = false;
    });
  }

  Future<void> deleteComment(String id) async {
    await supabase.from('commentaire').delete().eq('id', id);
    fetchComments();
  }

  Future<void> banUser(String stagiaireId) async {
    await supabase
        .from('stagiaire')
        .update({'banned': true})
        .eq('id', stagiaireId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User $stagiaireId banned')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚨 Reported Comments')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : comments.isEmpty
              ? const Center(child: Text('No reported comments.'))
              : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Comment: ${comment['text']}'),
                            Text('Note: ${comment['note']}'),
                            Text('Voyage ID: ${comment['voyage_id']}'),
                            if (comment['image_url'] != null)
                              Image.network(comment['image_url']),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () =>
                                      deleteComment(comment['id']),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.block),
                                  label: const Text('Ban User'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange),
                                  onPressed: () =>
                                      banUser(comment['stagiaire_id']),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

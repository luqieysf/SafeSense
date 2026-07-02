import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/child_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class EventLogSelectChildScreen extends StatefulWidget {
  const EventLogSelectChildScreen({super.key});

  @override
  State<EventLogSelectChildScreen> createState() =>
      _EventLogSelectChildScreenState();
}

class _EventLogSelectChildScreenState
    extends State<EventLogSelectChildScreen> {
  final _db = FirestoreService();
  List<ChildProfile> _children = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ids  = auth.currentUser?.linkedChildIds ?? [];
    final list = await _db.getChildrenForUser(ids);
    if (mounted) setState(() { _children = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.darkGray, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Log Event — Select Child',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                  color: AppColors.sageGreen))
                  : _children.isEmpty
                  ? const Center(
                  child: Text(
                    'No children linked yet.\n'
                        'Add a child from the dashboard first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGray),
                  ))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _children.length,
                itemBuilder: (_, i) {
                  final c = _children[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.parentEventLog,
                        arguments: c.childId),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warmBeige,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.softBlue,
                            backgroundImage:
                            c.profileImageUrl.isNotEmpty
                                ? NetworkImage(c.profileImageUrl)
                                : null,
                            child: c.profileImageUrl.isEmpty
                                ? const Icon(Icons.person,
                                color: AppColors.darkGray)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGray,
                                    )),
                                Text(
                                  'Tokens: ${c.tokenBalance}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: AppColors.sageGreen, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

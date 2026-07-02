import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/child_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
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
            // header
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
                  const Text('Select Child',
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
                      'No children linked yet.',
                      style: TextStyle(
                          color: AppColors.darkGray)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _children.length,
                itemBuilder: (_, i) {
                  final s = _children[i];
                  final now = DateTime.now();
                  final currentMonth =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}';
                  final showBadge =
                      s.lastEventMonth == currentMonth &&
                          s.monthlyEventCount > 0;

                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.studentEvents,
                        arguments: s),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
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
                            s.profileImageUrl.isNotEmpty
                                ? NetworkImage(s.profileImageUrl)
                                : null,
                            child: s.profileImageUrl.isEmpty
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
                                Text(s.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGray,
                                    )),
                                Text('Tokens: ${s.tokenBalance}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkGray,
                                    )),
                              ],
                            ),
                          ),
                          if (showBadge)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${s.monthlyEventCount} this month',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              color: AppColors.darkGray),
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

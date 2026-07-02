import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/child_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class ParentChildrenScreen extends StatefulWidget {
  const ParentChildrenScreen({super.key});

  @override
  State<ParentChildrenScreen> createState() =>
      _ParentChildrenScreenState();
}

class _ParentChildrenScreenState extends State<ParentChildrenScreen> {
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
                  const Expanded(
                    child: Text('My Children',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        )),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.parentAddChild)
                        .then((_) => _load()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Add',
                              style: TextStyle(
                                color: Colors.white, fontSize: 13,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                  color: AppColors.sageGreen))
                  : _children.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.child_care,
                        color: AppColors.dustyGray, size: 60),
                    const SizedBox(height: 16),
                    const Text('No children added yet.',
                        style: TextStyle(color: AppColors.darkGray)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.parentAddChild)
                          .then((_) => _load()),
                      child: const Text('Add Child'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _children.length,
                itemBuilder: (_, i) {
                  final c = _children[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.parentEditChild,
                        arguments: c)
                        .then((_) => _load()),
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
                            radius: 28,
                            backgroundColor: AppColors.softBlue,
                            backgroundImage:
                            c.profileImageUrl.isNotEmpty
                                ? NetworkImage(c.profileImageUrl)
                                : null,
                            child: c.profileImageUrl.isEmpty
                                ? const Icon(Icons.person,
                                color: AppColors.darkGray,
                                size: 28)
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
                                  'Tokens: ${c.tokenBalance}  •  PIN: ${c.pin}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit,
                              color: AppColors.sageGreen, size: 20),
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

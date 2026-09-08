import 'dart:convert';
import 'dart:typed_data';
import 'package:aner_astaner/features/rewards_page/domain/entities/reward.dart';
import 'package:aner_astaner/features/rewards_page/domain/repositories/reward_repository.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RewardsPage extends StatefulWidget {
  final String? churchId;
  final String? chapterId;
  const RewardsPage({super.key, this.churchId, this.chapterId});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  bool _isAdmin = false;
  String? _churchId;
  String? _chapterId;

  @override
  void initState() {
    super.initState();
    checkIfAdmin();
    _resolveOrganization();
  }

  Future<void> _resolveOrganization() async {
    if (widget.churchId != null && widget.chapterId != null) {
      if (!mounted) return;
      setState(() {
        _churchId = widget.churchId;
        _chapterId = widget.chapterId;
      });
      return;
    }
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      _churchId = widget.churchId ?? profile?.churchId;
      _chapterId = widget.chapterId ?? profile?.chapterId;
    });
  }

  Future<void> checkIfAdmin() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    final role = profile?.role ?? "user";

    if (role == "Admin" || role == "SuperAdmin") {
      setState(() => _isAdmin = true);
    }
  }

  Future<String?> uploadImage(Uint8List bytes) async {
    const apiKey = '617c18f7c03af1e2bba0fec00c6f96ab';
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'),
      body: {'image': base64Image, 'name': 'reward_image'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['url'];
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ فشل رفع الصورة")));
      return null;
    }
  }

  Future<void> addOrEditReward({String? docId, String? oldImageUrl}) async {
    final churchId = _churchId;
    final chapterId = _chapterId;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    Uint8List? newImageBytes;
    String? finalUrl = oldImageUrl;

    if (docId != null) {
      final data = await Get.find<RewardRepository>().fetchRewardData(docId);
      if (data != null) {
        titleController.text = data['title'] ?? "";
        descController.text = data['description'] ?? "";
      }
    }

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(docId == null ? "إضافة جائزة" : "تعديل الجائزة"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          requestFullMetadata: false,
                        );

                        if (image != null) {
                          newImageBytes = await image.readAsBytes();
                          setDialogState(() {});
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: newImageBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(newImageBytes!),
                                  fit: BoxFit.cover,
                                )
                              : (finalUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(finalUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child: finalUrl == null && newImageBytes == null
                            ? const Icon(Icons.add_a_photo, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "عنوان الجائزة",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "وصف الجائزة",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("إلغاء"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("حفظ"),
                  onPressed: () async {
                    if (newImageBytes != null) {
                      finalUrl = await uploadImage(newImageBytes!);
                    }

                    if (finalUrl == null ||
                        titleController.text.trim().isEmpty ||
                        descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("❌ يجب إدخال كل البيانات"),
                        ),
                      );
                      return;
                    }

                    final data = {
                      'imageUrl': finalUrl,
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'churchId': churchId,
                      'chapterId': chapterId,
                    };

                    if (docId == null) {
                      await Get.find<RewardRepository>().addReward(data);
                    } else {
                      await Get.find<RewardRepository>().updateReward(
                        docId,
                        data,
                      );
                    }

                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteReward(String docId) async {
    await Get.find<RewardRepository>().deleteReward(docId);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("🗑️ تم حذف الجائزة")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏆 الجوائز"), centerTitle: true),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => addOrEditReward(),
              child: const Icon(Icons.add),
            )
          : null,
      body: _churchId == null || _chapterId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Reward>>(
              stream: Get.find<RewardRepository>().watchRewards(
                churchId: _churchId!,
                chapterId: _chapterId!,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rewards = snapshot.data!;

                if (rewards.isEmpty) {
                  return const Center(child: Text("لا توجد جوائز بعد 🎁"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final docId = reward.id;

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                reward.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reward.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reward.description,
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (_isAdmin)
                            OverflowBar(
                              alignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => addOrEditReward(
                                    docId: docId,
                                    oldImageUrl: reward.imageUrl,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteReward(docId),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
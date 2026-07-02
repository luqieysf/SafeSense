import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/child_provider.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';

class ChildAudioScreen extends StatefulWidget {
  const ChildAudioScreen({super.key});

  @override
  State<ChildAudioScreen> createState() => _ChildAudioScreenState();
}

class _ChildAudioScreenState extends State<ChildAudioScreen> {
  String?  _customPath;
  bool     _loading    = true;
  bool     _picking    = false;
  bool     _previewing = false;
  final    AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final child = Provider.of<ChildProvider>(context, listen: false);
    final id    = child.childProfile?.childId ?? '';
    final path  = await AudioService.getCustomAudioPath(id);
    if (mounted) setState(() { _customPath = path; _loading = false; });
  }

  Future<void> _pickAudio() async {
    final child = Provider.of<ChildProvider>(context, listen: false);
    final id    = child.childProfile?.childId ?? '';
    if (id.isEmpty) return;

    setState(() => _picking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type:           FileType.audio,
        allowMultiple:  false,
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _picking = false);
        return;
      }

      final sourcePath = result.files.single.path!;
      final ext        = sourcePath.split('.').last;

      // copy to app documents directory so it persists
      final appDir  = await getApplicationDocumentsDirectory();
      final destPath = '${appDir.path}/calming_audio_$id.$ext';
      await File(sourcePath).copy(destPath);

      await AudioService.saveCustomAudioPath(id, destPath);

      if (mounted) {
        setState(() { _customPath = destPath; _picking = false; });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom audio saved!')));
      }
    } catch (e) {
      setState(() => _picking = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _previewAudio() async {
    if (_previewing) {
      await _audio.stop();
      if (mounted) setState(() => _previewing = false);
      return;
    }

    setState(() => _previewing = true);
    final child = Provider.of<ChildProvider>(context, listen: false);
    await _audio.playWhiteNoise(childId: child.childProfile?.childId);

    // auto stop after 5 seconds preview
    await Future.delayed(const Duration(seconds: 5));
    await _audio.stop();
    if (mounted) setState(() => _previewing = false);
  }

  Future<void> _removeCustomAudio() async {
    final child = Provider.of<ChildProvider>(context, listen: false);
    final id    = child.childProfile?.childId ?? '';

    // delete local file
    if (_customPath != null && File(_customPath!).existsSync()) {
      await File(_customPath!).delete();
    }
    await AudioService.clearCustomAudioPath(id);

    if (mounted) {
      setState(() => _customPath = null);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content:
          Text('Custom audio removed. Default white noise will play.')));
    }
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
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
                  const Text('Calming Audio',
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
                  : ListView(
                padding: const EdgeInsets.all(20),
                children: [

                  // info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.info_outline,
                              color: AppColors.darkGray, size: 18),
                          SizedBox(width: 8),
                          Text('About Calming Audio',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGray,
                              )),
                        ]),
                        SizedBox(height: 8),
                        Text(
                          'You can replace the default white noise with '
                              'a custom calming sound (MP3, WAV, etc.) '
                              'stored on this device. The audio will play '
                              'when the child presses the overwhelmed button.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.darkGray),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // current audio status
                  const Text('Current Audio',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _customPath != null
                          ? AppColors.sageGreen
                          : AppColors.warmBeige,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            _customPath != null
                                ? Icons.music_note
                                : Icons.volume_up,
                            color: AppColors.darkGray, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                _customPath != null
                                    ? 'Custom Audio'
                                    : 'Default White Noise',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                              Text(
                                _customPath != null
                                    ? _customPath!.split('/').last
                                    : 'white_noise.mp3 (built-in)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkGray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // preview button
                  ElevatedButton.icon(
                    onPressed: _previewAudio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pastelTeal,
                      foregroundColor: AppColors.darkGray,
                    ),
                    icon: Icon(_previewing
                        ? Icons.stop : Icons.play_arrow),
                    label: Text(_previewing
                        ? 'Stop Preview' : 'Preview Audio (5s)'),
                  ),
                  const SizedBox(height: 24),

                  // upload custom audio
                  const Text('Change Audio',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _picking ? null : _pickAudio,
                    icon: _picking
                        ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.upload_file),
                    label: Text(_picking
                        ? 'Picking...' : 'Choose Audio File'),
                  ),
                  const SizedBox(height: 12),

                  // remove custom audio
                  if (_customPath != null) ...[
                    ElevatedButton.icon(
                      onPressed: _removeCustomAudio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lavender,
                        foregroundColor: AppColors.darkGray,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore Default White Noise'),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
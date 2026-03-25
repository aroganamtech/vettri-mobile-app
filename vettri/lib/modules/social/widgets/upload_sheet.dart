import 'package:flutter/material.dart';

class UploadSheet extends StatefulWidget {
  final String initialType;
  const UploadSheet({super.key, this.initialType = 'Post'});

  @override
  State<UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<UploadSheet> {
  final TextEditingController _captionController = TextEditingController();
  late String _selectedType;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Create New', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: _isUploading ? null : () => _handleUpload(context),
                    child: Text(
                      _isUploading ? 'Sharing...' : 'Share',
                      style: TextStyle(
                        color: _isUploading ? Colors.grey : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Selector — Post / Clip / Story
                    Row(
                      children: ['Post', 'Clip', 'Story'].map((type) {
                        final isSelected = _selectedType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Media Picker
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!, width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedType == 'Clip' ? Icons.videocam_outlined : Icons.add_photo_alternate_outlined,
                              size: 56,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedType == 'Clip' ? 'Tap to select a video' : 'Tap to select photos',
                              style: TextStyle(color: Colors.grey[600], fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedType == 'Clip' ? 'MP4, MOV up to 60 seconds' : 'JPG, PNG up to 10MB',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Caption', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _captionController,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: InputDecoration(
                        hintText: 'Write a caption... Add hashtags #',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OptionTile(icon: Icons.location_on_outlined, title: 'Add Location'),
                    _OptionTile(icon: Icons.people_outline, title: 'Tag People'),
                    _OptionTile(icon: Icons.music_note_outlined, title: 'Add Music'),
                    _OptionTile(
                      icon: Icons.public,
                      title: 'Audience',
                      trailing: const Text('Everyone', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
            if (_isUploading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _handleUpload(BuildContext context) {
    setState(() => _isUploading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $_selectedType shared successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _OptionTile({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}

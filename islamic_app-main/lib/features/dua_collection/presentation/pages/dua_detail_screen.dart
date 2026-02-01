import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua.dart';
import 'package:deenhub/features/dua_collection/domain/repositories/dua_repository.dart';

class DuaDetailScreen extends StatefulWidget {
  final Dua dua;
  final Function(Dua) onFavoriteToggled;

  const DuaDetailScreen({
    super.key,
    required this.dua,
    required this.onFavoriteToggled,
  });

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  final DuaRepository _duaRepository = DuaRepository();
  late Dua _dua;
  
  @override
  void initState() {
    super.initState();
    _dua = widget.dua;
  }
  
  void _toggleFavorite() {
    final updatedDua = _duaRepository.toggleFavorite(_dua);
    setState(() {
      _dua = updatedDua;
    });
    widget.onFavoriteToggled(updatedDua);
  }
  
  void _copyDuaToClipboard(String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$type copied to clipboard"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: _dua.title,
      appBarActions: [
        IconButton(
          icon: Icon(
            _dua.isFavorite ? Icons.favorite : Icons.favorite_outline,
            color: _dua.isFavorite ? Colors.red : null,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            _showShareOptions(context);
          },
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryBadge(),
            const SizedBox(height: 24),
            _buildArabicText(),
            const SizedBox(height: 24),
            _buildTransliterationSection(),
            const SizedBox(height: 24),
            _buildTranslationSection(),
            const SizedBox(height: 24),
            _buildReferenceSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryBadge() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _dua.category,
            style: TextStyle(
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_dua.subcategory != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              _dua.subcategory!,
              style: TextStyle(
                color: context.primaryColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildArabicText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Arabic",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () => _copyDuaToClipboard(_dua.arabicText, "Arabic text"),
              tooltip: "Copy Arabic text",
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceContainerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _dua.arabicText,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 24,
              height: 1.8,
              fontFamily: 'Amiri', // Make sure a suitable Arabic font is available
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransliterationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Transliteration",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () => _copyDuaToClipboard(_dua.transliteration, "Transliteration"),
              tooltip: "Copy transliteration",
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceContainerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _dua.transliteration,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: context.onSurfaceColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTranslationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Translation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () => _copyDuaToClipboard(_dua.translation, "Translation"),
              tooltip: "Copy translation",
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceContainerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _dua.translation,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildReferenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu_book,
            color: Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Reference",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dua.reference,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Share Dua",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy Arabic Text"),
                onTap: () {
                  _copyDuaToClipboard(_dua.arabicText, "Arabic text");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy Transliteration"),
                onTap: () {
                  _copyDuaToClipboard(_dua.transliteration, "Transliteration");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy Translation"),
                onTap: () {
                  _copyDuaToClipboard(_dua.translation, "Translation");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy All"),
                onTap: () {
                  final allText = 
                      "Arabic:\n${_dua.arabicText}\n\n"
                      "Transliteration:\n${_dua.transliteration}\n\n"
                      "Translation:\n${_dua.translation}\n\n"
                      "Reference: ${_dua.reference}";
                  _copyDuaToClipboard(allText, "Complete dua");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 
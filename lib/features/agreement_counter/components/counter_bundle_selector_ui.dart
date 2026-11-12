import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/document_template_model.dart';

class CounterBundleSelectorUi extends StatelessWidget {
  final List<String> availableTemplates;
  final List<String> selectedTemplates;
  final Map<String, DocumentTemplateModel> templateModelsMap;
  final Map<String, bool> templateHasCustomStamp;
  final Function(String title) onToggleTemplate;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final Function(String title) onOpenSingleEditor;
  final Function(String title) onDeleteTemplate;
  final Function(String title) onAttachStampToTemplate;

  const CounterBundleSelectorUi({
    super.key,
    required this.availableTemplates,
    required this.selectedTemplates,
    required this.templateModelsMap,
    required this.templateHasCustomStamp,
    required this.onToggleTemplate,
    required this.onSelectAll,
    required this.onClearAll,
    required this.onOpenSingleEditor,
    required this.onDeleteTemplate,
    required this.onAttachStampToTemplate,
  });

  void _showDeleteConfirmation(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'ٹیمپلیٹ ڈیلیٹ کریں؟',
                style: TextStyle(fontFamily: 'JameelNoori', fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'کیا آپ واقعی "$title" کو ہمیشہ کے لیے ڈیلیٹ کرنا چاہتے ہیں؟\nیہ عمل واپس نہیں لایا جا سکے گا۔',
            style: const TextStyle(fontFamily: 'JameelNoori', fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ کریں', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onDeleteTemplate(title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('ہاں، ڈیلیٹ کریں'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(80),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.layers_outlined, size: 18, color: AppColors.primaryEmerald),
              const SizedBox(width: 6),
              const Text(
                'دستاویزات بنڈل منتخب کریں:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              _buildCapsuleButton(
                label: 'سب چنیں',
                icon: Icons.done_all,
                color: AppColors.primaryEmerald,
                onTap: onSelectAll,
              ),
              const SizedBox(width: 6),
              _buildCapsuleButton(
                label: 'صاف کریں',
                icon: Icons.clear_all,
                color: Colors.red.shade700,
                onTap: onClearAll,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableTemplates.map((t) {
                final isSelected = selectedTemplates.contains(t);
                final doc = templateModelsMap[t];
                
                // اہم چیک: کیا یہ ٹیمپلیٹ اسٹامپ اوورلے والا ہے؟
                final bool isStampOverlay = doc?.mode == DocumentMode.stampOverlay;
                final bool hasCustomStamp = templateHasCustomStamp[t] ?? false;

                return Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryEmerald.withAlpha(20) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryEmerald : const Color(0xFFCBD5E1),
                      width: isSelected ? 1.6 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => onToggleTemplate(t),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                              size: 18,
                              color: isSelected ? AppColors.primaryEmerald : Colors.black45,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? AppColors.primaryEmerald : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // اسٹامپ اٹیچ کرنے کا بٹن صرف اور صرف ای-اسٹامپ موڈ والے پر ہوگا
                      if (isStampOverlay) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: hasCustomStamp ? 'نئے گاہک کا اسٹامپ منسلک ہے (بدلنے کیلئے کلک کریں)' : 'اس معاہدے کیلئے گاہک کا ای-اسٹامپ PDF چنیں',
                          child: InkWell(
                            onTap: () => onAttachStampToTemplate(t),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: hasCustomStamp ? AppColors.successGreen : Colors.brown.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.picture_as_pdf, size: 12, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    hasCustomStamp ? 'اسٹامپ ✓' : 'اسٹامپ +',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(width: 6),
                      Container(height: 14, width: 1, color: Colors.black26),
                      const SizedBox(width: 4),
                      Tooltip(
                        message: 'ایڈیٹر میں کھولیں',
                        child: InkWell(
                          onTap: () => onOpenSingleEditor(t),
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(Icons.edit_note, size: 18, color: AppColors.primaryEmerald),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Tooltip(
                        message: 'ٹیمپلیٹ ڈیلیٹ کریں',
                        child: InkWell(
                          onTap: () => _showDeleteConfirmation(context, t),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(Icons.close, size: 15, color: Colors.red.shade600),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
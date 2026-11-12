import '../../../core/models/document_template_model.dart';
import '../../../core/models/overlay_box_model.dart';
import '../../../core/time/time_status_service.dart';
import '../../../core/utils/tag_extraction_helper.dart';
import '../models/stamp_overlay_field_model.dart';

class StampPayloadBuilder {
  static Map<String, dynamic> build({
    required String title,
    required String content,
    required String paperSize,
    required double topMargin,
    required double subsequentTopMargin,
    required double bottomMargin,
    required double subsequentBottomMargin,
    required double sideMargin,
    required double fontSize,
    required String? base64Pdf,
    required String? stampFileName,
    required List<String> pages,
    required List<StampOverlayFieldModel> overlayFields,
  }) {
    final now = TimeStatusService.nowUtcIso();
    final List<OverlayBoxModel> floatingBoxes = overlayFields.map((f) {
      return OverlayBoxModel(
        id: f.id,
        tag: f.tag,
        x: f.x,
        y: f.y,
        width: f.width,
        height: 35.0,
        fontSize: f.fontSize,
        isBold: f.isBold,
        isUnderline: f.isUnderline,
        isMultiLine: false,
      );
    }).toList();

    final Set<String> allExtractedFields = {};
    for (final tag in TemplateService.extractFields(content)) {
      allExtractedFields.add(tag);
    }
    for (final f in overlayFields) {
      if (!f.isStaticText) {
        for (final tag in TemplateService.extractFields(f.tag)) {
          if (tag.isNotEmpty) {
            allExtractedFields.add(tag);
          }
        }
      }
    }

    final doc = DocumentTemplateModel(
      id: title.trim(),
      title: title.trim(),
      content: content.trim(),
      mode: DocumentMode.stampOverlay,
      paperSize: paperSize,
      topMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      subsequentBottomMargin: subsequentBottomMargin,
      sideMargin: sideMargin,
      fontSize: fontSize,
      base64Pdf: base64Pdf,
      stampFileName: stampFileName,
      floatingBoxes: floatingBoxes,
      fields: allExtractedFields.toList(),
      pages: pages,
    );

    final map = doc.toMap();
    map['isSynced'] = false;
    map['updatedAt'] = now;
    map['createdAt'] = now;
    map['isDeleted'] = false;
    return map;
  }
}
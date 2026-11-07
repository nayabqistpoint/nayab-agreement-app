class TemplateStudioArgs {
  final String? templateTitle;
  final String? templateContent;
  final String? paperSize;
  final bool? isEStamp;
  final double? topMargin;
  final double? subsequentTopMargin;
  final double? bottomMargin;
  final double? sideMargin;

  const TemplateStudioArgs({
    this.templateTitle,
    this.templateContent,
    this.paperSize,
    this.isEStamp,
    this.topMargin,
    this.subsequentTopMargin,
    this.bottomMargin,
    this.sideMargin,
  });
}
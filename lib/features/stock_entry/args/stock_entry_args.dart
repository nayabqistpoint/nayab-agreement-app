class StockEntryArgs {
  final Map<String, dynamic>? editingItem;
  final Map<String, dynamic>? prefillOrderData;
  final String? linkToOrderId;
  final int initialCategoryIndex;
  const StockEntryArgs({
    this.editingItem,
    this.prefillOrderData,
    this.linkToOrderId,
    this.initialCategoryIndex = 0,
  });
}
import 'package:flutter/material.dart';
import '../stock_inventory/services/stock_inventory_storage_service.dart';
class StockEntryController extends ChangeNotifier {
  int selectedCategoryIndex;
  StockMap? editingItem;
  int currentQuantity = 1;
  StockEntryController({
    this.editingItem,
    this.selectedCategoryIndex = 0,
  }) {
    if (editingItem != null) {
      final cat = editingItem!['productCategory']?.toString() ?? 'MOBILE';
      selectedCategoryIndex = (cat == 'ELECTRONICS') ? 1 : 0;
      currentQuantity = 1;
    }
  }
  void setCategory(int index) {
    if (editingItem != null) return;
    selectedCategoryIndex = index;
    notifyListeners();
  }
  void incrementQuantity() {
    if (currentQuantity < 50) {
      currentQuantity++;
      notifyListeners();
    }
  }
  void decrementQuantity() {
    if (currentQuantity > 1) {
      currentQuantity--;
      notifyListeners();
    }
  }
  Future<({int count, String firstStockId, String firstCode})> saveStockItem({
    required String stockId,
    required String itemName,
    required String imeiOrSerial,
    required String specsOrRam,
    required String color,
    required int purchasePrice,
    required int salePrice,
    required String supplier,
    required String conditionType,
    required String conditionRating,
    required int warranty,
    required bool isOnOrder,
    int quantity = 1,
    Map<String, String> dynamicFields = const {},
    Map<String, List<String>> perUnitOverrides = const {},
    required List<String> images,
    List<List<String>> perUnitImages = const [],
    String? linkToOrderId,
  }) async {
    final cat = selectedCategoryIndex == 1 ? 'ELECTRONICS' : 'MOBILE';
    return await StockInventoryStorageService.saveStock(
      stockId: stockId,
      category: cat,
      itemName: itemName,
      imeiOrSerial: imeiOrSerial,
      specsOrRam: specsOrRam,
      color: color,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      supplier: supplier,
      conditionType: conditionType,
      conditionRating: conditionRating,
      warrantyMonths: warranty,
      isOnOrder: isOnOrder,
      quantity: quantity,
      dynamicFields: dynamicFields,
      perUnitOverrides: perUnitOverrides,
      images: images,
      perUnitImages: perUnitImages,
      linkToOrderId: linkToOrderId,
    );
  }
}
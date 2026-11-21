import 'package:flutter/material.dart';
import 'services/stock_inventory_storage_service.dart';

class StockInventoryController extends ChangeNotifier {
  int selectedCategoryIndex = 0;
  String statusFilter = 'ACTIVE';
  StockMap? editingItem;
  int currentQuantity = 1;

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

  StockList getFilteredStock() {
    final all = StockInventoryStorageService.getAllStockItems();
    if (statusFilter == 'SOLD') {
      return all
          .where((i) => (i['status']?.toString() ?? '').toUpperCase() == 'SOLD')
          .toList();
    }
    return all
        .where((i) => (i['status']?.toString() ?? '').toUpperCase() != 'SOLD')
        .toList();
  }

  int get activeCount => StockInventoryStorageService.getAllStockItems()
      .where((i) => (i['status']?.toString() ?? '').toUpperCase() != 'SOLD')
      .length;

  int get soldCount => StockInventoryStorageService.getAllStockItems()
      .where((i) => (i['status']?.toString() ?? '').toUpperCase() == 'SOLD')
      .length;

  void setStatusFilter(String filter) {
    statusFilter = filter;
    notifyListeners();
  }

  void setCategory(int index) {
    selectedCategoryIndex = index;
    editingItem = null;
    notifyListeners();
  }

  void startEditing(StockMap item) {
    editingItem = item;
    currentQuantity = 1;
    final cat = item['productCategory']?.toString() ?? 'MOBILE';
    selectedCategoryIndex = (cat == 'ELECTRONICS') ? 1 : 0;
    notifyListeners();
  }

  void cancelEdit() {
    editingItem = null;
    notifyListeners();
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
    final result = await StockInventoryStorageService.saveStock(
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
    editingItem = null;
    currentQuantity = 1;
    notifyListeners();
    return result;
  }

  Future<bool> deleteStockItem(String stockId) async {
    final ok = await StockInventoryStorageService.deleteStock(stockId);
    notifyListeners();
    return ok;
  }

  Future<int> purgeDeleted() async {
    final count = await StockInventoryStorageService.purgeAllDeletedRecords();
    notifyListeners();
    return count;
  }

  Future<int> resetAllToZero() async {
    final count = await StockInventoryStorageService.resetAllTestDataToZero();
    editingItem = null;
    currentQuantity = 1;
    notifyListeners();
    return count;
  }
}
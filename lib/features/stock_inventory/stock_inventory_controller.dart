import 'package:flutter/material.dart';
import 'services/stock_inventory_storage_service.dart';

class StockInventoryController extends ChangeNotifier {
  int selectedCategoryIndex = 0;
  StockMap? editingItem;

  StockList getAllStock() {
    return StockInventoryStorageService.getAllStockItems();
  }

  void setCategory(int index) {
    selectedCategoryIndex = index;
    editingItem = null;
    notifyListeners();
  }

  void startEditing(StockMap item) {
    editingItem = item;
    final cat = item['productCategory']?.toString() ?? 'MOBILE';
    selectedCategoryIndex = (cat == 'ELECTRONICS') ? 1 : 0;
    notifyListeners();
  }

  void cancelEdit() {
    editingItem = null;
    notifyListeners();
  }

  Future<bool> saveStockItem({
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
    required List<String> images,
  }) async {
    final cat = selectedCategoryIndex == 1 ? 'ELECTRONICS' : 'MOBILE';
    await StockInventoryStorageService.saveStock(
      stockId: stockId,
      category: cat,
      itemName: itemName,
      imeiOrSerial: imeiOrSerial,
      specsOrRam: specsOrRam,
      color: color,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      supplierInfo: supplier,
      conditionType: conditionType,
      conditionRating: conditionRating,
      warrantyMonths: warranty,
      images: images,
    );
    editingItem = null;
    notifyListeners();
    return true;
  }

  Future<bool> deleteStockItem(String stockId) async {
    final ok = await StockInventoryStorageService.deleteStock(stockId);
    notifyListeners();
    return ok;
  }
}
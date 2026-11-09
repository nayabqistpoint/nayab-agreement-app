import 'package:flutter/material.dart';
import '../../customer_directory/customer_directory_page.dart';
import '../../stamp_agreement/stamp_studio_page.dart';

class CounterNavigationService {
  static Future<bool?> openEditor(BuildContext context, String templateTitle) async {
    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StampStudioPage(initialTitle: templateTitle),
      ),
    );
  }

  static Future<bool?> openStudio(BuildContext context, Widget studioPage) async {
    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => studioPage),
    );
  }

  static void openCustomerDirectory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerDirectoryPage()),
    );
  }
}
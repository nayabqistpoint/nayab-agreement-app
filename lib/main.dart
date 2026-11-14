import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/database/hive_box_manager.dart';
import 'features/agreement_counter/agreement_counter_page.dart';
import 'firebase_options.dart';
import 'sync/master_sync_hub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await HiveBoxManager.initialize();
  MasterSyncHub.startWatcher();
  runApp(const NayabAgreementApp());
}

class NayabAgreementApp extends StatelessWidget {
  const NayabAgreementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نایاب ایگریمنٹ جنریٹر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'JameelNoori',
        primaryColor: AppColors.primaryEmerald,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryEmerald,
          primary: AppColors.primaryEmerald,
        ),
        useMaterial3: true,
      ),
      home: const AgreementCounterPage(),
    );
  }
}
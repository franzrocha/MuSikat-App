import 'package:flutter/material.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/support_screens/transaction_screen.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/support_screens/wallet_screen.dart';
import 'package:musikat_app/screens/home/leaderboard.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/utils/exports.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: musikatBackgroundColor,
        appBar: CustomAppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Support',
                  style: appBarStyle,
                ),
              ),
            ],
          ),
          showLogo: false,
        ),
        body: Column(
          children: [
            TabBar(
              indicator: PillTabIndicator(
                indicatorColor: const Color(0xffE28D00),
                indicatorHeight: 50,
              ),
              tabs: const [
                Tab(
                  text: 'Wallet',
                ),
                Tab(
                  text: 'Transactions',
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  WalletScreen(),
                  TransactionScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/support_screens/cash_in_screen.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/support_screens/list_of_all_supporters.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/support_screens/list_of_all_you_supported.dart';
import 'package:musikat_app/utils/constants.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletTransactionService _walletService = WalletTransactionService();
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() async {
    double balance = await _walletService.getBalance();
    setState(() {
      _balance = balance;
    });
  }

  Future<void> _refreshData() async {
    _loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xff353434),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AVAILABLE BALANCE',
                          style: shortThinStyle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '₱ ${NumberFormat('#,##0.00').format(_balance)}',
                          style: moneyText.copyWith(
                            fontSize: 30,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.24,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const CashInScreen()),
                          );
                        },
                        child: const Text(
                          '+ Cash In',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            color: Color(0xff353434),
            thickness: 2,
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.fromLTRB(25, 45, 25, 15),
              decoration: BoxDecoration(
                color: const Color(0xff353434),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text('Total Number of Supporters',
                          style: shortDefault.copyWith(
                            fontSize: 20,
                          )),
                    ),
                    FutureBuilder<List<String>>(
                      future:
                          _walletService.getArtistThatSupportedMe(currentUser),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> snapshot) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data?.length.toString() ?? '0',
                              style: moneyText.copyWith(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListOfAllSupportersScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View List',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.fromLTRB(25, 0, 25, 60),
              decoration: BoxDecoration(
                color: const Color(0xff353434),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Total Number You Supported',
                        style: shortDefault.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    FutureBuilder<List<String>>(
                      future: _walletService.getArtistYouSupported(currentUser),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> snapshot) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data?.length.toString() ?? '0',
                              style: moneyText.copyWith(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ListOfAllYouSupportedScreen()),
                                  );
                                },
                                child: const Text(
                                  'View List',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

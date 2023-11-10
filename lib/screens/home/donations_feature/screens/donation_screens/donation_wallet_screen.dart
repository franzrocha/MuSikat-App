import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/donation_screens/donation_send_screen.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/donation_screens/donations_list_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class DonationWalletScreen extends StatefulWidget {
  final String userIdtoSupport;
  const DonationWalletScreen({super.key, required this.userIdtoSupport});

  @override
  State<DonationWalletScreen> createState() => _DonationWalletScreenState();
}

class _DonationWalletScreenState extends State<DonationWalletScreen> {
  final WalletTransactionService _walletService = WalletTransactionService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: musikatBackgroundColor,
        appBar: CustomAppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Donate',
                  style: appBarStyle,
                ),
              ),
            ],
          ),
          showLogo: false,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xff353434),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'AVAILABLE BALANCE',
                        style: shortThinStyle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      '₱ ${NumberFormat('#,##0.00').format(_balance)}',
                      style: moneyText.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => DonationSendScreen(
                                      userIdtoSupport: widget.userIdtoSupport,
                                    )),
                          );
                        },
                        child: const Text(
                          '+  Send Money',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color(0xff353434),
              thickness: 2,
            ),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff353434),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('Your donation(s) in this account',
                            style: shortDefault.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            )),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        width: MediaQuery.of(context).size.width * 0.24,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => DonationsListScreen(
                                        userIdtoSupport: widget.userIdtoSupport,
                                      )),
                            );
                          },
                          child: const Text(
                            'View List',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }
}

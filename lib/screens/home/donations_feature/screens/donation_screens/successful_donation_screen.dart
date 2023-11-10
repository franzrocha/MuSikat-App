import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/donation_screens/donation_wallet_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class SuccessfulDonationScreen extends StatelessWidget {
  final String userIdtoSupport;
  final double amount;
  final DateTime date;
  const SuccessfulDonationScreen(
      {super.key,
      required this.amount,
      required this.date,
      required this.userIdtoSupport});

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
                  const Icon(
                    Icons.check_rounded,
                    color: Color(0xff36B774),
                    size: 120,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text('Sent',
                      style: moneyText.copyWith(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Successfully!',
                      style: moneyText.copyWith(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 23,
                  ),
                  const Divider(
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text('Amount',
                          style: shortThinStyle.copyWith(
                              fontSize: 17, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text('₱ ${NumberFormat('#,##0.00').format(amount)}',
                          style: shortThinStyle.copyWith(
                              fontSize: 17, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(DateFormat('MMMM d, yyyy h:mm a').format(date),
                      style: shortThinStyle),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.9,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => DonationWalletScreen(
                            userIdtoSupport: userIdtoSupport,
                          )),
                );
              },
              child: const Text(
                'Done',
              ),
            ),
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}

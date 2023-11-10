import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/screens/home/donations_feature/models/user_transaction.dart';
import 'package:musikat_app/screens/home/donations_feature/widgets/transaction_dialog.dart';
import 'package:musikat_app/utils/exports.dart';

class DonationsListScreen extends StatelessWidget {
  final String userIdtoSupport;

  DonationsListScreen({super.key, required this.userIdtoSupport});

  final WalletTransactionService walletService = WalletTransactionService();
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

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
      body: StreamBuilder<List<UserTransaction>>(
        stream:
            walletService.fetchDonationHistory(currentUser, userIdtoSupport),
        builder: (BuildContext context,
            AsyncSnapshot<List<UserTransaction>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data?.isEmpty ?? true) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Text(
                    'You don’t have any donation',
                    style: shortDefault.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'in this account yet. ',
                    style: shortDefault.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          } else {
            List<UserTransaction> transactions =
                snapshot.data?.reversed.toList() ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xff353434),
                  ),
                  child: Text(
                    'Your donation(s) in this account: ${transactions.length}',
                    style: shortDefault.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      height: 0.1,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final transaction = transactions[index];

                      return ListTile(
                        title: Text(
                          'Send Money',
                          style: shortDefault.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('MMMM d, y h:mm a')
                              .format(transaction.transactionDate),
                          style: shortDefault.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₱ ${NumberFormat('#,##0.00').format(transaction.amount)}',
                              style: shortDefault.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              splashRadius: 20,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return TransactionDialog(
                                      title: 'Donation Details',
                                      description:
                                          'Thank you for donating in this artist account. Your donation will be used to support the artist\'s career.',
                                      transactionDate:
                                          DateFormat('MM/d/y h:mm a').format(
                                              transaction.transactionDate),
                                      amount: transaction.amount,
                                      message: transaction.transactionMessage,
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

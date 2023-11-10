import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/screens/home/donations_feature/models/user_transaction.dart';
import 'package:musikat_app/screens/home/donations_feature/widgets/transaction_dialog.dart';
import 'package:musikat_app/utils/exports.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletTransactionService walletService = WalletTransactionService();
    Stream<List<UserTransaction>> transactionsStream =
        walletService.transactionsStream();
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xff353434),
            ),
            child: Text(
              'Transactions as of ${DateFormat('MMMM d, y h:mm a').format(DateTime.now())}',
              style: shortDefault.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserTransaction>>(
              stream: transactionsStream, // Use your provided function
              builder: (BuildContext context,
                  AsyncSnapshot<List<UserTransaction>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<UserTransaction> transactions =
                      snapshot.data?.reversed.toList() ?? [];

                  return ListView.separated(
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
                          transaction.transactionType == 'cash_in'
                              ? 'Cash In'
                              : transaction.transactionType ==
                                      'donation_transaction'
                                  ? 'Send Money'
                                  : 'Receive Money',
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
                                if (transaction.transactionType == 'cash_in') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return TransactionDialog(
                                        title: 'Transaction Details',
                                        description: 'Cash In via InApp Wallet',
                                        transactionDate:
                                            DateFormat('MM/d/y h:mm a').format(
                                                transaction.transactionDate),
                                        amount: transaction.amount,
                                      );
                                    },
                                  );
                                } else if (transaction.transactionType ==
                                    'donation_transaction') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FutureBuilder<UserModel>(
                                        future: UserModel.fromUid(
                                            uid: transaction.artistId ?? ''),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<UserModel> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            UserModel userModel =
                                                snapshot.data!;
                                            return TransactionDialog(
                                              title: 'Transaction Details',
                                              description:
                                                  'Send Money to ${userModel.username} ',
                                              transactionDate:
                                                  DateFormat('MM/d/y h:mm a')
                                                      .format(transaction
                                                          .transactionDate),
                                              amount: transaction.amount,
                                              message: transaction
                                                  .transactionMessage,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FutureBuilder<UserModel>(
                                        future: UserModel.fromUid(
                                            uid: transaction.donorId ?? ''),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<UserModel> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            UserModel userModel =
                                                snapshot.data!;
                                            return TransactionDialog(
                                              title: 'Transaction Details',
                                              description:
                                                  'You receive money from your fan ${userModel.username} ',
                                              transactionDate:
                                                  DateFormat('MM/d/y h:mm a')
                                                      .format(transaction
                                                          .transactionDate),
                                              amount: transaction.amount,
                                              message: transaction
                                                  .transactionMessage,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  );
                                }
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
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

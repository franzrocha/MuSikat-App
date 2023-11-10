// ignore_for_file: use_build_context_synchronously

import 'package:intl/intl.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/donation_screens/successful_donation_screen.dart';
import 'package:musikat_app/screens/home/donations_feature/models/user_transaction.dart';
import 'package:musikat_app/utils/exports.dart';

class ConfirmDonationScreen extends StatefulWidget {
  final String userIdtoSupport;
  final double amount;
  final String message;

  const ConfirmDonationScreen(
      {super.key,
      required this.amount,
      required this.message,
      required this.userIdtoSupport});

  @override
  State<ConfirmDonationScreen> createState() => _ConfirmDonationScreenState();
}

class _ConfirmDonationScreenState extends State<ConfirmDonationScreen> {
  final WalletTransactionService walletService = WalletTransactionService();
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() async {
    double balance = await walletService.getBalance();
    setState(() {
      _balance = balance;
    });
  }

  Align fullnameText(snapshot) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(
          '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
          style: moneyText.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  usernameText(snapshot) {
    return Text(
      snapshot.data!.username,
      style: shortThinStyle.copyWith(
        fontSize: 12,
      ),
    );
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
              child: StreamBuilder<Object>(
                  stream: UserModel.fromUidStream(uid: widget.userIdtoSupport),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Container();
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          fullnameText(snapshot),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xff9D9D9D),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: usernameText(snapshot),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text('Wallet',
                                  style: shortThinStyle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Text(
                                  '₱ ${NumberFormat('#,##0.00').format(_balance)}',
                                  style: shortThinStyle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "You're about to send",
                              style: shortThinStyle,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text('Amount',
                                  style: shortThinStyle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Text(
                                  '₱ ${NumberFormat('#,##0.00').format(widget.amount)}',
                                  style: shortThinStyle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Text('Total',
                                  style: shortThinStyle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Text(
                                  '₱ ${NumberFormat('#,##0.00').format(widget.amount)}',
                                  style: shortDefault.copyWith(fontSize: 25)),
                            ],
                          ),
                        ],
                      );
                    }
                  }),
            ),
          ),
          const Spacer(),
          const Divider(
            color: Colors.white,
          ),
          const SizedBox(
            height: 5,
          ),
          Text('Confirmed transactions will not be refunded.',
              style: shortThinStyle.copyWith(fontSize: 15)),
          const SizedBox(
            height: 5,
          ),
          Text('Please make sure the amount entered is',
              style: shortThinStyle.copyWith(fontSize: 15)),
          const SizedBox(
            height: 5,
          ),
          Text('correct.', style: shortThinStyle.copyWith(fontSize: 15)),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.9,
            child: FilledButton(
              onPressed: () async {
                UserTransaction? transaction = await WalletTransactionService()
                    .donateMoneytoArtist(
                        widget.userIdtoSupport, widget.amount, widget.message);
                if (transaction != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SuccessfulDonationScreen(
                        userIdtoSupport: widget.userIdtoSupport,
                        amount: transaction.amount,
                        date: transaction.transactionDate,
                      ),
                    ),
                  );
                } else {
                  ToastMessage.show(
                      context, 'Something went wrong. Please try again.');
                }
              },
              child: const Text(
                'Send',
              ),
            ),
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}

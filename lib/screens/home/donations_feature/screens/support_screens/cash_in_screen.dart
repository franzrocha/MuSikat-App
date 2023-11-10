// ignore_for_file: use_build_context_synchronously

import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/screens/home/donations_feature/models/user_transaction.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/utils/exports.dart';

class CashInScreen extends StatelessWidget {
  const CashInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController cashIn = TextEditingController();
    List<UserTransaction> transactions = [];

    final WalletTransactionService walletService = WalletTransactionService();

    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cash In',
                style: appBarStyle,
              ),
            ),
          ],
        ),
        showLogo: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
            child: Text(
              'Amount',
              style: shortDefault.copyWith(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          CustomTextField(
            obscureText: false,
            controller: cashIn,
            keyboardType: TextInputType.number,
            hintText: 'Enter amount',
            validator: (value) {
              if (value!.isEmpty) {
                return null;
              } else {
                return null;
              }
            },
            prefixIcon: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                '₱',
                style: shortDefault.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: musikatColor2),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      if (cashIn.text.isNotEmpty) {
                        double amount = double.tryParse(cashIn.text) ?? 0.0;

                        await walletService.addAmountToWallet(
                          amount,
                        );

                        transactions.add(
                          UserTransaction(
                            amount: amount,
                            transactionType: 'cash_in',
                            transactionDate: DateTime.now(),
                          ),
                        );
                        cashIn.clear();

                        ToastMessage.show(context, 'Cash In Successful');
                      } else {
                        ToastMessage.show(context, 'Please enter amount');
                      }
                    },
                    child: const Text('Submit'),
                  ),
                )),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

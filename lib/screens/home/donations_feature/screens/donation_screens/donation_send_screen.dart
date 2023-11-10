// ignore_for_file: use_build_context_synchronously

import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/screens/home/donations_feature/screens/donation_screens/confirm_donation_screen.dart';
import 'package:musikat_app/screens/home/donations_feature/widgets/support_badge_widget.dart';
import 'package:musikat_app/utils/exports.dart';

class DonationSendScreen extends StatelessWidget {
  final String userIdtoSupport;
  const DonationSendScreen({super.key, required this.userIdtoSupport});

  @override
  Widget build(BuildContext context) {
    final TextEditingController donation = TextEditingController();
    final TextEditingController donationMessage = TextEditingController();
    final WalletTransactionService walletService = WalletTransactionService();

    void processDonation() async {
      final amount = double.tryParse(donation.text);
      final message = donationMessage.text;

      if (amount != null && amount > 0 && message.isNotEmpty) {
        final userBalance = await walletService.getUserBalance();

        if (userBalance >= amount) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ConfirmDonationScreen(
                userIdtoSupport: userIdtoSupport,
                amount: amount,
                message: message,
              ),
            ),
          );
        } else {
          ToastMessage.show(context, 'Insufficient balance for the donation');
        }
      } else {
        ToastMessage.show(context, 'Please enter a valid amount and message');
      }
    }

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
            controller: donation,
            keyboardType: TextInputType.number,
            hintText: 'Enter amount',
            suffixIcon: const SupportBadgeWidget(),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
            child: Text(
              'Message',
              style: shortDefault.copyWith(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          CustomTextField(
            obscureText: false,
            controller: donationMessage,
            hintText: 'Let them know what you think',
            validator: (value) {
              if (value!.isEmpty) {
                return null;
              } else {
                return null;
              }
            },
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
                    onPressed: () {
                      processDonation();
                    },
                    child: const Text('Proceed'),
                  ),
                )),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

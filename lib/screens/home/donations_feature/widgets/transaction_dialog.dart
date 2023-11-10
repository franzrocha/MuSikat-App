// ignore_for_file: must_be_immutable

import 'package:intl/intl.dart';
import 'package:musikat_app/utils/exports.dart';

class TransactionDialog extends StatelessWidget {
  final String title;
  String? description;
  final String transactionDate;
  final double amount;
  String? message;

  TransactionDialog({
    super.key,
    required this.title,
    required this.transactionDate,
    required this.amount,
    this.message,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff656464),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description ?? '',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date and Time: ',
                    style: shortDefault.copyWith(
                        color: Color(0xffB7B7B7), fontWeight: FontWeight.w400),
                  ),
                  Text(
                    transactionDate,
                    style: shortDefault.copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount: ',
                    style: shortDefault.copyWith(
                        color: Color(0xffB7B7B7), fontWeight: FontWeight.w400),
                  ),
                  Text(
                    '₱ ${NumberFormat('#,##0.00').format(amount)}',
                    style: shortDefault.copyWith(fontWeight: FontWeight.w400),
                  ), // replace with actual amount
                ],
              ),
              const SizedBox(height: 15),
              message == null
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Message: ',
                          style: shortDefault.copyWith(
                              color: Color(0xffB7B7B7),
                              fontWeight: FontWeight.w400),
                        ),

                        SizedBox(
                          width: 150,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              message ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: shortDefault.copyWith(
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ), // replace with actual amount
                      ],
                    ),
            ],
          ),
        ],
      ),
      actions: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Okay'),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

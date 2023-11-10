import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikat_app/screens/home/donations_feature/models/user_transaction.dart';

class WalletTransactionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> getUserBalance() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference walletRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .doc('wallet_transactions');
        DocumentSnapshot walletDoc = await walletRef.get();
        if (walletDoc.exists) {
          Map<String, dynamic> walletData =
              walletDoc.data() as Map<String, dynamic>;
          double balance = walletData['balance']?.toDouble() ?? 0.0;
          return balance;
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    } catch (e) {
      print("Error getting user balance: $e");
      return 0.0;
    }
  }

  Future<double> getBalance() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wallet')
          .doc('wallet_transactions')
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        return data?['balance'] ?? 0;
      }
    }
    return 0;
  }

  Future<UserTransaction?> addAmountToWallet(double amount) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference walletRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .doc('wallet_transactions');

        // Save the current timestamp
        DateTime now = DateTime.now();
        // Update the balance and transaction history in Firestore
        walletRef.set({
          'balance': FieldValue.increment(amount),
          'transactions': FieldValue.arrayUnion([
            {
              'transaction_amount': amount,
              'transaction_date': now,
              'transaction_type': 'cash_in'
            }
          ])
        }, SetOptions(merge: true));
        // Return the transaction details
        return UserTransaction(
            amount: amount, transactionDate: now, transactionType: 'cash_in');
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<UserTransaction?> donateMoneytoArtist(
      String userIdToSupport, double amount, String message) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference userWalletRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .doc('wallet_transactions');

        DocumentReference artistWalletRef = _firestore
            .collection('users')
            .doc(userIdToSupport)
            .collection('wallet')
            .doc('wallet_transactions');

        // Save the current timestamp
        DateTime now = DateTime.now();

        // Check if you have enough balance for the donation
        double userBalance = await getUserBalance();
        if (userBalance >= amount) {
          // Update your balance and transaction history
          userWalletRef.set({
            'balance': FieldValue.increment(-amount),
            'transactions': FieldValue.arrayUnion([
              {
                'transaction_message': message,
                'transaction_amount': -amount,
                'transaction_date': now,
                'transaction_type': 'donation_transaction',
                'artist_id': userIdToSupport,
              }
            ])
          }, SetOptions(merge: true));

          // Update the artist's balance and transaction history
          artistWalletRef.set({
            'balance': FieldValue.increment(amount),
            'transactions': FieldValue.arrayUnion([
              {
                'transaction_message': message,
                'transaction_amount': amount,
                'transaction_date': now,
                'transaction_type': 'support_transaction',
                'donor_id': user.uid,
              }
            ])
          }, SetOptions(merge: true));

          await _firestore.collection('users').doc(user.uid).update({
            'artist_you_supported': FieldValue.arrayUnion([userIdToSupport]),
          });

          await _firestore.collection('users').doc(userIdToSupport).update({
            'artist_that_supported_me':
                FieldValue.arrayUnion([user.uid]), // Add this line
          });

          // Return the transaction details
          return UserTransaction(
              amount: amount,
              transactionMessage: message,
              transactionDate: now,
              transactionType: 'donation_transaction');
        } else {
          // Insufficient balance for the donation
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<UserTransaction>?> getTransactions() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .orderBy('timestamp', descending: true)
            .get();

        return querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return UserTransaction(
            transactionType: data['transaction_type'],
            amount: data['amount'].toDouble(),
            transactionDate: data['timestamp'].toDate(),
          );
        }).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Stream<List<UserTransaction>> transactionsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wallet')
          .doc('wallet_transactions')
          .snapshots()
          .map((snapshot) {
        List<dynamic>? transactionsList = snapshot.data()?['transactions'];

        if (transactionsList != null) {
          return transactionsList.map((transactionData) {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(transactionData);
            return UserTransaction(
              artistId: data['artist_id'],
              donorId: data['donor_id'],
              transactionType: data['transaction_type'],
              amount: data['transaction_amount'].toDouble(),
              transactionDate: data['transaction_date'].toDate(),
              transactionMessage: data['transaction_message'],
            );
          }).toList();
        } else {
          return [];
        }
      });
    }
    return Stream<List<UserTransaction>>.value([]);
  }

  Future<List<String>> getArtistYouSupported(String selectedUserUID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserUID)
        .get();

    final artistYouSupportedList =
        (userSnapshot.data()?['artist_you_supported'] as List<dynamic>?) ?? [];

    return artistYouSupportedList.cast<String>();
  }

  Future<List<String>> getArtistThatSupportedMe(String selectedUserUID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserUID)
        .get();

    final artistThatSupportedMeList =
        (userSnapshot.data()?['artist_that_supported_me'] as List<dynamic>?) ??
            [];

    return artistThatSupportedMeList.cast<String>();
  }

  Stream<List<UserTransaction>> fetchDonationHistory(
      String currentUserId, String artistId) {
    return _firestore
        .collection('users')
        .doc(artistId)
        .collection('wallet')
        .doc('wallet_transactions')
        .snapshots()
        .map((snapshot) {
      List<dynamic>? transactionsList = snapshot.data()?['transactions'];

      if (transactionsList != null) {
        List<UserTransaction> filteredTransactions = transactionsList
            .map((transactionData) {
              Map<String, dynamic> data =
                  Map<String, dynamic>.from(transactionData);
              return UserTransaction(
                donorId: data['donor_id'],
                transactionType: data['transaction_type'],
                amount: data['transaction_amount'].toDouble(),
                transactionDate: data['transaction_date'].toDate(),
                transactionMessage: data['transaction_message'],
              );
            })
            .where((transaction) => transaction.donorId == currentUserId)
            .toList();

        if (filteredTransactions.isNotEmpty) {
          return filteredTransactions;
        }
      }
      return [];
    });
  }
}

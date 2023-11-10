class UserTransaction {
  String? artistId;
  String? donorId;
  final double amount;
  String? transactionMessage;
  final String transactionType;
  final DateTime transactionDate;

  UserTransaction({
    this.artistId,
    this.donorId,
    this.transactionMessage,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'artist_id': artistId,
      'donor_id': donorId,
      'transaction_message': transactionMessage,
      'transaction_type': transactionType,
      'amount': amount,
      'timestamp': transactionDate,
    };
  }
}

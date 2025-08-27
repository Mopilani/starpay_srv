class STRAccountData {
  STRAccountData({
    required this.due,
    required this.accountId,
    required this.lastPayment,
    required this.currency,
    required this.period,
  });

  String accountId;
  double due;
  String currency;
  DateTime lastPayment;
  List<DateTime> period;

  Map<String, dynamic> asMap() => {
    'accountId': accountId,
    'due': due,
    'currency': currency,
    'lastPayment': lastPayment,
    'period': period,
  };

  STRAccountData fromMap(Map<String, dynamic> data) {
    return STRAccountData(
      due: data['due'],
      accountId: data['accountId'],
      lastPayment: data['lastPayment'],
      currency: data['currency'],
      period: data['period'],
    );
  }
}

class STRAccountData {
  STRAccountData({
    required this.due,
    required this.accountId,
    required this.lastPayment,
    required this.currency,
    required this.period,
    required this.email,
    required this.password,
    required this.invoices,
  });

  String accountId;
  double due;
  String currency;
  String email;
  String password;
  DateTime lastPayment;
  List<DateTime> period;
  List<Map<String, dynamic>> invoices;

  Map<String, dynamic> asMap() => {
    'accountId': accountId,
    'due': due,
    'currency': currency,
    'lastPayment': lastPayment,
    'period': period,
    'invoices': invoices,
    'email': email,
    'password': password,
  };

  STRAccountData fromMap(Map<String, dynamic> data) {
    return STRAccountData(
      due: data['due'],
      accountId: data['accountId'],
      lastPayment: data['lastPayment'],
      currency: data['currency'],
      period: data['period'],
      invoices: data['invoices'],
      email: data['email'],
      password: data['password'],
    );
  }
}

import 'star_account_data.dart';

class AccountData {
  AccountData({
    required this.name,
    required this.accounts,
    required this.metaData,
  });

  /// Account owner name contains can contain first name and last name
  String name;

  /// For other users that are admins
  Map<String, dynamic> metaData;

  /// Accounts that added to the account to be listened to
  List<STRAccountData> accounts;

  Map<String, dynamic> asMap() => {
    'name': name,
    'metaData': metaData,
    'accounts': accounts.map((acc) => acc.asMap()),
  };

  AccountData fromMap(Map<String, dynamic> data) {
    return AccountData(
      name: data['name'],
      accounts: data['metaData'],
      metaData: data['accounts'],
    );
  }
}

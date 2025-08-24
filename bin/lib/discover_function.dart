import 'package:enough_mail/enough_mail.dart';

Future<void> discoverExample({required String email}) async {
  // var email = '';
  var config = await Discover.discover(
    email,
    isLogEnabled: false,
    forceSslConnection: true,
  );

  if (config == null) {
    print('Unable to discover settings for $email');
  } else {
    print('Settings for $email:');
    for (var provider in config.emailProviders!) {
      print('provider: ${provider.displayName}');
      print('provider-domains: ${provider.domains}');
      print('documentation-url: ${provider.documentationUrl}');
      print('Incoming:');
      print(provider.preferredIncomingServer);
      print('Outgoing:');
      print(provider.preferredOutgoingServer);
    }
  }
}

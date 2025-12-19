/// Configuration for Cafe Bazaar subscription
class BazaarConfig {
  // RSA Public Key from Cafe Bazaar panel
  static const String rsaPublicKey = 'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwC+Hwps1HJdKraXWIEy+ZAd8yIKfIAaikKPMkhdufZYj9HKoFERPwMzo6vaNf76u3YlgCmcgjIomxaIFemKpBs3fLDgD+QDB0pDwt9aTYH5dUoBGgW0Il4Z/iE88f0GBoh0bVbdL7dQWWYVxOYUBR36LS9sBzAxhbVKsS/YZ5wdP7NJhJVkY8EWFFQVQ/i2Du+cHVNkIIHRx5BN1Fa/rVfVdqfCFrzL0JC2TRXG4EsCAwEAAQ==';
  
  // Subscription SKU (Product ID)
  static const String monthlySubscriptionSku = 'monthly_subscription';
  
  // Subscription price (for display only - actual price managed by Bazaar)
  static const String subscriptionPrice = '۳۰۰,۰۰۰ تومان';
  static const String subscriptionPriceEn = '300,000 Toman';
  
  // Trial period (managed by Bazaar)
  static const int trialDays = 7;
}

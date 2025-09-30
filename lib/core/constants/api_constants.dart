const String API_BASE_URL = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.43.42:3000',
);

const String API_ENDPOINT = '$API_BASE_URL/api';

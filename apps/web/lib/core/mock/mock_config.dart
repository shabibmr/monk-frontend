import '../network/api_client_factory.dart';

/// Convenience accessors for offline demo mock mode.
class MockConfig {
  MockConfig._();

  static bool useMocks(AppConfig config) => config.useMocks;

  static Duration latency(AppConfig config) =>
      Duration(milliseconds: config.mockLatencyMs.clamp(0, 5000));
}

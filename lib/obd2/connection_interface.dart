abstract class Obd2Connection {
  Future<void> connect(String address);
  Future<void> disconnect();
  Stream<String> get rawDataStream;
  Future<void> sendCommand(String command);
}

class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

class ConflictException implements Exception {
  final String message;
  final Map<String, dynamic>? serverData;

  ConflictException(this.message, {this.serverData});
}

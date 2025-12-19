/// Base exception class
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

/// Authentication related exceptions
class AppAuthException extends AppException {
  const AppAuthException(super.message);
}

class InvalidCredentialsException extends AppAuthException {
  const InvalidCredentialsException([super.message = 'Invalid email or password']);
}

class EmailAlreadyExistsException extends AppAuthException {
  const EmailAlreadyExistsException([super.message = 'Email already exists']);
}

class WeakPasswordException extends AppAuthException {
  const WeakPasswordException([super.message = 'Password is too weak']);
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}


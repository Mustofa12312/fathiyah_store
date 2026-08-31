class AppException implements Exception {
  final String message;
  final String prefix;

  AppException([this.message = 'Terjadi kesalahan sistem', this.prefix = 'Error']);

  @override
  String toString() {
    return '$prefix: $message';
  }
}

class ValidationException extends AppException {
  ValidationException([String message = 'Data yang Anda masukkan tidak valid']) : super(message, 'Validasi Gagal');
}

class NetworkException extends AppException {
  NetworkException([String message = 'Koneksi terputus. Pastikan internet Anda menyala']) : super(message, 'Koneksi Gagal');
}

class PermissionException extends AppException {
  PermissionException([String message = 'Akses ditolak. Anda tidak memiliki izin untuk tindakan ini.']) : super(message, 'Akses Ditolak');
}

class DataNotFoundException extends AppException {
  DataNotFoundException([String message = 'Data tidak ditemukan']) : super(message, 'Tidak Ditemukan');
}

/// Interface class defining the platform-agnostic key-value storage requirements.
///
/// Feature modules specify concrete implementations (such as memory-only or
/// file system storage) dynamically.
abstract interface class StorageAdapter {
  /// Store a [value] matching [key].
  Future<void> write(String key, String value);

  /// Read the string contents corresponding to [key].
  Future<String?> read(String key);

  /// Delete values matching [key].
  Future<void> delete(String key);

  /// Clear all stored keys.
  Future<void> clear();
}

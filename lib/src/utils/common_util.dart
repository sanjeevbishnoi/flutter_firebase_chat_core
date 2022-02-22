import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// Extension with one [toShortString] method
extension RoleToShortString on types.Role {
  /// Converts enum to the string equal to enum's name
  String toShortString() {
    return toString().split('.').last;
  }
}

/// Extension with one [toShortString] method
extension RoomTypeToShortString on types.RoomType {
  /// Converts enum to the string equal to enum's name
  String toShortString() {
    return toString().split('.').last;
  }
}

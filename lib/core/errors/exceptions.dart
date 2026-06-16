class PlaceNotFoundException implements Exception {
  final String message;
  const PlaceNotFoundException([this.message = 'place_not_found']);
  @override
  String toString() => message;
}

class SubPlaceNotFoundException implements Exception {
  final String message;
  const SubPlaceNotFoundException([this.message = 'subplace_not_found']);
  @override
  String toString() => message;
}

class SlotAlreadyBookedException implements Exception {
  final String message;
  const SlotAlreadyBookedException([this.message = 'msg_already_booked']);
  @override
  String toString() => message;
}

class UserNotAuthenticatedException implements Exception {
  final String message;
  const UserNotAuthenticatedException([this.message = 'user_not_authenticated']);
  @override
  String toString() => message;
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
  @override
  String toString() => message;
}

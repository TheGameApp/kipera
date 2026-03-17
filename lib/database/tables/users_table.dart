import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  TextColumn get notificationTime => text().withDefault(const Constant('08:00'))();
  TextColumn get locale => text().withDefault(const Constant('en'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

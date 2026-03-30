import 'package:drift/drift.dart';

/// Queue for tracking local changes that need to be synced to Supabase.
/// Each row represents a pending insert/update/delete operation.
/// After successful sync, rows are marked as synced and periodically cleaned.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncTableName => text()();
  TextColumn get recordId => text()();
  TextColumn get action => text()(); // 'insert', 'update', 'delete'
  TextColumn get payload => text()(); // JSON of the full record
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

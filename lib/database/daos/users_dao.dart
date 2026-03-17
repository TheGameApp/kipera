import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<User?> getUserById(String id) =>
      (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertUser(UsersCompanion user) =>
      into(users).insertOnConflictUpdate(user);

  Future<void> updateUser(String id, UsersCompanion companion) =>
      (update(users)..where((t) => t.id.equals(id))).write(companion);

  Stream<User?> watchUser(String id) =>
      (select(users)..where((t) => t.id.equals(id))).watchSingleOrNull();
}

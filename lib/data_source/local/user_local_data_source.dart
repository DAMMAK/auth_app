import 'dart:convert';

import '../../core/persist/pref/pref_handler.dart';
import '../../locator.dart';
import '../../models/user_model.dart';

/// This handles the storing and retriving of user data
abstract class UserLocalDataSource {
  /// This gets the stored user data
  Future<UserModel> getUser();

  /// This saves the retrived user data
  Future<UserModel> saveUser({UserModel data});

  /// This clears the stored user data
  Future<UserModel> deleteUser();
}

final String key = 'userData';

/// This is an implemetation of [UserLocalDataSource] abstract class
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final pref = locator<PrefHandler>();

  @override
  Future<UserModel> getUser() async {
    final data = await pref.getData(key: key);
    print('figuring out the user data from local');
    print(data);
    print(data.toString());
    if (data != null) {
      final value = UserModel.fromJson(json.encode(data));
      return Future.value(value);
    } else {
      final userData = UserModel.fromJson(data);
      final value = UserModel(
        id: userData.id,
        name: userData.name,
        email: userData.email,
        username: userData.username,
      );
      return Future.value(value);
    }
  }

  @override
  Future<UserModel> saveUser({UserModel data}) {
    print('json printing');
    print(data.toJson());
    final value = json.decode(data.toString());
    print('string printing');
    print(value.toString());
    pref.saveData(key: key, value: value.toString());
    return Future.value(data);
  }

  @override
  Future<UserModel> deleteUser() {
    return pref.deleteData(key: key);
  }
}

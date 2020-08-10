import '../core/error/exceptions.dart';
import '../core/network/network_info.dart';
import '../core/utils/result.dart';
import '../data_source/local/data_local_data_source.dart';
import '../data_source/remote/login_remote_data_source.dart';
import '../locator.dart';
import '../models/login_model.dart';
import '../models/merged_model.dart';

abstract class LoginService {
  Future<Result<LoginModel>> performLogin({String email, String password});
}

class LoginServiceImpl implements LoginService {
  final remoteDataSource = locator<LoginRemoteDataSource>();
  final localDataSource = locator<DataLocalDataSource>();
  final networkInfo = locator<NetworkInfo>();
  @override
  Future<Result<LoginModel>> performLogin(
      {String email, String password}) async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final response =
            await remoteDataSource.getUser(email: email, password: password);
        localDataSource.saveResponse(data: MergedModel(loginModel: response));
        return Result(success: response);
      } on ServerException catch (err) {
        return Result(error: ServerError(err.toString()));
      }
    } else {
      try {
        final response = await localDataSource.getResponse();
        final data = response.toLogin();
        return Result(
            success: data, error: NoInternetError('No Internet Connection'));
      } on CacheException catch (err) {
        return Result(error: CacheError(err.toString()));
      }
    }
  }
}
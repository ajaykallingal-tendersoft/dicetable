import 'package:dicetable/src/model/customer/history/history_list_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

class HistoryDataProvider {
  Future<StateModel?> getHistory() async {

    try {
      final response = await ObjectFactory().apiClient.getHistory();
      if (response.statusCode == 200) {
        print(response.toString());
        return StateModel<HistoryListResponse>.success(
            HistoryListResponse.fromJson(response.data));
      } else {
        return null;
      }    }  on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error(
            "UnAuthorized error");
      }else if(e.response == null) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      }
    }
    return null;
  }

}
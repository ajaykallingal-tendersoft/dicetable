import 'package:dicetable/src/model/customer/favourite/get_favourite_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

class FavouriteDataProvider {
  Future<StateModel?> getHomeData() async {

    try {
      final response = await ObjectFactory().apiClient.getFavourite();
      if (response.statusCode == 200) {
        print(response.toString());
        return StateModel<GetFavouriteResponse>.success(
            GetFavouriteResponse.fromJson(response.data));
      } else {
        return null;
      }    }  on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response != null && e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      }
    }
    return null;

  }
}
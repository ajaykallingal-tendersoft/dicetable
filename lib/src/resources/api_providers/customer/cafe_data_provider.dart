import 'package:soloseaters/src/model/customer/cafe/add_favourite_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_search_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_search_response.dart';
import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/remove_favourite_request.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';
import 'package:soloseaters/src/model/customer/cafe/get_filter_options_response.dart';

import '../../../model/customer/cafe/add_favourite_response.dart';
import '../../../model/customer/cafe/remove_favourite_respomse.dart';

class CafeDataProvider {

  ///Fav
  Future<StateModel?> getFavourite() async {

    try {
      final response = await ObjectFactory().apiClient.getFavourite();
      if (response.statusCode == 200) {
        print(response.toString());
        return StateModel<FavouriteListResponse>.success(
            FavouriteListResponse.fromJson(response.data));
      } else {

        return null;
      }    }  on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error(
            "UnAuthorized error");
      }
    }
    return null;
  }

  ///Add fav
  Future<StateModel?> addFavourite(AddFavouriteRequest addFavouriteRequest) async {
    try {
      final response = await ObjectFactory().apiClient.addFavourite(addFavouriteRequest);
      print(response.toString());

      if (response.statusCode == 200) {
        final data = AddToFavouritesResponse.fromJson(response.data);
        return StateModel<AddToFavouritesResponse>.success(data);
      } else if (response.statusCode == 422) {
        final data = AddToFavouritesResponse.fromJson(response.data);
        return StateModel<AddToFavouritesResponse>.error(data.message);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 422) {
        final data = AddToFavouritesResponse.fromJson(e.response!.data);
        return StateModel<AddToFavouritesResponse>.error(data.message);
      } else if (e.response?.statusCode == 500) {
        return StateModel.error("The server isn't responding! Please try again later.");
      } else if (e.response?.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected. Please try again later.");
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection error. Please check your internet and try again later.");
      }
    }
    return null;
  }

  ///Remove fav
  Future<StateModel?> removeFavourite(RemoveFavouriteRequest removeFavouriteRequest) async {
    try {
      final response = await ObjectFactory().apiClient.removeFavourite(removeFavouriteRequest);
      print(response.toString());

      if (response.statusCode == 200) {
        final data = RemoveFavouritesResponse.fromJson(response.data);
        return StateModel<RemoveFavouritesResponse>.success(data);
      } else if (response.statusCode == 422) {
        final data = RemoveFavouritesResponse.fromJson(response.data);
        return StateModel<RemoveFavouritesResponse>.error(data.message);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 422) {
        final data = RemoveFavouritesResponse.fromJson(e.response!.data);
        return StateModel<RemoveFavouritesResponse>.error(data.message);
      } else if (e.response?.statusCode == 500) {
        return StateModel.error("The server isn't responding! Please try again later.");
      } else if (e.response?.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected. Please try again later.");
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection error. Please check your internet and try again later.");
      }
    }
    return null;
  }

  ///CafeList
  Future<StateModel?> getCafeList(CafeListRequest request) async {
    try {
      final response = await ObjectFactory().apiClient.getCafeList(request);
      if (response.statusCode == 200) {
        print(response.toString());
        return StateModel<CafeListResponse>.success(
            CafeListResponse.fromJson(response.data));
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

  ///CafeSearch
  Future<StateModel?> cafeSearch(CafeSearchRequest cafeSearchRequest) async {
    try {
      final response =
      await ObjectFactory().apiClient.cafeSearch(cafeSearchRequest);
      print(response.toString());
      // String jsonRequest = jsonEncode(cafeSearchRequest);
      // print("Request Payload:");
      // print(jsonRequest);
      if (response.statusCode == 200) {
        return StateModel<SearchRequestResponse>.success(
            SearchRequestResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == null) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      } else if (statusCode == 408) {
        return StateModel.error(
            "Your request took too long to process. Please try again later.");
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return StateModel.error(
            "The request timed out. Please check your connection and try again.");
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return StateModel.error(
            "Connection error. Please check your internet connection and try again.");
      }
    }
    return StateModel.error(
        "Unexpected error occurred. Please try again later.");
  }

  ///GetFilterOptions
  Future<StateModel?> getFilterOptions() async {

    try {
      final response = await ObjectFactory().apiClient.getFilterOptions();
      if (response.statusCode == 200) {
        print(response.toString());
        return StateModel<GetFilterOptionsResponse>.success(
            GetFilterOptionsResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      }
    }
    return StateModel.error(
        "The server isn't responding! Please try again later.");
  }

}
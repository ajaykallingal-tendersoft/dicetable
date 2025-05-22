
import 'dart:convert';

import 'package:dicetable/src/model/cafe_owner/subscription/subscription_overview_response.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_start_request.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_start_request_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

import '../../../model/cafe_owner/subscription/initial_subscription_plan_response.dart';

class SubscriptionDataProvider {

//Subscription Initial
  Future<StateModel?> getInitialSubscription() async {
    try {
      final response =
      await ObjectFactory().apiClient.getInitialSubscription();
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<InitialSubscriptionPlanResponse>.success(
            InitialSubscriptionPlanResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
        // return response!;
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      }

    }
    return null;
  }

//Subscription Overview
  Future<StateModel?> getSubscriptionOverview() async {
    try {
      final response =
      await ObjectFactory().apiClient.getSubscriptionOverview();
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<SubscriptionOverviewResponse>.success(
            SubscriptionOverviewResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
        // return response!;
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      }

    }
    return null;
  }


  Future<StateModel?> subscriptionStart(SubscriptionStartRequest subscriptionStart) async {
    try {
      final response =
      await ObjectFactory().apiClient.subscriptionStart(subscriptionStart);
      print(response.toString());
      String jsonRequest = jsonEncode(subscriptionStart);
      print("Request Payload:");
      print(jsonRequest);
      if (response.statusCode == 200) {
        return StateModel<SubscriptionStartResponse>.success(
            SubscriptionStartResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
        // return response!;
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      }

    }
    return null;
  }


}
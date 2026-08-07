import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/job_application.dart';
import 'package:eClassify/utils/api.dart';
import 'package:path/path.dart' as path;

class JobRepository {
  Future<Map<String, dynamic>> applyJobApplication(
    Map<String, dynamic> data,
    File? attachment,
  ) async {
    final parameters = Map<String, dynamic>.from(data);
    if (attachment != null) {
      parameters[Api.resume] = await MultipartFile.fromFile(
        attachment.path,
        filename: path.basename(attachment.path),
      );
    }
    return Api.post(url: Api.applyForJobApi, parameter: parameters);
  }

  Future<DataOutput<JobApplication>> fetchApplications({
    int? page,
    required int itemId,
    required bool isMyJobApplications,
  }) async {
    final response = await Api.get(
      url: isMyJobApplications
          ? Api.myJobApplicationsApi
          : Api.getJobApplicationsApi,
      queryParameters: {
        if (page != null) Api.page: page,
        Api.itemId: itemId,
      },
    );
    final list = response['data']['data'] as List? ?? [];
    final itemList = list
        .map((e) => JobApplication.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return DataOutput(
      total: response['data']['total'] as int? ?? itemList.length,
      modelList: itemList,
    );
  }

  Future<Map<String, dynamic>> changeJobApplicationStatus({
    required int jobId,
    required String status,
  }) async {
    return Api.post(
      url: Api.updateJobApplicationsStatusApi,
      parameter: {Api.status: status, Api.jobId: jobId},
    );
  }
}

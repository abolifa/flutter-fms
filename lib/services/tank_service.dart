import 'dart:convert';
import 'package:fms_app/helpers/api_service.dart';
import 'package:fms_app/helpers/params.dart';
import '../models/tank.dart';

class TankService {
  final ApiService apiService = ApiService(baseUrl: Constant.tanks);

  Future<List<Tank>> fetchTanks() async {
    final response = await apiService.get('/');
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Tank.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tanks: ${response.statusCode}');
    }
  }
}

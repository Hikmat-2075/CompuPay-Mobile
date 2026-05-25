import '../../../core/services/api_service.dart';
import '../../../models/employee_profile.dart';

class ProfileService {
  Future<EmployeeProfile> getProfile() async {
    final response = await ApiService.get('/employee/profile');

    return EmployeeProfile.fromJson(response.data);
  }
}

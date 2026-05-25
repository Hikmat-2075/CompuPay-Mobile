import 'package:flutter/material.dart';

import '../../../models/employee_profile.dart';

class ProfileHeader extends StatelessWidget {
  final EmployeeProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = profile.avatar.isNotEmpty;

    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFF6C3EF4),

            child: CircleAvatar(
              radius: 50,

              backgroundColor: Colors.grey.shade300,

              backgroundImage: hasAvatar ? NetworkImage(profile.avatar) : null,

              child: !hasAvatar
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          profile.fullName.isNotEmpty ? profile.fullName : 'Employee Name',

          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(
          profile.position.isNotEmpty ? profile.position : 'Employee Position',

          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF6C3EF4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

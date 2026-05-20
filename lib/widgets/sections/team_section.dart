import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  static const List<_TeamMember> _members = [
    _TeamMember(
      initials: 'AA',
      name: 'Alexandra\nASSAGA',
      role: 'Chef de Projet',
      email: 'alexandra@life-ai.app',
    ),
    _TeamMember(
      initials: 'BW',
      name: 'Brayan WEKO',
      role: 'Big Data & IA',
      email: 'brayan@life-ai.app',
    ),
    _TeamMember(
      initials: 'MM',
      name: 'Melvin MEUDJE',
      role: 'Architecture & Sécurité',
      email: 'melvin@life-ai.app',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final isMedium = width > 600;
    final padding = isWide ? 80.0 : 24.0;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        children: [
          const Text(
            'Notre Équipe à Votre Service',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Derrière LIFE.AI, une équipe passionnée et accessible',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText),
          ),
          const SizedBox(height: 48),

          if (isWide)
            Row(
              children: _members
                  .map((m) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _MemberCard(m),
                        ),
                      ))
                  .toList(),
            )
          else if (isMedium)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _MemberCard(_members[0])),
                    const SizedBox(width: 16),
                    Expanded(child: _MemberCard(_members[1])),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _MemberCard(_members[2])),
                    const SizedBox(width: 16),
                    Expanded(child: _MemberCard(_members[3])),
                  ],
                ),
              ],
            )
          else
            Column(
              children: _members
                  .map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _MemberCard(m),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _TeamMember {
  final String initials;
  final String name;
  final String role;
  final String email;

  const _TeamMember({
    required this.initials,
    required this.name,
    required this.role,
    required this.email,
  });
}

class _MemberCard extends StatelessWidget {
  final _TeamMember member;

  const _MemberCard(this.member);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary,
            child: Text(
              member.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nom
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),

          // Rôle
          Text(
            member.role,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            member.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
}

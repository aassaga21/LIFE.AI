import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';

class Navbar extends StatelessWidget {
  final String currentRoute;
  const Navbar({super.key, this.currentRoute = '/'});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                isLoggedIn ? '/dashboard' : '/',
                (route) => false),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.show_chart,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                const Text(
                  'LIFE.AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 40),
            if (isLoggedIn) ...[
              _NavLink('Dashboard',
                  route: '/dashboard', currentRoute: currentRoute),
              _NavLink('Check-in',
                  route: '/checkin', currentRoute: currentRoute),
              _NavLink('Historique',
                  route: '/history', currentRoute: currentRoute),
              _NavLink('Tarification',
                  route: '/pricing', currentRoute: currentRoute),
            ] else ...[
              _NavLink('Accueil',
                  route: '/', currentRoute: currentRoute),
              _NavLink('Fonctionnalités',
                  route: '/features', currentRoute: currentRoute),
              _NavLink('Tarification',
                  route: '/pricing', currentRoute: currentRoute),
              _NavLink('Entreprises',
                  route: '/entreprises', currentRoute: currentRoute),
              _NavLink('Avis',
                  route: '/feedback', currentRoute: currentRoute),
              _NavLink('Blog',
                  route: '/blog', currentRoute: currentRoute),
              _NavLink('À propos',
                  route: '/about', currentRoute: currentRoute),
              _NavLink('Contact',
                  route: '/contact', currentRoute: currentRoute),
            ],
          ],
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined,
                color: AppColors.grayText, size: 20),
          ),
          if (isLoggedIn) ...[
            if (isWide) ...[
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/dashboard'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout,
                    size: 16, color: AppColors.grayText),
                label: const Text('Déconnexion',
                    style: TextStyle(
                        color: AppColors.grayText, fontSize: 14)),
              ),
            ] else ...[
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout,
                    color: AppColors.grayText, size: 20),
              ),
            ],
          ] else ...[
            if (isWide) ...[
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/login'),
                child: const Text('Se connecter',
                    style: TextStyle(
                        color: AppColors.grayText, fontSize: 14)),
              ),
              const SizedBox(width: 4),
            ],
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: Text(isWide ? 'Rejoindre la bêta' : 'Bêta'),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String route;
  final String currentRoute;

  const _NavLink(this.label,
      {required this.route, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    return GestureDetector(
      onTap: () {
        if (!isActive) Navigator.pushNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? AppColors.primary : AppColors.grayText,
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
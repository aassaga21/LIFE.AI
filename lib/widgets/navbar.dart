import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Navbar extends StatelessWidget {
  final String currentRoute;
  const Navbar({super.key, this.currentRoute = '/'});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
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
            _NavLink('Accueil', route: '/', currentRoute: currentRoute),
            _NavLink('Fonctionnalités',
                route: '/features', currentRoute: currentRoute),
            _NavLink('Tarification',
                route: '/pricing', currentRoute: currentRoute),
            _NavLink('Entreprises',
                route: '/entreprises', currentRoute: currentRoute),
            _NavLink('Blog', route: '/blog', currentRoute: currentRoute),
            _NavLink('À propos',
                route: '/about', currentRoute: currentRoute),
            _NavLink('Contact',
                route: '/contact', currentRoute: currentRoute),
          ],

          const Spacer(),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined,
                color: AppColors.grayText, size: 20),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            child: Text(isWide ? 'Rejoindre la bêta' : 'Bêta'),
          ),
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
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

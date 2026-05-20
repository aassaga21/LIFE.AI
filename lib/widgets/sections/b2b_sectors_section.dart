import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animated_entrance.dart';

class B2bSectorsSection extends StatelessWidget {
  const B2bSectorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final padding = isWide ? 80.0 : 24.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Cas d\'Usage par Secteur',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'LIFE.AI s\'adapte aux spécificités de votre industrie',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 48),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 100), child: HoverCard(child: _SectorCard('Tech & Startups', 'Prévenir le burnout dans les équipes en forte croissance', 'Rythme intense, horaires étendus, pression de la croissance', 'Détection précoce des signaux de surcharge, recommandations pour équilibrer les sprints')))),
                const SizedBox(width: 24),
                Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 200), child: HoverCard(child: _SectorCard('Santé & Hospitalier', 'Protéger les soignants de l\'épuisement professionnel', 'Charge émotionnelle, horaires décalés, manque de sommeil', 'Suivi de la récupération, alertes sur les patterns de fatigue chronique')))),
                const SizedBox(width: 24),
                Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 300), child: HoverCard(child: _SectorCard('Services & Conseil', 'Gérer le stress des consultants en mission', 'Déplacements fréquents, pression client, équilibre vie pro/perso', 'Accompagnement personnalisé selon les missions, coaching bien-être à distance')))),
              ],
            )
          else
            Column(
              children: [
                AnimatedEntrance(delay: const Duration(milliseconds: 100), child: _SectorCard('Tech & Startups', 'Prévenir le burnout dans les équipes en forte croissance', 'Rythme intense, horaires étendus, pression de la croissance', 'Détection précoce des signaux de surcharge, recommandations pour équilibrer les sprints')),
                const SizedBox(height: 16),
                AnimatedEntrance(delay: const Duration(milliseconds: 200), child: _SectorCard('Santé & Hospitalier', 'Protéger les soignants de l\'épuisement professionnel', 'Charge émotionnelle, horaires décalés, manque de sommeil', 'Suivi de la récupération, alertes sur les patterns de fatigue chronique')),
                const SizedBox(height: 16),
                AnimatedEntrance(delay: const Duration(milliseconds: 300), child: _SectorCard('Services & Conseil', 'Gérer le stress des consultants en mission', 'Déplacements fréquents, pression client, équilibre vie pro/perso', 'Accompagnement personnalisé selon les missions, coaching bien-être à distance')),
              ],
            ),
        ],
      ),
    );
  }
}

class _SectorCard extends StatelessWidget {
  final String sector;
  final String subtitle;
  final String defi;
  final String solution;

  const _SectorCard(this.sector, this.subtitle, this.defi, this.solution);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sector,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  height: 1.4)),
          const SizedBox(height: 16),
          _Label('DÉFI'),
          const SizedBox(height: 4),
          Text(defi,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.grayText, height: 1.5)),
          const SizedBox(height: 12),
          _Label('SOLUTION'),
          const SizedBox(height: 4),
          Text(solution,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.grayText, height: 1.5)),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.grayText,
          letterSpacing: 0.8),
    );
  }
}

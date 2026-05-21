import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai/models/checkin_model.dart';
import 'package:life_ai/services/health_calculator.dart';

/// Fabrique un CheckIn minimal pour les tests
CheckIn _makeCheckin({
  int humeur = 3,
  int energie = 5,
  int sommeil = 5,
  int stress = 5,
  DateTime? date,
}) {
  return CheckIn(
    id: 'test_${DateTime.now().millisecondsSinceEpoch}',
    uid: 'test_uid',
    date: date ?? DateTime.now(),
    humeur: humeur,
    energie: energie,
    sommeil: sommeil,
    stress: stress,
  );
}

void main() {
  group('StressCalculator', () {
    // ── Scores extrêmes ──────────────────────────────────────────────────────

    test('score stress maximum (tout à 10)', () {
      // stress=10, sommeil=1, energie=1, humeur=1
      // Formule : 10*0.4 + (10-1)*0.3 + (10-1)*0.2 + (5-1)*2*0.1
      //         = 4.0 + 2.7 + 1.8 + 0.8 = 9.3  (sur 10)
      final c = _makeCheckin(stress: 10, sommeil: 1, energie: 1, humeur: 1);
      expect(c.scoreStress, closeTo(9.3, 0.01));
    });

    test('score stress minimum (tout optimal)', () {
      // stress=1, sommeil=10, energie=10, humeur=5
      // Formule : 1*0.4 + 0*0.3 + 0*0.2 + 0*0.1 = 0.4
      final c = _makeCheckin(stress: 1, sommeil: 10, energie: 10, humeur: 5);
      expect(c.scoreStress, closeTo(0.4, 0.01));
    });

    test('score fatigue maximum', () {
      final c = _makeCheckin(stress: 10, sommeil: 1, energie: 1, humeur: 1);
      // (10-1)*0.35 + (10-1)*0.25 + 10*0.25 + (5-1)*2*0.15
      // = 3.15 + 2.25 + 2.5 + 1.2 = 9.1
      expect(c.scoreFatigue, closeTo(9.1, 0.01));
    });

    test('score fatigue minimum (tout optimal)', () {
      final c = _makeCheckin(stress: 1, sommeil: 10, energie: 10, humeur: 5);
      // 0*0.35 + 0*0.25 + 1*0.25 + 0*0.15 = 0.25
      expect(c.scoreFatigue, closeTo(0.25, 0.01));
    });

    test('scoreBienEtre reste entre 0 et 100 toujours', () {
      // 100 jeux de données générés manuellement avec des combinaisons variées
      final cases = <(int, int, int, int)>[
        (1, 1, 1, 1),
        (5, 5, 5, 5),
        (10, 10, 10, 5),
        (1, 10, 10, 5),
        (5, 3, 7, 2),
        (3, 8, 2, 4),
        (10, 1, 1, 1),
        (1, 10, 1, 5),
        (7, 7, 7, 3),
        (2, 9, 8, 5),
      ];
      for (final (stress, sommeil, energie, humeur) in cases) {
        final c = _makeCheckin(
            stress: stress,
            sommeil: sommeil,
            energie: energie,
            humeur: humeur);
        expect(c.scoreBienEtre, inInclusiveRange(0.0, 100.0),
            reason: 'stress=$stress,sommeil=$sommeil,'
                'energie=$energie,humeur=$humeur');
      }
    });

    test('valeurs par défaut ne lèvent pas d\'exception', () {
      final c = _makeCheckin(); // valeurs par défaut
      expect(() => c.scoreStress, returnsNormally);
      expect(() => c.scoreFatigue, returnsNormally);
      expect(() => c.scoreBienEtre, returnsNormally);
    });

    // ── getTrend ────────────────────────────────────────────────────────────

    test('getTrend IMPROVING si score stress baisse sur 7j', () {
      // Première moitié : stress élevé (8), deuxième moitié : stress faible (2)
      final now = DateTime.now();
      final checkins = [
        _makeCheckin(stress: 8, date: now.subtract(const Duration(days: 6))),
        _makeCheckin(stress: 8, date: now.subtract(const Duration(days: 5))),
        _makeCheckin(stress: 8, date: now.subtract(const Duration(days: 4))),
        _makeCheckin(stress: 2, date: now.subtract(const Duration(days: 3))),
        _makeCheckin(stress: 2, date: now.subtract(const Duration(days: 2))),
        _makeCheckin(stress: 2, date: now.subtract(const Duration(days: 1))),
      ];
      expect(HealthCalculator.getTrend(checkins), equals('IMPROVING'));
    });

    test('getTrend DEGRADING si score stress monte sur 7j', () {
      final now = DateTime.now();
      final checkins = [
        _makeCheckin(stress: 2, date: now.subtract(const Duration(days: 6))),
        _makeCheckin(stress: 2, date: now.subtract(const Duration(days: 5))),
        _makeCheckin(stress: 2, date: now.subtract(const Duration(days: 4))),
        _makeCheckin(stress: 8, date: now.subtract(const Duration(days: 3))),
        _makeCheckin(stress: 8, date: now.subtract(const Duration(days: 2))),
        _makeCheckin(stress: 8, date: now.subtract(const Duration(days: 1))),
      ];
      expect(HealthCalculator.getTrend(checkins), equals('DEGRADING'));
    });

    test('getTrend STABLE si variation < 10%', () {
      final now = DateTime.now();
      final checkins = [
        _makeCheckin(stress: 5, date: now.subtract(const Duration(days: 5))),
        _makeCheckin(stress: 5, date: now.subtract(const Duration(days: 4))),
        _makeCheckin(stress: 5, date: now.subtract(const Duration(days: 3))),
        _makeCheckin(stress: 5, date: now.subtract(const Duration(days: 2))),
        _makeCheckin(stress: 5, date: now.subtract(const Duration(days: 1))),
      ];
      expect(HealthCalculator.getTrend(checkins), equals('STABLE'));
    });

    test('getTrend avec liste vide retourne STABLE', () {
      expect(HealthCalculator.getTrend([]), equals('STABLE'));
    });

    test('getTrend avec un seul élément retourne STABLE', () {
      expect(HealthCalculator.getTrend([_makeCheckin()]), equals('STABLE'));
    });
  });
}

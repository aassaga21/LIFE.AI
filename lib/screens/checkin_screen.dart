import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/checkin_model.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../services/health_calculator.dart';
import '../theme/app_colors.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen>
    with TickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _notesController = TextEditingController();

  int _humeur = 3;
  double _energie = 5;
  double _sommeil = 5;
  double _stress = 5;
  bool _loading = false;
  bool _submitted = false;
  bool _alreadyDone = false;
  CheckIn? _todayCheckin;
  CheckIn? _resultCheckin;

  late AnimationController _resultController;
  late Animation<double> _resultAnimation;
  late List<AnimationController> _emojiControllers;

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
    _emojiControllers = List.generate(
      5,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 1.0,
        upperBound: 1.3,
      ),
    );
    _checkTodayCheckin();
  }

  @override
  void dispose() {
    _resultController.dispose();
    _notesController.dispose();
    for (final c in _emojiControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _checkTodayCheckin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final existing = await _firestoreService.getTodayCheckin(uid);
    if (existing != null && mounted) {
      setState(() {
        _alreadyDone = true;
        _todayCheckin = existing;
      });
    }
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);

    final checkin = CheckIn(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      date: DateTime.now(),
      humeur: _humeur,
      energie: _energie.round(),
      sommeil: _sommeil.round(),
      stress: _stress.round(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await context.read<UserProvider>().saveCheckin(checkin);
      if (mounted) {
        setState(() {
          _loading = false;
          _submitted = true;
          _resultCheckin = checkin;
        });
        _resultController.forward();
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  Color _sliderColor(double value, {required bool isStress}) {
    if (isStress) {
      if (value > 7) return AppColors.red;
      if (value > 5) return AppColors.orange;
      return AppColors.green;
    } else {
      if (value < 4) return AppColors.red;
      if (value < 7) return AppColors.orange;
      return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted && _resultCheckin != null) {
      return _buildResultCard(_resultCheckin!);
    }
    if (_alreadyDone && _todayCheckin != null) {
      return _buildAlreadyDone(_todayCheckin!);
    }
    return _buildForm();
  }

  // ── FORMULAIRE ────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Check-in du jour',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodSection(),
            const SizedBox(height: 24),
            _buildSliderSection(
              label: 'Énergie',
              icon: Icons.bolt,
              value: _energie,
              color: _sliderColor(_energie, isStress: false),
              onChanged: (v) => setState(() => _energie = v),
              isStress: false,
            ),
            const SizedBox(height: 16),
            _buildSliderSection(
              label: 'Sommeil',
              icon: Icons.bedtime,
              value: _sommeil,
              color: _sliderColor(_sommeil, isStress: false),
              onChanged: (v) => setState(() => _sommeil = v),
              isStress: false,
            ),
            const SizedBox(height: 16),
            _buildSliderSection(
              label: 'Stress',
              icon: Icons.psychology,
              value: _stress,
              color: _sliderColor(_stress, isStress: true),
              onChanged: (v) => setState(() => _stress = v),
              isStress: true,
            ),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    const emojis = ['😔', '😐', '🙂', '😊', '😁'];
    const labels = ['Difficile', 'Neutre', 'Bien', 'Très bien', 'Excellent'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment vous sentez-vous ?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final selected = _humeur == i + 1;
              return GestureDetector(
                onTap: () {
                  setState(() => _humeur = i + 1);
                  _emojiControllers[i]
                      .forward()
                      .then((_) => _emojiControllers[i].reverse());
                },
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _emojiControllers[i],
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          emojis[i],
                          style: TextStyle(fontSize: selected ? 44 : 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? AppColors.primary
                            : AppColors.grayText,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String label,
    required IconData icon,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
    required bool isStress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.round()}/10',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              overlayColor: color.withValues(alpha: 0.1),
            ),
            child: Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: value,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isStress ? 'Très calme' : 'Très faible',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.grayText),
              ),
              Text(
                isStress ? 'Très stressé' : 'Excellent',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.grayText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.grayText, size: 20),
              SizedBox(width: 8),
              Text(
                'Note du jour (optionnel)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'Comment s\'est passée votre journée ?',
              hintStyle:
                  TextStyle(color: AppColors.grayText, fontSize: 14),
              border: InputBorder.none,
              counterStyle: TextStyle(color: AppColors.grayText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Valider mon check-in',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  // ── RÉSULTAT POST-SOUMISSION ──────────────────────────────────────────────

  Widget _buildResultCard(CheckIn checkin) {
    final score = checkin.scoreBienEtre;
    final level = HealthCalculator.getStressLevel(score);
    final Color color;
    final String message;

    if (score > 75) {
      color = AppColors.green;
      message = 'Excellente forme ! Continuez sur cette lancée.';
    } else if (score > 50) {
      color = AppColors.orange;
      message = 'Vous êtes dans une bonne dynamique. Prenez soin de vous.';
    } else {
      color = AppColors.red;
      message = 'Accordez-vous du repos et de la bienveillance aujourd\'hui.';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: _resultAnimation,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: score / 100),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 10,
                              backgroundColor: color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                          Text(
                            '${(value * 100).round()}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Score du jour',
                    style: TextStyle(
                        color: AppColors.grayText, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.darkText, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Redirection vers le dashboard...',
                    style: TextStyle(
                        color: AppColors.grayText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── CHECK-IN DÉJÀ EFFECTUÉ ────────────────────────────────────────────────

  Widget _buildAlreadyDone(CheckIn checkin) {
    final score = checkin.scoreBienEtre;
    final Color color = score > 75
        ? AppColors.green
        : score > 50
            ? AppColors.orange
            : AppColors.red;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Check-in du jour',
          style: TextStyle(
              color: AppColors.darkText, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    size: 64, color: AppColors.green),
                const SizedBox(height: 16),
                const Text(
                  'Check-in déjà effectué !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vous avez déjà complété votre check-in aujourd\'hui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grayText),
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    Text(
                      '${score.round()}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed('/dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Voir le dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

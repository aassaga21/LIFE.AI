import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();

  // Contrôleurs de l'étape 1
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();

  bool _passwordVisible = false;
  bool _loading = false;
  String? _errorMessage;

  // État de la navigation multi-étapes
  int _etapeCourante = 0;

  // Données étape 2 — Santé
  String? _genre;
  double _sommeil = 5;
  double _stress = 5;
  String? _activite;

  // Données étape 3 — Objectifs
  final Set<String> _objectifsSelectionnes = {};

  static const List<String> _objectifs = [
    'Réduire le stress',
    'Améliorer le sommeil',
    'Plus d\'énergie',
    'Prévenir le burnout',
    'Mieux manger',
    'Bouger davantage',
  ];

  static const List<String> _niveauxActivite = [
    'Sédentaire',
    'Modéré',
    'Actif',
    'Très actif',
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _professionCtrl.dispose();
    super.dispose();
  }

  // Calcul de la force du mot de passe (0 à 4)
  int _forceMotDePasse(String password) {
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9!@#\$%^&*]').hasMatch(password)) score++;
    return score;
  }

  Color _couleurForce(int score) {
    switch (score) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      default:
        return AppColors.green;
    }
  }

  // Validation de l'étape 1
  String? _validerEtape1() {
    if (_firstNameCtrl.text.trim().isEmpty) return 'Le prénom est requis.';
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      return 'Veuillez entrer un email valide.';
    }
    if (_passwordCtrl.text.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return null;
  }

  void _etapeSuivante() {
    if (_etapeCourante == 0) {
      final erreur = _validerEtape1();
      if (erreur != null) {
        setState(() => _errorMessage = erreur);
        return;
      }
    }
    setState(() {
      _errorMessage = null;
      _etapeCourante++;
    });
  }

  void _etapePrecedente() {
    setState(() {
      _errorMessage = null;
      _etapeCourante--;
    });
  }

  // Création du compte à la dernière étape
  Future<void> _creerCompte() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        profession: _professionCtrl.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Indicateur d'étapes ───────────────────────────────────────────────────

  Widget _indicateurEtapes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final actif = i == _etapeCourante;
        final termine = i < _etapeCourante;
        return Row(
          children: [
            // Cercle numéroté
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (actif || termine) ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: (actif || termine) ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: termine
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: actif ? Colors.white : AppColors.grayText,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            // Ligne de connexion (sauf après le dernier)
            if (i < 2)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 2,
                color: i < _etapeCourante ? AppColors.primary : AppColors.border,
              ),
          ],
        );
      }),
    );
  }

  // ─── ÉTAPE 1 : Identité ───────────────────────────────────────────────────

  Widget _etape1() {
    final force = _forceMotDePasse(_passwordCtrl.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Votre identité',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
        ),
        const SizedBox(height: 20),
        _champTexte(controller: _firstNameCtrl, label: 'Prénom *', icon: Icons.person_outline),
        const SizedBox(height: 14),
        _champTexte(controller: _lastNameCtrl, label: 'Nom', icon: Icons.person_outline),
        const SizedBox(height: 14),
        _champTexte(
          controller: _emailCtrl,
          label: 'Email *',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: !_passwordVisible,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Mot de passe *',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        // Indicateur de force du mot de passe
        if (_passwordCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < force ? _couleurForce(force) : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            ['', 'Trop court', 'Faible', 'Moyen', 'Fort'][force.clamp(0, 4)],
            style: TextStyle(fontSize: 12, color: force > 0 ? _couleurForce(force) : AppColors.grayText),
          ),
        ],
        const SizedBox(height: 14),
        _champTexte(controller: _professionCtrl, label: 'Profession', icon: Icons.work_outline),
      ],
    );
  }

  // ─── ÉTAPE 2 : Santé ──────────────────────────────────────────────────────

  Widget _etape2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre santé',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
        ),
        const SizedBox(height: 20),

        // Genre
        const Text('Genre', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Homme', 'Femme', 'Autre'].map((g) {
            return ChoiceChip(
              label: Text(g),
              selected: _genre == g,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _genre == g ? Colors.white : AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) => setState(() => _genre = g),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Sommeil
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Qualité du sommeil', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText)),
            Text('${_sommeil.round()}/10', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
        Slider(
          value: _sommeil,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _sommeil = v),
        ),
        const SizedBox(height: 12),

        // Stress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Niveau de stress', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText)),
            Text('${_stress.round()}/10',
                style: TextStyle(
                  color: _stress >= 7 ? Colors.red : AppColors.primary,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
        Slider(
          value: _stress,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: _stress >= 7 ? Colors.red : AppColors.primary,
          onChanged: (v) => setState(() => _stress = v),
        ),
        const SizedBox(height: 20),

        // Niveau d'activité
        const Text('Activité physique', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _niveauxActivite.map((a) {
            return ChoiceChip(
              label: Text(a),
              selected: _activite == a,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _activite == a ? Colors.white : AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) => setState(() => _activite = a),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── ÉTAPE 3 : Objectifs ──────────────────────────────────────────────────

  Widget _etape3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Vos objectifs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
        ),
        const Text(
          'Sélectionnez tout ce qui vous correspond',
          style: TextStyle(color: AppColors.grayText, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Grille d'objectifs 2 colonnes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _objectifs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (_, i) {
            final obj = _objectifs[i];
            final selectionne = _objectifsSelectionnes.contains(obj);
            return GestureDetector(
              onTap: () => setState(() {
                if (selectionne) {
                  _objectifsSelectionnes.remove(obj);
                } else {
                  _objectifsSelectionnes.add(obj);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: selectionne ? AppColors.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectionne ? AppColors.primary : AppColors.border,
                    width: selectionne ? 2 : 1,
                  ),
                ),
                child: Text(
                  obj,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectionne ? AppColors.primary : AppColors.darkText,
                    fontWeight: selectionne ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Bandeau bêta gratuite
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
          ),
          child: const Text(
            '✓ Gratuit pendant la bêta · Sans engagement',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Champ texte réutilisable ─────────────────────────────────────────────

  Widget _champTexte({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  // ─── BUILD PRINCIPAL ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final titresEtapes = ['Identité', 'Santé', 'Objectifs'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                          children: [
                            TextSpan(text: 'LIFE'),
                            TextSpan(text: '.AI', style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Indicateur d'étapes
                  _indicateurEtapes(),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      titresEtapes[_etapeCourante],
                      style: const TextStyle(color: AppColors.grayText, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contenu de l'étape avec animation de transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_etapeCourante),
                      child: [_etape1(), _etape2(), _etape3()][_etapeCourante],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Message d'erreur
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Boutons de navigation
                  Row(
                    children: [
                      // Bouton Retour (sauf étape 1)
                      if (_etapeCourante > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _etapePrecedente,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('← Retour', style: TextStyle(color: AppColors.darkText)),
                          ),
                        ),
                      if (_etapeCourante > 0) const SizedBox(width: 12),

                      // Bouton Continuer ou Créer le compte
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : _etapeCourante < 2
                                    ? _etapeSuivante
                                    : _creerCompte,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : Text(
                                    _etapeCourante < 2 ? 'Continuer →' : 'Créer mon compte 🚀',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Lien vers la connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ? ',
                        style: TextStyle(color: AppColors.grayText, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

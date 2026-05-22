# LIFE.AI — Application Flutter

Application de suivi du bien-être et de la santé mentale, avec abonnement Premium via Stripe, authentification Firebase et IA de recommandation.

---

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Frontend | Flutter (Web + Android + iOS) |
| Auth | Firebase Authentication |
| Base de données | Cloud Firestore |
| Backend | Firebase Cloud Functions v2 (Gen 2 / Cloud Run) |
| Paiement | Stripe Checkout |
| Notifications | flutter_local_notifications |

---

## Architecture du projet

```
life_ai/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── models/
│   │   ├── checkin_model.dart
│   │   └── user_health_profile.dart
│   ├── providers/
│   │   └── user_provider.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── checkin_screen.dart
│   │   ├── pricing_screen.dart
│   │   └── ...
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── payment_service.dart       ← Stripe checkout
│   │   ├── stripe_service.dart
│   │   ├── notification_service.dart
│   │   ├── health_calculator.dart
│   │   └── ai/
│   │       ├── alert_engine.dart
│   │       └── recommendation_engine.dart
│   ├── widgets/
│   │   ├── navbar.dart
│   │   └── sections/
│   │       ├── pricing_section.dart   ← Listener Firestore temps réel
│   │       └── ...
│   └── theme/
│       └── app_colors.dart
├── functions/
│   ├── index.js                       ← Cloud Functions (Stripe)
│   ├── package.json
│   └── .env                           ← Variables Stripe (ne pas commiter)
├── android/
│   └── app/src/main/AndroidManifest.xml
└── ios/
    └── Runner/Info.plist
```

---

## Fonctionnalités implémentées

### Authentification
- Inscription / connexion par email + mot de passe via Firebase Auth
- Flux multi-étapes (login → register)
- Déconnexion

### Dashboard santé
- Check-in quotidien (humeur, énergie, stress, sommeil)
- Moteur IA de recommandations personnalisées
- Moteur d'alertes automatiques
- Historique des check-ins avec graphiques (fl_chart)
- Notifications locales

### Abonnement Premium (Stripe)
- Page de tarification avec 3 plans : Gratuit / Premium (9,99€/mois) / Entreprise
- Détection en temps réel du statut d'abonnement via Firestore `StreamBuilder`
- Affiche "Plan Premium actif ✅" si `subscription == "PREMIUM"`, sinon bouton de paiement
- Paiement via Stripe Checkout (redirection navigateur externe)
- Mise à jour automatique Firestore via webhook Stripe

---

## Configuration initiale

### 1. Prérequis

```bash
flutter pub get
cd functions && npm install
```

### 2. Variables d'environnement Stripe

Créer le fichier `functions/.env` (ne jamais commiter ce fichier) :

```env
STRIPE_SECRET_KEY=sk_test_XXXXXXXXXXXXXXXXXXXX
STRIPE_WEBHOOK_SECRET=whsec_XXXXXXXXXXXXXXXXXXXX
STRIPE_PRICE_ID=price_XXXXXXXXXXXXXXXXXXXX
```

- **STRIPE_SECRET_KEY** : Stripe Dashboard → Développeurs → Clés API → Clé secrète
- **STRIPE_PRICE_ID** : Stripe Dashboard → Catalogue de produits → ton produit → ID du tarif
- **STRIPE_WEBHOOK_SECRET** : Stripe Dashboard → Développeurs → Webhooks → ton endpoint → Secret de signature

### 3. Déployer les Cloud Functions

```bash
firebase deploy --only functions
```

### 4. Configurer Cloud Run (accès public pour CORS)

Après le premier déploiement, autoriser les requêtes CORS depuis le navigateur :

1. Aller sur [Google Cloud Console → Cloud Run](https://console.cloud.google.com/run)
2. Cliquer sur **`createcheckoutsession`**
3. Onglet **Sécurité** → sélectionner **"Autoriser l'accès public"**
4. Cliquer **"Modifier et déployer la nouvelle révision"** → **Déployer**

> Cette étape est nécessaire car le navigateur envoie un preflight CORS OPTIONS sans token d'authentification. Cloud Run doit l'accepter avant que la vraie requête avec token Firebase soit envoyée.

### 5. Configurer le webhook Stripe

1. Stripe Dashboard → Développeurs → Webhooks → **Ajouter un endpoint**
2. URL : `https://stripewebhook-7bxn6rvp2q-uc.a.run.app`
3. Événements à écouter :
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.paid`
   - `invoice.payment_failed`

---

## Cloud Functions

### `createCheckoutSession` (callable)

Crée une session Stripe Checkout et retourne l'URL de paiement.

- **Déclencheur** : Firebase callable (HTTPS)
- **Auth** : Firebase ID token requis (`request.auth`)
- **Paramètres** : `{ email: string }`
- **Réponse** : `{ url: string }` — URL de la page Stripe Checkout
- **URL Cloud Run** : `https://createcheckoutsession-7bxn6rvp2q-uc.a.run.app`

### `stripeWebhook` (HTTP)

Reçoit les événements Stripe et met à jour Firestore.

- **Déclencheur** : HTTP POST depuis Stripe
- **URL** : `https://stripewebhook-7bxn6rvp2q-uc.a.run.app`
- **Événements gérés** :
  - `checkout.session.completed` → `subscription: "PREMIUM"`
  - `customer.subscription.updated` → mise à jour statut
  - `customer.subscription.deleted` → `subscription: "FREE"`
  - `invoice.paid` → confirmation PREMIUM
  - `invoice.payment_failed` → `subscriptionStatus: "past_due"`

---

## Structure Firestore

### Collection `users`

```
users/{uid}
├── email: string
├── subscription: "FREE" | "PREMIUM"
├── subscriptionStatus: "active" | "past_due" | "canceled"
├── stripeCustomerId: string
├── subscriptionId: string
└── updatedAt: timestamp
```

---

## Lancer l'application

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## Tester le paiement Stripe (mode test)

1. Cliquer **"Passer en Premium"** sur la page Tarification
2. Utiliser la carte de test :

| Champ | Valeur |
|-------|--------|
| Numéro | `4242 4242 4242 4242` |
| Date d'expiration | `12/29` |
| CVC | `123` |
| Nom | N'importe quoi |

3. Après paiement, vérifier dans **Firestore → users → {uid}** que `subscription == "PREMIUM"`
4. La page Tarification affiche automatiquement **"Plan Premium actif ✅"**

---

## Modifications apportées

### Flutter

| Fichier | Modification |
|---------|-------------|
| `lib/services/payment_service.dart` | Nouveau — appel Firebase callable `createCheckoutSession`, ouverture URL Stripe |
| `lib/widgets/sections/pricing_section.dart` | StreamBuilder Firestore temps réel sur `users/{uid}`, affichage conditionnel Premium/bouton paiement |
| `android/app/src/main/AndroidManifest.xml` | Ajout queries intent `https` et `http` pour url_launcher |
| `ios/Runner/Info.plist` | Ajout `LSApplicationQueriesSchemes` pour https/http |

### Cloud Functions

| Fichier | Modification |
|---------|-------------|
| `functions/index.js` | Migration `createCheckoutSession` de l'API v1 (`functions.https.onCall`) vers l'API v2 (`onCall` de `firebase-functions/v2/https`) pour compatibilité auth Gen 2 |

### Infrastructure

| Action | Raison |
|--------|--------|
| Cloud Run `createcheckoutsession` → accès public | Permettre le preflight CORS OPTIONS depuis le navigateur (sans token) |

---

## Dépendances Flutter utilisées

```yaml
cloud_functions: ^6.3.1      # Appel callable Firebase Functions
url_launcher: ^6.2.0         # Ouvrir Stripe dans le navigateur
cloud_firestore: ^6.4.1      # Listener temps réel subscription
firebase_auth: ^6.5.1        # Authentification utilisateur
```

---

## Variables d'environnement (functions/.env)

> **Ne jamais commiter ce fichier.** Vérifier qu'il est dans `.gitignore`.

```
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_ID=price_...
```

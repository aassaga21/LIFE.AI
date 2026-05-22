const { onCall, HttpsError } = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const getStripe = () => require("stripe")(process.env.STRIPE_SECRET_KEY);

// 1. Créer une session Stripe Checkout
exports.createCheckoutSession = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Utilisateur non connecté");
  }

  const stripe = getStripe();

  try {
    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      payment_method_types: ["card"],
      line_items: [
        {
          price: process.env.STRIPE_PRICE_ID,
          quantity: 1,
        },
      ],
      success_url: "https://life.ai/merci?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "https://life.ai/tarification",
      customer_email: request.auth.token.email,
      metadata: {
        firebaseUid: request.auth.uid,
      },
    });

    return { url: session.url };
  } catch (error) {
    console.error("Erreur création session:", error);
    throw new HttpsError("internal", "Impossible de créer la session de paiement");
  }
});

// 2. Webhook Stripe
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const stripe = getStripe();
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;
  try {
    event = stripe.webhooks.constructEvent(
      req.rawBody,
      req.headers["stripe-signature"],
      webhookSecret
    );
  } catch (err) {
    console.error("Signature webhook invalide:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        await handleCheckoutCompleted(event.data.object);
        break;
      }
      case "customer.subscription.updated":
      case "customer.subscription.deleted": {
        await handleSubscriptionChange(event.data.object);
        break;
      }
      case "invoice.payment_failed": {
        await handlePaymentFailed(event.data.object);
        break;
      }
      case "invoice.paid": {
        await handleInvoicePaid(event.data.object);
        break;
      }
      default:
        console.log(`Événement non géré: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error("Erreur traitement webhook:", error);
    res.status(500).send("Erreur serveur");
  }
});

// --- Fonctions utilitaires ---

async function handleCheckoutCompleted(session) {
  const uid = session.metadata?.firebaseUid;
  const email = session.customer_email;

  let userRef;

  if (uid) {
    userRef = admin.firestore().collection("users").doc(uid);
  } else if (email) {
    const snapshot = await admin.firestore()
      .collection("users")
      .where("email", "==", email)
      .limit(1)
      .get();

    if (snapshot.empty) {
      console.error("Utilisateur introuvable pour l'email:", email);
      return;
    }
    userRef = snapshot.docs[0].ref;
  } else {
    console.error("Ni UID ni email dans la session:", session.id);
    return;
  }

  await userRef.update({
    subscription: "PREMIUM",
    stripeCustomerId: session.customer,
    subscriptionId: session.subscription,
    subscriptionStatus: "active",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`Utilisateur mis à jour en PREMIUM: ${uid || email}`);
}

async function handleSubscriptionChange(subscription) {
  const customerId = subscription.customer;

  const snapshot = await admin.firestore()
    .collection("users")
    .where("stripeCustomerId", "==", customerId)
    .limit(1)
    .get();

  if (snapshot.empty) {
    console.error("Utilisateur introuvable pour customerId:", customerId);
    return;
  }

  const isActive = subscription.status === "active";

  await snapshot.docs[0].ref.update({
    subscription: isActive ? "PREMIUM" : "FREE",
    subscriptionStatus: subscription.status,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`Abonnement mis à jour: ${subscription.status} pour ${customerId}`);
}

async function handlePaymentFailed(invoice) {
  const customerId = invoice.customer;

  const snapshot = await admin.firestore()
    .collection("users")
    .where("stripeCustomerId", "==", customerId)
    .limit(1)
    .get();

  if (!snapshot.empty) {
    await snapshot.docs[0].ref.update({
      subscriptionStatus: "past_due",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`Paiement échoué pour: ${customerId}`);
  }
}

async function handleInvoicePaid(invoice) {
  const customerId = invoice.customer;

  const snapshot = await admin.firestore()
    .collection("users")
    .where("stripeCustomerId", "==", customerId)
    .limit(1)
    .get();

  if (!snapshot.empty) {
    await snapshot.docs[0].ref.update({
      subscription: "PREMIUM",
      subscriptionStatus: "active",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`Facture payée, PREMIUM confirmé pour: ${customerId}`);
  }
}

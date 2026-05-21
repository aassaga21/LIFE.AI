const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// 1. Créer une session Stripe Checkout
exports.createCheckoutSession = functions.https.onCall(async (data, context) => {
  const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Utilisateur non connecté");
  }

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    payment_method_types: ["card"],
    line_items: [
      {
        price: "price_xxxxx", // Remplace par ton price_id Stripe
        quantity: 1,
      },
    ],
    success_url: "https://life.ai/merci",
    cancel_url: "https://life.ai/tarification",
    customer_email: context.auth.token.email,
  });

  return { url: session.url };
});

// 2. Webhook Stripe
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
  const event = req.body;

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    const email = session.customer_email;

    const userSnapshot = await admin.firestore()
      .collection("users")
      .where("email", "==", email)
      .get();

    if (!userSnapshot.empty) {
      const userDoc = userSnapshot.docs[0];
      await userDoc.ref.update({
        plan: "premium",
        stripeCustomerId: session.customer,
        subscriptionId: session.subscription,
        subscriptionStatus: "active",
      });
    }
  }

  res.json({ received: true });
});
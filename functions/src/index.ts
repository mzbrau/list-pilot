import * as crypto from 'crypto';
import * as admin from 'firebase-admin';
import { defineSecret } from 'firebase-functions/params';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { google } from 'googleapis';

admin.initializeApp();

const db = admin.firestore();

const playPackageName = defineSecret('PLAY_PACKAGE_NAME');
const playServiceAccountJson = defineSecret('PLAY_SERVICE_ACCOUNT_JSON');

type VerifyPlayPurchaseRequest = {
  uid: string;
  purchaseToken: string;
  productId: string;
  offerId?: string;
  platform?: string;
};

/**
 * Verifies a Google Play subscription and writes users/{uid}/private/billing.
 *
 * Secrets (firebase functions:secrets:set):
 * - PLAY_PACKAGE_NAME — Android applicationId
 * - PLAY_SERVICE_ACCOUNT_JSON — Play Developer API service account JSON
 */
export const verifyPlayPurchase = onCall(
  { secrets: [playPackageName, playServiceAccountJson] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required');
    }

    const data = request.data as VerifyPlayPurchaseRequest;
    if (request.auth.uid !== data.uid) {
      throw new HttpsError('permission-denied', 'UID mismatch');
    }

    const packageName = playPackageName.value();
    const serviceAccountJson = playServiceAccountJson.value();
    if (!packageName || !serviceAccountJson) {
      throw new HttpsError(
        'failed-precondition',
        'Play verification is not configured on the server',
      );
    }

    const credentials = JSON.parse(serviceAccountJson);
    const auth = new google.auth.GoogleAuth({
      credentials,
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    const androidPublisher = google.androidpublisher({ version: 'v3', auth });

    const purchase = await androidPublisher.purchases.subscriptions.get({
      packageName,
      subscriptionId: data.productId,
      token: data.purchaseToken,
    });

    const payload = purchase.data;
    const expiryMs = Number(payload.expiryTimeMillis ?? 0);
    const expiresAt = admin.firestore.Timestamp.fromMillis(expiryMs);
    const isPremium = expiryMs > Date.now();

    const tokenHash = crypto
      .createHash('sha256')
      .update(data.purchaseToken)
      .digest('hex');

    await db
      .collection('users')
      .doc(data.uid)
      .collection('private')
      .doc('billing')
      .set(
        {
          isPremium,
          expiresAt,
          platform: data.platform ?? 'play',
          productId: data.productId,
          promotionalPlanId: data.offerId ?? null,
          purchaseTokenHash: tokenHash,
          verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

    return { isPremium, expiresAt: expiresAt.toDate().toISOString() };
  },
);

/**
 * Future household invite redemption hook.
 */
export const redeemInvite = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required');
  }
  const code = (request.data?.code as string | undefined)?.trim();
  if (!code) {
    throw new HttpsError('invalid-argument', 'Invite code required');
  }

  const inviteRef = db.collection('invites').doc(code);
  const invite = await inviteRef.get();
  if (!invite.exists) {
    throw new HttpsError('not-found', 'Invite not found');
  }

  const inviteData = invite.data()!;
  const spaceId = inviteData.syncSpaceId as string;
  const expiresAt = inviteData.expiresAt as admin.firestore.Timestamp | undefined;
  if (expiresAt && expiresAt.toDate() < new Date()) {
    throw new HttpsError('failed-precondition', 'Invite expired');
  }

  const metaRef = db
    .collection('syncSpaces')
    .doc(spaceId)
    .collection('meta')
    .doc('info');

  await metaRef.set(
    { memberUids: admin.firestore.FieldValue.arrayUnion(request.auth.uid) },
    { merge: true },
  );

  await db
    .collection('users')
    .doc(request.auth.uid)
    .collection('private')
    .doc('sync')
    .set({ activeSyncSpaceId: spaceId }, { merge: true });

  return { syncSpaceId: spaceId };
});

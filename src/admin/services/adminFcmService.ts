import serviceAccount from '../firebase-service-account.json';

let cachedAccessToken: string | null = null;
let tokenExpiresAt = 0;

/**
 * Mengubah format PEM Private Key PKCS#8 menjadi ArrayBuffer untuk Web Crypto API
 */
function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64Lines = pem.replace(/-----[^\n]+-----/g, '').replace(/\s+/g, '');
  const binaryString = window.atob(b64Lines);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

/**
 * Base64URL encoder yang aman untuk UTF-8 string
 */
function toBase64Url(obj: any): string {
  const str = JSON.stringify(obj);
  const bytes = new TextEncoder().encode(str);
  let binary = '';
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
}

/**
 * Menghasilkan Google OAuth2 Access Token untuk FCM HTTP v1 API
 */
async function getGoogleFcmAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedAccessToken && now < tokenExpiresAt - 60) {
    return cachedAccessToken;
  }

  const binaryDer = pemToArrayBuffer(serviceAccount.private_key);
  const cryptoKey = await window.crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const header = { alg: 'RS256', typ: 'JWT' };
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const unsignedToken = `${toBase64Url(header)}.${toBase64Url(claimSet)}`;
  const dataToSign = new TextEncoder().encode(unsignedToken);
  const signatureBuffer = await window.crypto.subtle.sign('RSASSA-PKCS1-v1_5', cryptoKey, dataToSign);

  let sigBin = '';
  const sigBytes = new Uint8Array(signatureBuffer);
  for (let i = 0; i < sigBytes.length; i++) {
    sigBin += String.fromCharCode(sigBytes[i]);
  }
  const signature = window.btoa(sigBin).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  const jwt = `${unsignedToken}.${signature}`;

  const resp = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  const resJson = await resp.json();
  if (!resJson.access_token) {
    throw new Error('Gagal mendapatkan token autentikasi Google Firebase: ' + JSON.stringify(resJson));
  }

  cachedAccessToken = resJson.access_token as string;
  tokenExpiresAt = now + (resJson.expires_in || 3600);
  return cachedAccessToken;
}

export interface FcmPushPayload {
  tokens: string[];
  title: string;
  message: string;
  actionType?: string;
  actionUrl?: string;
}

export const adminFcmService = {
  /**
   * Menembakkan push notification FCM HTTP v1 ke seluruh token HP siswa yang terdaftar.
   * Memberikan sinyal data & notification priority tinggi agar Android menampilkan
   * expandable banner BigTextStyle meskipun app sedang tertutup / mati.
   */
  async sendPushNotificationToTokens(payload: FcmPushPayload): Promise<{ success: number; failed: number }> {
    const { tokens, title, message, actionType, actionUrl } = payload;
    if (!tokens || tokens.length === 0) {
      return { success: 0, failed: 0 };
    }

    try {
      const accessToken = await getGoogleFcmAccessToken();
      const projectId = serviceAccount.project_id || 'snaps-6767';
      const endpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

      let successCount = 0;
      let failedCount = 0;

      // Kirim secara paralel dalam batch kecil
      const promises = tokens.map(async (fcmToken) => {
        try {
          const body = {
            message: {
              token: fcmToken,
              notification: {
                title,
                body: message,
              },
              data: {
                title,
                message,
                action_type: actionType || 'none',
                action_url: actionUrl || '',
              },
              android: {
                priority: 'high',
                notification: {
                  channel_id: 'snaps_announcements',
                  default_sound: true,
                  default_vibrate_timings: true,
                  notification_priority: 'PRIORITY_MAX',
                  visibility: 'PUBLIC',
                },
              },
            },
          };

          const res = await fetch(endpoint, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
          });

          if (res.ok) {
            successCount++;
          } else {
            failedCount++;
          }
        } catch (e) {
          console.warn('FCM dispatch error for token:', fcmToken, e);
          failedCount++;
        }
      });

      await Promise.allSettled(promises);
      return { success: successCount, failed: failedCount };
    } catch (err) {
      console.error('sendPushNotificationToTokens failed:', err);
      return { success: 0, failed: tokens.length };
    }
  },
};

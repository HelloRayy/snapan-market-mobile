import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// In-memory token cache across warm Deno invocations
let cachedAccessToken: string | null = null;
let tokenExpiresAt = 0;

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64Lines = pem.replace(/-----[^\n]+-----/g, "").replace(/\s+/g, "");
  const binaryString = atob(b64Lines);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

function toBase64Url(obj: unknown): string {
  const str = JSON.stringify(obj);
  const bytes = new TextEncoder().encode(str);
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

async function getGoogleFcmAccessToken(serviceAccount: Record<string, any>): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedAccessToken && now < tokenExpiresAt - 60) {
    return cachedAccessToken;
  }

  const binaryDer = pemToArrayBuffer(serviceAccount.private_key);
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const header = { alg: "RS256", typ: "JWT" };
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const unsignedToken = `${toBase64Url(header)}.${toBase64Url(claimSet)}`;
  const dataToSign = new TextEncoder().encode(unsignedToken);
  const signatureBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    dataToSign,
  );

  let sigBin = "";
  const sigBytes = new Uint8Array(signatureBuffer);
  for (let i = 0; i < sigBytes.length; i++) {
    sigBin += String.fromCharCode(sigBytes[i]);
  }
  const signature = btoa(sigBin).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  const jwt = `${unsignedToken}.${signature}`;

  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const resJson = await resp.json();
  if (!resJson.access_token) {
    throw new Error("Failed to get Google OAuth token: " + JSON.stringify(resJson));
  }

  cachedAccessToken = resJson.access_token as string;
  tokenExpiresAt = now + (resJson.expires_in || 3600);
  return cachedAccessToken;
}

Deno.serve(async (req) => {
  // CORS check
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const payload = await req.json();
    // Payload from Postgres Database Webhook: { type: 'INSERT', table: 'direct_messages', record: { ... } }
    // Or direct invocation: { record: { ... } }
    const record = payload.record || payload;

    const conversationId = record.conversation_id as string;
    const senderId = record.sender_id as string;
    const rawText = (record.message_text || "") as string;

    if (!conversationId || !senderId || !rawText.trim()) {
      return new Response(JSON.stringify({ message: "Ignored: Missing required message fields" }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Connect to Supabase with Service Role Key
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 1. Dapatkan percakapan untuk menentukan siapa lawan bicara (penerima)
    const { data: convData, error: convError } = await supabase
      .from("conversations")
      .select("participant_one, participant_two")
      .eq("id", conversationId)
      .single();

    if (convError || !convData) {
      console.error("[send-dm-push] Conversation not found:", convError);
      return new Response(JSON.stringify({ error: "Conversation not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    const recipientId =
      convData.participant_one === senderId
        ? convData.participant_two
        : convData.participant_one;

    if (!recipientId || recipientId === senderId) {
      return new Response(JSON.stringify({ message: "Ignored: Recipient is sender" }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // 2. Ambil profil pengirim untuk nama di notifikasi
    const { data: senderProfile } = await supabase
      .from("profiles")
      .select("full_name, username")
      .eq("id", senderId)
      .single();

    const senderName =
      senderProfile?.full_name ||
      (senderProfile?.username ? `@${senderProfile.username}` : "Seseorang");

    // Potong cuplikan pesan maksimal 60 karakter sesuai keputusan SNAPS-71
    const cleanText = rawText.trim();
    const messagePreview =
      cleanText.length > 60 ? `${cleanText.substring(0, 57)}...` : cleanText;

    // 3. Ambil seluruh token perangkat aktif milik penerima
    const { data: tokensData, error: tokenError } = await supabase
      .from("user_fcm_tokens")
      .select("fcm_token")
      .eq("user_id", recipientId);

    if (tokenError || !tokensData || tokensData.length === 0) {
      console.log(`[send-dm-push] No registered FCM token for user ${recipientId}`);
      return new Response(JSON.stringify({ message: "No FCM tokens registered for recipient" }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // 4. Load Firebase Service Account
    const rawServiceAccount = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!rawServiceAccount) {
      console.error("[send-dm-push] FIREBASE_SERVICE_ACCOUNT secret is missing");
      return new Response(JSON.stringify({ error: "FCM service account not configured" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    const serviceAccount = JSON.parse(rawServiceAccount);
    const accessToken = await getGoogleFcmAccessToken(serviceAccount);
    const projectId = serviceAccount.project_id || "snaps-6767";
    const endpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const deadTokens: string[] = [];
    let sentCount = 0;

    // 5. Kirim Push Notification ke seluruh device penerima
    await Promise.all(
      tokensData.map(async ({ fcm_token }) => {
        try {
          const fcmMessage = {
            message: {
              token: fcm_token,
              notification: {
                title: senderName,
                body: messagePreview,
              },
              data: {
                type: "dm",
                conversation_id: conversationId,
                sender_id: senderId,
                sender_name: senderName,
                message: messagePreview,
              },
              android: {
                priority: "high",
                collapse_key: `dm_${conversationId}`,
                notification: {
                  channel_id: "snaps_direct_messages",
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                  tag: `dm_${conversationId}`,
                },
              },
            },
          };

          const res = await fetch(endpoint, {
            method: "POST",
            headers: {
              Authorization: `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify(fcmMessage),
          });

          if (!res.ok) {
            const errBody = await res.json().catch(() => ({}));
            const errCode =
              errBody?.error?.details?.[0]?.errorCode ||
              errBody?.error?.status ||
              "";
            console.warn(`[send-dm-push] FCM error for token:`, errCode);

            // Mitigasi Tech Debt 4: Auto-Purge invalid / unregistered tokens
            if (
              errCode === "UNREGISTERED" ||
              errCode === "NOT_FOUND" ||
              errCode === "INVALID_ARGUMENT" ||
              res.status === 404
            ) {
              deadTokens.push(fcm_token);
            }
          } else {
            sentCount++;
          }
        } catch (pushErr) {
          console.error(`[send-dm-push] Push error:`, pushErr);
        }
      }),
    );

    // Hapus token yang sudah mati agar tabel user_fcm_tokens tetap bersih
    if (deadTokens.length > 0) {
      console.log(`[send-dm-push] Purging ${deadTokens.length} dead FCM tokens...`);
      await supabase
        .from("user_fcm_tokens")
        .delete()
        .in("fcm_token", deadTokens);
    }

    return new Response(
      JSON.stringify({
        success: true,
        sent: sentCount,
        purgedTokens: deadTokens.length,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (err: any) {
    console.error("[send-dm-push] Uncaught server error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

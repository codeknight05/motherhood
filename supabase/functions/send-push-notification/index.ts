import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GoogleAuth } from "npm:google-auth-library@9.x";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface NotificationPayload {
  title: string;
  body: string;
  userIds?: string[];
  sendToAll?: boolean;
  data?: Record<string, string>;
}

// Generate OAuth 2.0 Access Token from Firebase Service Account
async function getAccessToken(serviceAccount: any): Promise<string> {
  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: "https://www.googleapis.com/auth/firebase.messaging",
  });
  const client = await auth.getClient();
  const tokenResponse = await client.getAccessToken();
  if (!tokenResponse.token) {
    throw new Error("Failed to get Google OAuth 2.0 access token");
  }
  return tokenResponse.token;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Parse payload
    const payload: NotificationPayload = await req.json();
    const { title, body, userIds, sendToAll, data } = payload;

    if (!title || !body) {
      return new Response(
        JSON.stringify({ error: "title and body are required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Load environment variables
    const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountJson) {
      return new Response(
        JSON.stringify({ error: "FIREBASE_SERVICE_ACCOUNT environment variable is not set." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const serviceAccount = JSON.parse(serviceAccountJson);
    const projectId = serviceAccount.project_id;
    if (!projectId) {
      throw new Error("Invalid service account JSON: project_id is missing");
    }

    // 3. Connect to Supabase using service role to bypass RLS
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // 4. Retrieve target tokens
    let query = supabase
      .from("profiles")
      .select("id, fcm_token")
      .not("fcm_token", "is", null);

    if (userIds && userIds.length > 0 && !sendToAll) {
      query = query.in("id", userIds);
    }

    const { data: profiles, error: dbError } = await query;

    if (dbError) {
      throw new Error(`Database error fetching tokens: ${dbError.message}`);
    }

    const tokens = profiles?.map((p) => p.fcm_token).filter(Boolean) as string[] || [];
    const uniqueTokens = [...new Set(tokens)];

    if (uniqueTokens.length === 0) {
      return new Response(
        JSON.stringify({ message: "No registered device tokens found for target users.", sentCount: 0 }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 5. Get Google OAuth 2.0 access token
    const accessToken = await getAccessToken(serviceAccount);
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    console.log(`[FCM] Attempting to send push notifications to ${uniqueTokens.length} devices.`);

    // 6. Send notifications in parallel
    const sendPromises = uniqueTokens.map(async (token) => {
      try {
        const fcmPayload = {
          message: {
            token: token,
            notification: {
              title: title,
              body: body,
            },
            data: data || {},
          },
        };

        const res = await fetch(fcmUrl, {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(fcmPayload),
        });

        const resJson = await res.json();
        if (!res.ok) {
          console.warn(`[FCM] Delivery failed for token starting with ${token.substring(0, 10)}...`, resJson);

          // Clean up invalid/expired device tokens from the profiles table
          if (
            resJson.error?.status === "UNREGISTERED" || 
            resJson.error?.details?.[0]?.errorCode === "UNREGISTERED"
          ) {
            console.log(`[FCM] Clearing unregistered/stale token from profiles table.`);
            await supabase
              .from("profiles")
              .update({ fcm_token: null })
              .eq("fcm_token", token);
          }

          return { token: token.substring(0, 15) + "...", success: false, error: resJson.error?.message || "FCM Error" };
        }

        return { token: token.substring(0, 15) + "...", success: true, messageId: resJson.name };
      } catch (e) {
        console.error(`[FCM] Exception sending to token:`, e);
        return { token: token.substring(0, 15) + "...", success: false, error: String(e) };
      }
    });

    const results = await Promise.all(sendPromises);
    const successCount = results.filter((r) => r.success).length;

    return new Response(
      JSON.stringify({
        message: `Dispatched push notifications to target devices.`,
        totalAttempted: uniqueTokens.length,
        successCount: successCount,
        details: results,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error(`[Error] send-push-notification failed:`, err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

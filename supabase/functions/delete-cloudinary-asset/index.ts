import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { public_id } = await req.json();

    if (!public_id || typeof public_id !== "string") {
      return new Response(
        JSON.stringify({ error: "public_id is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const cloudName = Deno.env.get("CLOUDINARY_CLOUD_NAME");
    const apiKey    = Deno.env.get("CLOUDINARY_API_KEY");
    const apiSecret = Deno.env.get("CLOUDINARY_API_SECRET");

    if (!cloudName || !apiKey || !apiSecret) {
      return new Response(
        JSON.stringify({ error: "Cloudinary env vars not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Build SHA-1 signature required by Cloudinary
    const timestamp = Math.floor(Date.now() / 1000).toString();
    const signatureString = `public_id=${public_id}&timestamp=${timestamp}${apiSecret}`;

    const encoder = new TextEncoder();
    const hashBuffer = await crypto.subtle.digest("SHA-1", encoder.encode(signatureString));
    const hashArray  = Array.from(new Uint8Array(hashBuffer));
    const signature  = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");

    // Call Cloudinary destroy endpoint
    const form = new FormData();
    form.append("public_id", public_id);
    form.append("timestamp",  timestamp);
    form.append("api_key",    apiKey);
    form.append("signature",  signature);

    const cloudinaryRes = await fetch(
      `https://api.cloudinary.com/v1_1/${cloudName}/image/destroy`,
      { method: "POST", body: form }
    );

    const result = await cloudinaryRes.json();

    return new Response(
      JSON.stringify(result),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

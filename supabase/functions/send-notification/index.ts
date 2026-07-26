import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";
import webpush from "https://esm.sh/web-push@3.6.7";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Tratează solicitările OPTIONS preflight CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { title, body } = await req.json();

    // Preluăm toate abonamentele din baza de date
    const { data: subs, error: fetchError } = await supabase
      .from('push_abonamente')
      .select('*');

    if (fetchError) {
      throw fetchError;
    }

    const vapidPublicKey = Deno.env.get('VAPID_PUBLIC_KEY') || 'BPrIpJE6ECtF7l4yopjOlIVMAo1aXwUVrZOCcsnbN7SGckJEi0Pcks0CByOP9jfYT0rz0fjz2FcT0vXM-IIRg00';
    const vapidPrivateKey = Deno.env.get('VAPID_PRIVATE_KEY')!;
    const vapidSubject = Deno.env.get('VAPID_SUBJECT') || 'mailto:contact@rewind.ro';

    webpush.setVapidDetails(vapidSubject, vapidPublicKey, vapidPrivateKey);

    let sentCount = 0;
    let failedCount = 0;
    const deletedSubscriptions = [];

    const payload = JSON.stringify({ title, body });

    for (const sub of subs || []) {
      if (!sub.endpoint || !sub.p256dh || !sub.auth) {
        console.warn(`Abonament invalid pentru ${sub.nume}: lipsesc detalii.`);
        failedCount++;
        continue;
      }

      const pushSubscription = {
        endpoint: sub.endpoint,
        keys: {
          p256dh: sub.p256dh,
          auth: sub.auth
        }
      };

      try {
        await webpush.sendNotification(pushSubscription, payload);
        sentCount++;
        console.log(`Push trimis cu succes către ${sub.nume}`);
      } catch (err: any) {
        console.error(`Eroare push către ${sub.nume}:`, err);
        failedCount++;

        // Identificăm codul de stare HTTP de la serverul de push (FCM/Mozilla/etc.)
        const statusCode = err.statusCode || (err.headers && err.headers.status) || (err.body && err.body.statusCode);
        
        // Auto-curățare: dacă tokenul este 410 Gone sau 404 Not Found, îl ștergem din baza de date
        if (statusCode === 410 || statusCode === 404) {
          const { error: delErr } = await supabase
            .from('push_abonamente')
            .delete()
            .eq('id', sub.id);

          if (delErr) {
            console.error(`Eroare la ștergerea automată a abonamentului expirat pentru ${sub.nume}:`, delErr);
          } else {
            console.log(`Abonament expirat/revocat șters automat pentru ${sub.nume}`);
            deletedSubscriptions.push(sub.nume);
          }
        }
      }
    }

    // Întoarcem MEREU status 200 cu un rezumat, prevenind prăbușirea apelului de inventar pe client
    return new Response(
      JSON.stringify({ 
        success: true, 
        sentCount, 
        failedCount,
        deletedCount: deletedSubscriptions.length,
        deleted: deletedSubscriptions
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error: any) {
    console.error("Critical function error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});

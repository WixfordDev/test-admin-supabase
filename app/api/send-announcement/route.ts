 


// import { createServerClient } from '@supabase/ssr';
// import { cookies } from 'next/headers';
// import { NextResponse } from 'next/server';

// export async function POST(request: Request) {
//   const cookieStore = await cookies();
//   const supabase = createServerClient(
//     process.env.NEXT_PUBLIC_SUPABASE_URL!,
//     process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
//     {
//       cookies: {
//         get(name: string) {
//           return cookieStore.get(name)?.value;
//         },
//       },
//     }
//   );

//   try {
//     const { data: { session } } = await supabase.auth.getSession();

//     if (!session) {
//       return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
//     }

//     const { data: { user } } = await supabase.auth.getUser();
//     if (!user) {
//       return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
//     }

//     const adminClient = createServerClient(
//       process.env.NEXT_PUBLIC_SUPABASE_URL!,
//       process.env.SUPABASE_SERVICE_ROLE_KEY!,
//       {
//         cookies: {
//           get(name: string) {
//             return undefined;
//           },
//           set(name: string, value: string, options: any) {},
//           remove(name: string, options: any) {},
//         },
//       }
//     );

//     const { data: adminCheck, error: adminError } = await adminClient
//       .from('admin_users')
//       .select('*')
//       .eq('user_id', user.id)
//       .single();

//     if (adminError || !adminCheck || !adminCheck.is_active) {
//       return NextResponse.json({ error: 'Forbidden: Admin access required' }, { status: 403 });
//     }

//     // ✅ user_id request body থেকে নেওয়া হচ্ছে (target user এর ID)
//     const { title, body, user_id } = await request.json();

//     if (!title || !body) {
//       return NextResponse.json({ error: 'Title and body are required' }, { status: 400 });
//     }

//     const edgeFunctionUrl = 'https://gbfgotocraqfbzovzzum.supabase.co/functions/v1/fcm-mosque-notification';
//     const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

//     if (!serviceRoleKey) {
//       return NextResponse.json({ error: 'Server configuration error' }, { status: 500 });
//     }

//     const response = await fetch(edgeFunctionUrl, {
//       method: 'POST',
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': `Bearer ${serviceRoleKey}`,
//       },
//       body: JSON.stringify({
//         title,
//         body,
//         type: 'announcement',
//         user_id: user_id || null, // ✅ specific user এর ID পাঠানো হচ্ছে
//       }),
//     });

//     if (!response.ok) {
//       const errorData = await response.text();
//       console.error('Edge function error:', errorData);
//       return NextResponse.json({ error: `Failed to send notification: ${errorData}` }, { status: response.status });
//     }

//     const result = await response.json();
//     return NextResponse.json({ success: true, result });
//   } catch (error) {
//     console.error('Error sending notification:', error);
//     return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
//   }
// }


import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { get: (name) => cookieStore.get(name)?.value } }
  );

  try {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    // ✅ Service role client — RLS bypass করবে
    const adminClient = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
      {
        cookies: {
          get: () => undefined,
          set: () => {},
          remove: () => {},
        },
      }
    );

    const { data: adminCheck, error: adminError } = await adminClient
      .from('admin_users')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (adminError || !adminCheck || !adminCheck.is_active) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const { title, body, user_id, type = 'announcement' } = await request.json();

    if (!title || !body) {
      return NextResponse.json({ error: 'Title and body are required' }, { status: 400 });
    }

    // ── ১. FCM push পাঠাও ──
    const edgeFunctionUrl = 'https://gbfgotocraqfbzovzzum.supabase.co/functions/v1/fcm-mosque-notification';
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

    const fcmResponse = await fetch(edgeFunctionUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${serviceRoleKey}`,
      },
      body: JSON.stringify({
        title,
        body,
        type,
        user_id: user_id || null,
      }),
    });

    if (!fcmResponse.ok) {
      const errorData = await fcmResponse.text();
      return NextResponse.json(
        { error: `FCM failed: ${errorData}` },
        { status: fcmResponse.status }
      );
    }

    // ── ২. DB তে save করো ──
    if (user_id) {
      // ✅ Specific user — directly insert
      const rows: { user_id: string; title: string; body: string; type: string; data: object }[] = [
        { user_id, title, body, type, data: {} },
      ];

      // Admin-এর জন্যও copy insert করো (যাতে NotificationBell-এ দেখায়)
      // কিন্তু যদি admin নিজেই target user হয় তাহলে duplicate হবে না
      if (user.id && user.id !== user_id) {
        rows.push({ user_id: user.id, title, body, type, data: {} });
      }

      const { error: insertError } = await adminClient
        .from('notifications')
        .insert(rows);

      if (insertError) {
        // FCM গেছে কিন্তু DB fail — log করো কিন্তু error return করো না
        console.error('❌ DB insert failed for specific user:', insertError.message, insertError.details);
      } else {
        console.log('✅ Notification saved for user:', user_id, '+ admin copy for:', user.id);
      }

    } else {
      // ✅ All users — user_profiles থেকে সব user_id নাও
      const { data: allUsers, error: fetchError } = await adminClient
        .from('user_profiles')
        .select('user_id');

      if (fetchError) {
        console.error('❌ Failed to fetch users:', fetchError);
      } else if (allUsers && allUsers.length > 0) {
        const rows = allUsers.map((u) => ({
          user_id: u.user_id,
          title,
          body,
          type,
          data: {},
        }));

        // ১০০০ করে batch insert
        const chunkSize = 1000;
        for (let i = 0; i < rows.length; i += chunkSize) {
          const { error: batchError } = await adminClient
            .from('notifications')
            .insert(rows.slice(i, i + chunkSize));

          if (batchError) {
            console.error('❌ Batch insert error:', batchError);
          }
        }
        console.log(`✅ Notifications saved for ${rows.length} users`);
      }
    }

    const result = await fcmResponse.json();
    return NextResponse.json({ success: true, result });

  } catch (error) {
    console.error('Error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
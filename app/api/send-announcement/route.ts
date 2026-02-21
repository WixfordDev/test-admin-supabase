// import { createServerClient } from '@supabase/ssr';
// import { cookies } from 'next/headers';
// import { NextResponse } from 'next/server';

// export async function POST(request: Request) {
//   // Create Supabase client for server-side operations
//   const cookieStore = cookies();
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
//     // Get the session to verify the user is authenticated
//     const { data: { session } } = await supabase.auth.getSession();

//     // Check if user is authenticated and has admin privileges
//     if (!session) {
//       return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
//     }

//     // You might want to add additional checks to ensure the user is an admin
//     // For example, check if the user has a specific role in your database
//     const { data: { user } } = await supabase.auth.getUser();
//     if (!user) {
//       return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
//     }

//     console.log('Current user ID:', user.id); // Debugging line

//     // Create admin client for database operations
//     const adminClient = createServerClient(
//       process.env.NEXT_PUBLIC_SUPABASE_URL!,
//       process.env.SUPABASE_SERVICE_ROLE_KEY!,
//       {
//         cookies: {
//           get() { return null; }, // Admin client doesn't need cookies
//           getAll() { return []; },
//           setAll() {}, // No-op for admin client
//         },
//       }
//     );

//     // Verify admin status (optional - customize based on your admin identification method)
//     const { data: adminCheck, error: adminError } = await adminClient
//       .from('admin_users')
//       .select('*') // Select all fields for debugging
//       .eq('user_id', user.id)
//       .single();

//     console.log('Admin check result:', { adminCheck, adminError }); // Debugging line

//     if (adminError || !adminCheck || !adminCheck.is_active) {
//       console.log('Admin verification failed:', adminError)
//       return NextResponse.json({ error: 'Forbidden: Admin access required' }, { status: 403 });
//     }

//     const { title, body } = await request.json();

//     if (!title || !body) {
//       return NextResponse.json({ error: 'Title and body are required' }, { status: 400 });
//     }

//     // Call the Edge Function with the service role key
//     const edgeFunctionUrl = 'https://gbfgotocraqfbzovzzum.supabase.co/functions/v1/fcm-mosque-notification';

//     // Use the service role key for authentication with the Edge Function
//     const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

//     if (!serviceRoleKey) {
//       console.error('Missing SUPABASE_SERVICE_ROLE_KEY environment variable');
//       return NextResponse.json({ error: 'Server configuration error' }, { status: 500 });
//     }

//     const response = await fetch(edgeFunctionUrl, {
//       method: 'POST',
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': `Bearer ${serviceRoleKey}`,
//       },
//      body: JSON.stringify({
//   title,
//   body,
//   type: 'announcement',
//   user_id: user.id || null, // 👈 এটা add করুন
// }),
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
  const cookieStore = cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value;
        },
      },
    }
  );

  try {
    const { data: { session } } = await supabase.auth.getSession();

    if (!session) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const adminClient = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
      {
        cookies: {
          get() { return null; },
          getAll() { return []; },
          setAll() {},
        },
      }
    );

    const { data: adminCheck, error: adminError } = await adminClient
      .from('admin_users')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (adminError || !adminCheck || !adminCheck.is_active) {
      return NextResponse.json({ error: 'Forbidden: Admin access required' }, { status: 403 });
    }

    // ✅ user_id request body থেকে নেওয়া হচ্ছে (target user এর ID)
    const { title, body, user_id } = await request.json();

    if (!title || !body) {
      return NextResponse.json({ error: 'Title and body are required' }, { status: 400 });
    }

    const edgeFunctionUrl = 'https://gbfgotocraqfbzovzzum.supabase.co/functions/v1/fcm-mosque-notification';
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!serviceRoleKey) {
      return NextResponse.json({ error: 'Server configuration error' }, { status: 500 });
    }

    const response = await fetch(edgeFunctionUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${serviceRoleKey}`,
      },
      body: JSON.stringify({
        title,
        body,
        type: 'announcement',
        user_id: user_id || null, // ✅ specific user এর ID পাঠানো হচ্ছে
      }),
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error('Edge function error:', errorData);
      return NextResponse.json({ error: `Failed to send notification: ${errorData}` }, { status: response.status });
    }

    const result = await response.json();
    return NextResponse.json({ success: true, result });
  } catch (error) {
    console.error('Error sending notification:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
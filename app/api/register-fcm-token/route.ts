import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  // Create Supabase client for server-side operations
  const cookieStore = cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        async get(name: string) {
          return (await cookieStore).get(name)?.value;
        },
      },
    }
  );

  // Get the session to verify the user is authenticated
  const { data: { session } } = await supabase.auth.getSession();
  
  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { fcmToken, deviceInfo } = await request.json();

    if (!fcmToken) {
      return NextResponse.json({ error: 'FCM token is required' }, { status: 400 });
    }

    // Call the RPC function to register the FCM token
    const { error } = await supabase.rpc('register_fcm_token', {
      p_user_id: session.user.id,
      p_fcm_token: fcmToken,
      p_device_info: deviceInfo || {}
    });

    if (error) {
      console.error('Error registering FCM token:', error);
      return NextResponse.json({ error: 'Failed to register FCM token' }, { status: 500 });
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error in FCM token registration API:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
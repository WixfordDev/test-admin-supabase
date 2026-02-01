import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
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
  
  // Check if user is authenticated and has admin privileges
  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Verify admin status
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Verify admin status (customize based on your admin identification method)
  const { data: adminCheck, error: adminError } = await supabase
    .from('admin_users')
    .select('id')
    .eq('user_id', user.id)
    .single();

  if (adminError || !adminCheck) {
    return NextResponse.json({ error: 'Forbidden: Admin access required' }, { status: 403 });
  }

  try {
    // Try to count the number of users with FCM tokens (subscribed to notifications)
    // First, try the user_profiles table since it's actively used in the application
    try {
      const { count: profileCount, error: profileError } = await supabase
        .from('user_profiles') // This table is actively used in the application
        .select('id', { count: 'exact', head: true });

      if (!profileError && profileCount !== null) {
        console.log(`Found ${profileCount} users in user_profiles table`);
        return NextResponse.json({
          success: true,
          subscriberCount: profileCount
        });
      } else if (profileError) {
        console.warn('Error querying user_profiles table:', profileError);
      }
    } catch (profileError) {
      console.warn('Could not query user_profiles table:', profileError);
    }

    // If user_profiles table doesn't exist or there was an error, try the user_fcm_tokens table
    try {
      const { count, error } = await supabase
        .from('user_fcm_tokens')
        .select('*', { count: 'exact', head: true });

      if (error) {
        if (error.code === '42P01') { // Table does not exist error code
          console.warn('user_fcm_tokens table does not exist, checking for alternative methods');
        } else {
          console.error('Error querying user_fcm_tokens table:', error);
        }
      } else {
        return NextResponse.json({
          success: true,
          subscriberCount: count || 0
        });
      }
    } catch (tableError) {
      console.warn('Could not query user_fcm_tokens table:', tableError);
    }

    // If we still don't have a count, try to count users from auth table
    try {
      // Count total registered users (fallback option)
      const { count: userCount, error: userError } = await supabase
        .from('auth.users') // Supabase auth table
        .select('*', { count: 'exact', head: true });

      if (!userError && userCount !== null) {
        console.log(`Found ${userCount} total registered users`);
        return NextResponse.json({
          success: true,
          subscriberCount: userCount
        });
      }
    } catch (userError) {
      console.warn('Could not query auth.users table:', userError);
    }

    // If all methods fail, return 0
    console.warn('Could not determine subscriber count from any available source');
    return NextResponse.json({
      success: true,
      subscriberCount: 0
    });
  } catch (error) {
    console.error('Error getting subscriber count:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
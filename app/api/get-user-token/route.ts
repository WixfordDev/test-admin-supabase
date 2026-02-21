import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;
const supabase = createClient(supabaseUrl, supabaseKey);

export async function GET(request: Request) {
  // Extract user_id from the URL query parameters
  const { searchParams } = new URL(request.url);
  const user_id = searchParams.get('user_id');

  if (!user_id) {
    return Response.json({ error: 'User ID is required' }, { status: 400 });
  }

  try {
    // Get the user's FCM token from the user_fcm_tokens table
    const { data, error } = await supabase
      .from('user_fcm_tokens')
      .select('fcm_token')
      .eq('user_id', user_id)
      .order('created_at', { ascending: false }) // Get the most recent token
      .limit(1);

    if (error) {
      console.error('Error fetching user token:', error);
      // Check if the error is due to table not existing
      if (error.code === '42P01' || error.message.includes('does not exist')) { // PostgreSQL error code for "undefined_table"
        console.warn('user_fcm_tokens table does not exist');
        return Response.json({ success: true, token: null });
      }
      return Response.json({ error: 'Failed to fetch user token' }, { status: 500 });
    }

    if (!data || data.length === 0) {
      return Response.json({ success: true, token: null });
    }

    return Response.json({
      success: true,
      token: data[0]?.fcm_token
    });
  } catch (error) {
    console.error('Error getting user token:', error);
    return Response.json({ error: 'Failed to get user token' }, { status: 500 });
  }
}
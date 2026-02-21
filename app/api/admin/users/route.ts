// import { createAdminClient } from '@/lib/supabase/server'
// import { NextRequest, NextResponse } from 'next/server'
// import type { UserFilters, UpdateUserData } from '@/lib/types/users'

// export async function GET(request: NextRequest) {
//   try {
//     const adminClient = await createAdminClient()
//     const { searchParams } = new URL(request.url)
    
//     // Parse filters from query params
//     const search = searchParams.get('search') || ''
//     const subscriptionStatus = searchParams.get('subscription_status') || 'all'
//     const sortBy = searchParams.get('sort_by') || 'created_at'
//     const sortOrder = searchParams.get('sort_order') || 'desc'
//     const page = parseInt(searchParams.get('page') || '1')
//     const limit = parseInt(searchParams.get('limit') || '50')

//     let query = adminClient
//       .from('user_profiles')
//       .select('*')

//     // Apply search filter
//     if (search) {
//       query = query.or(`full_name.ilike.%${search}%,email.ilike.%${search}%`)
//     }

//     // Apply subscription filter
//     if (subscriptionStatus !== 'all') {
//       query = query.eq('subscription_status', subscriptionStatus)
//     }

//     // Apply sorting
//     query = query.order(sortBy, { ascending: sortOrder === 'asc' })

//     // Apply pagination
//     const from = (page - 1) * limit
//     const to = from + limit - 1
//     query = query.range(from, to)

//     const { data: users, error, count } = await query

//     if (error) {
//       console.error('Error fetching users:', error)
//       return NextResponse.json(
//         { error: 'Failed to fetch users' },
//         { status: 500 }
//       )
//     }

//     // Get stats
//     const { data: statsData } = await adminClient
//       .from('user_profiles')
//       .select('subscription_status')

//     const stats = {
//       total_users: statsData?.length || 0,
//       free_users: statsData?.filter(u => u.subscription_status === 'free').length || 0,
//       barakah_access_users: statsData?.filter(u => u.subscription_status === 'barakah_access').length || 0,
//       quran_lite_users: statsData?.filter(u => u.subscription_status === 'quran_lite').length || 0,
//       deenhub_pro_users: statsData?.filter(u => u.subscription_status === 'deenhub_pro').length || 0,
//       new_users_this_month: 0, // TODO: Calculate based on created_at
//       active_users_last_30_days: 0, // TODO: Calculate based on last activity
//     }

//     return NextResponse.json({
//       users: users || [],
//       stats,
//       pagination: {
//         page,
//         limit,
//         total: count || 0,
//         totalPages: Math.ceil((count || 0) / limit)
//       }
//     })
//   } catch (error) {
//     console.error('Error in users API:', error)
//     return NextResponse.json(
//       { error: 'Internal server error' },
//       { status: 500 }
//     )
//   }
// }

// export async function PUT(request: NextRequest) {
//   try {
//     const adminClient = await createAdminClient()
//     const body = await request.json()
//     const { user_id, ...updateData }: { user_id: string } & UpdateUserData = body

//     if (!user_id) {
//       return NextResponse.json(
//         { error: 'User ID is required' },
//         { status: 400 }
//       )
//     }

//     // Get the current user data to check if status is changing to suspended
//     const { data: currentUser, error: fetchError } = await adminClient
//       .from('user_profiles')
//       .select('*')
//       .eq('user_id', user_id)
//       .single()

//     if (fetchError) {
//       console.error('Error fetching user:', fetchError)
//       return NextResponse.json(
//         { error: 'Failed to fetch user' },
//         { status: 500 }
//       )
//     }

//     // Calculate subscription expiry for monthly subscriptions
//     let dataToUpdate: any = { ...updateData }

//     if (updateData.subscription_status && updateData.subscription_status !== 'free') {
//       dataToUpdate.has_subscription = true
//       // Set monthly subscription expiry (30 days from now)
//       dataToUpdate.subscription_expiry = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
//     } else if (updateData.subscription_status === 'free') {
//       dataToUpdate.has_subscription = false
//       dataToUpdate.subscription_expiry = null
//     }

//     dataToUpdate.updated_at = new Date().toISOString()

//     const { data: updatedUser, error } = await adminClient
//       .from('user_profiles')
//       .update(dataToUpdate)
//       .eq('user_id', user_id)
//       .select()
//       .single()

//     if (error) {
//       console.error('Error updating user:', error)
//       return NextResponse.json(
//         { error: 'Failed to update user' },
//         { status: 500 }
//       )
//     }

//     // Check if the user is being suspended and send notification
//     if (dataToUpdate.subscription_status === 'expired' && currentUser?.subscription_status !== 'expired') {
//       // Trigger the suspension notification
//       try {
//         // Get the current admin user ID (this would come from the session in a real implementation)
//         // For now, we'll use a placeholder admin ID
//         const adminSession = await adminClient.auth.getUser();
//         const adminId = adminSession?.data?.user?.id || 'system'; // In a real scenario, get the actual admin ID

//         const suspensionPayload = {
//           user_id: user_id,
//           admin_id: adminId,
//           reason: updateData.suspension_reason || 'Account suspended by admin'
//         };

//         // Call the API to send the suspension notification
//         await fetch('/api/send-suspension-notification', {
//           method: 'POST',
//           headers: {
//             'Content-Type': 'application/json',
//           },
//           body: JSON.stringify(suspensionPayload),
//         });
//       } catch (notificationError) {
//         console.error('Failed to send suspension notification:', notificationError);
//         // Don't fail the entire request if notification fails
//       }
//     }

//     return NextResponse.json({
//       success: true,
//       user: updatedUser
//     })
//   } catch (error) {
//     console.error('Error in users PUT API:', error)
//     return NextResponse.json(
//       { error: 'Internal server error' },
//       { status: 500 }
//     )
//   }
// }





import { createAdminClient } from "@/lib/supabase/server";
import { NextRequest, NextResponse } from "next/server";
import type { UpdateUserData } from "@/lib/types/users";

// ===============================
// ✅ GET USERS
// ===============================
export async function GET(request: NextRequest) {
  try {
    const adminClient = await createAdminClient();
    const { searchParams } = new URL(request.url);

    const search = searchParams.get("search") || "";
    const subscriptionStatus = searchParams.get("subscription_status") || "all";
    const sortBy = searchParams.get("sort_by") || "created_at";
    const sortOrder = searchParams.get("sort_order") || "desc";
    const page = parseInt(searchParams.get("page") || "1");
    const limit = parseInt(searchParams.get("limit") || "50");

    let query = adminClient
      .from("user_profiles")
      .select("*", { count: "exact" }); // Enable count for pagination

    if (search) {
      query = query.or(
        `full_name.ilike.%${search}%,email.ilike.%${search}%`
      );
    }

    if (subscriptionStatus !== "all") {
      query = query.eq("subscription_status", subscriptionStatus);
    }

    query = query.order(sortBy, { ascending: sortOrder === "asc" });

    const from = (page - 1) * limit;
    const to = from + limit - 1;
    query = query.range(from, to);

    const { data: users, error, count } = await query;

    if (error) {
      return NextResponse.json(
        { error: "Failed to fetch users" },
        { status: 500 }
      );
    }

    const { data: statsData } = await adminClient
      .from("user_profiles")
      .select("subscription_status");

    const stats = {
      total_users: statsData?.length || 0,
      free_users:
        statsData?.filter((u) => u.subscription_status === "free").length || 0,
      barakah_access_users:
        statsData?.filter((u) => u.subscription_status === "barakah_access")
          .length || 0,
      quran_lite_users:
        statsData?.filter((u) => u.subscription_status === "quran_lite")
          .length || 0,
      deenhub_pro_users:
        statsData?.filter((u) => u.subscription_status === "deenhub_pro")
          .length || 0,
      new_users_this_month: 0,
      active_users_last_30_days: 0,
    };

    return NextResponse.json({
      users: users || [],
      stats,
      pagination: {
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit),
      },
    });
  } catch (error) {
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

// ===============================
// ✅ UPDATE USER
// ===============================
export async function PUT(request: NextRequest) {
  try {
    const adminClient = await createAdminClient();
    const body = await request.json();

    // ✅ Type safe fix for suspension_reason
    const parsedBody = body as {
      user_id: string;
    } & Partial<UpdateUserData> & { suspension_reason?: string };

    const { user_id, ...updateData } = parsedBody;

    if (!user_id) {
      return NextResponse.json(
        { error: "User ID is required" },
        { status: 400 }
      );
    }

    const { data: currentUser, error: fetchError } = await adminClient
      .from("user_profiles")
      .select("*")
      .eq("user_id", user_id)
      .single();

    if (fetchError) {
      return NextResponse.json(
        { error: "Failed to fetch user" },
        { status: 500 }
      );
    }

    // Prepare update data
    let dataToUpdate: any = { ...updateData };

    if (
      updateData.subscription_status &&
      updateData.subscription_status !== "free"
    ) {
      dataToUpdate.has_subscription = true;
      dataToUpdate.subscription_expiry = new Date(
        Date.now() + 30 * 24 * 60 * 60 * 1000
      ).toISOString();
    } else if (updateData.subscription_status === "free") {
      dataToUpdate.has_subscription = false;
      dataToUpdate.subscription_expiry = null;
    }

    dataToUpdate.updated_at = new Date().toISOString();

    const { data: updatedUser, error } = await adminClient
      .from("user_profiles")
      .update(dataToUpdate)
      .eq("user_id", user_id)
      .select()
      .single();

    if (error) {
      return NextResponse.json(
        { error: "Failed to update user" },
        { status: 500 }
      );
    }

    // ===============================
    // Suspension notification
    // ===============================
    if (
      dataToUpdate.subscription_status === "expired" &&
      currentUser?.subscription_status !== "expired"
    ) {
      try {
        const adminSession = await adminClient.auth.getUser();
        const adminId = adminSession?.data?.user?.id || "system";

        const suspensionPayload = {
          user_id,
          admin_id: adminId,
          reason:
            parsedBody.suspension_reason ||
            "Account suspended by admin",
        };

        await fetch(
          `${process.env.NEXT_PUBLIC_SITE_URL}/api/send-suspension-notification`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(suspensionPayload),
          }
        );
      } catch {
        // Notification failure should not break main request
      }
    }

    return NextResponse.json({
      success: true,
      user: updatedUser,
    });
  } catch {
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
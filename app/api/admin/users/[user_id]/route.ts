// import { createAdminClient } from '@/lib/supabase/server'
// import { NextRequest, NextResponse } from 'next/server'

// export async function DELETE(request: NextRequest, { params }: { params: { user_id: string } }) {
//   try {
//     const adminClient = await createAdminClient()
//     const { user_id } = params

//     if (!user_id) {
//       return NextResponse.json(
//         { error: 'User ID is required' },
//         { status: 400 }
//       )
//     }

//     // First, get the user profile to make sure it exists
//     const { data: userProfile, error: profileError } = await adminClient
//       .from('user_profiles')
//       .select('user_id, email')
//       .eq('user_id', user_id)
//       .single()

//     if (profileError || !userProfile) {
//       return NextResponse.json(
//         { error: 'User not found' },
//         { status: 404 }
//       )
//     }

//     // Delete user profile from our application table
//     const { error: profileDeleteError } = await adminClient
//       .from('user_profiles')
//       .delete()
//       .eq('user_id', user_id)

//     if (profileDeleteError) {
//       console.error('Error deleting user profile:', profileDeleteError)
//       return NextResponse.json(
//         { error: 'Failed to delete user profile' },
//         { status: 500 }
//       )
//     }

//     // Optionally, delete the user from Supabase Auth as well
//     const { error: authDeleteError } = await adminClient.auth.admin.deleteUser(user_id)

//     if (authDeleteError) {
//       console.error('Error deleting user from auth:', authDeleteError)
//       // Don't fail the operation if auth deletion fails, just log it
//     }

//     return NextResponse.json({
//       success: true,
//       message: 'User deleted successfully'
//     })
//   } catch (error: any) {
//     console.error('Error in delete user API:', error)
//     return NextResponse.json(
//       { error: error.message || 'Internal server error' },
//       { status: 500 }
//     )
//   }
// }




import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{
    user_id: string
  }>
}

export async function DELETE(
  request: NextRequest,
  context: RouteContext
) {
  try {
    const adminClient = await createAdminClient()

    const { user_id } = await context.params

    if (!user_id) {
      return NextResponse.json(
        { error: 'User ID is required' },
        { status: 400 }
      )
    }

    const { data: userProfile, error: profileError } = await adminClient
      .from('user_profiles')
      .select('user_id, email')
      .eq('user_id', user_id)
      .single()

    if (profileError || !userProfile) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      )
    }

    const { error: profileDeleteError } = await adminClient
      .from('user_profiles')
      .delete()
      .eq('user_id', user_id)

    if (profileDeleteError) {
      return NextResponse.json(
        { error: 'Failed to delete user profile' },
        { status: 500 }
      )
    }

    await adminClient.auth.admin.deleteUser(user_id)

    return NextResponse.json({
      success: true,
      message: 'User deleted successfully'
    })
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Internal server error' },
      { status: 500 }
    )
  }
}
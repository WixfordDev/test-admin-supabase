import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canConnectStripe } from '@/lib/helpers/mosque-permissions'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/donations
// Verified mosque owner sees their donation transaction history
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }
    const token = authHeader.split(' ')[1]

    const adminClient = await createAdminClient()
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token)
    if (authError || !user) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }

    const { mosqueId } = await context.params

    const allowed = await canConnectStripe(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json(
        { success: false, message: 'Forbidden: verified mosque owner only' },
        { status: 403 }
      )
    }

    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const from = (page - 1) * limit
    const to = from + limit - 1

    const { data: transactions, count, error } = await adminClient
      .from('donation_transactions')
      .select('*', { count: 'exact' })
      .eq('mosque_id', mosqueId)
      .order('created_at', { ascending: false })
      .range(from, to)

    if (error) {
      return NextResponse.json({ success: false, message: 'Failed to fetch donations' }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      data: {
        transactions: transactions ?? [],
        pagination: {
          page,
          limit,
          total: count ?? 0,
          totalPages: Math.ceil((count ?? 0) / limit),
        },
      },
    })
  } catch (err: any) {
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    )
  }
}

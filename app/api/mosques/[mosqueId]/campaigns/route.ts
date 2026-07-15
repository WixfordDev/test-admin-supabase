import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canConnectStripe } from '@/lib/helpers/mosque-permissions'
import type { CreateCampaignBody } from '@/lib/types/campaigns'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/campaigns — public list
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const { mosqueId } = await context.params
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const activeOnly = searchParams.get('active') === 'true'
    const from = (page - 1) * limit
    const to = from + limit - 1

    const adminClient = await createAdminClient()

    let query = adminClient
      .from('mosque_campaigns')
      .select('*', { count: 'exact' })
      .eq('mosque_id', mosqueId)
      .order('created_at', { ascending: false })
      .range(from, to)

    if (activeOnly) {
      query = query.eq('is_active', true)
    }

    const { data: campaigns, count, error } = await query

    if (error) {
      return NextResponse.json({ success: false, message: 'Failed to fetch campaigns' }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      data: {
        campaigns: campaigns ?? [],
        pagination: {
          page,
          limit,
          total: count ?? 0,
          totalPages: Math.ceil((count ?? 0) / limit),
        },
      },
    })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}

// POST /api/mosques/:mosqueId/campaigns — owner only
export async function POST(request: NextRequest, context: RouteContext) {
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

    const body: CreateCampaignBody = await request.json()

    if (!body.title || !body.description || !body.category || !body.goal_amount) {
      return NextResponse.json(
        { success: false, message: 'title, description, category and goal_amount are required' },
        { status: 400 }
      )
    }

    if (body.title.length < 3) {
      return NextResponse.json(
        { success: false, message: 'title must be at least 3 characters' },
        { status: 400 }
      )
    }

    if (body.goal_amount < 100) {
      return NextResponse.json(
        { success: false, message: 'goal_amount must be at least 100 cents ($1.00)' },
        { status: 400 }
      )
    }

    const noEndDate = body.no_end_date ?? false

    if (!noEndDate && body.end_date && body.start_date && body.end_date <= body.start_date) {
      return NextResponse.json(
        { success: false, message: 'end_date must be after start_date' },
        { status: 400 }
      )
    }

    const { data: campaign, error } = await adminClient
      .from('mosque_campaigns')
      .insert({
        mosque_id: mosqueId,
        title: body.title,
        description: body.description,
        category: body.category,
        goal_amount: body.goal_amount,
        currency: body.currency ?? 'usd',
        cover_image_url: body.cover_image_url ?? null,
        start_date: body.start_date ?? null,
        end_date: noEndDate ? null : body.end_date ?? null,
        no_end_date: noEndDate,
        is_active: body.is_active ?? true,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json(
        { success: false, message: 'Failed to create campaign', details: error.message },
        { status: 500 }
      )
    }

    return NextResponse.json(
      { success: true, message: 'Campaign created.', data: { campaign } },
      { status: 201 }
    )
  } catch (err: any) {
    return NextResponse.json(
      { success: false, message: 'Internal server error', details: err?.message },
      { status: 500 }
    )
  }
}

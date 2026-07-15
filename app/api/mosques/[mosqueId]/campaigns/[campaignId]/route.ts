import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canConnectStripe } from '@/lib/helpers/mosque-permissions'
import type { UpdateCampaignBody } from '@/lib/types/campaigns'

type RouteContext = {
  params: Promise<{ mosqueId: string; campaignId: string }>
}

// GET /api/mosques/:mosqueId/campaigns/:campaignId — public
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const { mosqueId, campaignId } = await context.params
    const adminClient = await createAdminClient()

    const { data: campaign, error } = await adminClient
      .from('mosque_campaigns')
      .select('*')
      .eq('id', campaignId)
      .eq('mosque_id', mosqueId)
      .single()

    if (error || !campaign) {
      return NextResponse.json({ success: false, message: 'Campaign not found' }, { status: 404 })
    }

    return NextResponse.json({ success: true, data: { campaign } })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}

// PUT /api/mosques/:mosqueId/campaigns/:campaignId — owner only
export async function PUT(request: NextRequest, context: RouteContext) {
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

    const { mosqueId, campaignId } = await context.params

    const allowed = await canConnectStripe(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json(
        { success: false, message: 'Forbidden: verified mosque owner only' },
        { status: 403 }
      )
    }

    const { data: existing } = await adminClient
      .from('mosque_campaigns')
      .select('id')
      .eq('id', campaignId)
      .eq('mosque_id', mosqueId)
      .single()

    if (!existing) {
      return NextResponse.json({ success: false, message: 'Campaign not found' }, { status: 404 })
    }

    const body: UpdateCampaignBody = await request.json()

    if (body.goal_amount !== undefined && body.goal_amount < 100) {
      return NextResponse.json(
        { success: false, message: 'goal_amount must be at least 100 cents ($1.00)' },
        { status: 400 }
      )
    }

    if (!body.no_end_date && body.end_date && body.start_date && body.end_date <= body.start_date) {
      return NextResponse.json(
        { success: false, message: 'end_date must be after start_date' },
        { status: 400 }
      )
    }

    const updateData: Record<string, any> = {}
    if (body.title !== undefined) updateData.title = body.title
    if (body.description !== undefined) updateData.description = body.description
    if (body.category !== undefined) updateData.category = body.category
    if (body.goal_amount !== undefined) updateData.goal_amount = body.goal_amount
    if (body.currency !== undefined) updateData.currency = body.currency
    if (body.cover_image_url !== undefined) updateData.cover_image_url = body.cover_image_url
    if (body.start_date !== undefined) updateData.start_date = body.start_date
    if (body.end_date !== undefined) updateData.end_date = body.end_date
    if (body.no_end_date !== undefined) {
      updateData.no_end_date = body.no_end_date
      if (body.no_end_date) updateData.end_date = null
    }
    if (body.is_active !== undefined) updateData.is_active = body.is_active

    const { data: campaign, error } = await adminClient
      .from('mosque_campaigns')
      .update(updateData)
      .eq('id', campaignId)
      .select()
      .single()

    if (error) {
      return NextResponse.json(
        { success: false, message: 'Failed to update campaign' },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, message: 'Campaign updated.', data: { campaign } })
  } catch (err: any) {
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    )
  }
}

// DELETE /api/mosques/:mosqueId/campaigns/:campaignId — owner only
export async function DELETE(request: NextRequest, context: RouteContext) {
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

    const { mosqueId, campaignId } = await context.params

    const allowed = await canConnectStripe(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json(
        { success: false, message: 'Forbidden: verified mosque owner only' },
        { status: 403 }
      )
    }

    const { error } = await adminClient
      .from('mosque_campaigns')
      .delete()
      .eq('id', campaignId)
      .eq('mosque_id', mosqueId)

    if (error) {
      return NextResponse.json(
        { success: false, message: 'Failed to delete campaign' },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, message: 'Campaign deleted.' })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}

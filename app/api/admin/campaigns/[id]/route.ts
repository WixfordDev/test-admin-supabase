import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ id: string }>
}

// GET /api/admin/campaigns/:id — single campaign with transactions
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const { id } = await context.params
    const adminClient = await createAdminClient()

    const { data: campaign, error } = await adminClient
      .from('mosque_campaigns')
      .select('*')
      .eq('id', id)
      .single()

    if (error || !campaign) {
      return NextResponse.json({ error: 'Campaign not found' }, { status: 404 })
    }

    const { data: mosque } = await adminClient
      .from('mosques_metadata')
      .select('mosque_id, name, address')
      .eq('mosque_id', campaign.mosque_id)
      .single()

    const { data: transactions } = await adminClient
      .from('donation_transactions')
      .select('id, amount, mosque_amount, platform_fee, currency, status, receipt_url, created_at, donor_user_id')
      .eq('campaign_id', id)
      .order('created_at', { ascending: false })
      .limit(20)

    const totalRaised = transactions
      ?.filter((t) => t.status === 'completed')
      .reduce((sum, t) => sum + (t.amount ?? 0), 0) ?? 0

    return NextResponse.json({
      campaign: { ...campaign, mosque: mosque ?? null },
      transactions: transactions ?? [],
      stats: {
        total_raised_cents: totalRaised,
        total_transactions: transactions?.length ?? 0,
        completed: transactions?.filter((t) => t.status === 'completed').length ?? 0,
        pending: transactions?.filter((t) => t.status === 'pending').length ?? 0,
        failed: transactions?.filter((t) => t.status === 'failed').length ?? 0,
      },
    })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

// DELETE /api/admin/campaigns/:id — admin force delete
export async function DELETE(request: NextRequest, context: RouteContext) {
  try {
    const { id } = await context.params
    const adminClient = await createAdminClient()

    const { error } = await adminClient
      .from('mosque_campaigns')
      .delete()
      .eq('id', id)

    if (error) {
      return NextResponse.json({ error: 'Failed to delete campaign' }, { status: 500 })
    }

    return NextResponse.json({ success: true, message: 'Campaign deleted.' })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

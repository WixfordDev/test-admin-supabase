import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

// Define types
type UserProfile = {
  id: string
  email: string
  full_name: string | null
}

type Report = {
  id: string
  user_id: string | null
  report_type: string
  category: string
  title: string
  description: string | null
  content_id: string | null
  content_data: any
  context_data: any
  status: string
  admin_notes: string | null
  resolved_at: string | null
  resolved_by: string | null
  created_at: string | null
  updated_at: string | null
}

type TransformedReport = Report & {
  reporter: {
    id: string
    email: string
    full_name: string | null
  } | null
}

export async function GET(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)
    
    const status = searchParams.get('status') || 'all'
    const reportType = searchParams.get('report_type') || 'all'
    const search = searchParams.get('search') || ''
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '50')

    // Build the main query
    let query = adminClient
      .from('reports')
      .select(`
        id,
        user_id,
        report_type,
        category,
        title,
        description,
        content_id,
        content_data,
        context_data,
        status,
        admin_notes,
        resolved_at,
        resolved_by,
        created_at,
        updated_at
      `)

    // Apply status filter
    if (status !== 'all') {
      query = query.eq('status', status)
    }

    // Apply report type filter
    if (reportType !== 'all') {
      query = query.eq('report_type', reportType)
    }

    // Apply search filter
    if (search) {
      query = query.or(`title.ilike.%${search}%,description.ilike.%${search}%`)
    }

    // Apply sorting
    query = query.order('created_at', { ascending: false })

    // Apply pagination
    const from = (page - 1) * limit
    const to = from + limit - 1
    query = query.range(from, to)

    const { data: reports, error, count } = await query

    if (error) {
      console.error('Error fetching reports:', error)
      return NextResponse.json(
        { error: 'Failed to fetch reports' },
        { status: 500 }
      )
    }

    // Get user details separately
    const userIds = [...new Set(reports?.map(r => r.user_id).filter((id): id is string => Boolean(id)) || [])]
    let userData: UserProfile[] = []

    if (userIds.length > 0) {
      // First try user_profiles table
      const { data: profiles } = await adminClient
        .from('user_profiles')
        .select('id, email, full_name')
        .in('id', userIds)

      userData = (profiles as UserProfile[]) || []

      // Fallback to auth.users for any user IDs not found in user_profiles
      const foundIds = new Set(userData.map(u => u.id))
      const missingIds = userIds.filter(id => !foundIds.has(id))

      if (missingIds.length > 0) {
        const authResults = await Promise.all(
          missingIds.map(id => adminClient.auth.admin.getUserById(id))
        )
        const authUsers: UserProfile[] = authResults
          .filter(r => !r.error && r.data.user)
          .map(r => ({
            id: r.data.user!.id,
            email: r.data.user!.email || '',
            full_name:
              r.data.user!.user_metadata?.full_name ||
              r.data.user!.user_metadata?.name ||
              null
          }))
        userData = [...userData, ...authUsers]
      }
    }

    // Transform reports to include reporter info
    const transformedReports: TransformedReport[] = reports?.map(report => {
      const userProfile = userData.find(u => u.id === report.user_id)
      return {
        ...report,
        reporter: userProfile ? {
          id: userProfile.id,
          email: userProfile.email,
          full_name: userProfile.full_name
        } : null
      }
    }) || []

    // Get comprehensive stats
    const { data: allReports } = await adminClient
      .from('reports')
      .select('status, report_type, category, created_at')

    const stats = {
      total_reports: allReports?.length || 0,
      pending_reports: allReports?.filter(r => r.status === 'pending').length || 0,
      reviewed_reports: allReports?.filter(r => r.status === 'reviewing').length || 0,
      resolved_reports: allReports?.filter(r => r.status === 'resolved').length || 0,
      dismissed_reports: allReports?.filter(r => r.status === 'dismissed').length || 0,
    }

    return NextResponse.json({
      reports: transformedReports,
      stats,
      pagination: {
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit)
      }
    })

  } catch (error) {
    console.error('Error in reports API:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)
    const report_id = searchParams.get('id')

    if (!report_id) {
      return NextResponse.json({ error: 'Report ID is required' }, { status: 400 })
    }

    const body = await request.json()
    const { status, admin_notes, resolved_by } = body

    const updateData: Record<string, any> = {
      updated_at: new Date().toISOString()
    }

    if (status !== undefined) updateData.status = status
    if (admin_notes !== undefined) updateData.admin_notes = admin_notes

    // Set resolved_at and resolved_by when resolving or dismissing
    if (status === 'resolved' || status === 'dismissed') {
      updateData.resolved_at = new Date().toISOString()
      updateData.resolved_by = resolved_by || null
    }

    // Clear resolution fields when moving back to pending/reviewing
    if (status === 'pending' || status === 'reviewing') {
      updateData.resolved_at = null
      updateData.resolved_by = null
    }

    const { data, error } = await adminClient
      .from('reports')
      .update(updateData)
      .eq('id', report_id)
      .select()
      .single()

    if (error) {
      console.error('Error updating report:', error)
      return NextResponse.json({ error: 'Failed to update report', details: error.message }, { status: 500 })
    }

    return NextResponse.json({ success: true, report: data })
  } catch (error) {
    console.error('Error in report PATCH API:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
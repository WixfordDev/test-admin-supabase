import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

interface MosqueUpdateData {
  name?: string
  address?: string
  latitude?: number
  longitude?: number
  timezone?: string
  phone?: string
  website?: string
  additional_info?: string
  is_approved?: boolean
}

export async function GET(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)
    
    const search = searchParams.get('search') || ''
    const timezone = searchParams.get('timezone') || ''
    const facility = searchParams.get('facility') || ''
    const userSubmitted = searchParams.get('user_submitted') === 'true'
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '50')

    let query = adminClient
      .from('mosques_metadata')
      .select(`
        *,
        mosque_facilities (
          facility_type,
          availability,
          description,
          additional_info,
          last_updated,
          created_at,
          updated_by
        )
      `)

    // Apply search filter
    if (search) {
      query = query.or(`name.ilike.%${search}%,address.ilike.%${search}%,additional_info.ilike.%${search}%`)
    }

    // Apply timezone filter
    if (timezone) {
      query = query.eq('timezone', timezone)
    }

    // Apply facility filter (requires joining with mosque_facilities)
    if (facility) {
      query = query.filter('mosque_facilities.facility_type', 'eq', facility)
    }

    // Filter user-submitted mosques (mosque_id starts with 'user_mosque_')
    if (userSubmitted) {
      query = query.like('mosque_id', 'user_mosque_%')
    }

    // Apply sorting
    query = query.order('name', { ascending: true })

    // Apply pagination
    const from = (page - 1) * limit
    const to = from + limit - 1
    query = query.range(from, to)

    const { data: mosques, error, count } = await query

    // console.log("get data", mosques);

    if (error) {
      console.error('Error fetching mosques:', error)
      return NextResponse.json(
        { error: 'Failed to fetch mosques', details: error.message },
        { status: 500 }
      )
    }

    // Get stats  
    const { data: statsData } = await adminClient
      .from('mosques_metadata')
      .select('*, mosque_facilities(*)')

    const now = new Date()
    const thisWeekStart = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
    const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1)

    const thisWeekCount = (statsData || []).filter((m: any) => 
      new Date(m.created_at) >= thisWeekStart
    ).length

    const thisMonthCount = (statsData || []).filter((m: any) => 
      new Date(m.created_at) >= thisMonthStart
    ).length

    // Group by timezone
    const byTimezone = {} as Record<string, number>
    const byFacility = {} as Record<string, number>
    
    (statsData || []).forEach((mosque: any) => {
      // Count by timezone
      const timezone = mosque.timezone || 'UTC'
      byTimezone[timezone] = (byTimezone[timezone] || 0) + 1
      
      // Count by facility
      if (mosque.mosque_facilities && Array.isArray(mosque.mosque_facilities)) {
        mosque.mosque_facilities.forEach((facility: any) => {
          if (facility.facility_type) {
            byFacility[facility.facility_type] = (byFacility[facility.facility_type] || 0) + 1
          }
        })
      }
    })

    const pendingApprovalCount = (statsData || []).filter((m: any) =>
      m.mosque_id?.startsWith('user_mosque_') && !m.is_approved
    ).length

    const stats = {
      total_mosques: statsData?.length || 0,
      this_week: thisWeekCount,
      this_month: thisMonthCount,
      pending_approval: pendingApprovalCount,
      by_timezone: byTimezone,
      by_facility: byFacility
    }

    // Transform the data to match our interface
    const transformedMosques = (mosques || []).map((mosque: any) => ({
      ...mosque,
      facilities: mosque.mosque_facilities || []
    }))

    return NextResponse.json({
      mosques: transformedMosques,
      stats,
      pagination: {
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit)
      }
    })
  } catch (error) {
    console.error('Error in mosques API:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function PUT(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)
    const mosque_id = searchParams.get('id')
    
    if (!mosque_id) {
      return NextResponse.json(
        { error: 'Mosque ID is required' },
        { status: 400 }
      )
    }

    const updateData: MosqueUpdateData = await request.json()

    // Update mosque metadata
    const { data, error } = await adminClient
      .from('mosques_metadata')
      .update({
        ...updateData,
        updated_at: new Date().toISOString()
      })
      .eq('mosque_id', mosque_id)
      .select()

    if (error) {
      console.error('Error updating mosque:', error)
      return NextResponse.json(
        { error: 'Failed to update mosque', details: error.message },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      mosque: data?.[0] || null
    })
  } catch (error) {
    console.error('Error in mosque update API:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)
    const mosque_id = searchParams.get('id')
    
    if (!mosque_id) {
      return NextResponse.json(
        { error: 'Mosque ID is required' },
        { status: 400 }
      )
    }

    // First delete associated facilities
    const { error: facilitiesError } = await adminClient
      .from('mosque_facilities')
      .delete()
      .eq('mosque_id', mosque_id)

    if (facilitiesError) {
      console.error('Error deleting mosque facilities:', facilitiesError)
      return NextResponse.json(
        { error: 'Failed to delete mosque facilities', details: facilitiesError.message },
        { status: 500 }
      )
    }

    // Then delete the mosque
    const { error: mosqueError } = await adminClient
      .from('mosques_metadata')
      .delete()
      .eq('mosque_id', mosque_id)

    if (mosqueError) {
      console.error('Error deleting mosque:', mosqueError)
      return NextResponse.json(
        { error: 'Failed to delete mosque', details: mosqueError.message },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      message: 'Mosque deleted successfully'
    })
  } catch (error) {
    console.error('Error in mosque delete API:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

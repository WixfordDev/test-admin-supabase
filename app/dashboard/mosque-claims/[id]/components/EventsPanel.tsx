'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { RefreshCw, Edit, Trash2 } from 'lucide-react'
import toast from 'react-hot-toast'
import type { MosqueEvent, UpdateEventBody } from '@/lib/types/events'
import EditEventDialog from './EditEventDialog'

interface Props {
  mosqueId: string
}

type AdminEvent = MosqueEvent & { attendee_count: number }

export default function EventsPanel({ mosqueId }: Props) {
  const [events, setEvents] = useState<AdminEvent[]>([])
  const [loading, setLoading] = useState(true)
  const [isActing, setIsActing] = useState(false)
  const [editing, setEditing] = useState<AdminEvent | null>(null)
  const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, totalPages: 0 })

  const fetchEvents = async () => {
    try {
      setLoading(true)
      const params = new URLSearchParams()
      params.set('mosqueId', mosqueId)
      params.set('page', pagination.page.toString())
      params.set('limit', pagination.limit.toString())

      const response = await fetch(`/api/admin/mosque-events?${params}`)
      if (!response.ok) throw new Error('Failed to fetch events')

      const data = await response.json()
      setEvents(data.events ?? [])
      setPagination((prev) => ({
        ...prev,
        total: data.pagination?.total ?? 0,
        totalPages: data.pagination?.totalPages ?? 0,
      }))
    } catch {
      toast.error('Failed to load events')
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async (id: string, body: UpdateEventBody) => {
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-events/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)

      toast.success('Event updated')
      setEditing(null)
      await fetchEvents()
    } catch (err: any) {
      toast.error(err.message || 'Failed to update event')
    } finally {
      setIsActing(false)
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this event? This cannot be undone.')) return
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-events/${id}`, { method: 'DELETE' })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)

      toast.success('Event deleted')
      await fetchEvents()
    } catch (err: any) {
      toast.error(err.message || 'Failed to delete event')
    } finally {
      setIsActing(false)
    }
  }

  useEffect(() => {
    fetchEvents()
  }, [mosqueId, pagination.page, pagination.limit])

  return (
    <div className="space-y-6">
      <div className="flex justify-end">
        <Button variant="outline" className="text-black flex items-center gap-2" onClick={fetchEvents}>
          <RefreshCw className="h-4 w-4" />
          Refresh
        </Button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-48">
          <RefreshCw className="h-7 w-7 animate-spin text-gray-400" />
        </div>
      ) : events.length === 0 ? (
        <Card className="p-12 text-center">
          <p className="text-gray-500">No events found for this mosque.</p>
        </Card>
      ) : (
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-gray-50 border-b text-left">
                  <th className="px-4 py-3 font-medium text-gray-600">Title</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Date</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Attendees</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Status</th>
                  <th className="px-4 py-3 font-medium text-gray-600 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {events.map((e) => (
                  <tr key={e.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-4 py-3 text-gray-900 font-medium max-w-[220px] truncate">{e.title}</td>
                    <td className="px-4 py-3 text-gray-600">
                      {new Date(e.event_date).toLocaleString()}
                      {e.location && <p className="text-xs text-gray-500">{e.location}</p>}
                    </td>
                    <td className="px-4 py-3 text-gray-600">
                      {e.attendee_count}
                      {e.max_attendees ? ` / ${e.max_attendees}` : ''}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                          e.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'
                        }`}
                      >
                        {e.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          className="text-black"
                          onClick={() => setEditing(e)}
                          disabled={isActing}
                        >
                          <Edit className="h-4 w-4 mr-1" />
                          Edit
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="text-red-600 border-red-300 hover:bg-red-50"
                          onClick={() => handleDelete(e.id)}
                          disabled={isActing}
                        >
                          <Trash2 className="h-4 w-4 mr-1" />
                          Delete
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {pagination.totalPages > 1 && (
        <Card className="p-4">
          <div className="flex items-center justify-between">
            <p className="text-sm text-gray-600">
              Showing {(pagination.page - 1) * pagination.limit + 1}–
              {Math.min(pagination.page * pagination.limit, pagination.total)} of {pagination.total} events
            </p>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                className="text-black"
                onClick={() => setPagination((p) => ({ ...p, page: p.page - 1 }))}
                disabled={pagination.page === 1}
              >
                Previous
              </Button>
              <span className="text-sm text-gray-600">
                Page {pagination.page} of {pagination.totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                className="text-black"
                onClick={() => setPagination((p) => ({ ...p, page: p.page + 1 }))}
                disabled={pagination.page === pagination.totalPages}
              >
                Next
              </Button>
            </div>
          </div>
        </Card>
      )}

      {editing && (
        <EditEventDialog
          event={editing}
          onClose={() => setEditing(null)}
          onSave={handleSave}
          isActing={isActing}
        />
      )}
    </div>
  )
}

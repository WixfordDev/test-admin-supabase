'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { RefreshCw, Edit, Trash2 } from 'lucide-react'
import toast from 'react-hot-toast'
import type { MosqueAnnouncement } from '@/lib/types/announcements'
import EditAnnouncementDialog from './EditAnnouncementDialog'
import ConfirmDialog from '@/app/components/ui/confirm-dialog'

interface Props {
  mosqueId: string
}

export default function AnnouncementsPanel({ mosqueId }: Props) {
  const [announcements, setAnnouncements] = useState<MosqueAnnouncement[]>([])
  const [loading, setLoading] = useState(true)
  const [isActing, setIsActing] = useState(false)
  const [editing, setEditing] = useState<MosqueAnnouncement | null>(null)
  const [deleting, setDeleting] = useState<MosqueAnnouncement | null>(null)
  const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, totalPages: 0 })

  const fetchAnnouncements = async () => {
    try {
      setLoading(true)
      const params = new URLSearchParams()
      params.set('mosqueId', mosqueId)
      params.set('page', pagination.page.toString())
      params.set('limit', pagination.limit.toString())

      const response = await fetch(`/api/admin/mosque-announcements?${params}`)
      if (!response.ok) throw new Error('Failed to fetch announcements')

      const data = await response.json()
      setAnnouncements(data.announcements ?? [])
      setPagination((prev) => ({
        ...prev,
        total: data.pagination?.total ?? 0,
        totalPages: data.pagination?.totalPages ?? 0,
      }))
    } catch {
      toast.error('Failed to load announcements')
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async (id: string, body: { title: string; content: string }) => {
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-announcements/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)

      toast.success('Announcement updated')
      setEditing(null)
      await fetchAnnouncements()
    } catch (err: any) {
      toast.error(err.message || 'Failed to update announcement')
    } finally {
      setIsActing(false)
    }
  }

  const handleDelete = async () => {
    if (!deleting) return
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-announcements/${deleting.id}`, { method: 'DELETE' })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)

      toast.success('Announcement deleted')
      setDeleting(null)
      await fetchAnnouncements()
    } catch (err: any) {
      toast.error(err.message || 'Failed to delete announcement')
    } finally {
      setIsActing(false)
    }
  }

  useEffect(() => {
    fetchAnnouncements()
  }, [mosqueId, pagination.page, pagination.limit])

  return (
    <div className="space-y-6">
      <div className="flex justify-end">
        <Button variant="outline" className="text-black flex items-center gap-2" onClick={fetchAnnouncements}>
          <RefreshCw className="h-4 w-4" />
          Refresh
        </Button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-48">
          <RefreshCw className="h-7 w-7 animate-spin text-gray-400" />
        </div>
      ) : announcements.length === 0 ? (
        <Card className="p-12 text-center">
          <p className="text-gray-500">No announcements found for this mosque.</p>
        </Card>
      ) : (
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-gray-50 border-b text-left">
                  <th className="px-4 py-3 font-medium text-gray-600">Title</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Content</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Created</th>
                  <th className="px-4 py-3 font-medium text-gray-600 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {announcements.map((a) => (
                  <tr key={a.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-4 py-3 text-gray-900 font-medium max-w-[220px] truncate">{a.title}</td>
                    <td className="px-4 py-3 text-gray-600 max-w-[360px] truncate">{a.content}</td>
                    <td className="px-4 py-3 text-gray-600">{new Date(a.created_at).toLocaleDateString()}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          className="text-black"
                          onClick={() => setEditing(a)}
                          disabled={isActing}
                        >
                          <Edit className="h-4 w-4 mr-1" />
                          Edit
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="text-red-600 border-red-300 hover:bg-red-50"
                          onClick={() => setDeleting(a)}
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
              {Math.min(pagination.page * pagination.limit, pagination.total)} of {pagination.total} announcements
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
        <EditAnnouncementDialog
          announcement={editing}
          onClose={() => setEditing(null)}
          onSave={handleSave}
          isActing={isActing}
        />
      )}

      <ConfirmDialog
        open={!!deleting}
        title="Delete Announcement"
        description={`Are you sure you want to delete "${deleting?.title}"? This cannot be undone.`}
        confirmText="Delete"
        isLoading={isActing}
        onConfirm={handleDelete}
        onCancel={() => setDeleting(null)}
      />
    </div>
  )
}

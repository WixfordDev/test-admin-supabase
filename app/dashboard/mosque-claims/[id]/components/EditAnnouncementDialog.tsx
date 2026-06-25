'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Input } from '@/app/components/ui/input'
import { X } from 'lucide-react'
import type { MosqueAnnouncement } from '@/lib/types/announcements'

interface Props {
  announcement: MosqueAnnouncement
  onClose: () => void
  onSave: (id: string, body: { title: string; content: string }) => void
  isActing: boolean
}

export default function EditAnnouncementDialog({ announcement, onClose, onSave, isActing }: Props) {
  const [title, setTitle] = useState(announcement.title)
  const [content, setContent] = useState(announcement.content)

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <Card className="w-full max-w-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">Edit Announcement</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
            <Input value={title} onChange={(e) => setTitle(e.target.value)} />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Content</label>
            <textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
              rows={5}
              className="flex w-full text-black rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            />
          </div>
        </div>

        <div className="flex justify-end gap-2 mt-6">
          <Button variant="outline" className="text-black" onClick={onClose} disabled={isActing}>
            Cancel
          </Button>
          <Button
            onClick={() => onSave(announcement.id, { title, content })}
            disabled={isActing || !title.trim() || !content.trim()}
          >
            Save Changes
          </Button>
        </div>
      </Card>
    </div>
  )
}

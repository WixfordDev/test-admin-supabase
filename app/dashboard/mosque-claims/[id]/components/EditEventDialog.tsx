'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Input } from '@/app/components/ui/input'
import { X } from 'lucide-react'
import type { MosqueEvent, UpdateEventBody } from '@/lib/types/events'

interface Props {
  event: MosqueEvent
  onClose: () => void
  onSave: (id: string, body: UpdateEventBody) => void
  isActing: boolean
}

// Converts an ISO string to the value expected by <input type="datetime-local">
function toLocalInputValue(iso: string | null): string {
  if (!iso) return ''
  const d = new Date(iso)
  const offset = d.getTimezoneOffset()
  const local = new Date(d.getTime() - offset * 60000)
  return local.toISOString().slice(0, 16)
}

export default function EditEventDialog({ event, onClose, onSave, isActing }: Props) {
  const [title, setTitle] = useState(event.title)
  const [description, setDescription] = useState(event.description ?? '')
  const [eventDate, setEventDate] = useState(toLocalInputValue(event.event_date))
  const [endDate, setEndDate] = useState(toLocalInputValue(event.end_date))
  const [location, setLocation] = useState(event.location ?? '')
  const [maxAttendees, setMaxAttendees] = useState(event.max_attendees?.toString() ?? '')
  const [isActive, setIsActive] = useState(event.is_active)

  const handleSave = () => {
    onSave(event.id, {
      title,
      description,
      event_date: new Date(eventDate).toISOString(),
      end_date: endDate ? new Date(endDate).toISOString() : undefined,
      location,
      max_attendees: maxAttendees ? parseInt(maxAttendees) : undefined,
      is_active: isActive,
    })
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 overflow-y-auto">
      <Card className="w-full max-w-lg p-6 my-8">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">Edit Event</h3>
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
            <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              className="flex w-full text-black rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Start</label>
              <Input type="datetime-local" value={eventDate} onChange={(e) => setEventDate(e.target.value)} />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">End</label>
              <Input type="datetime-local" value={endDate} onChange={(e) => setEndDate(e.target.value)} />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
            <Input value={location} onChange={(e) => setLocation(e.target.value)} />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Max Attendees</label>
            <Input
              type="number"
              value={maxAttendees}
              onChange={(e) => setMaxAttendees(e.target.value)}
              placeholder="No limit"
            />
          </div>
          <label className="flex items-center gap-2 text-sm text-gray-700">
            <input
              type="checkbox"
              checked={isActive}
              onChange={(e) => setIsActive(e.target.checked)}
              className="h-4 w-4"
            />
            Active (uncheck to cancel this event)
          </label>
        </div>

        <div className="flex justify-end gap-2 mt-6">
          <Button variant="outline" className="text-black" onClick={onClose} disabled={isActing}>
            Cancel
          </Button>
          <Button onClick={handleSave} disabled={isActing || !title.trim() || !eventDate}>
            Save Changes
          </Button>
        </div>
      </Card>
    </div>
  )
}

'use client'

import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { AlertTriangle } from 'lucide-react'

interface Props {
  open: boolean
  title: string
  description: string
  confirmText?: string
  cancelText?: string
  variant?: 'danger' | 'default'
  isLoading?: boolean
  onConfirm: () => void
  onCancel: () => void
}

export default function ConfirmDialog({
  open,
  title,
  description,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  variant = 'danger',
  isLoading = false,
  onConfirm,
  onCancel,
}: Props) {
  if (!open) return null

  return (
    <div className="fixed inset-0 z-[50] flex items-center justify-center bg-black/50 p-4">
      <Card className="w-full max-w-sm p-6 bg-white">
        <div className="flex items-start gap-3 mb-4">
          <div
            className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full ${
              variant === 'danger' ? 'bg-red-100' : 'bg-yellow-100'
            }`}
          >
            <AlertTriangle
              className={`h-5 w-5 ${variant === 'danger' ? 'text-red-600' : 'text-yellow-600'}`}
            />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
            <p className="text-sm text-gray-600 mt-1">{description}</p>
          </div>
        </div>

        <div className="flex justify-end gap-2 mt-2">
          <Button variant="outline" className="text-black" onClick={onCancel} disabled={isLoading}>
            {cancelText}
          </Button>
          <Button
            className={variant === 'danger' ? 'bg-red-600 hover:bg-red-700 text-white' : ''}
            onClick={onConfirm}
            disabled={isLoading}
          >
            {confirmText}
          </Button>
        </div>
      </Card>
    </div>
  )
}

'use client'

import { useSearchParams } from 'next/navigation'
import { Suspense } from 'react'
import { CheckCircle, Clock, XCircle } from 'lucide-react'

function StripeConnectResult() {
  const searchParams = useSearchParams()
  const status = searchParams.get('status')

  const config = {
    success: {
      icon: <CheckCircle className="h-16 w-16 text-green-500" />,
      title: 'Stripe Connected!',
      message: 'Your mosque can now accept donations. You may close this window and return to the app.',
      bg: 'bg-green-50',
      border: 'border-green-200',
    },
    pending: {
      icon: <Clock className="h-16 w-16 text-yellow-500" />,
      title: 'Almost There',
      message: 'Your Stripe account setup is pending. Please complete all required information to start accepting donations.',
      bg: 'bg-yellow-50',
      border: 'border-yellow-200',
    },
    error: {
      icon: <XCircle className="h-16 w-16 text-red-500" />,
      title: 'Something Went Wrong',
      message: 'We could not verify your Stripe account. Please go back to the app and try again.',
      bg: 'bg-red-50',
      border: 'border-red-200',
    },
  }

  const current = config[status as keyof typeof config] ?? config.error

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-6">
      <div className={`w-full max-w-md rounded-2xl border p-8 text-center shadow-sm ${current.bg} ${current.border}`}>
        <div className="flex justify-center mb-4">{current.icon}</div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">{current.title}</h1>
        <p className="text-gray-600">{current.message}</p>
        <p className="text-xs text-gray-400 mt-6">DeenHub — Donation by Stripe Connect</p>
      </div>
    </div>
  )
}

export default function StripeConnectPage() {
  return (
    <Suspense>
      <StripeConnectResult />
    </Suspense>
  )
}

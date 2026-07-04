'use client'

import { useSearchParams } from 'next/navigation'
import { Suspense } from 'react'
import { CheckCircle, XCircle } from 'lucide-react'

function DonationResult() {
  const searchParams = useSearchParams()
  const status = searchParams.get('status')

  const isSuccess = status === 'success'

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-6">
      <div
        className={`w-full max-w-md rounded-2xl border p-8 text-center shadow-sm ${
          isSuccess ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'
        }`}
      >
        <div className="flex justify-center mb-4">
          {isSuccess ? (
            <CheckCircle className="h-16 w-16 text-green-500" />
          ) : (
            <XCircle className="h-16 w-16 text-red-400" />
          )}
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">
          {isSuccess ? 'JazakAllah Khayran!' : 'Donation Cancelled'}
        </h1>
        <p className="text-gray-600">
          {isSuccess
            ? 'Your donation was successful. May Allah accept it from you.'
            : 'Your donation was not completed. You may close this window and try again.'}
        </p>
        <p className="text-xs text-gray-400 mt-6">DeenHub — Powered by Stripe</p>
      </div>
    </div>
  )
}

export default function DonationPage() {
  return (
    <Suspense>
      <DonationResult />
    </Suspense>
  )
}

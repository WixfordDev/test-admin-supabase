'use client'

import { useRouter } from 'next/navigation'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import type { MosqueClaim } from '@/lib/types/mosque-claims'
import { Eye, CheckCircle, XCircle } from 'lucide-react'

interface Props {
  claims: MosqueClaim[]
  onApprove: (id: string) => void
  onReject: (id: string) => void
  isActing: boolean
}

const statusColors: Record<string, string> = {
  pending: 'bg-yellow-100 text-yellow-800',
  approved: 'bg-green-100 text-green-800',
  rejected: 'bg-red-100 text-red-800',
  verified: 'bg-purple-100 text-purple-800',
}

export default function MosqueClaimsTable({
  claims,
  onApprove,
  onReject,
  isActing,
}: Props) {
  const router = useRouter()

  if (claims.length === 0) {
    return (
      <Card className="p-12 text-center">
        <p className="text-gray-500">No claims found.</p>
      </Card>
    )
  }

  return (
    <Card className="overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-gray-50 border-b text-left">
              <th className="px-4 py-3 font-medium text-gray-600">Mosque</th>
              <th className="px-4 py-3 font-medium text-gray-600">Position</th>
              <th className="px-4 py-3 font-medium text-gray-600">Contact</th>
              <th className="px-4 py-3 font-medium text-gray-600">Status</th>
              <th className="px-4 py-3 font-medium text-gray-600">Submitted</th>
              <th className="px-4 py-3 font-medium text-gray-600 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {claims.map((claim) => (
              <tr key={claim.id} className="hover:bg-gray-50 transition-colors">
                <td className="px-4 py-3">
                  <p className="font-medium text-gray-900">{claim.mosque?.name ?? '—'}</p>
                  <p className="text-xs text-gray-500 mt-0.5">{claim.mosque?.address ?? claim.mosque_id}</p>
                </td>
                <td className="px-4 py-3 text-gray-700">{claim.position ?? '—'}</td>
                <td className="px-4 py-3">
                  <p className="text-gray-700">{claim.mosque_email ?? '—'}</p>
                  <p className="text-xs text-gray-500">{claim.mosque_phone ?? ''}</p>
                </td>
                <td className="px-4 py-3">
                  <span
                    className={`px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${
                      statusColors[claim.status] ?? 'bg-gray-100 text-gray-800'
                    }`}
                  >
                    {claim.status}
                  </span>
                </td>
                <td className="px-4 py-3 text-gray-600">
                  {new Date(claim.created_at).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <div className="flex items-center justify-end gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-black"
                      onClick={() => router.push(`/dashboard/mosque-claims/${claim.id}`)}
                    >
                      <Eye className="h-4 w-4 mr-1" />
                      View
                    </Button>
                    {claim.status === 'pending' && (
                      <>
                        <Button
                          size="sm"
                          className="bg-green-600 hover:bg-green-700 text-white"
                          onClick={() => onApprove(claim.id)}
                          disabled={isActing}
                        >
                          <CheckCircle className="h-4 w-4 mr-1" />
                          Approve
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="text-red-600 border-red-300 hover:bg-red-50"
                          onClick={() => onReject(claim.id)}
                          disabled={isActing}
                        >
                          <XCircle className="h-4 w-4 mr-1" />
                          Reject
                        </Button>
                      </>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  )
}

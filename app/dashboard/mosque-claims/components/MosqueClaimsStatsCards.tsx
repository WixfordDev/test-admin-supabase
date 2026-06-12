'use client'

import { Card } from '@/app/components/ui/card'
import { ClipboardList, Clock, CheckCircle, XCircle, BadgeCheck } from 'lucide-react'
import type { MosqueClaimStats } from '@/lib/types/mosque-claims'

interface Props {
  stats: MosqueClaimStats
}

export default function MosqueClaimsStatsCards({ stats }: Props) {
  const cards = [
    {
      title: 'Total Claims',
      value: stats.total,
      icon: ClipboardList,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
    },
    {
      title: 'Pending',
      value: stats.pending,
      icon: Clock,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-50',
    },
    {
      title: 'Approved',
      value: stats.approved,
      icon: CheckCircle,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
    },
    {
      title: 'Rejected',
      value: stats.rejected,
      icon: XCircle,
      color: 'text-red-600',
      bgColor: 'bg-red-50',
    },
    {
      title: 'Verified',
      value: stats.verified,
      icon: BadgeCheck,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
    },
  ]

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
      {cards.map((card) => {
        const Icon = card.icon
        return (
          <Card key={card.title} className="p-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">{card.title}</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">
                  {card.value.toLocaleString()}
                </p>
              </div>
              <div className={`p-3 rounded-full ${card.bgColor}`}>
                <Icon className={`h-6 w-6 ${card.color}`} />
              </div>
            </div>
          </Card>
        )
      })}
    </div>
  )
}

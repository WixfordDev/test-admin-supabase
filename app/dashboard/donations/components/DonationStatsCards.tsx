'use client'

import { Card } from '@/app/components/ui/card'
import { Building2, Clock, DollarSign, TrendingUp, Receipt } from 'lucide-react'

interface Stats {
  connected_mosques: number
  pending_connections: number
  total_donations_cents: number
  platform_revenue_cents: number
  total_transactions: number
}

function formatAmount(cents: number) {
  return `$${(cents / 100).toFixed(2)}`
}

export default function DonationStatsCards({ stats }: { stats: Stats }) {
  const cards = [
    {
      title: 'Connected Mosques',
      value: stats.connected_mosques,
      icon: Building2,
      color: 'text-emerald-600',
      bg: 'bg-emerald-50',
      format: 'number',
    },
    {
      title: 'Pending Connections',
      value: stats.pending_connections,
      icon: Clock,
      color: 'text-yellow-600',
      bg: 'bg-yellow-50',
      format: 'number',
    },
    {
      title: 'Total Donations',
      value: stats.total_donations_cents,
      icon: DollarSign,
      color: 'text-blue-600',
      bg: 'bg-blue-50',
      format: 'currency',
    },
    {
      title: 'Platform Revenue (2%)',
      value: stats.platform_revenue_cents,
      icon: TrendingUp,
      color: 'text-purple-600',
      bg: 'bg-purple-50',
      format: 'currency',
    },
    {
      title: 'Total Transactions',
      value: stats.total_transactions,
      icon: Receipt,
      color: 'text-gray-600',
      bg: 'bg-gray-100',
      format: 'number',
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
                  {card.format === 'currency'
                    ? formatAmount(card.value)
                    : card.value.toLocaleString()}
                </p>
              </div>
              <div className={`p-3 rounded-full ${card.bg}`}>
                <Icon className={`h-6 w-6 ${card.color}`} />
              </div>
            </div>
          </Card>
        )
      })}
    </div>
  )
}

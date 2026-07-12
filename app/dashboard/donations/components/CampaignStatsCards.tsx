'use client'

import { Card } from '@/app/components/ui/card'
import { LayoutList, CheckCircle, XCircle, Target, TrendingUp } from 'lucide-react'

interface Stats {
  total: number
  active: number
  inactive: number
  total_raised_cents: number
  total_goal_cents: number
}

function fmt(cents: number) {
  return `$${(cents / 100).toLocaleString('en-US', { minimumFractionDigits: 2 })}`
}

export default function CampaignStatsCards({ stats }: { stats: Stats }) {
  const cards = [
    { title: 'Total Campaigns', value: stats.total, icon: LayoutList, color: 'text-blue-600', bg: 'bg-blue-50', format: 'number' },
    { title: 'Active', value: stats.active, icon: CheckCircle, color: 'text-emerald-600', bg: 'bg-emerald-50', format: 'number' },
    { title: 'Inactive', value: stats.inactive, icon: XCircle, color: 'text-gray-500', bg: 'bg-gray-100', format: 'number' },
    { title: 'Total Raised', value: stats.total_raised_cents, icon: TrendingUp, color: 'text-purple-600', bg: 'bg-purple-50', format: 'currency' },
    { title: 'Total Goal', value: stats.total_goal_cents, icon: Target, color: 'text-yellow-600', bg: 'bg-yellow-50', format: 'currency' },
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
                  {card.format === 'currency' ? fmt(card.value) : card.value.toLocaleString()}
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

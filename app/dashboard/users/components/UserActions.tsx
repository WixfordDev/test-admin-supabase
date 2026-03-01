
import { useState } from 'react'
import { Button } from '@/app/components/ui/button'
import {
  MoreHorizontal, Edit, Trash2, Crown, Ban, Send,
  ArrowUpCircle, ArrowDownCircle, CheckCircle2,
} from 'lucide-react'
import EditUserDialog from './EditUserDialog'
import type { UserProfile } from '@/lib/types/users'

interface UserActionsProps {
  user: UserProfile
  onUserUpdate: (user: UserProfile) => void
  onDelete?: () => void
}

type SubscriptionStatus = 'free' | 'barakah_access' | 'quran_lite' | 'deenhub_pro' | 'expired'

const DEFAULT_MESSAGES: Record<SubscriptionStatus, { title: string; body: string }> = {
  deenhub_pro:    { title: '🎉 Subscription Upgraded!', body: 'Congratulations! Your subscription has been upgraded to DeenHub Pro. Enjoy premium features.' },
  quran_lite:     { title: '✨ Subscription Updated',   body: 'Your subscription has been updated to Quran Lite. Enjoy enhanced features.' },
  barakah_access: { title: '✨ Subscription Updated',   body: 'Your subscription has been updated to Barakah Access. Enjoy exclusive content.' },
  free:           { title: '🔄 Subscription Changed',  body: 'Your subscription has been changed to Free tier. Some features may be limited.' },
  expired:        { title: '⚠️ Subscription Expired',  body: 'Your subscription has expired. Please renew to continue enjoying premium features.' },
}

const PLAN_BADGE: Record<string, string> = {
  deenhub_pro:    'bg-purple-100 text-purple-700',
  quran_lite:     'bg-blue-100 text-blue-700',
  barakah_access: 'bg-teal-100 text-teal-700',
  free:           'bg-gray-100 text-gray-600',
  expired:        'bg-red-100 text-red-600',
}

const PLAN_LABEL: Record<string, string> = {
  deenhub_pro:    'DeenHub Pro',
  quran_lite:     'Quran Lite',
  barakah_access: 'Barakah Access',
  free:           'Free',
  expired:        'Expired',
}

export default function UserActions({ user, onUserUpdate, onDelete }: UserActionsProps) {
  const [isOpen, setIsOpen]         = useState(false)
  const [loading, setLoading]       = useState(false)
  const [showEditDialog, setShowEditDialog] = useState(false)
  const [customMessage, setCustomMessage]   = useState('')
  const [sendingMsg, setSendingMsg]         = useState(false)
  const [msgSent, setMsgSent]               = useState(false)

  const sendNotification = async (userId: string, title: string, body: string) => {
    try {
      const res = await fetch('/api/send-announcement', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ title, body, user_id: userId }),
      })
      const data = await res.json()
      if (!res.ok) console.error('Notification error:', data.error)
    } catch (e) {
      console.error('Notification error:', e)
    }
  }

  const handleSubscriptionChange = async (newStatus: SubscriptionStatus) => {
    setLoading(true)
    try {
      const res    = await fetch('/api/admin/users', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_id: user.user_id, subscription_status: newStatus }),
      })
      const result = await res.json()
      if (result.success) {
        const defaults = DEFAULT_MESSAGES[newStatus]
        const title    = customMessage.trim() ? '📢 Subscription Update' : defaults.title
        const body     = customMessage.trim() ? customMessage.trim()     : defaults.body
        await sendNotification(user.user_id, title, body)
        onUserUpdate(result.user)
        setIsOpen(false)
        setCustomMessage('')
      } else {
        alert('Failed to update subscription. Please try again.')
      }
    } catch {
      alert('Failed to update subscription. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleSuspendUser = async () => {
    setLoading(true)
    try {
      const res    = await fetch('/api/admin/users', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: user.user_id,
          subscription_status: 'expired',
          has_subscription: false,
          subscription_expiry: null,
        }),
      })
      const result = await res.json()
      if (result.success) {
        const body = customMessage.trim() || 'Your account has been suspended. Please contact support for assistance.'
        await sendNotification(user.user_id, '⚠️ Account Suspended', body)
        onUserUpdate(result.user)
        setIsOpen(false)
        setCustomMessage('')
      } else {
        alert('Failed to suspend user. Please try again.')
      }
    } catch {
      alert('Failed to suspend user. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteUser = async () => {
    if (!confirm(`Delete ${user.full_name || user.email}? This cannot be undone.`)) return
    setLoading(true)
    try {
      const res = await fetch(`/api/admin/users/${user.user_id}`, { method: 'DELETE' })
      if (res.ok) {
        setIsOpen(false)
        alert('User deleted successfully')
        onDelete?.()
      } else {
        const err = await res.json()
        alert(`Failed to delete user: ${err.error}`)
      }
    } catch {
      alert('Failed to delete user. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleSendCustomMessage = async () => {
    if (!customMessage.trim()) return
    setSendingMsg(true)
    try {
      await sendNotification(user.user_id, '📢 Message from Admin', customMessage.trim())
      setMsgSent(true)
      setCustomMessage('')
      setTimeout(() => setMsgSent(false), 2500)
    } finally {
      setSendingMsg(false)
    }
  }

  const isPro     = user.subscription_status === 'deenhub_pro'
  const isLite    = user.subscription_status === 'quran_lite'
  const isFreeish = user.subscription_status === 'free' || user.subscription_status === 'expired'

  return (
    <div className="relative">
      <Button
        variant="ghost"
        size="sm"
        onClick={() => { setIsOpen(!isOpen); setCustomMessage(''); setMsgSent(false) }}
        disabled={loading}
        className="h-8 w-8 p-0 rounded-full hover:bg-gray-100"
      >
        {loading
          ? <div className="h-4 w-4 animate-spin rounded-full border-2 border-gray-400 border-t-transparent" />
          : <MoreHorizontal className="h-4 w-4 text-gray-500" />}
      </Button>

      {isOpen && (
        <>
          {/* backdrop */}
          <div className="fixed inset-0 z-10" onClick={() => setIsOpen(false)} />

          {/* panel */}
          <div className="absolute right-0 top-full z-20 mt-2 w-72 bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">

            {/* ── User header ── */}
            <div className="px-4 py-3 bg-gradient-to-r from-slate-50 to-gray-50 border-b border-gray-100 flex items-center gap-3">
              <div className="h-8 w-8 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white text-xs font-bold shrink-0">
                {(user.full_name || user.email || '?')[0].toUpperCase()}
              </div>
              <div className="min-w-0">
                <p className="text-sm font-semibold text-gray-800 truncate">
                  {user.full_name || 'Unknown'}
                </p>
                <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold mt-0.5 ${PLAN_BADGE[user.subscription_status] ?? 'bg-gray-100 text-gray-600'}`}>
                  {PLAN_LABEL[user.subscription_status] ?? user.subscription_status}
                </span>
              </div>
            </div>

            {/* ── Actions ── */}
            <div className="p-2 space-y-0.5">

              {/* Edit */}
              <button
                onClick={() => { setShowEditDialog(true); setIsOpen(false) }}
                disabled={loading}
                className="flex items-center gap-3 w-full px-3 py-2 rounded-xl text-sm text-gray-700 hover:bg-gray-50 transition-colors disabled:opacity-50"
              >
                <span className="h-7 w-7 rounded-lg bg-gray-100 flex items-center justify-center shrink-0">
                  <Edit className="h-3.5 w-3.5 text-gray-600" />
                </span>
                <span className="font-medium">Edit User</span>
              </button>

              {/* ── Subscription section ── */}
              <div className="pt-2 pb-1 px-3">
                <p className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-1">
                  <Crown className="h-3 w-3" /> Subscription
                </p>
              </div>

              {/* Upgrade to DeenHub Pro */}
              {!isPro && (
                <button
                  onClick={() => handleSubscriptionChange('deenhub_pro')}
                  disabled={loading}
                  className="flex items-center gap-3 w-full px-3 py-2 rounded-xl text-sm hover:bg-purple-50 transition-colors disabled:opacity-50 group"
                >
                  <span className="h-7 w-7 rounded-lg bg-purple-100 flex items-center justify-center shrink-0">
                    <ArrowUpCircle className="h-3.5 w-3.5 text-purple-600" />
                  </span>
                  <div className="text-left">
                    <p className="font-medium text-gray-800">
                      {isFreeish ? 'Upgrade' : 'Switch'} to DeenHub Pro
                    </p>
                    <p className="text-[10px] text-gray-400">Premium plan</p>
                  </div>
                </button>
              )}

              {/* Quran Lite */}
              {!isLite && (
                <button
                  onClick={() => handleSubscriptionChange('quran_lite')}
                  disabled={loading}
                  className="flex items-center gap-3 w-full px-3 py-2 rounded-xl text-sm hover:bg-blue-50 transition-colors disabled:opacity-50"
                >
                  <span className="h-7 w-7 rounded-lg bg-blue-100 flex items-center justify-center shrink-0">
                    {isPro
                      ? <ArrowDownCircle className="h-3.5 w-3.5 text-blue-600" />
                      : <ArrowUpCircle   className="h-3.5 w-3.5 text-blue-600" />}
                  </span>
                  <div className="text-left">
                    <p className="font-medium text-gray-800">
                      {isPro ? 'Downgrade' : 'Upgrade'} to Quran Lite
                    </p>
                    <p className="text-[10px] text-gray-400">Lite plan</p>
                  </div>
                </button>
              )}

              {/* Downgrade to Free */}
              {!isFreeish && (
                <button
                  onClick={() => handleSubscriptionChange('free')}
                  disabled={loading}
                  className="flex items-center gap-3 w-full px-3 py-2 rounded-xl text-sm hover:bg-gray-50 transition-colors disabled:opacity-50"
                >
                  <span className="h-7 w-7 rounded-lg bg-gray-100 flex items-center justify-center shrink-0">
                    <ArrowDownCircle className="h-3.5 w-3.5 text-gray-500" />
                  </span>
                  <div className="text-left">
                    <p className="font-medium text-gray-800">Downgrade to Free</p>
                    <p className="text-[10px] text-gray-400">Basic plan</p>
                  </div>
                </button>
              )}
            </div>

            {/* ── Custom notification ── */}
            <div
              className="mx-2 mb-2 rounded-xl bg-gradient-to-br from-blue-50 to-indigo-50 border border-blue-100 p-3"
              onClick={(e) => e.stopPropagation()}
            >
              <p className="text-[10px] font-semibold text-blue-600 uppercase tracking-wider mb-2 flex items-center gap-1">
                <Send className="h-3 w-3" /> Custom Notification
              </p>
              <textarea
                value={customMessage}
                onChange={(e) => { setCustomMessage(e.target.value); setMsgSent(false) }}
                placeholder="Write a message for this user…"
                rows={2}
                className="w-full px-3 py-2 text-xs bg-white border border-blue-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none text-gray-700 placeholder-gray-400 shadow-sm"
              />
              <div className="flex items-center gap-2 mt-2">
                <button
                  onClick={handleSendCustomMessage}
                  disabled={!customMessage.trim() || sendingMsg}
                  className="flex-1 flex items-center justify-center gap-1.5 py-1.5 text-xs font-semibold rounded-lg transition-all disabled:opacity-40 disabled:cursor-not-allowed bg-blue-600 hover:bg-blue-700 active:scale-95 text-white shadow-sm"
                >
                  {sendingMsg ? (
                    <div className="h-3 w-3 animate-spin rounded-full border-2 border-white border-t-transparent" />
                  ) : msgSent ? (
                    <><CheckCircle2 className="h-3 w-3" /> Sent!</>
                  ) : (
                    <><Send className="h-3 w-3" /> Send to User</>
                  )}
                </button>
                {customMessage.trim() && !msgSent && (
                  <span className="text-[10px] text-blue-500 leading-tight">
                    Also used for<br/>plan changes
                  </span>
                )}
              </div>
            </div>

            {/* ── Danger zone ── */}
            <div className="border-t border-gray-100 p-2 space-y-0.5">
              <button
                onClick={handleSuspendUser}
                disabled={loading}
                className="flex items-center gap-3 w-full px-3 py-2 rounded-xl text-sm hover:bg-amber-50 transition-colors disabled:opacity-50"
              >
                <span className="h-7 w-7 rounded-lg bg-amber-100 flex items-center justify-center shrink-0">
                  <Ban className="h-3.5 w-3.5 text-amber-600" />
                </span>
                <div className="text-left">
                  <p className="font-medium text-amber-700">Suspend User</p>
                  <p className="text-[10px] text-gray-400">Disable account access</p>
                </div>
              </button>

              <button
                onClick={handleDeleteUser}
                disabled={loading}
                className="flex items-center gap-3 w-full px-3 py-2 rounded-xl text-sm hover:bg-red-50 transition-colors disabled:opacity-50"
              >
                <span className="h-7 w-7 rounded-lg bg-red-100 flex items-center justify-center shrink-0">
                  <Trash2 className="h-3.5 w-3.5 text-red-600" />
                </span>
                <div className="text-left">
                  <p className="font-medium text-red-600">Delete User</p>
                  <p className="text-[10px] text-gray-400">Permanently remove</p>
                </div>
              </button>
            </div>

          </div>
        </>
      )}

      {showEditDialog && (
        <EditUserDialog
          isOpen={showEditDialog}
          onClose={() => setShowEditDialog(false)}
          user={user}
          onSuccess={(updatedUser) => {
            onUserUpdate(updatedUser)
            setShowEditDialog(false)
          }}
        />
      )}
    </div>
  )
}

// 'use client'

// import { useState } from 'react'
// import { Button } from '@/app/components/ui/button'
// import { Input } from '@/app/components/ui/input'
// import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card'
// import { X, User, Mail, Crown, CheckCircle } from 'lucide-react'

// interface AddUserDialogProps {
//   isOpen: boolean
//   onClose: () => void
//   onSuccess: () => void
// }

// export default function AddUserDialog({ isOpen, onClose, onSuccess }: AddUserDialogProps) {
//   const [formData, setFormData] = useState({
//     email: '',
//     full_name: '',
//     subscription_status: 'free'
//   })
//   const [loading, setLoading] = useState(false)
//   const [error, setError] = useState('')
//   const [success, setSuccess] = useState(false)

//   const handleSubmit = async (e: React.FormEvent) => {
//     e.preventDefault()
//     setLoading(true)
//     setError('')
//     setSuccess(false)

//     try {
//       const response = await fetch('/api/admin/users/add', {
//         method: 'POST',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify(formData),
//       })
//       console.log(response)

//       if (!response.ok) {
//         const data = await response.json().catch(() => ({}))
//         throw new Error(data.error || `Failed to add user: ${response.status} ${response.statusText}`)
//       }

//       setSuccess(true)
//       // Reset form after a short delay to show success feedback
//       setTimeout(() => {
//         onSuccess()
//         setFormData({ email: '', full_name: '', subscription_status: 'free' })
//         setSuccess(false)
//       }, 1500)
//     } catch (err) {
//       setError(err instanceof Error ? err.message : 'Failed to add user')
//     } finally {
//       setLoading(false)
//     }
//   }

//   if (!isOpen) return null

//   return (
//     <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
//       <Card className="w-full max-w-md mx-4 shadow-xl">
//         <CardHeader className="pb-3">
//           <div className="flex items-center justify-between">
//             <div>
//               <CardTitle className="flex items-center gap-2 text-xl">
//                 <User className="h-5 w-5 text-blue-600" />
//                 Add New User
//               </CardTitle>
//               <CardDescription className="mt-1">
//                 Create a new user account in the system
//               </CardDescription>
//             </div>
//             <Button
//               variant="ghost"
//               size="icon"
//               onClick={onClose}
//               className="hover:bg-gray-100"
//             >
//               <X className="h-4 w-4" />
//             </Button>
//           </div>
//         </CardHeader>
//         <CardContent>
//           <form onSubmit={handleSubmit} className="space-y-4">
//             {error && (
//               <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
//                 <p className="text-sm text-red-700">{error}</p>
//               </div>
//             )}

//             {success && (
//               <div className="p-3 bg-green-50 border border-green-200 rounded-lg flex items-center">
//                 <CheckCircle className="h-5 w-5 text-green-600 mr-2" />
//                 <p className="text-sm text-green-700">User created successfully!</p>
//               </div>
//             )}

//             <div className="space-y-2">
//               <label className="text-sm font-medium text-gray-700 block">
//                 Email Address *
//               </label>
//               <div className="relative">
//                 <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
//                 <Input
//                   type="email"
//                   placeholder="user@example.com"
//                   value={formData.email}
//                   onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
//                   className="pl-10 w-full"
//                   required
//                   disabled={loading}
//                 />
//               </div>
//             </div>

//             <div className="space-y-2">
//               <label className="text-sm font-medium text-gray-700 block">
//                 Full Name
//               </label>
//               <div className="relative">
//                 <User className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
//                 <Input
//                   type="text"
//                   placeholder="John Doe"
//                   value={formData.full_name}
//                   onChange={(e) => setFormData(prev => ({ ...prev, full_name: e.target.value }))}
//                   className="pl-10 w-full"
//                   disabled={loading}
//                 />
//               </div>
//             </div>

//             <div className="space-y-2">
//               <label className="text-sm font-medium text-gray-700 block">
//                 Subscription Status
//               </label>
//               <div className="relative">
//                 <Crown className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
//                 <select
//                   value={formData.subscription_status}
//                   onChange={(e) => setFormData(prev => ({ ...prev, subscription_status: e.target.value }))}
//                   className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
//                   disabled={loading}
//                 >
//                   <option value="free">Free</option>
//                   <option value="barakah_access">Barakah Access</option>
//                   <option value="quran_lite">Quran Lite</option>
//                   <option value="deenhub_pro">DeenHub Pro</option>
//                 </select>
//               </div>
//             </div>

//             <div className="flex gap-3 pt-4">
//               <Button
//                 type="button"
//                 variant="outline"
//                 onClick={onClose}
//                 className="flex-1"
//                 disabled={loading}
//               >
//                 Cancel
//               </Button>
//               <Button
//                 type="submit"
//                 disabled={loading || !formData.email}
//                 className="flex-1 bg-blue-600 hover:bg-blue-700 text-white"
//               >
//                 {loading ? (
//                   <div className="flex items-center justify-center">
//                     <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
//                     Adding...
//                   </div>
//                 ) : (
//                   'Add User'
//                 )}
//               </Button>
//             </div>
//           </form>
//         </CardContent>
//       </Card>
//     </div>
//   )
// }



'use client'

import { useState } from 'react'
import { Button } from '@/app/components/ui/button'
import { Input } from '@/app/components/ui/input'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card'
import { X, User, Mail, Crown, AlertCircle, CheckCircle2, Calendar } from 'lucide-react'

interface AddUserDialogProps {
  isOpen: boolean
  onClose: () => void
  onSuccess: () => void
}

export default function AddUserDialog({ isOpen, onClose, onSuccess }: AddUserDialogProps) {
  const [formData, setFormData] = useState({
    email: '',
    full_name: '',
    subscription_status: 'free',
    subscription_expiry: ''
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)

  const handleSubmit = async () => {
    if (!formData.email) return
    
    setLoading(true)
    setError('')
    setSuccess(false)

    try {
      const response = await fetch('/api/admin/users/add', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      })

      const data = await response.json().catch(() => ({}))

  console.log(data)

      if (!response.ok) {
        throw new Error(data.error || `Failed to add user: ${response.status} ${response.statusText}`)
      }

      setSuccess(true)
      setTimeout(() => {
        onSuccess()
        setFormData({ email: '', full_name: '', subscription_status: 'free', subscription_expiry: '' })
        setSuccess(false)
      }, 1500)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add user')
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    if (!loading) {
      setFormData({ email: '', full_name: '', subscription_status: 'free', subscription_expiry: '' })
      setError('')
      setSuccess(false)
      onClose()
    }
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !loading && !success && formData.email) {
      handleSubmit()
    }
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-80 p-4">
      <div 
        className="absolute inset-0" 
        onClick={handleClose}
      />
      
      <Card className="w-full max-w-lg relative bg-slate-400 shadow-2xl border-0 animate-in fade-in zoom-in duration-200">
        <CardHeader className="bg-linear-to-r from-blue-50 to-purple-50 border-b">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 bg-blue-600 rounded-lg flex items-center justify-center">
                <User className="h-5 w-5 text-white" />
              </div>
              <div>
                <CardTitle className="text-xl">Add New User</CardTitle>
                <CardDescription className="text-sm mt-1">
                  Create a new user account in the system
                </CardDescription>
              </div>
            </div>
            <Button 
              variant="ghost" 
              size="icon" 
              onClick={handleClose}
              disabled={loading}
              className="hover:bg-white/50"
            >
              <X className="h-4 w-4" />
            </Button>
          </div>
        </CardHeader>

        <CardContent className="pt-6">
          <div className="space-y-5">
            {error && (
              <div className="p-4 bg-red-50 border-l-4 border-red-500 rounded-r-lg flex items-start gap-3 animate-in slide-in-from-top-2">
                <AlertCircle className="h-5 w-5 text-red-500 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-red-900">Error</p>
                  <p className="text-sm text-red-700 mt-1">{error}</p>
                </div>
              </div>
            )}

            {success && (
              <div className="p-4 bg-green-50 border-l-4 border-green-500 rounded-r-lg flex items-start gap-3 animate-in slide-in-from-top-2">
                <CheckCircle2 className="h-5 w-5 text-green-500 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-green-900">Success</p>
                  <p className="text-sm text-green-700 mt-1">User added successfully!</p>
                </div>
              </div>
            )}

            <div className="space-y-2">
              <label className="text-sm font-semibold text-gray-700 flex items-center gap-2">
                <Mail className="h-4 w-4 text-gray-500" />
                Email Address
                <span className="text-red-500">*</span>
              </label>
              <Input
                type="email"
                placeholder="user@example.com"
                value={formData.email}
                onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                onKeyPress={handleKeyPress}
                className="h-11 border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-200"
                disabled={loading || success}
              />
              <p className="text-xs text-gray-500">
                This email will be used for login credentials
              </p>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-semibold text-gray-700 flex items-center gap-2">
                <User className="h-4 w-4 text-gray-500" />
                Full Name
              </label>
              <Input
                type="text"
                placeholder="John Doe"
                value={formData.full_name}
                onChange={(e) => setFormData(prev => ({ ...prev, full_name: e.target.value }))}
                onKeyPress={handleKeyPress}
                className="h-11 border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-200"
                disabled={loading || success}
              />
              <p className="text-xs text-gray-500">
                Optional: User's display name
              </p>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-semibold text-gray-700 flex items-center gap-2">
                <Crown className="h-4 w-4 text-gray-500" />
                Subscription Plan
              </label>
              <div className="relative">
                <select
                  value={formData.subscription_status}
                  onChange={(e) => setFormData(prev => ({ ...prev, subscription_status: e.target.value }))}
                  className="w-full h-11 px-3 py-2 border border-gray-300 rounded-lg focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-200 bg-white disabled:bg-gray-50 disabled:text-gray-500"
                  disabled={loading || success}
                >
                  <option value="free">🆓 Free - No subscription</option>
                  <option value="barakah_access">✨ Barakah Access - Premium tier</option>
                  <option value="quran_lite">📖 Quran Lite - Basic Quran features</option>
                  <option value="deenhub_pro">👑 DeenHub Pro - Full access</option>
                </select>
              </div>
            </div>

            {formData.subscription_status !== 'free' && (
              <div className="space-y-2 animate-in slide-in-from-top-2">
                <label className="text-sm font-semibold text-gray-700 flex items-center gap-2">
                  <Calendar className="h-4 w-4 text-gray-500" />
                  Subscription Expiry Date
                </label>
                <Input
                  type="date"
                  value={formData.subscription_expiry}
                  onChange={(e) => setFormData(prev => ({ ...prev, subscription_expiry: e.target.value }))}
                  min={new Date().toISOString().split('T')[0]}
                  className="h-11 border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-200"
                  disabled={loading || success}
                />
                <p className="text-xs text-gray-500">
                  Optional: When the subscription should expire
                </p>
              </div>
            )}

            <div className="flex gap-3 pt-6 border-t">
              <Button
                onClick={handleClose}
                variant="outline"
                className="flex-1 h-11"
                disabled={loading || success}
              >
                Cancel
              </Button>
              <Button
                onClick={handleSubmit}
                disabled={loading || !formData.email || success}
                className="flex-1 h-11 bg-blue-600 hover:bg-blue-700"
              >
                {loading ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                    </svg>
                    Adding...
                  </span>
                ) : success ? (
                  <span className="flex items-center gap-2">
                    <CheckCircle2 className="h-4 w-4" />
                    Added!
                  </span>
                ) : (
                  'Add User'
                )}
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
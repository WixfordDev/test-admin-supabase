// import { useState } from 'react'
// import { Button } from '@/app/components/ui/button'
// import { MoreHorizontal, Edit, Trash2, Crown, Ban, UserCheck, AlertTriangle, CheckCircle, Bell } from 'lucide-react'
// import EditUserDialog from './EditUserDialog';
// import type { UserProfile } from '@/lib/types/users'

// interface UserActionsProps {
//   user: UserProfile
//   onUserUpdate: (user: UserProfile) => void
//   onDelete?: () => void
// }

// export default function UserActions({ user, onUserUpdate, onDelete }: UserActionsProps) {
//   const [isOpen, setIsOpen] = useState(false)
//   const [loading, setLoading] = useState(false)
//   const [showEditDialog, setShowEditDialog] = useState(false)

//   const handleSubscriptionChange = async (newStatus: 'free' | 'barakah_access' | 'quran_lite' | 'deenhub_pro' | 'expired') => {
//     setLoading(true)
//     try {
//       const response = await fetch('/api/admin/users', {
//         method: 'PUT',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify({
//           user_id: user.user_id,
//           subscription_status: newStatus,
//         }),
//       })

//       const result = await response.json()

//       if (result.success) {
//         // Send notification to the user about their subscription change
//         await sendSubscriptionNotification(user.user_id, newStatus);

//         onUserUpdate(result.user)
//         setIsOpen(false)
//       } else {
//         console.error('Failed to update user subscription:', result.error)
//         alert('Failed to update subscription. Please try again.')
//       }
//     } catch (error) {
//       console.error('Error updating subscription:', error)
//       alert('Failed to update subscription. Please try again.')
//     } finally {
//       setLoading(false)
//     }
//   }

//   const sendSubscriptionNotification = async (userId: string, newStatus: string) => {
//    try {
//     // Get user's FCM token from the database
//     const tokenResponse = await fetch(`/api/get-user-token?user_id=${userId}`);

//     if (!tokenResponse.ok) {
//       console.error('Failed to fetch user token:', tokenResponse.status, tokenResponse.statusText);
//       return;
//     }

//     const tokenResult = await tokenResponse.json();

//     if (!tokenResult.success || !tokenResult.token) {
//       console.warn(`User ${userId} does not have an FCM token registered. Notification will not be sent.`);
//       // Still consider this a success since the subscription update worked
//       // Just inform the admin that the notification couldn't be sent
//       return;
//     }

//       // Prepare notification based on subscription change
//       let title = '';
//       let body = '';

//       switch(newStatus) {
//         case 'deenhub_pro':
//           title = '🎉 Subscription Upgraded!';
//           body = 'Congratulations! Your subscription has been upgraded to DeenHub Pro. Enjoy premium features.';
//           break;
//         case 'quran_lite':
//           title = '✨ Subscription Updated';
//           body = 'Your subscription has been updated to Quran Lite. Enjoy enhanced features.';
//           break;
//         case 'barakah_access':
//           title = '✨ Subscription Updated';
//           body = 'Your subscription has been updated to Barakah Access. Enjoy exclusive content.';
//           break;
//         case 'free':
//           title = '🔄 Subscription Changed';
//           body = 'Your subscription has been changed to Free tier. Some features may be limited.';
//           break;
//         case 'expired':
//           title = '⚠️ Subscription Expired';
//           body = 'Your subscription has expired. Please renew to continue enjoying premium features.';
//           break;
//         default:
//           title = '📋 Subscription Updated';
//           body = 'Your subscription status has been updated.';
//       }

//       // Send notification via FCM
//       const notificationResponse = await fetch('/api/send-notification', {
//         method: 'POST',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify({
//           title,
//           body,
//           target: 'single',
//           token: tokenResult.token,
//         }),
//       });

//       if (!notificationResponse.ok) {
//         console.error('Failed to send notification:', notificationResponse.status, notificationResponse.statusText);
//         return;
//       }

//       const notificationResult = await notificationResponse.json();

//       if (!notificationResult.success) {
//         console.error('Failed to send notification:', notificationResult.error);
//       } else {
//         console.log('Notification sent successfully to user:', userId);
//       }
//     } catch (error) {
//       console.error('Error sending subscription notification:', error);
//     }
//   }

//     const handleSuspendUser = async () => {
//     setLoading(true)
//     try {
//       // In Supabase, we can update user's status by changing their role or by managing a flag in our user_profiles table
//       // Here we'll update their subscription status to 'expired' and set has_subscription to false
//       const response = await fetch('/api/admin/users', {
//         method: 'PUT',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify({
//           user_id: user.user_id,
//           subscription_status: 'expired',
//           has_subscription: false,
//           subscription_expiry: null,
//         }),
//       })

//       const result = await response.json()

//       if (result.success) {
//         onUserUpdate(result.user)
//         setIsOpen(false)
//       } else {
//         console.error('Failed to suspend user:', result.error)
//         alert('Failed to suspend user. Please try again.')
//       }
//     } catch (error) {
//       console.error('Error suspending user:', error)
//       alert('Failed to suspend user. Please try again.')
//     } finally {
//       setLoading(false)
//     }
//   }

//   // const handleSuspendUser = async () => {
//   //   // Prompt for suspension reason
//   //   const reason = prompt('Enter the reason for suspending this user:');

//   //   if (!reason) {
//   //     alert('A reason is required to suspend a user.');
//   //     return;
//   //   }

//   //   setLoading(true)
//   //   try {
//   //     // In Supabase, we can update user's status by changing their role or by managing a flag in our user_profiles table
//   //     // Here we'll update their subscription status to 'expired' and set has_subscription to false
//   //     const response = await fetch('/api/admin/users', {
//   //       method: 'PUT',
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //       },
//   //       body: JSON.stringify({
//   //         user_id: user.user_id,
//   //         subscription_status: 'expired',
//   //         has_subscription: false,
//   //         subscription_expiry: null,
//   //         suspension_reason: reason, // This will be stored for reference
//   //       }),
//   //     })

//   //     const result = await response.json()

//   //     if (result.success) {
//   //       onUserUpdate(result.user)
//   //       setIsOpen(false)
//   //     } else {
//   //       console.error('Failed to suspend user:', result.error)
//   //       alert('Failed to suspend user. Please try again.')
//   //     }
//   //   } catch (error) {
//   //     console.error('Error suspending user:', error)
//   //     alert('Failed to suspend user. Please try again.')
//   //   } finally {
//   //     setLoading(false)
//   //   }
//   // }

//   const handleDeleteUser = async () => {
//     if (confirm(`Are you sure you want to delete ${user.full_name || user.email}? This action cannot be undone.`)) {
//       setLoading(true)
//       try {
//         const response = await fetch(`/api/admin/users/${user.user_id}`, {
//           method: 'DELETE',
//         })

//         if (response.ok) {
//           // In the UsersManagement component, we'll need to update the UI to remove the deleted user
//           // Since we can't remove the user from the parent component directly, we'll just close the menu
//           setIsOpen(false)
//           alert('User deleted successfully')
//           onDelete?.()
//         } else {
//           const error = await response.json()
//           console.error('Failed to delete user:', error.error)
//           alert(`Failed to delete user: ${error.error}`)
//         }
//       } catch (error) {
//         console.error('Error deleting user:', error)
//         alert('Failed to delete user. Please try again.')
//       } finally {
//         setLoading(false)
//       }
//     }
//   }

//   const handleEditUser = () => {
//     setShowEditDialog(true)
//     setIsOpen(false)
//   }

//   return (
//     <div className="relative">
//       <Button
//         variant="ghost"
//         size="sm"
//         onClick={() => setIsOpen(!isOpen)}
//         disabled={loading}
//       >
//         {loading ? (
//           <div className="h-4 w-4 animate-spin rounded-full border-2 border-gray-300 border-t-transparent"></div>
//         ) : (
//           <MoreHorizontal className="h-4 w-4" />
//         )}
//       </Button>

//       {isOpen && (
//         <>
//           <div
//             className="fixed inset-0 z-10"
//             onClick={() => setIsOpen(false)}
//           />
//           <div className="absolute right-0 top-full z-20 mt-1 w-56 bg-white border border-gray-200 rounded-lg shadow-lg overflow-hidden">
//             <div className="py-1">
//               <button
//                 onClick={handleEditUser}
//                 disabled={loading}
//                 className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
//               >
//                 <Edit className="mr-2 h-4 w-4" />
//                 Edit User
//               </button>

//               {/* Subscription Actions based on current status */}
//               {user.subscription_status === 'free' || user.subscription_status === 'expired' ? (
//                 <>
//                   <button
//                     onClick={() => handleSubscriptionChange('quran_lite')}
//                     disabled={loading}
//                     className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
//                   >
//                     <Crown className="mr-2 h-4 w-4 text-blue-500" />
//                     Upgrade to Quran Lite
//                   </button>
//                   <button
//                     onClick={() => handleSubscriptionChange('deenhub_pro')}
//                     disabled={loading}
//                     className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
//                   >
//                     <Crown className="mr-2 h-4 w-4 text-purple-500" />
//                     Upgrade to DeenHub Pro
//                   </button>
//                 </>
//               ) : (
//                 <>
//                   {user.subscription_status !== 'deenhub_pro' && (
//                     <button
//                       onClick={() => handleSubscriptionChange('deenhub_pro')}
//                       disabled={loading}
//                       className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
//                     >
//                       <Crown className="mr-2 h-4 w-4 text-purple-500" />
//                       Upgrade to DeenHub Pro
//                     </button>
//                   )}
//                   {user.subscription_status !== 'quran_lite' && (
//                     <button
//                       onClick={() => handleSubscriptionChange('quran_lite')}
//                       disabled={loading}
//                       className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
//                     >
//                       <Crown className="mr-2 h-4 w-4 text-blue-500" />
//                       {user.subscription_status === 'deenhub_pro' ? 'Downgrade to Quran Lite' : 'Upgrade to Quran Lite'}
//                     </button>
//                   )}
//                   <button
//                     onClick={() => handleSubscriptionChange('free')}
//                     disabled={loading}
//                     className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
//                   >
//                     <Crown className="mr-2 h-4 w-4" />
//                     Downgrade to Free
//                   </button>
//                 </>
//               )}

//               <div className="border-t border-gray-100 my-1"></div>

//               <button
//                 onClick={handleSuspendUser}
//                 disabled={loading}
//                 className="flex items-center w-full px-4 py-2 text-sm text-amber-600 hover:bg-amber-50 transition-colors disabled:opacity-50"
//               >
//                 <Ban className="mr-2 h-4 w-4" />
//                 Suspend User
//               </button>

//               <div className="border-t border-gray-100 my-1"></div>

//               <button
//                 onClick={handleDeleteUser}
//                 disabled={loading}
//                 className="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors disabled:opacity-50"
//               >
//                 <Trash2 className="mr-2 h-4 w-4" />
//                 Delete User
//               </button>
//             </div>
//           </div>
//         </>
//       )}

//       {showEditDialog && (
//         <EditUserDialog
//           isOpen={showEditDialog}
//           onClose={() => setShowEditDialog(false)}
//           user={user}
//           onSuccess={(updatedUser) => {
//             onUserUpdate(updatedUser)
//             setShowEditDialog(false)
//           }}
//         />
//       )}
//     </div>
//   )
// }






import { useState } from 'react'
import { Button } from '@/app/components/ui/button'
import { MoreHorizontal, Edit, Trash2, Crown, Ban } from 'lucide-react'
import EditUserDialog from './EditUserDialog';
import type { UserProfile } from '@/lib/types/users'

interface UserActionsProps {
  user: UserProfile
  onUserUpdate: (user: UserProfile) => void
  onDelete?: () => void
}

export default function UserActions({ user, onUserUpdate, onDelete }: UserActionsProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [loading, setLoading] = useState(false)
  const [showEditDialog, setShowEditDialog] = useState(false)

  // ✅ Same API as notification page, just pass user_id for specific user
  const sendSubscriptionNotification = async (userId: string, newStatus: string) => {
    try {
      let title = '';
      let body = '';

      switch (newStatus) {
        case 'deenhub_pro':
          title = '🎉 Subscription Upgraded!';
          body = 'Congratulations! Your subscription has been upgraded to DeenHub Pro. Enjoy premium features.';
          break;
        case 'quran_lite':
          title = '✨ Subscription Updated';
          body = 'Your subscription has been updated to Quran Lite. Enjoy enhanced features.';
          break;
        case 'barakah_access':
          title = '✨ Subscription Updated';
          body = 'Your subscription has been updated to Barakah Access. Enjoy exclusive content.';
          break;
        case 'free':
          title = '🔄 Subscription Changed';
          body = 'Your subscription has been changed to Free tier. Some features may be limited.';
          break;
        case 'expired':
          title = '⚠️ Subscription Expired';
          body = 'Your subscription has expired. Please renew to continue enjoying premium features.';
          break;
        default:
          title = '📋 Subscription Updated';
          body = 'Your subscription status has been updated.';
      }

      // ✅ Same endpoint as notification page — just adding user_id
      const response = await fetch('/api/send-announcement', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({
          title,
          body,
          user_id: userId, // 👈 specific user ko target korbe
        }),
      });

      const data = await response.json();

      console.log(data, userId);
      

      if (response.ok) {
        console.log('✅ Notification sent to user:', userId);
      } else {
        console.error('❌ Failed to send notification:', data.error);
      }
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  };

  const handleSubscriptionChange = async (newStatus: 'free' | 'barakah_access' | 'quran_lite' | 'deenhub_pro' | 'expired') => {
    setLoading(true)
    try {
      const response = await fetch('/api/admin/users', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: user.user_id,
          subscription_status: newStatus,
        }),
      })

      const result = await response.json()

      if (result.success) {
        // ✅ Subscription update holar pore notification pathabo
        await sendSubscriptionNotification(user.user_id, newStatus);
        onUserUpdate(result.user)
        setIsOpen(false)
      } else {
        console.error('Failed to update user subscription:', result.error)
        alert('Failed to update subscription. Please try again.')
      }
    } catch (error) {
      console.error('Error updating subscription:', error)
      alert('Failed to update subscription. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleSuspendUser = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/admin/users', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: user.user_id,
          subscription_status: 'expired',
          has_subscription: false,
          subscription_expiry: null,
        }),
      })

      const result = await response.json()

      if (result.success) {
        // ✅ Suspend hole o notification pathabo
        await sendSubscriptionNotification(user.user_id, 'expired');
        onUserUpdate(result.user)
        setIsOpen(false)
      } else {
        console.error('Failed to suspend user:', result.error)
        alert('Failed to suspend user. Please try again.')
      }
    } catch (error) {
      console.error('Error suspending user:', error)
      alert('Failed to suspend user. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteUser = async () => {
    if (confirm(`Are you sure you want to delete ${user.full_name || user.email}? This action cannot be undone.`)) {
      setLoading(true)
      try {
        const response = await fetch(`/api/admin/users/${user.user_id}`, {
          method: 'DELETE',
        })

        if (response.ok) {
          setIsOpen(false)
          alert('User deleted successfully')
          onDelete?.()
        } else {
          const error = await response.json()
          console.error('Failed to delete user:', error.error)
          alert(`Failed to delete user: ${error.error}`)
        }
      } catch (error) {
        console.error('Error deleting user:', error)
        alert('Failed to delete user. Please try again.')
      } finally {
        setLoading(false)
      }
    }
  }

  const handleEditUser = () => {
    setShowEditDialog(true)
    setIsOpen(false)
  }

  return (
    <div className="relative">
      <Button
        variant="ghost"
        size="sm"
        onClick={() => setIsOpen(!isOpen)}
        disabled={loading}
      >
        {loading ? (
          <div className="h-4 w-4 animate-spin rounded-full border-2 border-gray-300 border-t-transparent"></div>
        ) : (
          <MoreHorizontal className="h-4 w-4" />
        )}
      </Button>

      {isOpen && (
        <>
          <div
            className="fixed inset-0 z-10"
            onClick={() => setIsOpen(false)}
          />
          <div className="absolute right-0 top-full z-20 mt-1 w-56 bg-white border border-gray-200 rounded-lg shadow-lg overflow-hidden">
            <div className="py-1">
              <button
                onClick={handleEditUser}
                disabled={loading}
                className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
              >
                <Edit className="mr-2 h-4 w-4" />
                Edit User
              </button>

              {/* Subscription Actions based on current status */}
              {user.subscription_status === 'free' || user.subscription_status === 'expired' ? (
                <>
                  <button
                    onClick={() => handleSubscriptionChange('quran_lite')}
                    disabled={loading}
                    className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
                  >
                    <Crown className="mr-2 h-4 w-4 text-blue-500" />
                    Upgrade to Quran Lite
                  </button>
                  <button
                    onClick={() => handleSubscriptionChange('deenhub_pro')}
                    disabled={loading}
                    className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
                  >
                    <Crown className="mr-2 h-4 w-4 text-purple-500" />
                    Upgrade to DeenHub Pro
                  </button>
                </>
              ) : (
                <>
                  {user.subscription_status !== 'deenhub_pro' && (
                    <button
                      onClick={() => handleSubscriptionChange('deenhub_pro')}
                      disabled={loading}
                      className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
                    >
                      <Crown className="mr-2 h-4 w-4 text-purple-500" />
                      Upgrade to DeenHub Pro
                    </button>
                  )}
                  {user.subscription_status !== 'quran_lite' && (
                    <button
                      onClick={() => handleSubscriptionChange('quran_lite')}
                      disabled={loading}
                      className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
                    >
                      <Crown className="mr-2 h-4 w-4 text-blue-500" />
                      {user.subscription_status === 'deenhub_pro' ? 'Downgrade to Quran Lite' : 'Upgrade to Quran Lite'}
                    </button>
                  )}
                  <button
                    onClick={() => handleSubscriptionChange('free')}
                    disabled={loading}
                    className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
                  >
                    <Crown className="mr-2 h-4 w-4" />
                    Downgrade to Free
                  </button>
                </>
              )}

              <div className="border-t border-gray-100 my-1"></div>

              <button
                onClick={handleSuspendUser}
                disabled={loading}
                className="flex items-center w-full px-4 py-2 text-sm text-amber-600 hover:bg-amber-50 transition-colors disabled:opacity-50"
              >
                <Ban className="mr-2 h-4 w-4" />
                Suspend User
              </button>

              <div className="border-t border-gray-100 my-1"></div>

              <button
                onClick={handleDeleteUser}
                disabled={loading}
                className="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors disabled:opacity-50"
              >
                <Trash2 className="mr-2 h-4 w-4" />
                Delete User
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
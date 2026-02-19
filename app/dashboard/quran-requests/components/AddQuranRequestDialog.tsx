// 'use client';

// import { useState } from 'react';
// import { Button } from '@/app/components/ui/button';
// import { Input } from '@/app/components/ui/input';
// import { Card } from '@/app/components/ui/card';
// import { X, Loader2 } from 'lucide-react';
// import { CreateQuranRequestData } from '@/lib/types/quran-requests';

// interface AddQuranRequestDialogProps {
//   isOpen: boolean;
//   onClose: () => void;
//   onSuccess: () => void;
// }

// export default function AddQuranRequestDialog({
//   isOpen,
//   onClose,
//   onSuccess
// }: AddQuranRequestDialogProps) {
//   const [loading, setLoading] = useState(false);
//   const [formData, setFormData] = useState<CreateQuranRequestData>({
//     full_name: '',
//     email: '',
//     address: '',
//     city: '',
//     state: '',
//     zip_code: '',
//     country: 'United States',
//     preferred_language: 'English',
//     reason: ''
//   });
//   const [errors, setErrors] = useState<Record<string, string>>({});

//   const validateForm = () => {
//     const newErrors: Record<string, string> = {};

//     if (!formData.full_name.trim()) {
//       newErrors.full_name = 'Full name is required';
//     }

//     if (!formData.email.trim()) {
//       newErrors.email = 'Email is required';
//     } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
//       newErrors.email = 'Please enter a valid email address';
//     }

//     if (!formData.address.trim()) {
//       newErrors.address = 'Address is required';
//     }

//     if (!formData.city.trim()) {
//       newErrors.city = 'City is required';
//     }

//     if (!formData.state.trim()) {
//       newErrors.state = 'State is required';
//     }

//     if (!formData.zip_code.trim()) {
//       newErrors.zip_code = 'Zip code is required';
//     }

//     if (!formData.country.trim()) {
//       newErrors.country = 'Country is required';
//     }

//     setErrors(newErrors);
//     return Object.keys(newErrors).length === 0;
//   };

//   const handleSubmit = async (e: React.FormEvent) => {
//     e.preventDefault();

//     if (!validateForm()) {
//       return;
//     }

//     setLoading(true);

//     try {
//       const response = await fetch('/api/admin/quran-requests', {
//         method: 'POST',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify({
//           ...formData,
//           status: 'requested'
//         }),
//       });

//       if (!response.ok) {
//         const error = await response.json();
//         setErrors({ submit: error.error || 'Failed to create request. Please try again.' });
//         return;
//       }

//       onSuccess();
//     } catch (error) {
//       console.error('Error:', error);
//       setErrors({ submit: 'An unexpected error occurred.' });
//     } finally {
//       setLoading(false);
//     }
//   };

//   const handleInputChange = (field: keyof CreateQuranRequestData, value: string) => {
//     setFormData(prev => ({ ...prev, [field]: value }));
//     // Clear error when user starts typing
//     if (errors[field]) {
//       setErrors(prev => ({ ...prev, [field]: '' }));
//     }
//   };

//   if (!isOpen) return null;

//   return (
//     <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
//       <Card className="w-full max-w-2xl max-h-[90vh] overflow-y-auto">
//         <div className="p-6">
//           <div className="flex items-center justify-between mb-6">
//             <h2 className="text-xl font-semibold text-gray-900">Add New Quran Request</h2>
//             <Button
//               variant="ghost"
//               size="sm"
//               onClick={onClose}
//               className="h-8 w-8 p-0"
//             >
//               <X className="h-4 w-4" />
//             </Button>
//           </div>

//           <form onSubmit={handleSubmit} className="space-y-4">
//             {/* Personal Information */}
//             <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-1">
//                   Full Name *
//                 </label>
//                 <Input
//                   value={formData.full_name}
//                   onChange={(e) => handleInputChange('full_name', e.target.value)}
//                   placeholder="Enter full name"
//                   className={errors.full_name ? 'border-red-500' : ''}
//                 />
//                 {errors.full_name && (
//                   <p className="text-sm text-red-600 mt-1">{errors.full_name}</p>
//                 )}
//               </div>

//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-1">
//                   Email Address *
//                 </label>
//                 <Input
//                   type="email"
//                   value={formData.email}
//                   onChange={(e) => handleInputChange('email', e.target.value)}
//                   placeholder="Enter email address"
//                   className={errors.email ? 'border-red-500' : ''}
//                 />
//                 {errors.email && (
//                   <p className="text-sm text-red-600 mt-1">{errors.email}</p>
//                 )}
//               </div>
//             </div>

//             {/* Address Information */}
//             <div>
//               <label className="block text-sm font-medium text-gray-700 mb-1">
//                 Street Address *
//               </label>
//               <Input
//                 value={formData.address}
//                 onChange={(e) => handleInputChange('address', e.target.value)}
//                 placeholder="Enter street address"
//                 className={errors.address ? 'border-red-500' : ''}
//               />
//               {errors.address && (
//                 <p className="text-sm text-red-600 mt-1">{errors.address}</p>
//               )}
//             </div>

//             <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-1">
//                   City *
//                 </label>
//                 <Input
//                   value={formData.city}
//                   onChange={(e) => handleInputChange('city', e.target.value)}
//                   placeholder="Enter city"
//                   className={errors.city ? 'border-red-500' : ''}
//                 />
//                 {errors.city && (
//                   <p className="text-sm text-red-600 mt-1">{errors.city}</p>
//                 )}
//               </div>

//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-1">
//                   State *
//                 </label>
//                 <Input
//                   value={formData.state}
//                   onChange={(e) => handleInputChange('state', e.target.value)}
//                   placeholder="Enter state"
//                   className={errors.state ? 'border-red-500' : ''}
//                 />
//                 {errors.state && (
//                   <p className="text-sm text-red-600 mt-1">{errors.state}</p>
//                 )}
//               </div>

//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-1">
//                   Zip Code *
//                 </label>
//                 <Input
//                   value={formData.zip_code}
//                   onChange={(e) => handleInputChange('zip_code', e.target.value)}
//                   placeholder="Enter zip code"
//                   className={errors.zip_code ? 'border-red-500' : ''}
//                 />
//                 {errors.zip_code && (
//                   <p className="text-sm text-red-600 mt-1">{errors.zip_code}</p>
//                 )}
//               </div>
//             </div>

//             <div>
//               <label className="block text-sm font-medium text-gray-700 mb-1">
//                 Country *
//               </label>
//               <select
//                 value={formData.country}
//                 onChange={(e) => handleInputChange('country', e.target.value)}
//                 className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
//               >
//                 <option value="United States">United States</option>
//                 <option value="Canada">Canada</option>
//                 <option value="United Kingdom">United Kingdom</option>
//                 <option value="Australia">Australia</option>
//                 <option value="Other">Other</option>
//               </select>
//               {errors.country && (
//                 <p className="text-sm text-red-600 mt-1">{errors.country}</p>
//               )}
//             </div>

//             {/* Preferences */}
//             <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-1">
//                   Preferred Language
//                 </label>
//                 <select
//                   value={formData.preferred_language}
//                   onChange={(e) => handleInputChange('preferred_language', e.target.value)}
//                   className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
//                 >
//                   <option value="English">English</option>
//                   <option value="Arabic">Arabic</option>
//                   <option value="Spanish">Spanish</option>
//                   <option value="French">French</option>
//                   <option value="Urdu">Urdu</option>
//                   <option value="Other">Other</option>
//                 </select>
//               </div>

//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-1">
//                   Reason for Request
//                 </label>
//                 <select
//                   value={formData.reason}
//                   onChange={(e) => handleInputChange('reason', e.target.value)}
//                   className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
//                 >
//                   <option value="">Select a reason</option>
//                   <option value="New Muslim">New Muslim</option>
//                   <option value="Educational Purpose">Educational Purpose</option>
//                   <option value="Gift">Gift</option>
//                   <option value="Study">Study</option>
//                   <option value="Lost/Damaged Copy">Lost/Damaged Copy</option>
//                   <option value="Other">Other</option>
//                 </select>
//               </div>
//             </div>

//             {/* Submit Error */}
//             {errors.submit && (
//               <div className="bg-red-50 border border-red-200 rounded-md p-3">
//                 <p className="text-sm text-red-600">{errors.submit}</p>
//               </div>
//             )}

//             {/* Actions */}
//             <div className="flex justify-end gap-3 pt-4 border-t">
//               <Button
//                 type="button"
//                 variant="outline"
//                 onClick={onClose}
//                 disabled={loading}
//               >
//                 Cancel
//               </Button>
//               <Button
//                 type="submit"
//                 disabled={loading}
//                 className="flex items-center gap-2"
//               >
//                 {loading && <Loader2 className="h-4 w-4 animate-spin" />}
//                 {loading ? 'Creating...' : 'Create Request'}
//               </Button>
//             </div>
//           </form>
//         </div>
//       </Card>
//     </div>
//   );
// }



'use client';

import { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { X, User, Mail, MapPin, Globe, Languages, MessageSquare, Loader2 } from 'lucide-react';

interface AddQuranRequestDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export default function AddQuranRequestDialog({
  isOpen,
  onClose,
  onSuccess
}: AddQuranRequestDialogProps) {
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    address: '',
    city: '',
    state: '',
    zip_code: '',
    country: '',
    preferred_language: '',
    reason: '',
    status: 'requested'
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.full_name.trim()) {
      newErrors.full_name = 'Full name is required';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Invalid email format';
    }

    if (!formData.address.trim()) {
      newErrors.address = 'Address is required';
    }

    if (!formData.city.trim()) {
      newErrors.city = 'City is required';
    }

    if (!formData.country.trim()) {
      newErrors.country = 'Country is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    try {
      setLoading(true);

      const response = await fetch('/api/admin/quran-requests', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Failed to create request');
      }

      onSuccess();
    } catch (error) {
      console.error('Error creating request:', error);
      alert('Failed to create request. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-40 p-4">
      <Card className="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto shadow-2xl">
        {/* Header */}
        <div className=" top-0 bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6 rounded-t-2xl">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold">Add New Quran Request</h2>
              <p className="text-blue-100 text-sm mt-1">Fill in the details to create a new request</p>
            </div>
            <button
              onClick={onClose}
              className="text-white hover:bg-white hover:bg-opacity-20 rounded-full p-2 transition-colors"
            >
              <X className="h-6 w-6" />
            </button>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Personal Information Section */}
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <User className="h-5 w-5 text-blue-600" />
              Personal Information
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Full Name <span className="text-red-500">*</span>
                </label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    value={formData.full_name}
                    onChange={(e) => handleChange('full_name', e.target.value)}
                    placeholder="Enter full name"
                    className={`w-full pl-10 pr-4 py-2.5 border ${
                      errors.full_name ? 'border-red-500' : 'border-gray-300'
                    } rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all`}
                  />
                </div>
                {errors.full_name && (
                  <p className="mt-1 text-sm text-red-600">{errors.full_name}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Email Address <span className="text-red-500">*</span>
                </label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => handleChange('email', e.target.value)}
                    placeholder="email@example.com"
                    className={`w-full pl-10 pr-4 py-2.5 border ${
                      errors.email ? 'border-red-500' : 'border-gray-300'
                    } rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all`}
                  />
                </div>
                {errors.email && (
                  <p className="mt-1 text-sm text-red-600">{errors.email}</p>
                )}
              </div>
            </div>
          </div>

          {/* Address Information Section */}
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <MapPin className="h-5 w-5 text-blue-600" />
              Address Information
            </h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Street Address <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={formData.address}
                  onChange={(e) => handleChange('address', e.target.value)}
                  placeholder="Enter street address"
                  className={`w-full px-4 py-2.5 border ${
                    errors.address ? 'border-red-500' : 'border-gray-300'
                  } rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all`}
                />
                {errors.address && (
                  <p className="mt-1 text-sm text-red-600">{errors.address}</p>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    City <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={formData.city}
                    onChange={(e) => handleChange('city', e.target.value)}
                    placeholder="City"
                    className={`w-full px-4 py-2.5 border ${
                      errors.city ? 'border-red-500' : 'border-gray-300'
                    } rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all`}
                  />
                  {errors.city && (
                    <p className="mt-1 text-sm text-red-600">{errors.city}</p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    State/Province
                  </label>
                  <input
                    type="text"
                    value={formData.state}
                    onChange={(e) => handleChange('state', e.target.value)}
                    placeholder="State"
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Zip Code
                  </label>
                  <input
                    type="text"
                    value={formData.zip_code}
                    onChange={(e) => handleChange('zip_code', e.target.value)}
                    placeholder="Zip"
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Country <span className="text-red-500">*</span>
                </label>
                <div className="relative">
                  <Globe className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    value={formData.country}
                    onChange={(e) => handleChange('country', e.target.value)}
                    placeholder="Enter country"
                    className={`w-full pl-10 pr-4 py-2.5 border ${
                      errors.country ? 'border-red-500' : 'border-gray-300'
                    } rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all`}
                  />
                </div>
                {errors.country && (
                  <p className="mt-1 text-sm text-red-600">{errors.country}</p>
                )}
              </div>
            </div>
          </div>

          {/* Additional Information Section */}
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <Languages className="h-5 w-5 text-blue-600" />
              Additional Information
            </h3>
            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Preferred Language
                  </label>
                  <select
                    value={formData.preferred_language}
                    onChange={(e) => handleChange('preferred_language', e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  >
                    <option value="">Select language</option>
                    <option value="English">English</option>
                    <option value="Arabic">Arabic</option>
                    <option value="Urdu">Urdu</option>
                    <option value="French">French</option>
                    <option value="Spanish">Spanish</option>
                    <option value="Turkish">Turkish</option>
                    <option value="Indonesian">Indonesian</option>
                    <option value="Bengali">Bengali</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Status
                  </label>
                  <select
                    value={formData.status}
                    onChange={(e) => handleChange('status', e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  >
                    <option value="requested">Requested</option>
                    <option value="processing">Processing</option>
                    <option value="sent">Sent</option>
                    <option value="delivered">Delivered</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Reason for Request
                </label>
                <div className="relative">
                  <MessageSquare className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <textarea
                    value={formData.reason}
                    onChange={(e) => handleChange('reason', e.target.value)}
                    placeholder="Please provide a reason for requesting the Quran..."
                    rows={4}
                    className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all resize-none"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Form Actions */}
          <div className="flex items-center text-black justify-end gap-3 pt-4 border-t">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={loading}
              className="px-6"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={loading}
              className="px-6 bg-blue-600 hover:bg-blue-700"
            >
              {loading ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Creating...
                </>
              ) : (
                'Create Request'
              )}
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
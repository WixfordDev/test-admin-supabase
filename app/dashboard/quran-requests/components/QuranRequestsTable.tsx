// 'use client';

// import { useState } from 'react';
// import { Card } from '@/app/components/ui/card';
// import { Button } from '@/app/components/ui/button';
// import { Badge } from '@/app/components/ui/badge';
// import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/app/components/ui/table';
// import { MoreHorizontal, Edit, Trash2, MapPin, MessageSquare } from 'lucide-react';
// import { QuranRequest } from '@/lib/types/quran-requests';
// import { formatDate, formatTime } from '@/lib/utils';

// interface QuranRequestsTableProps {
//   requests: QuranRequest[];
//   selectedRequests: string[];
//   onSelectionChange: (selected: string[]) => void;
//   onUpdateRequest: (id: string, updates: { status?: string; admin_notes?: string }) => void;
//   onDeleteRequest: (id: string) => void;
// }

// export default function QuranRequestsTable({
//   requests,
//   selectedRequests,
//   onSelectionChange,
//   onUpdateRequest,
//   onDeleteRequest
// }: QuranRequestsTableProps) {
//   const [editingNotes, setEditingNotes] = useState<string | null>(null);
//   const [noteValue, setNoteValue] = useState('');

//   const getStatusBadge = (status: string) => {
//     const statusConfig = {
//       requested: { variant: 'default' as const, color: 'bg-yellow-500' },
//       processing: { variant: 'secondary' as const, color: 'bg-orange-500' },
//       sent: { variant: 'secondary' as const, color: 'bg-purple-500' },
//       delivered: { variant: 'default' as const, color: 'bg-green-500' },
//       cancelled: { variant: 'destructive' as const, color: 'bg-red-500' }
//     };
    
//     const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.requested;
    
//     return (
//       <Badge variant={config.variant} className="capitalize">
//         {status}
//       </Badge>
//     );
//   };

//   const handleSelectAll = (checked: boolean) => {
//     if (checked) {
//       onSelectionChange(requests.map(r => r.id));
//     } else {
//       onSelectionChange([]);
//     }
//   };

//   const handleSelectRequest = (id: string, checked: boolean) => {
//     if (checked) {
//       onSelectionChange([...selectedRequests, id]);
//     } else {
//       onSelectionChange(selectedRequests.filter(rid => rid !== id));
//     }
//   };

//   const handleStatusChange = (id: string, status: string) => {
//     onUpdateRequest(id, { status });
//   };

//   const handleNotesEdit = (request: QuranRequest) => {
//     setEditingNotes(request.id);
//     setNoteValue(request.admin_notes || '');
//   };

//   const handleNotesSave = (id: string) => {
//     onUpdateRequest(id, { admin_notes: noteValue });
//     setEditingNotes(null);
//     setNoteValue('');
//   };

//   const handleNotesCancel = () => {
//     setEditingNotes(null);
//     setNoteValue('');
//   };

//   if (requests.length === 0) {
//     return (
//       <Card className="p-8 text-center">
//         <p className="text-gray-500">No Quran requests found</p>
//       </Card>
//     );
//   }

//   return (
//     <Card>
//       <Table>
//         <TableHeader>
//           <TableRow>
//             <TableHead className="w-12">
//               <input
//                 type="checkbox"
//                 checked={selectedRequests.length === requests.length && requests.length > 0}
//                 onChange={(e) => handleSelectAll(e.target.checked)}
//                 className="rounded border-gray-300"
//               />
//             </TableHead>
//             <TableHead>Requester</TableHead>
//             <TableHead>Address</TableHead>
//             <TableHead>Language</TableHead>
//             <TableHead>Status</TableHead>
//             <TableHead>Reason</TableHead>
//             <TableHead>Created</TableHead>
//             <TableHead className="w-24">Actions</TableHead>
//           </TableRow>
//         </TableHeader>
//         <TableBody>
//           {requests.map((request) => (
//             <TableRow key={request.id}>
//               <TableCell>
//                 <input
//                   type="checkbox"
//                   checked={selectedRequests.includes(request.id)}
//                   onChange={(e) => handleSelectRequest(request.id, e.target.checked)}
//                   className="rounded border-gray-300"
//                 />
//               </TableCell>
              
//               <TableCell>
//                 <div>
//                   <div className="font-medium text-gray-900">{request.full_name}</div>
//                   <div className="text-sm text-gray-500">{request.email}</div>
//                 </div>
//               </TableCell>
              
//               <TableCell>
//                 <div className="text-sm">
//                   <div className="flex items-center gap-1">
//                     <MapPin className="h-3 w-3 text-gray-400" />
//                     <span>{request.city}, {request.state}</span>
//                   </div>
//                   <div className="text-gray-500">{request.country}</div>
//                   <div className="text-xs text-gray-400">{request.zip_code}</div>
//                 </div>
//               </TableCell>
              
//               <TableCell>
//                 <span className="text-sm">
//                   {request.preferred_language || 'Not specified'}
//                 </span>
//               </TableCell>
              
//               <TableCell>
//                 <div className="space-y-1">
//                   {getStatusBadge(request.status)}
//                   <select
//                     value={request.status}
//                     onChange={(e) => handleStatusChange(request.id, e.target.value)}
//                     className="block w-full text-xs rounded border-gray-300 focus:border-blue-500 focus:ring-blue-500"
//                   >
//                     <option value="requested">Requested</option>
//                     <option value="processing">Processing</option>
//                     <option value="sent">Sent</option>
//                     <option value="delivered">Delivered</option>
//                     <option value="cancelled">Cancelled</option>
//                   </select>
//                 </div>
//               </TableCell>
              
//               <TableCell>
//                 <div className="max-w-xs">
//                   {request.reason ? (
//                     <span className="text-sm text-gray-600">{request.reason}</span>
//                   ) : (
//                     <span className="text-sm text-gray-400">No reason provided</span>
//                   )}
//                 </div>
//               </TableCell>
              
//               <TableCell>
//                 <div className="text-sm">
//                   <div>{formatDate(new Date(request.created_at))}</div>
//                   <div className="text-xs text-gray-500">
//                     {formatTime(new Date(request.created_at))}
//                   </div>
//                 </div>
//               </TableCell>
              
//               <TableCell>
//                 <div className="flex items-center gap-2">
//                   <Button
//                     variant="ghost"
//                     size="sm"
//                     onClick={() => handleNotesEdit(request)}
//                     className="h-8 w-8 p-0"
//                   >
//                     <MessageSquare className="h-4 w-4" />
//                   </Button>
                  
//                   <Button
//                     variant="ghost"
//                     size="sm"
//                     onClick={() => onDeleteRequest(request.id)}
//                     className="h-8 w-8 p-0 text-red-600 hover:text-red-800"
//                   >
//                     <Trash2 className="h-4 w-4" />
//                   </Button>
//                 </div>
//               </TableCell>
//             </TableRow>
//           ))}
//         </TableBody>
//       </Table>

//       {/* Notes Edit Modal */}
//       {editingNotes && (
//         <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
//           <div className="bg-white rounded-lg p-6 w-full max-w-md">
//             <h3 className="text-lg font-semibold mb-4">Edit Admin Notes</h3>
//             <textarea
//               value={noteValue}
//               onChange={(e) => setNoteValue(e.target.value)}
//               placeholder="Add notes about this request..."
//               className="w-full h-32 p-3 border border-gray-300 rounded-md resize-none focus:border-blue-500 focus:outline-none"
//             />
//             <div className="flex justify-end gap-2 mt-4">
//               <Button variant="outline" onClick={handleNotesCancel}>
//                 Cancel
//               </Button>
//               <Button onClick={() => handleNotesSave(editingNotes)}>
//                 Save Notes
//               </Button>
//             </div>
//           </div>
//         </div>
//       )}
//     </Card>
//   );
// } 



'use client';

import { useState } from 'react';
import { Card } from '@/app/components/ui/card';
import { Button } from '@/app/components/ui/button';
import { Badge } from '@/app/components/ui/badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/app/components/ui/table';
import { MoreHorizontal, Edit, Trash2, MapPin, MessageSquare } from 'lucide-react';
import { QuranRequest } from '@/lib/types/quran-requests';
import { formatDate, formatTime } from '@/lib/utils';

interface QuranRequestsTableProps {
  requests: QuranRequest[];
  selectedRequests: string[];
  onSelectionChange: (selected: string[]) => void;
  onUpdateRequest: (id: string, updates: { status?: string; admin_notes?: string; tracking_number?: string }) => void;
  onDeleteRequest: (id: string) => void;
}

export default function QuranRequestsTable({
  requests,
  selectedRequests,
  onSelectionChange,
  onUpdateRequest,
  onDeleteRequest
}: QuranRequestsTableProps) {
  const [editingNotes, setEditingNotes] = useState<string | null>(null);
  const [noteValue, setNoteValue] = useState('');
  const [trackingNumber, setTrackingNumber] = useState('');

  const getStatusBadge = (status: string) => {
    const statusConfig = {
      requested: { variant: 'default' as const, color: 'bg-yellow-500' },
      processing: { variant: 'secondary' as const, color: 'bg-orange-500' },
      sent: { variant: 'secondary' as const, color: 'bg-purple-500' },
      delivered: { variant: 'default' as const, color: 'bg-green-500' },
      cancelled: { variant: 'destructive' as const, color: 'bg-red-500' }
    };
    
    const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.requested;
    
    return (
      <Badge variant={config.variant} className="capitalize">
        {status}
      </Badge>
    );
  };

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      onSelectionChange(requests.map(r => r.id));
    } else {
      onSelectionChange([]);
    }
  };

  const handleSelectRequest = (id: string, checked: boolean) => {
    if (checked) {
      onSelectionChange([...selectedRequests, id]);
    } else {
      onSelectionChange(selectedRequests.filter(rid => rid !== id));
    }
  };

  const handleStatusChange = (id: string, status: string) => {
    onUpdateRequest(id, { status });
  };

  const handleNotesEdit = (request: QuranRequest) => {
    setEditingNotes(request.id);
    setNoteValue(request.admin_notes || '');
    setTrackingNumber((request as any).tracking_number || '');
  };

  const handleNotesSave = (id: string) => {
    console.log(trackingNumber, noteValue)
    onUpdateRequest(id, { 
      admin_notes: noteValue,
      tracking_number: trackingNumber 
    });
    setEditingNotes(null);
    setNoteValue('');
    setTrackingNumber('');
  };

  const handleNotesCancel = () => {
    setEditingNotes(null);
    setNoteValue('');
    setTrackingNumber('');
  };

  if (requests.length === 0) {
    return (
      <Card className="p-8 text-center">
        <p className="text-gray-500">No Quran requests found</p>
      </Card>
    );
  }

  return (
    <Card>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-12">
              <input
                type="checkbox"
                checked={selectedRequests.length === requests.length && requests.length > 0}
                onChange={(e) => handleSelectAll(e.target.checked)}
                className="rounded border-gray-300"
              />
            </TableHead>
            <TableHead>Requester</TableHead>
            <TableHead>Address</TableHead>
            <TableHead>Language</TableHead>
            <TableHead>Tracking #</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Reason</TableHead>
            <TableHead>Created</TableHead>
            <TableHead className="w-24">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {requests.map((request) => (
            <TableRow key={request.id}>
              <TableCell>
                <input
                  type="checkbox"
                  checked={selectedRequests.includes(request.id)}
                  onChange={(e) => handleSelectRequest(request.id, e.target.checked)}
                  className="rounded border-gray-300"
                />
              </TableCell>
              
              <TableCell>
                <div>
                  <div className="font-medium text-gray-900">{request.full_name}</div>
                  <div className="text-sm text-gray-500">{request.email}</div>
                </div>
              </TableCell>
              
              <TableCell>
                <div className="text-sm">
                  <div className="flex items-center gap-1">
                    <MapPin className="h-3 w-3 text-gray-400" />
                    <span>{request.city}, {request.state}</span>
                  </div>
                  <div className="text-gray-500">{request.country}</div>
                  <div className="text-xs text-gray-400">{request.zip_code}</div>
                </div>
              </TableCell>
              
              <TableCell>
                <span className="text-sm">
                  {request.preferred_language || 'Not specified'}
                </span>
              </TableCell>
              
              <TableCell>
              
              <span>{request?.admin_notes || 'Not assigned'}</span>
              </TableCell>
              
              <TableCell>
                <div className="space-y-1">
                  {getStatusBadge(request.status)}
                  <select
                    value={request.status}
                    onChange={(e) => handleStatusChange(request.id, e.target.value)}
                    className="block w-full text-xs rounded border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                  >
                    <option value="requested">Requested</option>
                    <option value="processing">Processing</option>
                    <option value="sent">Sent</option>
                    <option value="delivered">Delivered</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                </div>
              </TableCell>
              
              <TableCell>
                <div className="max-w-xs">
                  {request.reason ? (
                    <span className="text-sm text-gray-600">{request.reason}</span>
                  ) : (
                    <span className="text-sm text-gray-400">No reason provided</span>
                  )}
                </div>
              </TableCell>
              
              <TableCell>
                <div className="text-sm">
                  <div>{formatDate(new Date(request.created_at))}</div>
                  <div className="text-xs text-gray-500">
                    {formatTime(new Date(request.created_at))}
                  </div>
                </div>
              </TableCell>
              
              <TableCell>
                <div className="flex items-center gap-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleNotesEdit(request)}
                    className="h-8 w-8 p-0"
                  >
                    <MessageSquare className="h-4 w-4" />
                  </Button>
                  
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => onDeleteRequest(request.id)}
                    className="h-8 w-8 p-0 text-red-600 hover:text-red-800"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {/* Notes Edit Modal */}
      {editingNotes && (
        <div className="fixed inset-0 bg-black/70 bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg text-black font-semibold mb-4">Edit Request Details</h3>
            
            <div className="space-y-4">
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Admin Notes/Tracking 
                </label>
                <textarea
                  value={noteValue}
                  onChange={(e) => setNoteValue(e.target.value)}
                  placeholder="Add notes about this request..."
                  className="w-full h-32 p-3 border border-gray-300 rounded-md resize-none focus:border-blue-500 focus:outline-none"
                />
              </div>
            </div>
            
            <div className="flex text-black justify-end gap-2 mt-4">
              <Button variant="outline" onClick={handleNotesCancel}>
                Cancel
              </Button>
              <Button className='border' onClick={() => handleNotesSave(editingNotes)}>
                Save Changes
              </Button>
            </div>
          </div>
        </div>
      )}
    </Card>
  );
}
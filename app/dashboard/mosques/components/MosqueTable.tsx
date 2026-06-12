'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Badge } from '@/app/components/ui/badge'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/app/components/ui/table'
import { Edit, Trash2, MapPin, Phone, Globe, CheckCircle, Eye, Building, X, Clock } from 'lucide-react'
import type { Mosque } from '@/lib/types/mosques'
import { formatDate } from '@/lib/utils'

interface MosqueTableProps {
  mosques: Mosque[]
  selectedMosques: string[]
  onSelectionChange: (selected: string[]) => void
  onUpdateMosque: (id: string, updates: Partial<Mosque>) => void
  onDeleteMosque: (id: string) => void
  onApproveMosque: (id: string) => void
  loading: boolean
}

const isUserSubmitted = (mosque_id: string) => mosque_id.startsWith('user_mosque_')

export default function MosqueTable({
  mosques,
  selectedMosques,
  onSelectionChange,
  onUpdateMosque,
  onDeleteMosque,
  onApproveMosque,
  loading
}: MosqueTableProps) {
  const [editingMosque, setEditingMosque] = useState<string | null>(null)
  const [editFormData, setEditFormData] = useState<Partial<Mosque>>({})
  const [viewingMosque, setViewingMosque] = useState<Mosque | null>(null)

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      onSelectionChange(mosques.map(m => m.mosque_id))
    } else {
      onSelectionChange([])
    }
  }
console.log(mosques);
  const handleSelectMosque = (id: string, checked: boolean) => {
    if (checked) {
      onSelectionChange([...selectedMosques, id])
    } else {
      onSelectionChange(selectedMosques.filter(mid => mid !== id))
    }
  }

  const handleEditMosque = (mosque: Mosque) => {
    setEditingMosque(mosque.mosque_id)
    setEditFormData({
      name: mosque.name,
      address: mosque.address,
      phone: mosque.phone,
      website: mosque.website,
      latitude: mosque.latitude,
      longitude: mosque.longitude,
      timezone: mosque.timezone,
      additional_info: mosque.additional_info,
    })
  }

  const handleSaveEdit = () => {
    if (editingMosque) {
      onUpdateMosque(editingMosque, editFormData)
      setEditingMosque(null)
      setEditFormData({})
    }
  }

  const handleCancelEdit = () => {
    setEditingMosque(null)
    setEditFormData({})
  }

  if (loading) {
    return (
      <Card className="p-6">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="h-16 bg-gray-200 rounded"></div>
          ))}
        </div>
      </Card>
    )
  }

  if (mosques.length === 0) {
    return (
      <Card className="p-8 text-center">
        <Building className="mx-auto h-12 w-12 text-gray-400 mb-4" />
        <p className="text-gray-500">No mosques found</p>
      </Card>
    )
  }

  return (
    <Card>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-12">
              <input
                type="checkbox"
                checked={selectedMosques.length === mosques.length && mosques.length > 0}
                onChange={(e) => handleSelectAll(e.target.checked)}
                className="rounded border-gray-300"
              />
            </TableHead>
            <TableHead>Mosque</TableHead>
            <TableHead>Location</TableHead>
            <TableHead>Contact</TableHead>
            <TableHead>Facilities</TableHead>
            <TableHead>Created</TableHead>
            <TableHead className="w-32">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {mosques.map((mosque) => (
            <TableRow key={mosque.mosque_id}>
              <TableCell>
                <input
                  type="checkbox"
                  checked={selectedMosques.includes(mosque.mosque_id)}
                  onChange={(e) => handleSelectMosque(mosque.mosque_id, e.target.checked)}
                  className="rounded border-gray-300"
                />
              </TableCell>

              <TableCell>
                <div>
                  <div className="font-medium text-gray-900">{mosque.name}</div>
                  <div className="text-sm text-gray-500 max-w-xs truncate">{mosque.address}</div>
                  {mosque.additional_info && (
                    <div className="text-xs text-gray-400 mt-1 truncate max-w-xs">
                      {mosque.additional_info}
                    </div>
                  )}
                  {isUserSubmitted(mosque.mosque_id) && (
                    <div className="mt-1">
                      {mosque.is_approved ? (
                        <Badge className="text-xs bg-green-100 text-green-700 border-green-300">
                          Approved
                        </Badge>
                      ) : (
                        <Badge className="text-xs bg-yellow-100 text-yellow-700 border-yellow-300">
                          <Clock className="h-3 w-3 mr-1" />
                          Pending Approval
                        </Badge>
                      )}
                    </div>
                  )}
                </div>
              </TableCell>

              <TableCell>
                <div className="text-sm">
                  {mosque.latitude && mosque.longitude ? (
                    <div className="flex items-center gap-1">
                      <MapPin className="h-3 w-3 text-gray-400" />
                      <span>{mosque.latitude.toFixed(4)}, {mosque.longitude.toFixed(4)}</span>
                    </div>
                  ) : (
                    <div className="text-gray-500">No coordinates</div>
                  )}
                  <div className="text-gray-500 text-xs">{mosque.timezone}</div>
                </div>
              </TableCell>

              <TableCell>
                <div className="space-y-1">
                  {mosque.phone && (
                    <div className="flex items-center gap-1 text-xs">
                      <Phone className="h-3 w-3 text-gray-400" />
                      <span>{mosque.phone}</span>
                    </div>
                  )}
                  {mosque.website && (
                    <div className="flex items-center gap-1 text-xs">
                      <Globe className="h-3 w-3 text-gray-400" />
                      <a
                        href={mosque.website}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-600 hover:underline truncate max-w-24"
                      >
                        Website
                      </a>
                    </div>
                  )}
                </div>
              </TableCell>

              <TableCell>
                <div className="space-y-1">
                  {mosque.facilities && mosque.facilities.length > 0 ? (
                    <div className="flex flex-wrap gap-1">
                      {mosque.facilities.slice(0, 3).map((facility) => (
                        <Badge key={facility.facility_type} variant="outline" className="text-xs">
                          {facility.facility_type}
                        </Badge>
                      ))}
                      {mosque.facilities.length > 3 && (
                        <Badge variant="outline" className="text-xs">
                          +{mosque.facilities.length - 3} more
                        </Badge>
                      )}
                    </div>
                  ) : (
                    <span className="text-sm text-gray-500">No facilities listed</span>
                  )}
                </div>
              </TableCell>

              <TableCell>
                <span className="text-sm text-gray-500">
                  {formatDate(new Date(mosque.created_at))}
                </span>
              </TableCell>

              <TableCell>
                <div className="flex items-center gap-1">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setViewingMosque(mosque)}
                    className="h-8 w-8 p-0 text-blue-600 hover:text-blue-800"
                    title="View Details"
                  >
                    <Eye className="h-4 w-4" />
                  </Button>

                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleEditMosque(mosque)}
                    className="h-8 w-8 p-0"
                    title="Edit"
                  >
                    <Edit className="h-4 w-4" />
                  </Button>

                  {isUserSubmitted(mosque.mosque_id) && !mosque.is_approved && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => onApproveMosque(mosque.mosque_id)}
                      className="h-8 w-8 p-0 text-green-600 hover:text-green-800"
                      title="Approve"
                    >
                      <CheckCircle className="h-4 w-4" />
                    </Button>
                  )}

                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => onDeleteMosque(mosque.mosque_id)}
                    className="h-8 w-8 p-0 text-red-600 hover:text-red-800"
                    title="Delete"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {/* View Details Modal */}
      {viewingMosque && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h3 className="text-lg font-semibold text-gray-900">{viewingMosque.name}</h3>
                <p className="text-sm text-gray-500">{viewingMosque.mosque_id}</p>
              </div>
              <div className="flex items-center gap-2">
                {isUserSubmitted(viewingMosque.mosque_id) && (
                  viewingMosque.is_approved ? (
                    <Badge className="bg-green-100 text-green-700 border-green-300">Approved</Badge>
                  ) : (
                    <Badge className="bg-yellow-100 text-yellow-700 border-yellow-300">Pending Approval</Badge>
                  )
                )}
                <Button variant="ghost" size="sm" onClick={() => setViewingMosque(null)} className="h-8 w-8 p-0">
                  <X className="h-4 w-4" />
                </Button>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-3">
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Address</p>
                  <p className="text-sm text-gray-900">{viewingMosque.address || '—'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Coordinates</p>
                  {viewingMosque.latitude && viewingMosque.longitude ? (
                    <p className="text-sm text-gray-900">
                      {viewingMosque.latitude.toFixed(6)}, {viewingMosque.longitude.toFixed(6)}
                    </p>
                  ) : (
                    <p className="text-sm text-gray-400">—</p>
                  )}
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Timezone</p>
                  <p className="text-sm text-gray-900">{viewingMosque.timezone || '—'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Phone</p>
                  <p className="text-sm text-gray-900">{viewingMosque.phone || '—'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Website</p>
                  {viewingMosque.website ? (
                    <a href={viewingMosque.website} target="_blank" rel="noopener noreferrer" className="text-sm text-blue-600 hover:underline">
                      {viewingMosque.website}
                    </a>
                  ) : (
                    <p className="text-sm text-gray-400">—</p>
                  )}
                </div>
              </div>

              <div className="space-y-3">
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Additional Info</p>
                  <p className="text-sm text-gray-900">{viewingMosque.additional_info || '—'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Created</p>
                  <p className="text-sm text-gray-900">{formatDate(new Date(viewingMosque.created_at))}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase">Updated</p>
                  <p className="text-sm text-gray-900">{formatDate(new Date(viewingMosque.updated_at))}</p>
                </div>
              </div>
            </div>

            {viewingMosque.facilities && viewingMosque.facilities.length > 0 && (
              <div className="mt-4">
                <p className="text-xs font-medium text-gray-500 uppercase mb-2">Facilities</p>
                <div className="flex flex-wrap gap-2">
                  {viewingMosque.facilities.map((facility) => (
                    <Badge key={facility.facility_type} variant="outline" className="text-xs">
                      {facility.facility_type}
                      {facility.availability && ` · ${facility.availability}`}
                    </Badge>
                  ))}
                </div>
              </div>
            )}

            <div className="flex justify-end gap-2 mt-6 pt-4 border-t">
              {isUserSubmitted(viewingMosque.mosque_id) && !viewingMosque.is_approved && (
                <Button
                  onClick={() => {
                    onApproveMosque(viewingMosque.mosque_id)
                    setViewingMosque(null)
                  }}
                  className="bg-green-600 hover:bg-green-700 text-white flex items-center gap-2"
                >
                  <CheckCircle className="h-4 w-4" />
                  Approve Mosque
                </Button>
              )}
              <Button variant="outline" onClick={() => setViewingMosque(null)}>
                Close
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Edit Modal */}
      {editingMosque && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h3 className="text-lg font-semibold mb-4">Edit Mosque</h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                <input
                  type="text"
                  value={editFormData.name || ''}
                  onChange={(e) => setEditFormData({...editFormData, name: e.target.value})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Timezone</label>
                <input
                  type="text"
                  value={editFormData.timezone || ''}
                  onChange={(e) => setEditFormData({...editFormData, timezone: e.target.value})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                  placeholder="e.g., America/New_York"
                />
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
                <input
                  type="text"
                  value={editFormData.address || ''}
                  onChange={(e) => setEditFormData({...editFormData, address: e.target.value})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Latitude</label>
                <input
                  type="number"
                  step="any"
                  value={editFormData.latitude || ''}
                  onChange={(e) => setEditFormData({...editFormData, latitude: e.target.value ? parseFloat(e.target.value) : undefined})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Longitude</label>
                <input
                  type="number"
                  step="any"
                  value={editFormData.longitude || ''}
                  onChange={(e) => setEditFormData({...editFormData, longitude: e.target.value ? parseFloat(e.target.value) : undefined})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                <input
                  type="text"
                  value={editFormData.phone || ''}
                  onChange={(e) => setEditFormData({...editFormData, phone: e.target.value})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Website</label>
                <input
                  type="url"
                  value={editFormData.website || ''}
                  onChange={(e) => setEditFormData({...editFormData, website: e.target.value})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Additional Information</label>
                <textarea
                  value={editFormData.additional_info || ''}
                  onChange={(e) => setEditFormData({...editFormData, additional_info: e.target.value})}
                  className="w-full p-2 border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none"
                  rows={3}
                />
              </div>
            </div>

            <div className="flex justify-end gap-2 mt-6">
              <Button variant="outline" onClick={handleCancelEdit}>
                Cancel
              </Button>
              <Button onClick={handleSaveEdit}>
                Save Changes
              </Button>
            </div>
          </div>
        </div>
      )}
    </Card>
  )
}

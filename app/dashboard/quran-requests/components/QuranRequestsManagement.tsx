// 'use client';

// import { useState, useEffect } from 'react';
// import { Button } from '@/app/components/ui/button';
// import { Card } from '@/app/components/ui/card';
// import { Plus, Download, RefreshCw } from 'lucide-react';
// // Removed unused createClient import
// import { QuranRequest, QuranRequestFilters, QuranRequestStats } from '@/lib/types/quran-requests';
// import QuranRequestsStatsCards from './QuranRequestsStatsCards';
// import QuranRequestFiltersPanel from './QuranRequestFiltersPanel';
// import QuranRequestsTable from './QuranRequestsTable';
// import AddQuranRequestDialog from './AddQuranRequestDialog';

// export default function QuranRequestsManagement() {
//   const [requests, setRequests] = useState<QuranRequest[]>([]);
//   const [stats, setStats] = useState<QuranRequestStats>({
//     total: 0,
//     requested: 0,
//     processing: 0,
//     sent: 0,
//     delivered: 0,
//     cancelled: 0,
//     thisWeek: 0,
//     thisMonth: 0,
//     averageProcessingDays: 0
//   });
//   const [filters, setFilters] = useState<QuranRequestFilters>({
//     search: '',
//     status: 'all',
//     country: '',
//     state: '',
//     preferred_language: '',
//     dateRange: { from: null, to: null }
//   });
//   const [loading, setLoading] = useState(true);
//   const [selectedRequests, setSelectedRequests] = useState<string[]>([]);
//   const [showAddDialog, setShowAddDialog] = useState(false);

//   // Removed unused supabase client

//   const fetchRequests = async () => {
//     try {
//       setLoading(true);

//       // Build query parameters
//       const params = new URLSearchParams();
//       if (filters.status !== 'all') {
//         params.set('status', filters.status);
//       }
//       if (filters.search) {
//         params.set('search', filters.search);
//       }

//       // Use the admin API instead of direct database queries
//       const response = await fetch(`/api/admin/quran-requests?${params.toString()}`);

//       if (!response.ok) {
//         throw new Error('Failed to fetch quran requests');
//       }

//       const data = await response.json();
//       setRequests(data.requests || []);
//       setStats({
//         total: data.stats?.total_requests || 0,
//         requested: data.stats?.requested_requests || 0,
//         processing: data.stats?.processing_requests || 0,
//         sent: data.stats?.sent_requests || 0,
//         delivered: data.stats?.delivered_requests || 0,
//         cancelled: 0,
//         thisWeek: 0,
//         thisMonth: 0,
//         averageProcessingDays: 0
//       });
//     } catch (error) {
//       console.error('Error fetching requests:', error);
//       setRequests([]);
//     } finally {
//       setLoading(false);
//     }
//   };

//   // Remove calculateStats since we get stats from API

//   const handleUpdateRequest = async (id: string, updates: { status?: string; admin_notes?: string }) => {
//     try {
//       const response = await fetch(`/api/admin/quran-requests?id=${id}`, {
//         method: 'PUT',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify(updates),
//       });

//       if (!response.ok) {
//         const error = await response.json();
//         throw new Error(error.error || 'Failed to update request');
//       }

//       await fetchRequests();
//     } catch (error) {
//       console.error('Error updating request:', error);
//       alert('Failed to update request. Please try again.');
//     }
//   }

//   const handleDeleteRequest = async (id: string) => {
//     if (!confirm('Are you sure you want to delete this request?')) return;

//     try {
//       const response = await fetch(`/api/admin/quran-requests?id=${id}`, {
//         method: 'DELETE',
//       });

//       if (!response.ok) {
//         const error = await response.json();
//         throw new Error(error.error || 'Failed to delete request');
//       }

//       await fetchRequests();
//     } catch (error) {
//       console.error('Error deleting request:', error);
//       alert('Failed to delete request. Please try again.');
//     }
//   }

//   const handleBulkAction = async (action: string) => {
//     if (selectedRequests.length === 0) return;

//     try {
//       const response = await fetch('/api/admin/quran-requests/bulk', {
//         method: 'PUT',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify({
//           requestIds: selectedRequests,
//           action,
//         }),
//       });

//       if (!response.ok) {
//         const error = await response.json();
//         throw new Error(error.error || 'Failed to perform bulk action');
//       }

//       setSelectedRequests([]);
//       await fetchRequests();
//     } catch (error) {
//       console.error('Error performing bulk action:', error);
//       alert('Failed to perform bulk action. Please try again.');
//     }
//   }

//   const handleExport = () => {
//     const csvContent = [
//       ['ID', 'Full Name', 'Email', 'Address', 'City', 'State', 'Zip Code', 'Country', 'Language', 'Reason', 'Status', 'Created At'].join(','),
//       ...requests.map(request => [
//         request.id,
//         `"${request.full_name}"`,
//         request.email,
//         `"${request.address}"`,
//         request.city,
//         request.state,
//         request.zip_code,
//         request.country,
//         request.preferred_language || '',
//         `"${request.reason || ''}"`,
//         request.status,
//         new Date(request.created_at).toLocaleDateString()
//       ].join(','))
//     ].join('\n');

//     const blob = new Blob([csvContent], { type: 'text/csv' });
//     const url = window.URL.createObjectURL(blob);
//     const a = document.createElement('a');
//     a.href = url;
//     a.download = `quran-requests-${new Date().toISOString().split('T')[0]}.csv`;
//     a.click();
//     window.URL.revokeObjectURL(url);
//   };

//   useEffect(() => {
//     fetchRequests();
//   }, [filters]);

//   if (loading) {
//     return (
//       <div className="flex items-center justify-center h-64">
//         <RefreshCw className="h-8 w-8 animate-spin text-gray-500" />
//       </div>
//     );
//   }

//   return (
//     <div className="space-y-6">
//       {/* Statistics Cards */}
//       <QuranRequestsStatsCards stats={stats} />

//       {/* Actions Bar */}
//       <Card className="p-4">
//         <div className="flex items-center justify-between">
//           <div className="flex items-center gap-4">
//             <Button onClick={() => setShowAddDialog(true)} className="flex items-center gap-2">
//               <Plus className="h-4 w-4" />
//               Add Request
//             </Button>

//             {selectedRequests.length > 0 && (
//               <div className="flex items-center gap-2">
//                 <span className="text-sm text-gray-600">
//                   {selectedRequests.length} selected
//                 </span>
//                 <Button
//                   variant="outline"
//                   size="sm"
//                   onClick={() => handleBulkAction('mark_processing')}
//                 >
//                   Mark Processing
//                 </Button>
//                 <Button
//                   variant="outline"
//                   size="sm"
//                   onClick={() => handleBulkAction('mark_sent')}
//                 >
//                   Mark Sent
//                 </Button>
//                 <Button
//                   variant="outline"
//                   size="sm"
//                   onClick={() => handleBulkAction('mark_delivered')}
//                 >
//                   Mark Delivered
//                 </Button>
//               </div>
//             )}
//           </div>

//           <div className="flex items-center gap-2">
//             <Button
//               variant="outline"
//               onClick={fetchRequests}
//               className="flex items-center gap-2"
//             >
//               <RefreshCw className="h-4 w-4" />
//               Refresh
//             </Button>
//             <Button
//               variant="outline"
//               onClick={handleExport}
//               className="flex items-center gap-2"
//             >
//               <Download className="h-4 w-4" />
//               Export CSV
//             </Button>
//           </div>
//         </div>
//       </Card>

//       {/* Filters */}
//       <QuranRequestFiltersPanel
//         filters={filters}
//         onFiltersChange={setFilters}
//         requests={requests}
//       />

//       {/* Requests Table */}
//       <QuranRequestsTable
//         requests={requests}
//         selectedRequests={selectedRequests}
//         onSelectionChange={setSelectedRequests}
//         onUpdateRequest={handleUpdateRequest}
//         onDeleteRequest={handleDeleteRequest}
//       />

//       {/* Add Request Dialog */}
//       {showAddDialog && (
//         <AddQuranRequestDialog
//           isOpen={showAddDialog}
//           onClose={() => setShowAddDialog(false)}
//           onSuccess={() => {
//             setShowAddDialog(false);
//             fetchRequests();
//           }}
//         />
//       )}
//     </div>
//   );
// }

"use client";

import { Button } from "@/app/components/ui/button";
import { Card } from "@/app/components/ui/card";
import {
  QuranRequest,
  QuranRequestFilters,
  QuranRequestStats,
} from "@/lib/types/quran-requests";
import { Download, Plus, RefreshCw } from "lucide-react";
import { useEffect, useState } from "react";
import AddQuranRequestDialog from "./AddQuranRequestDialog";
import QuranRequestFiltersPanel from "./QuranRequestFiltersPanel";
import QuranRequestsStatsCards from "./QuranRequestsStatsCards";
import QuranRequestsTable from "./QuranRequestsTable";
 import toast, { Toaster } from 'react-hot-toast';
export default function QuranRequestsManagement() {
  const [requests, setRequests] = useState<QuranRequest[]>([]);
 
  console.log(requests);

  const [stats, setStats] = useState<QuranRequestStats>({
    total: 0,
    requested: 0,
    processing: 0,
    sent: 0,
    delivered: 0,
    cancelled: 0,
    thisWeek: 0,
    thisMonth: 0,
    averageProcessingDays: 0,
  });
  const [filters, setFilters] = useState<QuranRequestFilters>({
    search: "",
    status: "all",
    country: "",
    state: "",
    preferred_language: "",
    dateRange: { from: null, to: null },
  });
  const [loading, setLoading] = useState(true);
  const [selectedRequests, setSelectedRequests] = useState<string[]>([]);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 3,
    total: 0,
    totalPages: 0,
  });

  const fetchRequests = async () => {
    try {
      setLoading(true);

      // Build query parameters
      const params = new URLSearchParams();
      if (filters.status !== "all") {
        params.set("status", filters.status);
      }
      if (filters.search) {
        params.set("search", filters.search);
      }
      params.set("page", pagination.page.toString());
      params.set("limit", pagination.limit.toString());

      // Use the admin API instead of direct database queries
      const response = await fetch(
        `/api/admin/quran-requests?${params.toString()}`
      );

      if (!response.ok) {
        throw new Error("Failed to fetch quran requests");
      }

      const data = await response.json();
      setRequests(data.requests || []);
      console.log(data);

      // Update pagination info
      setPagination((prev) => ({
        ...prev,
        page: data.pagination?.page || 1,
        total: data.pagination?.total || 0,
        totalPages: data.pagination?.totalPages || 0,
      }));

      // Calculate cancelled count from requests if not provided by API
      const cancelledCount =
        data.stats?.cancelled_requests ??
        (data.requests || []).filter(
          (r: QuranRequest) => r.status === "cancelled"
        ).length;

      // Calculate week, month, and average processing days
      const now = new Date();
      const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const oneMonthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

      const thisWeekCount = (data.requests || []).filter(
        (r: QuranRequest) => new Date(r.created_at) >= oneWeekAgo
      ).length;

      const thisMonthCount = (data.requests || []).filter(
        (r: QuranRequest) => new Date(r.created_at) >= oneMonthAgo
      ).length;

      // Calculate average processing days for delivered requests
      const deliveredRequests = (data.requests || []).filter(
        (r: QuranRequest) => r.status === "delivered" || r.status === "sent"
      );

      let averageProcessingDays = 0;
      if (deliveredRequests.length > 0) {
        const totalDays = deliveredRequests.reduce(
          (sum: number, r: QuranRequest) => {
            const created = new Date(r.created_at);
            const updated = new Date(r.updated_at);
            const days = Math.floor(
              (updated.getTime() - created.getTime()) / (1000 * 60 * 60 * 24)
            );
            return sum + days;
          },
          0
        );
        averageProcessingDays = Math.round(
          totalDays / deliveredRequests.length
        );
      }

      setStats({
        total: data.stats?.total_requests || 0,
        requested: data.stats?.requested_requests || 0,
        processing: data.stats?.processing_requests || 0,
        sent: data.stats?.sent_requests || 0,
        delivered: data.stats?.delivered_requests || 0,
        cancelled: cancelledCount,
        thisWeek: thisWeekCount,
        thisMonth: thisMonthCount,
        averageProcessingDays: averageProcessingDays,
      });
    } catch (error) {
      console.error("Error fetching requests:", error);
      setRequests([]);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateRequest = async (
    id: string,
    updates: { status?: string; admin_notes?: string }
  ) => {
    try {
      const response = await fetch(`/api/admin/quran-requests?id=${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(updates),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || "Failed to update request");
      }

      await fetchRequests();
    } catch (error) {
      console.error("Error updating request:", error);
      alert("Failed to update request. Please try again.");
    }
  };



const handleDeleteRequest = async (id: string) => {
  if (!confirm("Are you sure you want to delete this request?")) return;

  try {
    const response = await fetch(`/api/admin/quran-requests?id=${id}`, {
      method: "DELETE",
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || "Failed to delete request");
    }

    await fetchRequests();

    // SUCCESS TOAST
    toast.success("Request deleted successfully!");
  } catch (error) {
    console.error("Error deleting request:", error);
    toast.error("Failed to delete request. Please try again.");
  }
};


  // const handleDeleteRequest = async (id: string) => {
  //   if (!confirm("Are you sure you want to delete this request?")) return;

  //   try {
  //     const response = await fetch(`/api/admin/quran-requests?id=${id}`, {
  //       method: "DELETE",
  //     });

  //     if (!response.ok) {
  //       const error = await response.json();
  //       throw new Error(error.error || "Failed to delete request");
  //     }

  //     await fetchRequests();
  //   } catch (error) {
  //     console.error("Error deleting request:", error);
  //     alert("Failed to delete request. Please try again.");
  //   }
  // };

  const handleBulkAction = async (action: string) => {
    if (selectedRequests.length === 0) return;

    try {
      const response = await fetch("/api/admin/quran-requests/bulk", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          requestIds: selectedRequests,
          action,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || "Failed to perform bulk action");
      }

      setSelectedRequests([]);
      await fetchRequests();
    } catch (error) {
      console.error("Error performing bulk action:", error);
      alert("Failed to perform bulk action. Please try again.");
    }
  };

  const handleExport = () => {
    const csvContent = [
      [
        "ID",
        "Full Name",
        "Email",
        "Address",
        "City",
        "State",
        "Zip Code",
        "Country",
        "Language",
        "Reason",
        "Status",
        "Created At",
      ].join(","),
      ...requests.map((request) =>
        [
          request.id,
          `"${request.full_name}"`,
          request.email,
          `"${request.address}"`,
          request.city,
          request.state,
          request.zip_code,
          request.country,
          request.preferred_language || "",
          `"${request.reason || ""}"`,
          request.status,
          new Date(request.created_at).toLocaleDateString(),
        ].join(",")
      ),
    ].join("\n");

    const blob = new Blob([csvContent], { type: "text/csv" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `quran-requests-${new Date().toISOString().split("T")[0]}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  useEffect(() => {
    fetchRequests();
  }, [filters, pagination.page, pagination.limit]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <RefreshCw className="h-8 w-8 animate-spin text-gray-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
       <Toaster />
      {/* Statistics Cards */}
      <QuranRequestsStatsCards stats={stats} />

      {/* Actions Bar */}

      <Card className="p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Button
              onClick={() => setShowAddDialog(true)}
              className="flex items-center text-black gap-2 border"
            >
              <Plus className="h-4 w-4" />
              Add Request
            </Button>

            {selectedRequests.length > 0 && (
              <div className="flex items-center gap-2">
                <span className="text-sm text-black">
                  {selectedRequests.length} selected
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleBulkAction("mark_processing")}
                >
                  Mark Processing
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleBulkAction("mark_sent")}
                >
                  Mark Sent

                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleBulkAction("mark_delivered")}
                >
                  Mark Delivered

                </Button>
              </div>
            )}
          </div>

          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              onClick={fetchRequests}
              className="flex text-black items-center gap-2"
            >
              <RefreshCw className="h-4 w-4" />
              Refresh
            </Button>
            <Button
              variant="outline"
              onClick={handleExport}
              className="flex text-black items-center gap-2"
            >
              <Download className="h-4 w-4" />
              Export CSV
            </Button>
          </div>
        </div>
      </Card>

      {/* Filters */}
      
      <QuranRequestFiltersPanel
        filters={filters}
        onFiltersChange={setFilters}
        requests={requests}
      />

      {/* Requests Table */}
      <QuranRequestsTable
        requests={requests}
        selectedRequests={selectedRequests}
        onSelectionChange={setSelectedRequests}
        onUpdateRequest={handleUpdateRequest}
        onDeleteRequest={handleDeleteRequest}
      />

      {/* Pagination */}
      {pagination.totalPages > 1 && (
        <Card className="p-4">
          <div className="flex items-center justify-between">
            <div className="text-sm text-gray-600">
              Showing {(pagination.page - 1) * pagination.limit + 1} to{" "}
              {Math.min(pagination.page * pagination.limit, pagination.total)}{" "}
              of {pagination.total} requests
            </div>

            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                 className="text-black"
                size="sm"
                onClick={() => setPagination((prev) => ({ ...prev, page: 1 }))}
                disabled={pagination.page === 1}
              >
                First
              </Button>
              <Button
                variant="outline"
                 className="text-black"
                size="sm"
                onClick={() =>
                  setPagination((prev) => ({ ...prev, page: prev.page - 1 }))
                }
                disabled={pagination.page === 1}
              >
                Previous
              </Button>

              <div className="flex items-center gap-1">
                {Array.from(
                  { length: Math.min(5, pagination.totalPages) },
                  (_, i) => {
                    let pageNum;
                    if (pagination.totalPages <= 5) {
                      pageNum = i + 1;
                    } else if (pagination.page <= 3) {
                      pageNum = i + 1;
                    } else if (pagination.page >= pagination.totalPages - 2) {
                      pageNum = pagination.totalPages - 4 + i;
                    } else {
                      pageNum = pagination.page - 2 + i;
                    }

                    return (
                      <Button
                       className="text-black"
                        key={pageNum}
                        variant={
                          pagination.page === pageNum ? "default" : "outline"
                        }
                        size="sm"
                        onClick={() =>
                          setPagination((prev) => ({ ...prev, page: pageNum }))
                        }
                      >
                        {pageNum}
                      </Button>
                    );
                  }
                )}
              </div>

              <Button
                variant="outline"
                 className="text-black"
                size="sm"
                onClick={() =>
                  setPagination((prev) => ({ ...prev, page: prev.page + 1 }))
                }
                disabled={pagination.page === pagination.totalPages}
              >
                Next
              </Button>
              <Button
              className="text-black"
                variant="outline"
                size="sm"
                onClick={() =>
                  setPagination((prev) => ({
                    ...prev,
                    page: pagination.totalPages,
                  }))
                }
                disabled={pagination.page === pagination.totalPages}
              >
                Last
              </Button>
            </div>

            <div className="flex items-center gap-2">
              <span className="text-sm text-gray-600">Per page:</span>
              <select
                value={pagination.limit}
                onChange={(e) =>
                  setPagination((prev) => ({
                    ...prev,
                    limit: Number(e.target.value),
                    page: 1,
                  }))
                }
                className="border rounded px-2 py-1 text-sm"
              >
                <option value={10}>10</option>
                <option value={25}>25</option>
                <option value={50}>50</option>
                <option value={100}>100</option>
              </select>
            </div>
          </div>
        </Card>
      )}

      {/* Add Request Dialog */}
      {showAddDialog && (
        <AddQuranRequestDialog
          isOpen={showAddDialog}
          onClose={() => setShowAddDialog(false)}
          onSuccess={() => {
            setShowAddDialog(false);
            fetchRequests();
          }}
        />
      )}
    </div>
  );
}

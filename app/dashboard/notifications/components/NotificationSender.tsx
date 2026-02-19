'use client';

import { useState, useEffect } from 'react';

export default function AdminNotifications() {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [subscriberCount, setSubscriberCount] = useState<number | null>(null);
  const [countLoading, setCountLoading] = useState(true);

  // Fetch subscriber count on component mount
  useEffect(() => {
    const fetchSubscriberCount = async () => {
      try {
        const response = await fetch('/api/get-subscriber-count');
        const data = await response.json();

        if (response.ok) {
          setSubscriberCount(data.subscriberCount);
        } else {
          console.error('Error fetching subscriber count:', data.error);
        }
      } catch (error) {
        console.error('Network error fetching subscriber count:', error);
      } finally {
        setCountLoading(false);
      }
    };

    fetchSubscriberCount();
  }, []);

  const handleSendNotification = async () => {
    // Validation
    if (!title.trim() || !body.trim()) {
      setMessage('Please fill in both title and body fields');
      return;
    }

    setIsLoading(true);
    setMessage('');

    // Log to console
    console.log('=== Sending Notification ===');
    console.log('Title:', title);
    console.log('Body:', body);
    console.log('Timestamp:', new Date().toISOString());

    try {
      // API call to send notification to all users via our secure API route
      const response = await fetch('/api/send-announcement', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include', // Include cookies for authentication
        body: JSON.stringify({
          title,
          body,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        console.log('Success:', data);
        setMessage('Notification sent successfully to all users!');
        // Clear form
        setTitle('');
        setBody('');
      } else {
        console.error('Error:', data);
        setMessage(`Error: ${data.error || 'Failed to send notification'}`);
      }
    } catch (error) {
      console.error('Network error:', error);
      setMessage('Network error: Failed to send notification');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="  bg-gray-100   px-4">
      <div className="max-w-2xl mx-auto">
        <div className="bg-white rounded-lg shadow-md p-8">
          <div className="flex items-center justify-between mb-2">
            <h1 className="text-3xl font-bold text-gray-800">
              Send Notification to All Users
            </h1>
            {countLoading ? (
              <span className="text-gray-500">Loading subscriber count...</span>
            ) : (
              <span className="text-lg font-semibold text-blue-600">
                
              </span>
            )}
          </div>
          <p className="text-gray-600 mb-8">
            Send a custom notification message to all registered users
          </p>

          <div className="space-y-6">
            {/* Title Input */}
            <div>
              <label
                htmlFor="notification-title"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Notification Title
              </label>
              <input
                id="notification-title"
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Enter notification title..."
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
                disabled={isLoading}
              />
            </div>

            {/* Body Input */}
            <div>
              <label
                htmlFor="notification-body"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Notification Body
              </label>
              <textarea
                id="notification-body"
                value={body}
                onChange={(e) => setBody(e.target.value)}
                placeholder="Enter notification message..."
                rows={6}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition resize-none"
                disabled={isLoading}
              />
            </div>

            {/* Send Button */}
            <button
              onClick={handleSendNotification}
              disabled={isLoading}
              className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-semibold py-3 px-6 rounded-lg transition duration-200 flex items-center justify-center"
            >
              {isLoading ? (
                <>
                  <svg
                    className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    ></circle>
                    <path
                      className="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                  </svg>
                  Sending...
                </>
              ) : (
                `Send Notification${subscriberCount !== null ? ` (${subscriberCount.toLocaleString()} subscribers)` : ''}`
              )}
            </button>

            {/* Message Display */}
            {message && (
              <div
                className={`p-4 rounded-lg ${
                  message.includes('success')
                    ? 'bg-green-50 text-green-800 border border-green-200'
                    : 'bg-red-50 text-red-800 border border-red-200'
                }`}
              >
                {message}
              </div>
            )}
          </div>

          {/* Preview Section */}
          {(title || body) && (
            <div className="mt-8 pt-8 border-t border-gray-200">
              <h2 className="text-lg font-semibold text-gray-800 mb-4">
                Preview
              </h2>
              <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                {title && (
                  <h3 className="font-semibold text-gray-900 mb-2">{title}</h3>
                )}
                {body && <p className="text-gray-700 whitespace-pre-wrap">{body}</p>}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

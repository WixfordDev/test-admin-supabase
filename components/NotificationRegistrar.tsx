// components/NotificationRegistrar.tsx

'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

interface NotificationRegistrarProps {
  userId: string;
}

export default function NotificationRegistrar({ userId }: NotificationRegistrarProps) {
  const [permission, setPermission] = useState<NotificationPermission>('default');
  const [isSupported, setIsSupported] = useState(false);
  const [supabase] = useState(() => createClient());

  useEffect(() => {
    // Check if notifications are supported
    if ('Notification' in window) {
      setIsSupported(true);
      setPermission(Notification.permission);
    } else {
      setIsSupported(false);
    }
  }, []);

  const requestNotificationPermission = async () => {
    if (!isSupported) return;

    try {
      const permissionResult = await Notification.requestPermission();
      setPermission(permissionResult);

      if (permissionResult === 'granted') {
        // Register the service worker
        if ('serviceWorker' in navigator) {
          const registration = await navigator.serviceWorker.register('/sw.js');

          // Subscribe to push notifications
          const subscription = await registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: urlBase64ToUint8Array(process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY!)
          });

          // Send the subscription to your server via API route
          const subscriptionData = JSON.stringify(subscription);

          // Save the subscription via API route
          const response = await fetch('/api/register-fcm-token', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              fcmToken: subscriptionData,
              deviceInfo: {
                platform: navigator.platform,
                userAgent: navigator.userAgent,
                language: navigator.language
              }
            }),
          });

          if (!response.ok) {
            const errorData = await response.json();
            console.error('Error saving subscription:', errorData);
          } else {
            console.log('Push notification subscription saved');
          }
        }
      }
    } catch (error) {
      console.error('Error requesting notification permission:', error);
    }
  };

  // Helper function to convert VAPID key
  const urlBase64ToUint8Array = (base64String: string) => {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding)
      .replace(/\-/g, '+')
      .replace(/_/g, '/');
  
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
  
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  };

  if (!isSupported) {
    return (
      <div className="p-4 bg-yellow-100 text-yellow-800 rounded-md">
        Push notifications are not supported in your browser.
      </div>
    );
  }

  if (permission === 'granted') {
    return (
      <div className="p-4 bg-green-100 text-green-800 rounded-md">
        You have granted permission for push notifications.
      </div>
    );
  }

  if (permission === 'denied') {
    return (
      <div className="p-4 bg-red-100 text-red-800 rounded-md">
        You have blocked push notifications. Please enable them in your browser settings.
      </div>
    );
  }

  return (
    <div className="p-4 bg-blue-100 text-blue-800 rounded-md">
      <p>Enable push notifications to receive updates about your account.</p>
      <button
        onClick={requestNotificationPermission}
        className="mt-2 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
      >
        Enable Notifications
      </button>
    </div>
  );
}
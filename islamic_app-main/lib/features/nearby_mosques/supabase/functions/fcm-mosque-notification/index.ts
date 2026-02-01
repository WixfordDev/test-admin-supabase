// Supabase Edge Function for sending Firebase Cloud Messaging notifications
// about mosque prayer time changes - SENDS MINIMAL DATA FOR DEVICE PROCESSING
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Load environment variables
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
const FIREBASE_SERVICE_ACCOUNT_EMAIL = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_EMAIL') || ''
const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID') || 'deenhub-4bf96'
const FIREBASE_PRIVATE_KEY = Deno.env.get('FIREBASE_PRIVATE_KEY') || ''

// Initialize Supabase client with service role key (only used for logging, not for mosque data)
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

// Function to generate a signed JWT for FCM authentication
async function generateAccessToken() {
  if (!FIREBASE_SERVICE_ACCOUNT_EMAIL || !FIREBASE_PROJECT_ID || !FIREBASE_PRIVATE_KEY) {
    throw new Error('Missing Firebase service account configuration')
  }

  // Prepare the private key - ensure it's properly formatted
  let privateKey = FIREBASE_PRIVATE_KEY
  
  // Handle different key formats
  if (privateKey.includes('\\n')) {
    privateKey = privateKey.replace(/\\n/g, '\n')
  }
  
  // Ensure the key has proper headers/footers
  if (!privateKey.includes('-----BEGIN PRIVATE KEY-----')) {
    throw new Error('Private key must be in PEM format with proper headers')
  }

  // Create JWT payload
  const now = Math.floor(Date.now() / 1000)
  const payload = {
    iss: FIREBASE_SERVICE_ACCOUNT_EMAIL,
    sub: FIREBASE_SERVICE_ACCOUNT_EMAIL,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600, // 1 hour expiration
    scope: 'https://www.googleapis.com/auth/firebase.messaging'
  }

  try {
    // Extract the key content from PEM format
    const pemHeader = '-----BEGIN PRIVATE KEY-----'
    const pemFooter = '-----END PRIVATE KEY-----'
    const keyContent = privateKey
      .replace(pemHeader, '')
      .replace(pemFooter, '')
      .replace(/\s/g, '')
    
    // Decode base64 to get binary data
    const binaryString = atob(keyContent)
    const bytes = new Uint8Array(binaryString.length)
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i)
    }
    
    // Import the key using the correct format
    const cryptoKey = await crypto.subtle.importKey(
      'pkcs8',
      bytes.buffer,
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256',
      },
      false,
      ['sign']
    )

    // Create JWT header
    const header = {
      alg: 'RS256',
      typ: 'JWT'
    }

    // Helper function for base64url encoding
    function base64urlEncode(str: string): string {
      return btoa(str)
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '')
    }

    // Encode header and payload
    const encodedHeader = base64urlEncode(JSON.stringify(header))
    const encodedPayload = base64urlEncode(JSON.stringify(payload))
    
    // Create signature
    const signatureInput = `${encodedHeader}.${encodedPayload}`
    const signature = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      cryptoKey,
      new TextEncoder().encode(signatureInput)
    )
    
    // Encode signature in base64url format
    const signatureArray = new Uint8Array(signature)
    const signatureString = String.fromCharCode(...signatureArray)
    const encodedSignature = base64urlEncode(signatureString)
    
    // Create the JWT
    const jwt = `${encodedHeader}.${encodedPayload}.${encodedSignature}`
    
    // Exchange JWT for access token
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    })

    const tokenData = await tokenResponse.json()
    
    if (!tokenResponse.ok) {
      console.error('Token response error:', tokenData)
      throw new Error(`Failed to get access token: ${tokenData.error || 'Unknown error'}`)
    }
    
    return tokenData.access_token
  } catch (error) {
    console.error('Error generating access token:', error)
    throw error
  }
}

// Legacy function for compatibility - now just calls generateAccessToken
async function getAccessToken() {
  return await generateAccessToken()
}

// Function to send minimal FCM notification for device processing
async function sendMinimalFcmNotification({
  mosqueId,
  mosqueName,
  mosqueLatitude,
  mosqueLongitude,
  prayerName,
  timeType,
  adjustmentMinutes,
  previousAdjustment,
  changeSource,
  effectiveDate
}: {
  mosqueId: string,
  mosqueName: string,
  mosqueLatitude: number,
  mosqueLongitude: number,
  prayerName: string,
  timeType: string,
  adjustmentMinutes: number,
  previousAdjustment?: number,
  changeSource: string,
  effectiveDate?: string
}) {
  try {
    const accessToken = await getAccessToken()
    const topic = `mosque_${mosqueId}`
    
    // Use mosque name as notification title
    const title = mosqueName
    const body = 'Prayer time updated - tap to view'
    
    // Prepare minimal FCM message payload with mosque coordinates for device processing
    const fcmPayload = {
      message: {
        topic,
        notification: {
          title,
          body
        },
        data: {
          // MINIMAL DATA + MOSQUE COORDINATES - device does all calculation and formatting
          type: 'mosque_prayer_time_change',
          mosque_id: mosqueId,
          mosque_name: mosqueName,
          mosque_latitude: String(mosqueLatitude),
          mosque_longitude: String(mosqueLongitude),
          prayer_name: prayerName,
          time_type: timeType,
          adjustment_minutes: String(adjustmentMinutes),
          previous_adjustment: previousAdjustment !== undefined ? String(previousAdjustment) : '',
          change_source: changeSource,
          effective_date: effectiveDate || '',
          timestamp: new Date().toISOString()
        }
      }
    }

    console.log('=== FCM MINIMAL DATA WITH MOSQUE INFO DEBUG ===')
    console.log('FCM Topic:', topic)
    console.log('Change Source:', changeSource)
    console.log('Mosque name as title:', title)
    console.log('Simple notification body:', body)
    console.log('Enhanced data payload:', JSON.stringify(fcmPayload.message.data, null, 2))
    console.log('FCM URL:', `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`)

    // FCM HTTP v1 API request
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`
        },
        body: JSON.stringify(fcmPayload)
      }
    )

    const result = await response.json()
    
    console.log('=== FCM Response ===')
    console.log('Response Status:', response.status)
    console.log('Response Body:', JSON.stringify(result, null, 2))
    
    if (!response.ok) {
      console.error('FCM Error Details:', result)
      throw new Error(`Failed to send FCM notification: ${result.error?.message || 'Unknown error'}`)
    }
    
    if (result.name) {
      console.log('✅ FCM Message sent successfully with ID:', result.name)
    } else {
      console.warn('⚠️ FCM Response missing message ID')
    }
    
    // Mark notification as sent in Supabase
    if (result.name) {
      try {
        const notificationId = parseInt(result.name, 10)
        if (!isNaN(notificationId)) {
          await supabase
            .from('mosque_time_change_history')
            .update({ 
              notification_sent: true,
              notification_sent_at: new Date().toISOString()
            })
            .eq('id', notificationId)
        }
      } catch (updateError) {
        console.error('Error updating notification status:', updateError)
      }
    }
    
    return result
  } catch (error) {
    console.error('Error sending minimal FCM notification:', error)
    throw error
  }
}

// Main server function
serve(async (req) => {
  console.log('=== FCM Minimal Notification Function Called ===')
  console.log('Request Method:', req.method)
  console.log('Request URL:', req.url)
  
  // Check authorization
  const authHeader = req.headers.get('Authorization')
  console.log('Auth Header Present:', !!authHeader)
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.log('❌ Authorization failed')
    return new Response(
      JSON.stringify({ error: 'Unauthorized' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } }
    )
  }
  
  try {
    // Parse request body
    const requestBody = await req.json()
    console.log('Request Body:', JSON.stringify(requestBody, null, 2))
    
    const { 
      mosque_id, 
      mosque_name,
      mosque_latitude, // Now required in request body
      mosque_longitude, // Now required in request body
      prayer_name, 
      time_type,
      adjustment_minutes, 
      previous_adjustment, 
      change_source,
      effective_date,
      notification_id 
    } = requestBody
    
    // Validate required fields including coordinates
    if (!mosque_id || !mosque_name || !prayer_name || adjustment_minutes === undefined || 
        mosque_latitude === undefined || mosque_longitude === undefined) {
      console.log('❌ Missing required fields:', { 
        mosque_id, mosque_name, prayer_name, adjustment_minutes, mosque_latitude, mosque_longitude 
      })
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields: mosque_id, mosque_name, prayer_name, adjustment_minutes, mosque_latitude, mosque_longitude' 
        }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }
    
    console.log('✅ Request validation passed')
    console.log('Processing notification with mosque info:', { 
      mosque_id, 
      mosque_name,
      coordinates: `${mosque_latitude}, ${mosque_longitude}`,
      prayer_name, 
      time_type: time_type || 'adhan',
      adjustment_minutes,
      change_source: change_source || 'user'
    })
    
    // Send the minimal FCM notification with mosque info - device will do all processing
    const result = await sendMinimalFcmNotification({
      mosqueId: mosque_id,
      mosqueName: mosque_name,
      mosqueLatitude: mosque_latitude,
      mosqueLongitude: mosque_longitude,
      prayerName: prayer_name,
      timeType: time_type || 'adhan',
      adjustmentMinutes: adjustment_minutes,
      previousAdjustment: previous_adjustment,
      changeSource: change_source || 'user',
      effectiveDate: effective_date
    })
    
    // Update notification status in Supabase if notification_id is provided
    if (notification_id) {
      try {
        await supabase
          .from('mosque_time_change_history')
          .update({ 
            notification_sent: true,
            notification_sent_at: new Date().toISOString()
          })
          .eq('id', notification_id)
      } catch (updateError) {
        console.error('Error updating notification status (non-critical):', updateError)
        // Don't fail the notification if this update fails
      }
    }
    
    return new Response(
      JSON.stringify({ success: true, result, message: 'Enhanced FCM notification sent with mosque info - device will process' }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Function error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
}) 
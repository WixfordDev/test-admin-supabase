const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const { createClient } = require("@supabase/supabase-js");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

/**
 * Sends a notification to all users subscribed to a mosque's updates
 * Triggered by a Supabase webhook when mosque_adjustments table is updated
 */
exports.sendMosqueUpdateNotification = functions.https.onRequest(async (req, res) => {
  try {
    // Verify request is from Supabase webhook
    const authHeader = req.get("Authorization");
    if (!authHeader || authHeader !== `Bearer ${process.env.WEBHOOK_SECRET}`) {
      console.error("Invalid authorization token");
      return res.status(403).send("Unauthorized");
    }

    // Get data from request body
    const { mosque_id, prayer_name, adjustment_minutes, updated_by } = req.body;
    
    if (!mosque_id || !prayer_name) {
      return res.status(400).send("Missing required parameters");
    }

    // Get mosque details from Supabase
    const { data: mosqueData, error: mosqueError } = await supabase
      .from("mosques_metadata")
      .select("name")
      .eq("mosque_id", mosque_id)
      .single();

    if (mosqueError) {
      console.error("Error fetching mosque data:", mosqueError);
      return res.status(500).send("Failed to fetch mosque data");
    }

    const mosqueName = mosqueData?.name || "Mosque";

    // Get updated prayer time
    const { data: prayerTimeData, error: prayerTimeError } = await supabase.rpc(
      "get_adjusted_prayer_time",
      { 
        mosque_id_param: mosque_id,
        prayer_name_param: prayer_name
      }
    );

    if (prayerTimeError) {
      console.error("Error getting prayer time:", prayerTimeError);
      return res.status(500).send("Failed to get prayer time");
    }

    const newTime = prayerTimeData?.formatted_time || "updated time";
    const isVerified = true; // User-verified time

    // Determine appropriate message
    const title = `${mosqueName} Prayer Time Updated`;
    const body = isVerified
      ? `${prayer_name} Prayer/Iqamah Time changed. Verified Time: ${newTime}`
      : `${prayer_name} prayer time changes from tomorrow! Predicted to be at ${newTime}`;

    // Send FCM notification to topic
    const message = {
      notification: {
        title,
        body
      },
      data: {
        mosque_id: mosque_id,
        prayer_name: prayer_name,
        time: newTime,
        is_verified: String(isVerified)
      },
      topic: `mosque_${mosque_id}`
    };

    await admin.messaging().send(message);
    
    // Log the notification
    await admin.firestore().collection("notification_logs").add({
      mosque_id,
      prayer_name,
      message_title: title,
      message_body: body,
      sent_at: FieldValue.serverTimestamp(),
      sent_by: updated_by
    });

    console.log(`Notification sent to topic mosque_${mosque_id}`);
    return res.status(200).send("Notification sent successfully");
  } catch (error) {
    console.error("Error sending notification:", error);
    return res.status(500).send("Internal server error");
  }
});

/**
 * Verifies that the mosque time change is significant enough to send a notification
 * Only sends notifications for changes of 5 minutes or more for predicted times
 */
exports.processTimeChange = functions.https.onRequest(async (req, res) => {
  try {
    // Verify request is from Supabase webhook
    const authHeader = req.get("Authorization");
    if (!authHeader || authHeader !== `Bearer ${process.env.WEBHOOK_SECRET}`) {
      console.error("Invalid authorization token");
      return res.status(403).send("Unauthorized");
    }

    // Get data from request body
    const { mosque_id, prayer_name, previous_time, new_time, is_user_verified } = req.body;
    
    if (!mosque_id || !prayer_name || !new_time) {
      return res.status(400).send("Missing required parameters");
    }

    // If user verified, always send notification
    if (is_user_verified) {
      // Call the sendMosqueUpdateNotification endpoint
      const notificationResult = await fetch(
        `${process.env.FUNCTION_BASE_URL}/sendMosqueUpdateNotification`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${process.env.WEBHOOK_SECRET}`
          },
          body: JSON.stringify(req.body)
        }
      );
      
      if (!notificationResult.ok) {
        console.error("Failed to send notification:", await notificationResult.text());
        return res.status(500).send("Failed to send notification");
      }
      
      return res.status(200).send("Notification sent for user-verified change");
    }
    
    // For prediction changes, only send if the difference is 5 minutes or more
    if (previous_time && new_time) {
      const prevTimeDate = new Date(`1970-01-01T${previous_time}Z`);
      const newTimeDate = new Date(`1970-01-01T${new_time}Z`);
      
      const diffInMinutes = Math.abs(
        (newTimeDate.getTime() - prevTimeDate.getTime()) / (60 * 1000)
      );
      
      if (diffInMinutes >= 5) {
        // Call the sendMosqueUpdateNotification endpoint
        const notificationResult = await fetch(
          `${process.env.FUNCTION_BASE_URL}/sendMosqueUpdateNotification`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${process.env.WEBHOOK_SECRET}`
            },
            body: JSON.stringify(req.body)
          }
        );
        
        if (!notificationResult.ok) {
          console.error("Failed to send notification:", await notificationResult.text());
          return res.status(500).send("Failed to send notification");
        }
        
        return res.status(200).send("Notification sent for significant time change");
      } else {
        console.log(`Time change of ${diffInMinutes} minutes is less than threshold of 5 minutes. No notification sent.`);
        return res.status(200).send("Change not significant enough for notification");
      }
    }
    
    return res.status(400).send("Invalid time format");
  } catch (error) {
    console.error("Error processing time change:", error);
    return res.status(500).send("Internal server error");
  }
}); 
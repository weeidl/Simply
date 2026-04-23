package com.weeidl.simply

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "simply/device_runtime"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getRuntimeInfo" -> result.success(getRuntimeInfo())
                    else -> result.notImplemented()
                }
            }
    }

    private fun getRuntimeInfo(): Map<String, Any?> {
        val hasPhonePermission = hasAnyPhonePermission()
        if (!hasPhonePermission) {
            return mapOf(
                "sim_count" to null,
                "active_sim_slot" to null,
                "sim_cards" to emptyList<Map<String, Any?>>(),
            )
        }

        return try {
            val subscriptionManager = getSystemService(
                Context.TELEPHONY_SUBSCRIPTION_SERVICE
            ) as SubscriptionManager
            val activeDataSubscriptionId =
                SubscriptionManager.getActiveDataSubscriptionId()
            val subscriptions = subscriptionManager.activeSubscriptionInfoList ?: emptyList()
            val simCards = subscriptions.mapNotNull { info ->
                val slotIndex = info.simSlotIndex
                if (slotIndex < 0) {
                    null
                } else {
                    mapOf(
                        "slot" to slotIndex + 1,
                        "subscription_id" to info.subscriptionId,
                        "carrier_name" to info.carrierName?.toString(),
                        "display_name" to info.displayName?.toString(),
                        "is_active" to (info.subscriptionId == activeDataSubscriptionId),
                    )
                }
            }
            val activeCard = simCards.firstOrNull { it["is_active"] == true }
            val activeSlot = when {
                activeCard != null -> activeCard["slot"]
                simCards.size == 1 -> simCards.first()["slot"]
                else -> null
            }

            mapOf(
                "sim_count" to simCards.size,
                "active_sim_slot" to activeSlot,
                "sim_cards" to simCards,
            )
        } catch (_: SecurityException) {
            mapOf(
                "sim_count" to null,
                "active_sim_slot" to null,
                "sim_cards" to emptyList<Map<String, Any?>>(),
            )
        }
    }

    private fun hasAnyPhonePermission(): Boolean {
        val permissions = buildList {
            add(Manifest.permission.READ_PHONE_STATE)
            add(Manifest.permission.READ_PHONE_NUMBERS)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                add(Manifest.permission.READ_BASIC_PHONE_STATE)
            }
        }
        return permissions.any { permission ->
            ContextCompat.checkSelfPermission(
                this,
                permission,
            ) == PackageManager.PERMISSION_GRANTED
        }
    }
}

// android/app/src/main/kotlin/com/example/quick_call/widget/SpeedDialWidgetProvider3x2.kt
package com.example.quick_call.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import com.example.quick_call.R
import org.json.JSONArray

/**
 * Quick Call 3×2 위젯 Provider (6개 버튼)
 */
class SpeedDialWidgetProvider3x2 : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "QuickCallWidgetPrefs"
        private const val PREF_PREFIX = "widget_data_3x2_"
        private const val PREF_ALL_BUTTONS = "all_buttons_data"
        private const val ACTION_CALL = "com.example.quick_call.ACTION_CALL_3X2"
        private const val EXTRA_PHONE_NUMBER = "phone_number"
        private const val MAX_BUTTONS = 6
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_speed_dial_3x2)
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonData = prefs.getString("$PREF_PREFIX$appWidgetId", null)
            
            if (jsonData != null && jsonData.isNotEmpty()) {
                try {
                    val buttons = WidgetUtils.parseButtonData(jsonData, MAX_BUTTONS)
                    
                    if (buttons.isNotEmpty()) {
                        views.setViewVisibility(R.id.empty_message, View.GONE)
                        
                        val buttonIds = listOf(
                            Triple(R.id.button_1, R.id.icon_1, R.id.name_1),
                            Triple(R.id.button_2, R.id.icon_2, R.id.name_2),
                            Triple(R.id.button_3, R.id.icon_3, R.id.name_3),
                            Triple(R.id.button_4, R.id.icon_4, R.id.name_4),
                            Triple(R.id.button_5, R.id.icon_5, R.id.name_5),
                            Triple(R.id.button_6, R.id.icon_6, R.id.name_6)
                        )
                        
                        for ((index, ids) in buttonIds.withIndex()) {
                            if (index < buttons.size) {
                                WidgetUtils.setupButton(context, views, ids, buttons[index], ACTION_CALL)
                            } else {
                                views.setViewVisibility(ids.first, View.INVISIBLE)
                            }
                        }
                    } else {
                        showEmptyState(views)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    showEmptyState(views)
                }
            } else {
                showEmptyState(views)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        
        private fun showEmptyState(views: RemoteViews) {
            views.setViewVisibility(R.id.empty_message, View.VISIBLE)
            for (i in 1..MAX_BUTTONS) {
                val buttonId = when(i) {
                    1 -> R.id.button_1
                    2 -> R.id.button_2
                    3 -> R.id.button_3
                    4 -> R.id.button_4
                    5 -> R.id.button_5
                    6 -> R.id.button_6
                    else -> R.id.button_1
                }
                views.setViewVisibility(buttonId, View.INVISIBLE)
            }
        }
        
        fun updateAllWidgets(context: Context) {
            val intent = Intent(context, SpeedDialWidgetProvider3x2::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, SpeedDialWidgetProvider3x2::class.java))
            
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        for (appWidgetId in appWidgetIds) {
            editor.remove("$PREF_PREFIX$appWidgetId")
        }
        editor.apply()
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_CALL) {
            val phoneNumber = intent.getStringExtra(EXTRA_PHONE_NUMBER)
            if (phoneNumber != null) {
                WidgetUtils.makePhoneCall(context, phoneNumber)
            }
        }
    }
}
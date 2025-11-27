// android/app/src/main/kotlin/com/example/quick_call/widget/SpeedDialWidgetProvider1x1.kt
package com.oceancode.quick_call.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import com.oceancode.quick_call.R
import org.json.JSONArray

/**
 * Quick Call 1×1 위젯 Provider (1개 버튼)
 */
class SpeedDialWidgetProvider1x1 : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "QuickCallWidgetPrefs"
        private const val PREF_PREFIX = "widget_data_1x1_"
        private const val PREF_ALL_BUTTONS = "all_buttons_data"
        private const val ACTION_CALL = "com.oceancode.quick_call.ACTION_CALL_1X1"
        private const val EXTRA_PHONE_NUMBER = "phone_number"
        private const val MAX_BUTTONS = 1
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_speed_dial_1x1)
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonData = prefs.getString("$PREF_PREFIX$appWidgetId", null)
            
            if (jsonData != null && jsonData.isNotEmpty()) {
                try {
                    val buttons = WidgetUtils.parseButtonData(jsonData, MAX_BUTTONS)
                    
                    if (buttons.isNotEmpty()) {
                        views.setViewVisibility(R.id.empty_message, View.GONE)
                        val button = buttons[0]
                        WidgetUtils.setupButton(
                            context, views, 
                            Quadruple(R.id.button_1, R.id.icon_1, R.id.name_1, R.id.phone_1), 
                            button, ACTION_CALL
                        )
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
            views.setViewVisibility(R.id.button_1, View.INVISIBLE)
        }
        
        fun updateAllWidgets(context: Context) {
            val intent = Intent(context, SpeedDialWidgetProvider1x1::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, SpeedDialWidgetProvider1x1::class.java))
            
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
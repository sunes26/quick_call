// android/app/src/main/kotlin/com/example/quick_call/widget/SpeedDialWidgetProvider.kt
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
import org.json.JSONObject

/**
 * Quick Call 홈 화면 위젯 Provider (위젯 ID별 독립 데이터 지원)
 */
class SpeedDialWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "QuickCallWidgetPrefs"
        private const val PREF_PREFIX = "widget_data_"  // 위젯 ID별 데이터
        private const val PREF_ALL_BUTTONS = "all_buttons_data"  // 전체 버튼 목록
        
        private const val ACTION_CALL = "com.example.quick_call.ACTION_CALL"
        private const val EXTRA_PHONE_NUMBER = "phone_number"
        
        /**
         * 특정 위젯 업데이트
         */
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_speed_dial)
            
            // 위젯 ID별 데이터 로드
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonData = prefs.getString("$PREF_PREFIX$appWidgetId", null)
            
            if (jsonData != null && jsonData.isNotEmpty()) {
                try {
                    val buttons = parseButtonData(jsonData)
                    
                    if (buttons.isNotEmpty()) {
                        views.setViewVisibility(R.id.empty_message, View.GONE)
                        
                        val buttonIds = listOf(
                            Triple(R.id.button_1, R.id.icon_1, R.id.name_1),
                            Triple(R.id.button_2, R.id.icon_2, R.id.name_2),
                            Triple(R.id.button_3, R.id.icon_3, R.id.name_3),
                            Triple(R.id.button_4, R.id.icon_4, R.id.name_4)
                        )
                        
                        for ((index, ids) in buttonIds.withIndex()) {
                            if (index < buttons.size) {
                                val button = buttons[index]
                                setupButton(context, views, ids, button)
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
        
        /**
         * 모든 위젯 강제 업데이트
         */
        fun updateAllWidgets(context: Context) {
            val intent = Intent(context, SpeedDialWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, SpeedDialWidgetProvider::class.java))
            
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        }
        
        /**
         * 버튼 설정
         */
        private fun setupButton(
            context: Context,
            views: RemoteViews,
            ids: Triple<Int, Int, Int>,
            button: WidgetButton
        ) {
            val (buttonId, iconId, nameId) = ids
            
            views.setViewVisibility(buttonId, View.VISIBLE)
            
            val icon = getIconFromCodePoint(button.iconCodePoint)
            views.setTextViewText(iconId, icon)
            views.setTextViewText(nameId, button.name)
            
            val intent = Intent(context, SpeedDialWidgetProvider::class.java).apply {
                action = ACTION_CALL
                putExtra(EXTRA_PHONE_NUMBER, button.phoneNumber)
                data = Uri.parse("tel:${button.phoneNumber}")
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                button.id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            views.setOnClickPendingIntent(buttonId, pendingIntent)
        }
        
        /**
         * 빈 상태 표시
         */
        private fun showEmptyState(views: RemoteViews) {
            views.setViewVisibility(R.id.empty_message, View.VISIBLE)
            views.setViewVisibility(R.id.button_1, View.INVISIBLE)
            views.setViewVisibility(R.id.button_2, View.INVISIBLE)
            views.setViewVisibility(R.id.button_3, View.INVISIBLE)
            views.setViewVisibility(R.id.button_4, View.INVISIBLE)
        }
        
        /**
         * JSON 데이터 파싱
         */
        private fun parseButtonData(jsonData: String): List<WidgetButton> {
            val buttons = mutableListOf<WidgetButton>()
            
            try {
                val jsonArray = JSONArray(jsonData)
                for (i in 0 until jsonArray.length().coerceAtMost(4)) {
                    val obj = jsonArray.getJSONObject(i)
                    buttons.add(
                        WidgetButton(
                            id = obj.getInt("id"),
                            name = obj.getString("name"),
                            phoneNumber = obj.getString("phoneNumber"),
                            iconCodePoint = obj.getInt("iconCodePoint"),
                            group = obj.optString("group", "일반")
                        )
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
            
            return buttons
        }
        
        /**
         * IconData codePoint를 이모지로 변환
         */
        private fun getIconFromCodePoint(codePoint: Int): String {
            return when (codePoint) {
                0xe0cd -> "👤"  // person
                0xe7fd -> "👨"  // man
                0xe7fe -> "👩"  // woman
                0xe7e9 -> "👨‍👩‍👧‍👦"  // people
                0xe0b6 -> "👴"  // elderly
                0xe7f8 -> "💼"  // business
                0xe0be -> "📞"  // phone
                0xe0b0 -> "📱"  // smartphone
                0xe325 -> "🚨"  // emergency
                0xe567 -> "💊"  // medical
                0xe558 -> "🏥"  // hospital
                0xe87d -> "❤️"  // favorite
                0xe87e -> "🧡"  // favorite_border
                0xe838 -> "⭐"  // star
                0xe83a -> "☆"  // star_border
                0xe88e -> "⭐"  // star_outline
                0xe0c9 -> "🏠"  // home
                0xe0da -> "💼"  // work
                0xe7e8 -> "🏢"  // business_center
                0xebcc -> "🎓"  // school
                0xe531 -> "🚗"  // car
                0xe532 -> "🚕"  // taxi
                0xe556 -> "🍴"  // restaurant
                0xe541 -> "☕"  // coffee
                0xe560 -> "🍕"  // pizza
                else -> "📞"
            }
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

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }
    
    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        
        // 위젯 삭제 시 해당 데이터도 삭제
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
                makePhoneCall(context, phoneNumber)
            }
        }
    }

    /**
     * 전화 걸기
     */
    private fun makePhoneCall(context: Context, phoneNumber: String) {
        try {
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$phoneNumber")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * 위젯 버튼 데이터 클래스
     */
    data class WidgetButton(
        val id: Int,
        val name: String,
        val phoneNumber: String,
        val iconCodePoint: Int,
        val group: String
    )
}
// android/app/src/main/kotlin/com/example/quick_call/widget/WidgetUtils.kt
package com.example.quick_call.widget

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

/**
 * 위젯 공통 유틸리티
 */
object WidgetUtils {
    
    /**
     * JSON 데이터 파싱
     */
    fun parseButtonData(jsonData: String, maxButtons: Int): List<WidgetButton> {
        val buttons = mutableListOf<WidgetButton>()
        
        try {
            val jsonArray = JSONArray(jsonData)
            for (i in 0 until jsonArray.length().coerceAtMost(maxButtons)) {
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
     * 버튼 설정 (이모지 아이콘)
     */
    fun setupButton(
        context: Context,
        views: RemoteViews,
        ids: Triple<Int, Int, Int>,
        button: WidgetButton,
        action: String
    ) {
        val (buttonId, iconId, nameId) = ids
        
        views.setViewVisibility(buttonId, android.view.View.VISIBLE)
        
        // 이모지 아이콘 설정
        val emoji = getIconFromCodePoint(button.iconCodePoint)
        views.setTextViewText(iconId, emoji)
        
        // 이름 설정
        views.setTextViewText(nameId, button.name)
        
        val intent = Intent(action).apply {
            putExtra("phone_number", button.phoneNumber)
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
     * 아이콘 코드포인트를 이모지로 변환
     */
    fun getIconFromCodePoint(codePoint: Int): String {
        return when (codePoint) {
            0xe0cd -> "👤"  // person
            0xe7fd -> "📞"  // phone
            0xe0b0 -> "👨"  // male
            0xe63e -> "👩"  // female
            0xe7ef -> "✉️"  // email
            0xe0b1 -> "👪"  // family
            0xe55c -> "❤️"  // favorite
            0xe8b6 -> "💼"  // work
            0xe88a -> "🏠"  // home
            0xe0ba -> "🎂"  // cake (birthday)
            0xe8d4 -> "🎓"  // school
            0xe531 -> "⭐"  // star
            0xe7f4 -> "📱"  // smartphone
            0xe0cf -> "🙂"  // face
            0xe7ff -> "📧"  // email
            0xe0b9 -> "👶"  // child
            0xe8f4 -> "🚗"  // car
            0xe55f -> "🍴"  // restaurant
            0xe0da -> "🎮"  // games
            0xe8cd -> "💪"  // fitness
            0xe157 -> "🏥"  // local_hospital
            0xe0e0 -> "📚"  // book
            0xe8b8 -> "🏢"  // business
            0xe7e9 -> "🔔"  // notifications
            0xe87c -> "🎵"  // music
            else -> "📞"    // 기본값: 전화 아이콘
        }
    }
    
    /**
     * 전화 걸기
     */
    fun makePhoneCall(context: Context, phoneNumber: String) {
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
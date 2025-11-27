// android/app/src/main/kotlin/com/example/quick_call/MainActivity.kt
package com.oceancode.quick_call

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.oceancode.quick_call.widget.SpeedDialWidgetProvider1x1
import com.oceancode.quick_call.widget.SpeedDialWidgetProvider2x3
import com.oceancode.quick_call.widget.SpeedDialWidgetProvider3x2

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.oceancode.quick_call/widget"
    private val PREFS_NAME = "QuickCallWidgetPrefs"
    private val PREF_ALL_BUTTONS = "all_buttons_data"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // 전체 버튼 데이터 저장 (위젯 설정 화면에서 사용)
                "saveAllButtonsData" -> {
                    try {
                        val data = call.argument<String>("data")
                        if (data != null) {
                            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            prefs.edit().putString(PREF_ALL_BUTTONS, data).apply()
                            result.success(true)
                        } else {
                            result.error("INVALID_DATA", "Data is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, null)
                    }
                }
                
                // 특정 위젯의 데이터 저장 (앱에서 위젯 업데이트용)
                "updateWidgetData" -> {
                    try {
                        val widgetId = call.argument<Int>("widgetId")
                        val data = call.argument<String>("data")
                        
                        if (widgetId != null && data != null) {
                            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            
                            // 위젯 타입 확인하여 적절한 키로 저장
                            val appWidgetManager = AppWidgetManager.getInstance(this)
                            val provider1x1Ids = appWidgetManager.getAppWidgetIds(
                                ComponentName(this, SpeedDialWidgetProvider1x1::class.java)
                            )
                            val provider2x3Ids = appWidgetManager.getAppWidgetIds(
                                ComponentName(this, SpeedDialWidgetProvider2x3::class.java)
                            )
                            val provider3x2Ids = appWidgetManager.getAppWidgetIds(
                                ComponentName(this, SpeedDialWidgetProvider3x2::class.java)
                            )
                            
                            when {
                                provider1x1Ids.contains(widgetId) -> {
                                    prefs.edit().putString("widget_data_1x1_$widgetId", data).apply()
                                    SpeedDialWidgetProvider1x1.updateAppWidget(this, appWidgetManager, widgetId)
                                }
                                provider2x3Ids.contains(widgetId) -> {
                                    prefs.edit().putString("widget_data_2x3_$widgetId", data).apply()
                                    SpeedDialWidgetProvider2x3.updateAppWidget(this, appWidgetManager, widgetId)
                                }
                                provider3x2Ids.contains(widgetId) -> {
                                    prefs.edit().putString("widget_data_3x2_$widgetId", data).apply()
                                    SpeedDialWidgetProvider3x2.updateAppWidget(this, appWidgetManager, widgetId)
                                }
                            }
                            
                            result.success(true)
                        } else {
                            result.error("INVALID_DATA", "Widget ID or data is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("UPDATE_ERROR", e.message, null)
                    }
                }
                
                // 모든 위젯 새로고침
                "refreshAllWidgets" -> {
                    try {
                        SpeedDialWidgetProvider1x1.updateAllWidgets(this)
                        SpeedDialWidgetProvider2x3.updateAllWidgets(this)
                        SpeedDialWidgetProvider3x2.updateAllWidgets(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("REFRESH_ERROR", e.message, null)
                    }
                }
                
                // 설치된 위젯 ID 목록 가져오기 (3개 Provider 모두)
                "getWidgetIds" -> {
                    try {
                        val appWidgetManager = AppWidgetManager.getInstance(this)
                        
                        val ids1x1 = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider1x1::class.java)
                        )
                        val ids2x3 = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider2x3::class.java)
                        )
                        val ids3x2 = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider3x2::class.java)
                        )
                        
                        val allIds = ids1x1.toList() + ids2x3.toList() + ids3x2.toList()
                        result.success(allIds)
                    } catch (e: Exception) {
                        result.error("GET_IDS_ERROR", e.message, null)
                    }
                }
                
                // 특정 위젯의 데이터 가져오기
                "getWidgetData" -> {
                    try {
                        val widgetId = call.argument<Int>("widgetId")
                        if (widgetId != null) {
                            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            
                            // 3개 키를 모두 확인
                            val data = prefs.getString("widget_data_1x1_$widgetId", null)
                                ?: prefs.getString("widget_data_2x3_$widgetId", null)
                                ?: prefs.getString("widget_data_3x2_$widgetId", null)
                            
                            result.success(data)
                        } else {
                            result.error("INVALID_ID", "Widget ID is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("GET_DATA_ERROR", e.message, null)
                    }
                }
                
                // 특정 위젯의 크기 정보 가져오기
                "getWidgetSize" -> {
                    try {
                        val widgetId = call.argument<Int>("widgetId")
                        if (widgetId != null) {
                            val appWidgetManager = AppWidgetManager.getInstance(this)
                            
                            // 위젯 타입 확인
                            val provider1x1Ids = appWidgetManager.getAppWidgetIds(
                                ComponentName(this, SpeedDialWidgetProvider1x1::class.java)
                            )
                            val provider2x3Ids = appWidgetManager.getAppWidgetIds(
                                ComponentName(this, SpeedDialWidgetProvider2x3::class.java)
                            )
                            val provider3x2Ids = appWidgetManager.getAppWidgetIds(
                                ComponentName(this, SpeedDialWidgetProvider3x2::class.java)
                            )
                            
                            val maxButtons = when {
                                provider1x1Ids.contains(widgetId) -> 1
                                provider2x3Ids.contains(widgetId) -> 6
                                provider3x2Ids.contains(widgetId) -> 6
                                else -> 4 // 기본값
                            }
                            
                            val sizeInfo = mapOf(
                                "width" to 180,
                                "height" to 180,
                                "maxButtons" to maxButtons
                            )
                            
                            result.success(sizeInfo)
                        } else {
                            result.error("INVALID_ID", "Widget ID is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("GET_SIZE_ERROR", e.message, null)
                    }
                }
                
                // 위젯이 있는지 확인
                "hasWidgets" -> {
                    try {
                        val appWidgetManager = AppWidgetManager.getInstance(this)
                        
                        val ids1x1 = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider1x1::class.java)
                        )
                        val ids2x3 = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider2x3::class.java)
                        )
                        val ids3x2 = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider3x2::class.java)
                        )
                        
                        val hasAnyWidget = ids1x1.isNotEmpty() || ids2x3.isNotEmpty() || ids3x2.isNotEmpty()
                        result.success(hasAnyWidget)
                    } catch (e: Exception) {
                        result.error("CHECK_ERROR", e.message, null)
                    }
                }
                
                // 모든 위젯 데이터 삭제
                "clearAllWidgets" -> {
                    try {
                        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        val editor = prefs.edit()
                        
                        // 모든 widget_data_* 키 삭제
                        val allKeys = prefs.all.keys
                        for (key in allKeys) {
                            if (key.startsWith("widget_data_")) {
                                editor.remove(key)
                            }
                        }
                        
                        editor.apply()
                        
                        // 모든 위젯 새로고침
                        SpeedDialWidgetProvider1x1.updateAllWidgets(this)
                        SpeedDialWidgetProvider2x3.updateAllWidgets(this)
                        SpeedDialWidgetProvider3x2.updateAllWidgets(this)
                        
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CLEAR_ERROR", e.message, null)
                    }
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
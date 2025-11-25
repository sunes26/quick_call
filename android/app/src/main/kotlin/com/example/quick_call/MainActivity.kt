// android/app/src/main/kotlin/com/example/quick_call/MainActivity.kt
package com.example.quick_call

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.quick_call.widget.SpeedDialWidgetProvider

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.quick_call/widget"
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
                            prefs.edit().putString("widget_data_$widgetId", data).apply()
                            
                            // 해당 위젯만 업데이트
                            val appWidgetManager = AppWidgetManager.getInstance(this)
                            SpeedDialWidgetProvider.updateAppWidget(this, appWidgetManager, widgetId)
                            
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
                        SpeedDialWidgetProvider.updateAllWidgets(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("REFRESH_ERROR", e.message, null)
                    }
                }
                
                // 설치된 위젯 ID 목록 가져오기
                "getWidgetIds" -> {
                    try {
                        val appWidgetManager = AppWidgetManager.getInstance(this)
                        val ids = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider::class.java)
                        )
                        result.success(ids.toList())
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
                            val data = prefs.getString("widget_data_$widgetId", null)
                            result.success(data)
                        } else {
                            result.error("INVALID_ID", "Widget ID is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("GET_DATA_ERROR", e.message, null)
                    }
                }
                
                // 위젯이 있는지 확인
                "hasWidgets" -> {
                    try {
                        val appWidgetManager = AppWidgetManager.getInstance(this)
                        val ids = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, SpeedDialWidgetProvider::class.java)
                        )
                        result.success(ids.isNotEmpty())
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
                        SpeedDialWidgetProvider.updateAllWidgets(this)
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
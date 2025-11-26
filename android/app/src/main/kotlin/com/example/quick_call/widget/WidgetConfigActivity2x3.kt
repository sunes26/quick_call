package com.example.quick_call.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.TextView
import androidx.cardview.widget.CardView
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.quick_call.R
import org.json.JSONArray
import org.json.JSONObject

/**
 * 2×3 위젯 설정 Activity (6개 버튼 선택)
 */
class WidgetConfigActivity2x3 : Activity() {
    
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private val maxButtons = 6
    private val selectedButtons = mutableListOf<WidgetButton>()
    private val allButtons = mutableListOf<WidgetButton>()
    
    private lateinit var allButtonsAdapter: SimpleAllButtonsAdapter2x3
    private lateinit var recyclerAll: RecyclerView
    private lateinit var btnSave: Button
    private lateinit var btnCancel: Button
    private lateinit var selectedInfo: TextView
    private lateinit var emptyState: View
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setResult(RESULT_CANCELED)
        
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        
        setContentView(R.layout.activity_widget_config_simple)
        
        recyclerAll = findViewById(R.id.recycler_all_buttons)
        btnSave = findViewById(R.id.btn_save)
        btnCancel = findViewById(R.id.btn_cancel)
        selectedInfo = findViewById(R.id.selected_info)
        emptyState = findViewById(R.id.empty_state)
        
        loadAllButtons()
        setupAdapters()
        
        btnSave.setOnClickListener { saveConfiguration() }
        btnCancel.setOnClickListener { finish() }
        
        updateUI()
    }
    
    private fun loadAllButtons() {
        val prefs = getSharedPreferences("QuickCallWidgetPrefs", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("all_buttons_data", null)
        
        if (jsonString != null && jsonString.isNotEmpty()) {
            try {
                val jsonArray = JSONArray(jsonString)
                allButtons.clear()
                
                for (i in 0 until jsonArray.length()) {
                    val json = jsonArray.getJSONObject(i)
                    allButtons.add(WidgetButton(
                        id = json.getInt("id"),
                        name = json.getString("name"),
                        phoneNumber = json.getString("phoneNumber"),
                        iconCodePoint = json.getInt("iconCodePoint"),
                        group = json.optString("group", "")
                    ))
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    private fun setupAdapters() {
        allButtonsAdapter = SimpleAllButtonsAdapter2x3(allButtons, selectedButtons, maxButtons) { button ->
            if (selectedButtons.any { it.id == button.id }) {
                selectedButtons.removeAll { it.id == button.id }
            } else {
                if (selectedButtons.size < maxButtons) {
                    selectedButtons.add(button)
                }
            }
            allButtonsAdapter.notifyDataSetChanged()
            updateUI()
        }
        
        recyclerAll.apply {
            layoutManager = GridLayoutManager(this@WidgetConfigActivity2x3, 3)
            adapter = allButtonsAdapter
        }
    }
    
    private fun updateUI() {
        // 빈 상태 표시
        if (allButtons.isEmpty()) {
            emptyState.visibility = View.VISIBLE
            recyclerAll.visibility = View.GONE
            selectedInfo.text = "앱에서 버튼을 먼저 추가하세요"
            btnSave.isEnabled = false
            btnSave.alpha = 0.5f
            return
        } else {
            emptyState.visibility = View.GONE
            recyclerAll.visibility = View.VISIBLE
        }
        
        selectedInfo.text = "선택: ${selectedButtons.size} / $maxButtons"
        
        btnSave.isEnabled = selectedButtons.isNotEmpty()
        btnSave.alpha = if (selectedButtons.isNotEmpty()) 1.0f else 0.5f
    }
    
    private fun saveConfiguration() {
        val jsonArray = JSONArray()
        selectedButtons.forEach { button ->
            jsonArray.put(JSONObject().apply {
                put("id", button.id)
                put("name", button.name)
                put("phoneNumber", button.phoneNumber)
                put("iconCodePoint", button.iconCodePoint)
                put("group", button.group)
            })
        }
        
        val prefs = getSharedPreferences("QuickCallWidgetPrefs", Context.MODE_PRIVATE)
        prefs.edit().putString("widget_data_2x3_$appWidgetId", jsonArray.toString()).apply()
        
        val appWidgetManager = AppWidgetManager.getInstance(this)
        SpeedDialWidgetProvider2x3.updateAppWidget(this, appWidgetManager, appWidgetId)
        
        val resultValue = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_OK, resultValue)
        finish()
    }
}

class SimpleAllButtonsAdapter2x3(
    private val allButtons: List<WidgetButton>,
    private val selectedButtons: List<WidgetButton>,
    private val maxButtons: Int,
    private val onToggle: (WidgetButton) -> Unit
) : RecyclerView.Adapter<SimpleAllButtonsAdapter2x3.ViewHolder>() {
    
    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val cardView: CardView = view.findViewById(R.id.card_view)
        val selectionBackground: FrameLayout = view.findViewById(R.id.selection_background)
        val icon: TextView = view.findViewById(R.id.button_icon)
        val name: TextView = view.findViewById(R.id.button_name)
    }
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_widget_button_all, parent, false)
        return ViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val button = allButtons[position]
        val isSelected = selectedButtons.any { it.id == button.id }
        
        // 아이콘은 이모지로 이미 설정됨 (👤)
        holder.name.text = button.name
        
        // 선택 상태에 따라 배경 변경
        if (isSelected) {
            holder.selectionBackground.setBackgroundResource(R.drawable.widget_button_selected)
        } else {
            holder.selectionBackground.setBackgroundResource(R.drawable.widget_button_unselected)
        }
        
        // 최대 개수 도달 시 선택 불가능한 항목 처리
        val canSelect = isSelected || selectedButtons.size < maxButtons
        holder.cardView.alpha = if (canSelect) 1.0f else 0.5f
        
        // CardView에 클릭 리스너 설정
        holder.cardView.setOnClickListener {
            if (canSelect || isSelected) {
                onToggle(button)
            }
        }
    }
    
    override fun getItemCount() = allButtons.size
}
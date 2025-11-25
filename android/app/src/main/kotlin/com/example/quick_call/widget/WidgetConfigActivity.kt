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
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import android.widget.CheckBox
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.ItemTouchHelper
import androidx.recyclerview.widget.RecyclerView
import com.example.quick_call.R
import org.json.JSONArray
import org.json.JSONObject
import java.util.Collections

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

/**
 * 위젯 설정 Activity
 * 위젯 추가 시 자동으로 실행되어 사용자가 버튼을 선택할 수 있도록 함
 */
class WidgetConfigActivity : Activity() {
    
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    
    // 선택된 버튼 리스트 (최대 4개)
    private val selectedButtons = mutableListOf<WidgetButton>()
    
    // 전체 버튼 리스트
    private val allButtons = mutableListOf<WidgetButton>()
    
    // RecyclerView 어댑터
    private lateinit var selectedAdapter: SelectedButtonsAdapter
    private lateinit var allButtonsAdapter: AllButtonsAdapter
    
    // Views
    private lateinit var recyclerSelected: RecyclerView
    private lateinit var recyclerAll: RecyclerView
    private lateinit var btnSave: Button
    private lateinit var emptyView: View
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 기본 결과를 CANCELED로 설정
        setResult(RESULT_CANCELED)
        
        // Intent에서 위젯 ID 가져오기
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        
        // 위젯 ID가 유효하지 않으면 Activity 종료
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        
        setContentView(R.layout.activity_widget_config)
        
        // View 초기화
        recyclerSelected = findViewById(R.id.recycler_selected_buttons)
        recyclerAll = findViewById(R.id.recycler_all_buttons)
        btnSave = findViewById(R.id.btn_save)
        emptyView = findViewById(R.id.empty_view)
        
        // 데이터 로드
        loadAllButtons()
        
        // RecyclerView 설정
        setupAdapters()
        
        // 저장 버튼 클릭
        btnSave.setOnClickListener {
            saveConfiguration()
        }
        
        // UI 업데이트
        updateUI()
    }
    
    /**
     * SharedPreferences에서 전체 버튼 데이터 로드
     */
    private fun loadAllButtons() {
        val prefs = getSharedPreferences("QuickCallWidgetPrefs", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("all_buttons_data", null) ?: return
        
        try {
            val jsonArray = JSONArray(jsonString)
            allButtons.clear()
            
            for (i in 0 until jsonArray.length()) {
                val json = jsonArray.getJSONObject(i)
                val button = WidgetButton(
                    id = json.getInt("id"),
                    name = json.getString("name"),
                    phoneNumber = json.getString("phoneNumber"),
                    iconCodePoint = json.getInt("iconCodePoint"),
                    group = json.optString("group", "")
                )
                allButtons.add(button)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    /**
     * 버튼 선택 추가
     */
    private fun addButton(button: WidgetButton) {
        if (selectedButtons.size >= 4) {
            // 최대 4개까지만 선택 가능
            return
        }
        
        if (!selectedButtons.any { it.id == button.id }) {
            selectedButtons.add(button)
            selectedAdapter.notifyDataSetChanged()
            allButtonsAdapter.notifyDataSetChanged()
            updateUI()
        }
    }
    
    /**
     * 버튼 선택 제거
     */
    private fun removeButton(button: WidgetButton) {
        selectedButtons.removeAll { it.id == button.id }
        selectedAdapter.notifyDataSetChanged()
        allButtonsAdapter.notifyDataSetChanged()
        updateUI()
    }
    
    /**
     * RecyclerView 어댑터 설정
     */
    private fun setupAdapters() {
        // 선택된 버튼 RecyclerView (2열 그리드, 드래그 가능)
        selectedAdapter = SelectedButtonsAdapter(selectedButtons) { button ->
            removeButton(button)
        }
        
        recyclerSelected.apply {
            layoutManager = GridLayoutManager(this@WidgetConfigActivity, 2)
            adapter = selectedAdapter
        }
        
        // 드래그 앤 드롭 설정
        val itemTouchHelper = ItemTouchHelper(object : ItemTouchHelper.SimpleCallback(
            ItemTouchHelper.UP or ItemTouchHelper.DOWN or 
            ItemTouchHelper.LEFT or ItemTouchHelper.RIGHT,
            0
        ) {
            override fun onMove(
                recyclerView: RecyclerView,
                viewHolder: RecyclerView.ViewHolder,
                target: RecyclerView.ViewHolder
            ): Boolean {
                val fromPosition = viewHolder.adapterPosition
                val toPosition = target.adapterPosition
                
                if (fromPosition < selectedButtons.size && toPosition < selectedButtons.size) {
                    Collections.swap(selectedButtons, fromPosition, toPosition)
                    selectedAdapter.notifyItemMoved(fromPosition, toPosition)
                }
                
                return true
            }
            
            override fun onSwiped(viewHolder: RecyclerView.ViewHolder, direction: Int) {
                // 스와이프는 사용하지 않음
            }
        })
        
        itemTouchHelper.attachToRecyclerView(recyclerSelected)
        
        // 전체 버튼 RecyclerView (3열 그리드)
        allButtonsAdapter = AllButtonsAdapter(
            allButtons,
            selectedButtons
        ) { button ->
            if (selectedButtons.any { it.id == button.id }) {
                removeButton(button)
            } else {
                addButton(button)
            }
        }
        
        recyclerAll.apply {
            layoutManager = GridLayoutManager(this@WidgetConfigActivity, 3)
            adapter = allButtonsAdapter
        }
    }
    
    /**
     * UI 업데이트
     */
    private fun updateUI() {
        // 저장 버튼 활성화/비활성화
        btnSave.isEnabled = selectedButtons.isNotEmpty()
        
        // 빈 상태 표시
        if (allButtons.isEmpty()) {
            emptyView.visibility = View.VISIBLE
            recyclerAll.visibility = View.GONE
        } else {
            emptyView.visibility = View.GONE
            recyclerAll.visibility = View.VISIBLE
        }
    }
    
    /**
     * 설정 저장
     */
    private fun saveConfiguration() {
        // 선택된 버튼을 JSON으로 변환
        val jsonArray = JSONArray()
        selectedButtons.forEach { button ->
            val json = JSONObject().apply {
                put("id", button.id)
                put("name", button.name)
                put("phoneNumber", button.phoneNumber)
                put("iconCodePoint", button.iconCodePoint)
                put("group", button.group)
            }
            jsonArray.put(json)
        }
        
        // SharedPreferences에 저장
        val prefs = getSharedPreferences("QuickCallWidgetPrefs", Context.MODE_PRIVATE)
        prefs.edit()
            .putString("widget_data_$appWidgetId", jsonArray.toString())
            .apply()
        
        // 위젯 업데이트
        val appWidgetManager = AppWidgetManager.getInstance(this)
        SpeedDialWidgetProvider.updateAppWidget(
            this,
            appWidgetManager,
            appWidgetId
        )
        
        // 결과 반환
        val resultValue = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_OK, resultValue)
        finish()
    }
}

/**
 * 선택된 버튼 어댑터
 */
class SelectedButtonsAdapter(
    private val buttons: List<WidgetButton>,
    private val onRemove: (WidgetButton) -> Unit
) : RecyclerView.Adapter<SelectedButtonsAdapter.ViewHolder>() {
    
    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val icon: ImageView = view.findViewById(R.id.button_icon)
        val name: TextView = view.findViewById(R.id.button_name)
        val removeBtn: ImageButton = view.findViewById(R.id.btn_remove)
    }
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_widget_button_selected, parent, false)
        return ViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val button = buttons[position]
        holder.icon.setImageResource(getIconResource(button.iconCodePoint))
        holder.name.text = button.name
        
        holder.removeBtn.setOnClickListener {
            onRemove(button)
        }
    }
    
    override fun getItemCount() = buttons.size
    
    private fun getIconResource(codePoint: Int): Int {
        return when (codePoint) {
            0xe7fd -> android.R.drawable.ic_menu_call  // phone
            0xe7ef -> android.R.drawable.ic_dialog_email  // email
            else -> android.R.drawable.ic_menu_call
        }
    }
}

/**
 * 전체 버튼 어댑터
 */
class AllButtonsAdapter(
    private val allButtons: List<WidgetButton>,
    private val selectedButtons: List<WidgetButton>,
    private val onToggle: (WidgetButton) -> Unit
) : RecyclerView.Adapter<AllButtonsAdapter.ViewHolder>() {
    
    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val icon: ImageView = view.findViewById(R.id.button_icon)
        val name: TextView = view.findViewById(R.id.button_name)
        val checkbox: CheckBox = view.findViewById(R.id.checkbox)
    }
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_widget_button_all, parent, false)
        return ViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val button = allButtons[position]
        val isSelected = selectedButtons.any { it.id == button.id }
        
        holder.icon.setImageResource(getIconResource(button.iconCodePoint))
        holder.name.text = button.name
        holder.checkbox.isChecked = isSelected
        
        // 최대 4개 제한
        holder.itemView.isEnabled = isSelected || selectedButtons.size < 4
        holder.checkbox.isEnabled = isSelected || selectedButtons.size < 4
        
        holder.itemView.setOnClickListener {
            onToggle(button)
        }
    }
    
    override fun getItemCount() = allButtons.size
    
    private fun getIconResource(codePoint: Int): Int {
        return when (codePoint) {
            0xe7fd -> android.R.drawable.ic_menu_call  // phone
            0xe7ef -> android.R.drawable.ic_dialog_email  // email
            else -> android.R.drawable.ic_menu_call
        }
    }
}
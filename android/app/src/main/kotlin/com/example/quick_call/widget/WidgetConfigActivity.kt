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
 * 위젯 설정 Activity (기존 - 사용 안 함)
 * 새로운 3개 위젯 시스템에서는 사용하지 않습니다.
 */
class WidgetConfigActivity : Activity() {
    
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private var maxButtons = 4
    
    private val selectedButtons = mutableListOf<WidgetButton>()
    private val allButtons = mutableListOf<WidgetButton>()
    
    private lateinit var selectedAdapter: SelectedButtonsAdapter
    private lateinit var allButtonsAdapter: AllButtonsAdapter
    
    private lateinit var recyclerSelected: RecyclerView
    private lateinit var recyclerAll: RecyclerView
    private lateinit var btnSave: Button
    private lateinit var btnCancel: Button
    private lateinit var emptyView: View
    private lateinit var selectedCount: TextView
    private lateinit var maxCountText: TextView
    private lateinit var emptySelectedHint: TextView
    private lateinit var widgetSizeInfo: TextView
    
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
        
        maxButtons = 4
        
        setContentView(R.layout.activity_widget_config)
        
        recyclerSelected = findViewById(R.id.recycler_selected_buttons)
        recyclerAll = findViewById(R.id.recycler_all_buttons)
        btnSave = findViewById(R.id.btn_save)
        btnCancel = findViewById(R.id.btn_cancel)
        emptyView = findViewById(R.id.empty_view)
        selectedCount = findViewById(R.id.selected_count)
        maxCountText = findViewById(R.id.max_count_text)
        emptySelectedHint = findViewById(R.id.empty_selected_hint)
        widgetSizeInfo = findViewById(R.id.widget_size_info)
        
        maxCountText.text = " / $maxButtons"
        updateWidgetSizeInfo()
        
        loadAllButtons()
        setupAdapters()
        
        btnSave.setOnClickListener {
            saveConfiguration()
        }
        
        btnCancel.setOnClickListener {
            finish()
        }
        
        updateUI()
    }
    
    private fun updateWidgetSizeInfo() {
        widgetSizeInfo.text = "기존 위젯 (사용 안 함)"
    }
    
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
    
    private fun addButton(button: WidgetButton) {
        if (selectedButtons.size >= maxButtons) {
            return
        }
        
        if (!selectedButtons.any { it.id == button.id }) {
            selectedButtons.add(button)
            selectedAdapter.notifyDataSetChanged()
            allButtonsAdapter.notifyDataSetChanged()
            updateUI()
        }
    }
    
    private fun removeButton(button: WidgetButton) {
        selectedButtons.removeAll { it.id == button.id }
        selectedAdapter.notifyDataSetChanged()
        allButtonsAdapter.notifyDataSetChanged()
        updateUI()
    }
    
    private fun setupAdapters() {
        selectedAdapter = SelectedButtonsAdapter(selectedButtons) { button ->
            removeButton(button)
        }
        
        recyclerSelected.apply {
            layoutManager = GridLayoutManager(this@WidgetConfigActivity, 2)
            adapter = selectedAdapter
        }
        
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
            }
        })
        
        itemTouchHelper.attachToRecyclerView(recyclerSelected)
        
        allButtonsAdapter = AllButtonsAdapter(
            allButtons,
            selectedButtons,
            maxButtons
        ) { button ->
            if (selectedButtons.any { it.id == button.id }) {
                removeButton(button)
            } else {
                addButton(button)
            }
        }
        
        recyclerAll.apply {
            layoutManager = GridLayoutManager(this@WidgetConfigActivity, 2)
            adapter = allButtonsAdapter
        }
    }
    
    private fun updateUI() {
        selectedCount.text = selectedButtons.size.toString()
        
        btnSave.isEnabled = selectedButtons.isNotEmpty()
        btnSave.alpha = if (selectedButtons.isNotEmpty()) 1.0f else 0.5f
        
        if (selectedButtons.isEmpty()) {
            emptySelectedHint.visibility = View.VISIBLE
            emptySelectedHint.text = "최대 ${maxButtons}개 버튼 선택 가능"
            recyclerSelected.visibility = View.GONE
        } else {
            emptySelectedHint.visibility = View.GONE
            recyclerSelected.visibility = View.VISIBLE
        }
        
        if (allButtons.isEmpty()) {
            emptyView.visibility = View.VISIBLE
            recyclerAll.visibility = View.GONE
        } else {
            emptyView.visibility = View.GONE
            recyclerAll.visibility = View.VISIBLE
        }
    }
    
    private fun saveConfiguration() {
        finish()
    }
}

class SelectedButtonsAdapter(
    private val buttons: List<WidgetButton>,
    private val onRemove: (WidgetButton) -> Unit
) : RecyclerView.Adapter<SelectedButtonsAdapter.ViewHolder>() {
    
    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val icon: ImageView = view.findViewById(R.id.button_icon)
        val name: TextView = view.findViewById(R.id.button_name)
        val removeContainer: View = view.findViewById(R.id.btn_remove_container)
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
        
        holder.removeContainer.setOnClickListener {
            onRemove(button)
        }
    }
    
    override fun getItemCount() = buttons.size
    
    private fun getIconResource(codePoint: Int): Int {
        return when (codePoint) {
            0xe7fd -> android.R.drawable.ic_menu_call
            0xe7ef -> android.R.drawable.ic_dialog_email
            else -> android.R.drawable.ic_menu_call
        }
    }
}

class AllButtonsAdapter(
    private val allButtons: List<WidgetButton>,
    private val selectedButtons: List<WidgetButton>,
    private val maxButtons: Int,
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
        
        val canSelect = isSelected || selectedButtons.size < maxButtons
        holder.itemView.isEnabled = canSelect
        holder.itemView.alpha = if (canSelect) 1.0f else 0.5f
        
        holder.itemView.setOnClickListener {
            if (canSelect) {
                onToggle(button)
            }
        }
    }
    
    override fun getItemCount() = allButtons.size
    
    private fun getIconResource(codePoint: Int): Int {
        return when (codePoint) {
            0xe7fd -> android.R.drawable.ic_menu_call
            0xe7ef -> android.R.drawable.ic_dialog_email
            else -> android.R.drawable.ic_menu_call
        }
    }
}
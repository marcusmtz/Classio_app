package com.example.classio_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.util.Log

class ClassioWidgetProvider : AppWidgetProvider() {
    
    companion object {
        private const val TAG = "ClassioWidget"
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")
        
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.classio_widget).apply {
                    val widgetData = HomeWidgetPlugin.getData(context)
                    
                    Log.d(TAG, "Widget data: $widgetData")
                    
                    // Última actualización
                    val lastUpdate = widgetData.getString("last_update", null)
                    if (lastUpdate != null) {
                        setTextViewText(R.id.last_update, lastUpdate)
                    } else {
                        setTextViewText(R.id.last_update, "--:--")
                    }
                    
                    // Clase actual
                    val hasCurrentClass = widgetData.getBoolean("has_current_class", false)
                    Log.d(TAG, "Has current class: $hasCurrentClass")
                    
                    if (hasCurrentClass) {
                        setViewVisibility(R.id.current_class_container, View.VISIBLE)
                        setViewVisibility(R.id.empty_state, View.GONE)
                        
                        setTextViewText(
                            R.id.current_class_course,
                            widgetData.getString("current_class_course", "")
                        )
                        setTextViewText(
                            R.id.current_class_time,
                            widgetData.getString("current_class_time", "")
                        )
                        setTextViewText(
                            R.id.current_class_location,
                            widgetData.getString("current_class_location", "")
                        )
                    } else {
                        setViewVisibility(R.id.current_class_container, View.GONE)
                    }
                    
                    // Próxima clase
                    val hasNextClass = widgetData.getBoolean("has_next_class", false)
                    Log.d(TAG, "Has next class: $hasNextClass")
                    
                    if (hasNextClass) {
                        setViewVisibility(R.id.next_class_container, View.VISIBLE)
                        setViewVisibility(R.id.empty_state, View.GONE)
                        
                        setTextViewText(
                            R.id.next_class_course,
                            widgetData.getString("next_class_course", "")
                        )
                        setTextViewText(
                            R.id.next_class_day,
                            widgetData.getString("next_class_day", "")
                        )
                        setTextViewText(
                            R.id.next_class_time,
                            widgetData.getString("next_class_time", "")
                        )
                    } else {
                        setViewVisibility(R.id.next_class_container, View.GONE)
                    }
                    
                    // Próxima evaluación
                    val hasEvaluation = widgetData.getBoolean("has_evaluation", false)
                    Log.d(TAG, "Has evaluation: $hasEvaluation")
                    
                    if (hasEvaluation) {
                        setViewVisibility(R.id.evaluation_container, View.VISIBLE)
                        setViewVisibility(R.id.empty_state, View.GONE)
                        
                        setTextViewText(
                            R.id.evaluation_course,
                            widgetData.getString("evaluation_course", "")
                        )
                        setTextViewText(
                            R.id.evaluation_title,
                            widgetData.getString("evaluation_title", "")
                        )
                        setTextViewText(
                            R.id.evaluation_days,
                            widgetData.getString("evaluation_days", "")
                        )
                        setTextViewText(
                            R.id.evaluation_date,
                            widgetData.getString("evaluation_date", "")
                        )
                    } else {
                        setViewVisibility(R.id.evaluation_container, View.GONE)
                    }
                    
                    // Mostrar empty state si no hay nada
                    if (!hasCurrentClass && !hasNextClass && !hasEvaluation) {
                        setViewVisibility(R.id.empty_state, View.VISIBLE)
                        Log.d(TAG, "Showing empty state")
                    }
                    
                    // Click listener para abrir la app
                    val intent = android.content.Intent(context, MainActivity::class.java)
                    val pendingIntent = android.app.PendingIntent.getActivity(
                        context,
                        0,
                        intent,
                        android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                }
                
                appWidgetManager.updateAppWidget(widgetId, views)
                Log.d(TAG, "Widget $widgetId updated successfully")
                
            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget $widgetId", e)
            }
        }
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "Widget enabled - first instance added")
    }
    
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "Widget disabled - last instance removed")
    }
}


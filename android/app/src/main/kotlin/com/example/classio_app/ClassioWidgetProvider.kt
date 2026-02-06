package com.example.classio_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class ClassioWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.classio_widget).apply {
                val widgetData = HomeWidgetPlugin.getData(context)
                
                // Última actualización
                val lastUpdate = widgetData.getString("last_update", "--:--")
                setTextViewText(R.id.last_update, lastUpdate)
                
                // Clase actual
                val hasCurrentClass = widgetData.getBoolean("has_current_class", false)
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
                }
                
                // Click listener para abrir la app
                val intent = android.content.Intent(context, MainActivity::class.java)
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.empty_state, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

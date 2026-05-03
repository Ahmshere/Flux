package com.converter.whitefox.cur_converter

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class FluxRateWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val data  = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName,
                R.layout.flux_rate_widget)

            val fromFlag  = data.getString("from_flag",  "🇺🇸") ?: "🇺🇸"
            val toFlag    = data.getString("to_flag",    "🇪🇺") ?: "🇪🇺"
            val amountStr = data.getString("amount_str", "100 USD") ?: "100 USD"
            val resultStr = data.getString("result_str", "—") ?: "—"
            val toCode    = data.getString("to_code",    "EUR") ?: "EUR"
            val rateStr   = data.getString("rate_str",   "ECB: 1 USD = — EUR") ?: ""
            val bankRate  = data.getString("bank_rate",  "") ?: ""
            val updatedAt = data.getString("updated_at", "--:--") ?: "--:--"

            views.setTextViewText(R.id.widget_from_flag,  fromFlag)
            views.setTextViewText(R.id.widget_to_flag,    toFlag)
            views.setTextViewText(R.id.widget_amount,     amountStr)
            views.setTextViewText(R.id.widget_result,     "$resultStr $toCode")
            views.setTextViewText(R.id.widget_rate,       rateStr)
            views.setTextViewText(R.id.widget_bank_rate,  bankRate)
            views.setTextViewText(R.id.widget_updated,    updatedAt)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
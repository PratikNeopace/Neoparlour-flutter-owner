package com.neoparlour.owner

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.neoparlour.owner/app_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "changeIcon" -> {
                    val iconName = call.argument<String>("iconName")
                    val success = setAppIcon(iconName)
                    result.success(success)
                }
                "getCurrentIcon" -> {
                    result.success(getCurrentIcon())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun setAppIcon(iconName: String?): Boolean {
        return try {
            val pm = applicationContext.packageManager
            val pkg = applicationContext.packageName

            val defaultAlias = ComponentName(pkg, "$pkg.MainActivityDefault")
            val diwaliAlias = ComponentName(pkg, "$pkg.MainActivityDiwali")
            val christmasAlias = ComponentName(pkg, "$pkg.MainActivityChristmas")
            val newYearAlias = ComponentName(pkg, "$pkg.MainActivityNewYear")

            val target = iconName?.lowercase() ?: "default"
            val targetAlias = when (target) {
                "diwali" -> diwaliAlias
                "christmas" -> christmasAlias
                "newyear", "new_year" -> newYearAlias
                else -> defaultAlias
            }

            // 1. Enable target alias FIRST
            pm.setComponentEnabledSetting(
                targetAlias,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

            // 2. Disable all other aliases
            val allAliases = listOf(defaultAlias, diwaliAlias, christmasAlias, newYearAlias)
            for (alias in allAliases) {
                if (alias != targetAlias) {
                    pm.setComponentEnabledSetting(
                        alias,
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                }
            }

            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun getCurrentIcon(): String {
        return try {
            val pm = applicationContext.packageManager
            val pkg = applicationContext.packageName
            val diwaliAlias = ComponentName(pkg, "$pkg.MainActivityDiwali")
            val christmasAlias = ComponentName(pkg, "$pkg.MainActivityChristmas")
            val newYearAlias = ComponentName(pkg, "$pkg.MainActivityNewYear")
            val defaultAlias = ComponentName(pkg, "$pkg.MainActivityDefault")

            val christmasState = pm.getComponentEnabledSetting(christmasAlias)
            if (christmasState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return "christmas"

            val newYearState = pm.getComponentEnabledSetting(newYearAlias)
            if (newYearState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return "newyear"

            val defaultState = pm.getComponentEnabledSetting(defaultAlias)
            if (defaultState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return "default"

            val diwaliState = pm.getComponentEnabledSetting(diwaliAlias)
            if (diwaliState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return "diwali"
            if (diwaliState == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT) return "diwali"

            "default"
        } catch (e: Exception) {
            "default"
        }
    }
}

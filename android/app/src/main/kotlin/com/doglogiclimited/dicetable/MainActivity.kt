package com.mydicetable.app

import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        super.onCreate(savedInstanceState)
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }

        // super.onCreate(savedInstanceState)
    }
}
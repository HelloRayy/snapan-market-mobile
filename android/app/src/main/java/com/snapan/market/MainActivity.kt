package com.snapan.market

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import com.snapan.market.data.local.LocalDataStore
import com.snapan.market.ui.screens.HelloScreen
import com.snapan.market.ui.screens.onboarding.OnboardingScreen
import com.snapan.market.ui.theme.SnapanTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    private val dataStore by lazy { LocalDataStore(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            SnapanTheme {
                val coroutineScope = rememberCoroutineScope()
                // In Onboarding slicing phase, allow easy toggling and reset
                var isCompletedInSession by remember { mutableStateOf(false) }

                if (!isCompletedInSession) {
                    OnboardingScreen(
                        onComplete = {
                            isCompletedInSession = true
                        }
                    )
                } else {
                    HelloScreen(
                        onResetOnboarding = {
                            isCompletedInSession = false
                            coroutineScope.launch {
                                dataStore.setOnboarded(false)
                            }
                        }
                    )
                }
            }
        }
    }
}

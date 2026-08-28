package com.snapan.market.data.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "snapan_prefs")

class LocalDataStore(private val context: Context) {
    companion object {
        private val KEY_ONBOARDED = booleanPreferencesKey("snapan_has_onboarded")
        private val KEY_AUTH_TOKEN = stringPreferencesKey("snapan_auth_token")
        private val KEY_DRAFT_CAPTION = stringPreferencesKey("snapan_draft_caption")
    }

    val isOnboarded: Flow<Boolean> = context.dataStore.data.map { preferences ->
        preferences[KEY_ONBOARDED] ?: false
    }

    val draftCaption: Flow<String?> = context.dataStore.data.map { preferences ->
        preferences[KEY_DRAFT_CAPTION]
    }

    suspend fun setOnboarded(onboarded: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[KEY_ONBOARDED] = onboarded
        }
    }

    suspend fun saveDraft(caption: String) {
        context.dataStore.edit { preferences ->
            preferences[KEY_DRAFT_CAPTION] = caption
        }
    }

    suspend fun clearDraft() {
        context.dataStore.edit { preferences ->
            preferences.remove(KEY_DRAFT_CAPTION)
        }
    }
}

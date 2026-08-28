package com.snapan.market.data.remote

import com.snapan.market.data.model.UserProfile
import io.github.jan.supabase.auth.auth
import io.github.jan.supabase.auth.providers.builtin.OTP
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

class AuthRepository {
    private val auth = SnapanSupabase.client.auth

    private val _currentUser = MutableStateFlow<UserProfile?>(
        UserProfile(
            id = "user_me",
            fullName = "Raditya Rayhan",
            username = "radityarayhannnn",
            email = "raditya@smkn8jkt.sch.id",
            phone = "081234567890",
            avatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
            classGroup = "XII PPLG 1",
            nisn = "0068192837",
            isVerifiedStudent = true,
            bio = "Siswa PPLG SMKN 8 Jakarta 💻 | Jual modul praktek & preloved buku coding",
            postsCount = 12,
            followersCount = 148,
            followingCount = 92
        )
    )
    val currentUser: Flow<UserProfile?> = _currentUser.asStateFlow()

    suspend fun sendOtp(phoneOrEmail: String): Result<Boolean> {
        return try {
            if (phoneOrEmail.contains("@")) {
                auth.signInWith(OTP) {
                    email = phoneOrEmail
                }
            } else {
                auth.signInWith(OTP) {
                    phone = phoneOrEmail
                }
            }
            Result.success(true)
        } catch (e: Exception) {
            // Safe fallback for offline demo
            Result.success(true)
        }
    }

    suspend fun verifyOtp(phoneOrEmail: String, token: String): Result<Boolean> {
        return try {
            Result.success(true)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun signOut() {
        try {
            auth.signOut()
        } catch (_: Exception) {}
        _currentUser.value = null
    }

    fun updateCurrentUser(profile: UserProfile) {
        _currentUser.value = profile
    }
}

package com.snapan.market.ui.screens.onboarding

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.relocation.BringIntoViewRequester
import androidx.compose.foundation.relocation.bringIntoViewRequester
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.outlined.Email
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Phone
import androidx.compose.material.icons.outlined.Visibility
import androidx.compose.material.icons.outlined.VisibilityOff
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapan.market.ui.theme.DangerRed
import com.snapan.market.ui.theme.InkBlack
import com.snapan.market.ui.theme.KumoBlue
import com.snapan.market.ui.theme.PureWhite
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// Exact Capsule Input with Auto Bring-Into-View on Keyboard Open
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun PillAuthField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,
    leadingIcon: ImageVector? = null,
    iconTint: Color = Color(0xFF10B981),
    isPassword: Boolean = false,
    errorMessage: String? = null,
    keyboardType: KeyboardType = KeyboardType.Text,
    imeAction: ImeAction = ImeAction.Next,
    onImeAction: () -> Unit = {}
) {
    var isFocused by remember { mutableStateOf(false) }
    var passwordVisible by remember { mutableStateOf(false) }
    val bringIntoViewRequester = remember { BringIntoViewRequester() }
    val coroutineScope = rememberCoroutineScope()

    LaunchedEffect(isFocused) {
        if (isFocused) {
            delay(150L) // Wait for keyboard animation to settle
            bringIntoViewRequester.bringIntoView()
        }
    }

    val borderColor = when {
        errorMessage != null -> DangerRed
        isFocused -> KumoBlue
        else -> Color(0xFFE5E7EB)
    }

    val shape = RoundedCornerShape(percent = 50)

    Column(
        modifier = modifier
            .fillMaxWidth()
            .bringIntoViewRequester(bringIntoViewRequester)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp)
                .clip(shape)
                .background(PureWhite)
                .border(
                    BorderStroke(if (isFocused || errorMessage != null) 1.5.dp else 1.dp, borderColor),
                    shape
                )
                .onFocusChanged {
                    isFocused = it.isFocused
                    if (it.isFocused) {
                        coroutineScope.launch {
                            delay(150L)
                            bringIntoViewRequester.bringIntoView()
                        }
                    }
                }
                .padding(horizontal = 16.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (leadingIcon != null) {
                    Icon(
                        imageVector = leadingIcon,
                        contentDescription = null,
                        tint = if (errorMessage != null) DangerRed else iconTint,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                }

                Box(
                    modifier = Modifier.weight(1f),
                    contentAlignment = Alignment.CenterStart
                ) {
                    if (value.isEmpty()) {
                        Text(
                            text = placeholder,
                            color = Color(0xFF94A3B8),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Normal,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }

                    BasicTextField(
                        value = value,
                        onValueChange = onValueChange,
                        modifier = Modifier.fillMaxWidth(),
                        textStyle = TextStyle(
                            color = InkBlack,
                            fontSize = 14.5.sp,
                            fontWeight = FontWeight.SemiBold
                        ),
                        cursorBrush = SolidColor(KumoBlue),
                        singleLine = true,
                        visualTransformation = if (isPassword && !passwordVisible) PasswordVisualTransformation() else VisualTransformation.None,
                        keyboardOptions = KeyboardOptions(
                            keyboardType = keyboardType,
                            imeAction = imeAction
                        ),
                        keyboardActions = KeyboardActions(onAny = { onImeAction() })
                    )
                }

                if (isPassword) {
                    IconButton(
                        onClick = { passwordVisible = !passwordVisible },
                        modifier = Modifier.size(28.dp)
                    ) {
                        Icon(
                            imageVector = if (passwordVisible) Icons.Outlined.Visibility else Icons.Outlined.VisibilityOff,
                            contentDescription = null,
                            tint = Color(0xFF94A3B8),
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }

        AnimatedVisibility(visible = errorMessage != null) {
            if (errorMessage != null) {
                Text(
                    text = errorMessage,
                    color = DangerRed,
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.padding(top = 4.dp, start = 12.dp)
                )
            }
        }
    }
}

// WhatsApp Phone Field with Auto Bring-Into-View
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun PillWhatsAppField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    errorMessage: String? = null,
    imeAction: ImeAction = ImeAction.Next,
    onImeAction: () -> Unit = {}
) {
    var isFocused by remember { mutableStateOf(false) }
    val bringIntoViewRequester = remember { BringIntoViewRequester() }
    val coroutineScope = rememberCoroutineScope()

    LaunchedEffect(isFocused) {
        if (isFocused) {
            delay(150L)
            bringIntoViewRequester.bringIntoView()
        }
    }

    val borderColor = when {
        errorMessage != null -> DangerRed
        isFocused -> KumoBlue
        else -> Color(0xFFE5E7EB)
    }

    val shape = RoundedCornerShape(percent = 50)

    Column(
        modifier = modifier
            .fillMaxWidth()
            .bringIntoViewRequester(bringIntoViewRequester)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Flag Box
            Box(
                modifier = Modifier
                    .width(76.dp)
                    .height(52.dp)
                    .clip(shape)
                    .background(Color(0xFFF8FAFC))
                    .border(BorderStroke(1.dp, Color(0xFFE2E8F0)), shape),
                contentAlignment = Alignment.Center
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(text = "🇮🇩", fontSize = 15.sp)
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "+62",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = InkBlack
                    )
                }
            }

            // Input Box
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(52.dp)
                    .clip(shape)
                    .background(PureWhite)
                    .border(
                        BorderStroke(if (isFocused || errorMessage != null) 1.5.dp else 1.dp, borderColor),
                        shape
                    )
                    .onFocusChanged {
                        isFocused = it.isFocused
                        if (it.isFocused) {
                            coroutineScope.launch {
                                delay(150L)
                                bringIntoViewRequester.bringIntoView()
                            }
                        }
                    }
                    .padding(horizontal = 16.dp),
                contentAlignment = Alignment.CenterStart
            ) {
                if (value.isEmpty() && !isFocused) {
                    Text(
                        text = "857-9799-857",
                        color = Color(0xFF94A3B8),
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Normal
                    )
                }

                BasicTextField(
                    value = value,
                    onValueChange = { input ->
                        val digits = input.filter { it.isDigit() || it == '-' }
                        onValueChange(digits)
                    },
                    modifier = Modifier.fillMaxWidth(),
                    textStyle = TextStyle(
                        color = InkBlack,
                        fontSize = 14.5.sp,
                        fontWeight = FontWeight.SemiBold
                    ),
                    cursorBrush = SolidColor(KumoBlue),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Phone,
                        imeAction = imeAction
                    ),
                    keyboardActions = KeyboardActions(onAny = { onImeAction() })
                )
            }
        }

        AnimatedVisibility(visible = errorMessage != null) {
            if (errorMessage != null) {
                Text(
                    text = errorMessage,
                    color = DangerRed,
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.padding(top = 4.dp, start = 12.dp)
                )
            }
        }
    }
}

// 3-Grid Class Selector matching SMKN 8
@Composable
fun PillClassPickerGrid(
    selectedGrade: String,
    onGradeSelected: (String) -> Unit,
    selectedMajor: String,
    onMajorSelected: (String) -> Unit,
    selectedClassNum: String,
    onClassNumSelected: (String) -> Unit,
    modifier: Modifier = Modifier,
    errorMessage: String? = null
) {
    val gradeOptions = listOf("X", "XI", "XII", "Guru / Karyawan")
    val majorOptions = listOf("DKV", "LK", "PPLG", "PS", "TJKT")
    val classNumOptions = listOf("1", "2", "3")

    var isGradeOpen by remember { mutableStateOf(false) }
    var isMajorOpen by remember { mutableStateOf(false) }
    var isClassNumOpen by remember { mutableStateOf(false) }

    val isGuruOrStaff = selectedGrade == "Guru / Karyawan"

    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Tingkat
            Box(modifier = Modifier.weight(if (isGuruOrStaff) 1f else 0.34f)) {
                PillDropdownButton(
                    text = selectedGrade.ifEmpty { "Kelas" },
                    isOpen = isGradeOpen,
                    hasValue = selectedGrade.isNotEmpty(),
                    hasError = errorMessage != null,
                    onClick = { isGradeOpen = true }
                )
                DropdownMenu(
                    expanded = isGradeOpen,
                    onDismissRequest = { isGradeOpen = false }
                ) {
                    gradeOptions.forEach { grade ->
                        DropdownMenuItem(
                            text = { Text(grade, fontSize = 13.sp, fontWeight = FontWeight.Bold) },
                            onClick = {
                                onGradeSelected(grade)
                                isGradeOpen = false
                            }
                        )
                    }
                }
            }

            if (!isGuruOrStaff) {
                // Jurusan
                Box(modifier = Modifier.weight(0.38f)) {
                    PillDropdownButton(
                        text = selectedMajor.ifEmpty { "Jurusan" },
                        isOpen = isMajorOpen,
                        hasValue = selectedMajor.isNotEmpty(),
                        hasError = errorMessage != null,
                        onClick = { isMajorOpen = true }
                    )
                    DropdownMenu(
                        expanded = isMajorOpen,
                        onDismissRequest = { isMajorOpen = false }
                    ) {
                        majorOptions.forEach { major ->
                            DropdownMenuItem(
                                text = { Text(major, fontSize = 13.sp, fontWeight = FontWeight.Bold) },
                                onClick = {
                                    onMajorSelected(major)
                                    isMajorOpen = false
                                }
                            )
                        }
                    }
                }

                // No. Kelas
                Box(modifier = Modifier.weight(0.28f)) {
                    PillDropdownButton(
                        text = if (selectedClassNum.isNotEmpty()) "Kelas $selectedClassNum" else "No.",
                        isOpen = isClassNumOpen,
                        hasValue = selectedClassNum.isNotEmpty(),
                        hasError = errorMessage != null,
                        onClick = { isClassNumOpen = true }
                    )
                    DropdownMenu(
                        expanded = isClassNumOpen,
                        onDismissRequest = { isClassNumOpen = false }
                    ) {
                        classNumOptions.forEach { num ->
                            DropdownMenuItem(
                                text = { Text("Kelas $num", fontSize = 13.sp, fontWeight = FontWeight.Bold) },
                                onClick = {
                                    onClassNumSelected(num)
                                    isClassNumOpen = false
                                }
                            )
                        }
                    }
                }
            }
        }

        AnimatedVisibility(visible = errorMessage != null) {
            if (errorMessage != null) {
                Text(
                    text = errorMessage,
                    color = DangerRed,
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.padding(top = 4.dp, start = 12.dp)
                )
            }
        }
    }
}

@Composable
private fun PillDropdownButton(
    text: String,
    isOpen: Boolean,
    hasValue: Boolean,
    hasError: Boolean,
    onClick: () -> Unit
) {
    val shape = RoundedCornerShape(percent = 50)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(52.dp)
            .clip(shape)
            .background(if (isOpen) Color(0xFFEFF6FF) else PureWhite)
            .border(
                BorderStroke(
                    1.dp,
                    if (hasError) DangerRed else if (isOpen) KumoBlue else Color(0xFFE5E7EB)
                ),
                shape
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = text,
            fontSize = 13.sp,
            fontWeight = if (hasValue) FontWeight.Bold else FontWeight.Medium,
            color = if (hasValue) InkBlack else Color(0xFF94A3B8),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f, fill = false)
        )
        Icon(
            imageVector = Icons.Default.KeyboardArrowDown,
            contentDescription = null,
            tint = if (isOpen) KumoBlue else Color(0xFF94A3B8),
            modifier = Modifier.size(16.dp)
        )
    }
}

// 6-Digit WhatsApp OTP Boxes
@Composable
fun OtpPinInput(
    otpDigits: List<String>,
    onDigitChange: (index: Int, value: String) -> Unit,
    modifier: Modifier = Modifier
) {
    val focusRequesters = remember { List(6) { FocusRequester() } }

    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(6) { index ->
            val digit = otpDigits.getOrElse(index) { "" }
            val isFilled = digit.isNotEmpty()
            val shape = RoundedCornerShape(16.dp)

            BasicTextField(
                value = digit,
                onValueChange = { input ->
                    val clean = input.filter { it.isDigit() }
                    if (clean.length <= 1) {
                        onDigitChange(index, clean)
                        if (clean.isNotEmpty() && index < 5) {
                            focusRequesters[index + 1].requestFocus()
                        }
                    } else if (clean.length == 6) {
                        clean.forEachIndexed { i, char ->
                            if (i < 6) onDigitChange(i, char.toString())
                        }
                        focusRequesters[5].requestFocus()
                    }
                },
                modifier = Modifier
                    .weight(1f)
                    .height(56.dp)
                    .focusRequester(focusRequesters[index])
                    .clip(shape)
                    .background(if (isFilled) Color(0xFFEFF6FF) else Color(0xFFF8FAFC))
                    .border(
                        BorderStroke(
                            1.5.dp,
                            if (isFilled) KumoBlue else Color(0xFFE2E8F0)
                        ),
                        shape
                    ),
                textStyle = TextStyle(
                    fontSize = 22.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = if (isFilled) KumoBlue else InkBlack,
                    textAlign = TextAlign.Center
                ),
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.NumberPassword,
                    imeAction = if (index == 5) ImeAction.Done else ImeAction.Next
                ),
                singleLine = true,
                decorationBox = { innerTextField ->
                    Box(
                        modifier = Modifier.fillMaxWidth(),
                        contentAlignment = Alignment.Center
                    ) {
                        if (!isFilled) {
                            Text(
                                text = "-",
                                color = Color(0xFFCBD5E1),
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        innerTextField()
                    }
                }
            )
        }
    }
}

// Google & Facebook Side-by-Side Capsule Buttons matching reference
@Composable
fun SocialAuthRow(
    onGoogleClick: () -> Unit,
    onFacebookClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Google Button
        Box(
            modifier = Modifier
                .weight(1f)
                .height(48.dp)
                .clip(RoundedCornerShape(percent = 50))
                .background(PureWhite)
                .border(BorderStroke(1.dp, Color(0xFFE5E7EB)), RoundedCornerShape(percent = 50))
                .clickable(onClick = onGoogleClick),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "G",
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Black,
                    color = Color(0xFFEA4335)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Google",
                    fontSize = 13.5.sp,
                    fontWeight = FontWeight.Bold,
                    color = InkBlack
                )
            }
        }

        // Facebook Button
        Box(
            modifier = Modifier
                .weight(1f)
                .height(48.dp)
                .clip(RoundedCornerShape(percent = 50))
                .background(PureWhite)
                .border(BorderStroke(1.dp, Color(0xFFE5E7EB)), RoundedCornerShape(percent = 50))
                .clickable(onClick = onFacebookClick),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(18.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1877F2)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "f",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = PureWhite
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Facebook",
                    fontSize = 13.5.sp,
                    fontWeight = FontWeight.Bold,
                    color = InkBlack
                )
            }
        }
    }
}

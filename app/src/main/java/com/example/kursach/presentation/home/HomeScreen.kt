package com.example.kursach.presentation.home

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.Logout
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material.icons.outlined.Refresh
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathFillType
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.example.kursach.domain.model.ChartPoint
import com.example.kursach.domain.model.DashboardData
import com.example.kursach.domain.model.MarketMover
import com.example.kursach.domain.model.PortfolioAsset
import com.example.kursach.domain.model.UserProfile
import java.text.NumberFormat
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Currency
import java.util.Locale
import kotlinx.coroutines.launch

@Composable
fun HomeScreen(
    profile: UserProfile,
    onLogout: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: HomeViewModel = hiltViewModel(),
) {
    val uiState by viewModel.state.collectAsStateWithLifecycle()
    val snackbarHostState = remember { SnackbarHostState() }
    val coroutineScope = rememberCoroutineScope()
    val dashboard = uiState.dashboard

    LaunchedEffect(uiState.error) {
        val message = uiState.error
        if (message != null) {
            snackbarHostState.showSnackbar(message)
            viewModel.clearError()
        }
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
        topBar = {
            DashboardTopBar(
                profile = profile,
                isRefreshing = uiState.isRefreshing,
                onRefresh = {
                    viewModel.refresh(forceShowLoading = dashboard == null)
                },
                onLogout = onLogout,
                onSettingsClick = {
                    coroutineScope.launch {
                        snackbarHostState.showSnackbar(TEXT_COMING_SOON)
                    }
                },
            )
        },
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(innerPadding),
        ) {
            when {
                uiState.isLoading && !uiState.hasContent -> {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center),
                    )
                }

                dashboard != null -> {
                    DashboardContent(
                        data = dashboard,
                        padding = PaddingValues(horizontal = 16.dp, vertical = 24.dp),
                        onShowMore = {
                            coroutineScope.launch {
                                snackbarHostState.showSnackbar(TEXT_COMING_SOON)
                            }
                        },
                    )
                }

                else -> {
                    Text(
                        text = TEXT_NO_DATA,
                        modifier = Modifier.align(Alignment.Center),
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
            }
        }
    }
}

@Composable
private fun DashboardContent(
    data: DashboardData,
    padding: PaddingValues,
    onShowMore: () -> Unit,
    modifier: Modifier = Modifier,
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = padding,
        verticalArrangement = Arrangement.spacedBy(24.dp),
    ) {
        item {
            BalanceSection(data = data)
        }
        item {
            SectionHeader(
                title = TEXT_MARKET_MOVERS_TITLE,
                onAction = onShowMore,
            )
        }
        item {
            MarketMoversRow(
                movers = data.marketMovers,
                currency = data.currency,
            )
        }
        item {
            SectionHeader(
                title = TEXT_PORTFOLIO_TITLE,
                onAction = onShowMore,
            )
        }
        items(data.portfolio, key = { it.id }) { asset ->
            PortfolioRow(
                asset = asset,
                currency = data.currency,
            )
        }
        item {
            Text(
                text = formatUpdatedAt(data.lastUpdated),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun BalanceSection(
    data: DashboardData,
    modifier: Modifier = Modifier,
) {
    val balanceText = remember(data.portfolioBalance, data.currency) {
        formatCurrency(data.portfolioBalance, data.currency)
    }
    val changeText = remember(data.balanceChangePct) { formatChange(data.balanceChangePct) }
    val changeColor = if (data.balanceChangePct >= 0) PositiveAccent else NegativeAccent

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(
                text = TEXT_PORTFOLIO_BALANCE,
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Text(
                    text = balanceText,
                    style = MaterialTheme.typography.headlineLarge.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onSurface,
                )
                Surface(
                    shape = RoundedCornerShape(999.dp),
                    color = changeColor.copy(alpha = 0.12f),
                ) {
                    Text(
                        text = changeText,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Medium),
                        color = changeColor,
                    )
                }
            }
        }

        BalanceChart(
            points = data.chart,
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
                .clip(RoundedCornerShape(24.dp))
                .background(MaterialTheme.colorScheme.surface),
        )
    }
}

@Composable
private fun BalanceChart(
    points: List<ChartPoint>,
    modifier: Modifier = Modifier,
) {
    if (points.size < 2) {
        Surface(
            modifier = modifier,
            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
            shape = RoundedCornerShape(24.dp),
        ) {
            Box(contentAlignment = Alignment.Center) {
                Text(
                    text = TEXT_NOT_ENOUGH_DATA,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
        return
    }

    val lineColor = MaterialTheme.colorScheme.primary
    Canvas(modifier = modifier) {
        val minPrice = points.minOf { it.price }
        val maxPrice = points.maxOf { it.price }
        val priceRange = if (maxPrice > minPrice) maxPrice - minPrice else 1.0

        val path = Path()
        val lastIndex = points.lastIndex.toFloat()
        points.forEachIndexed { index, point ->
            val x = index.toFloat() / lastIndex * size.width
            val yRatio = (point.price - minPrice) / priceRange
            val y = size.height - (yRatio.toFloat() * size.height)
            if (index == 0) {
                path.moveTo(x, y)
            } else {
                path.lineTo(x, y)
            }
        }

        val fillPath = Path().apply {
            addPath(path)
            lineTo(size.width, size.height)
            lineTo(0f, size.height)
            close()
            fillType = PathFillType.EvenOdd
        }

        val color = lineColor
        drawPath(
            path = fillPath,
            brush = Brush.verticalGradient(
                colors = listOf(
                    color.copy(alpha = 0.4f),
                    color.copy(alpha = 0f),
                ),
            ),
        )

        drawPath(
            path = path,
            color = color,
            style = Stroke(width = 4.dp.toPx(), cap = StrokeCap.Round),
        )
    }
}

@Composable
private fun MarketMoversRow(
    movers: List<MarketMover>,
    currency: String,
    modifier: Modifier = Modifier,
) {
    if (movers.isEmpty()) {
        Text(
            text = TEXT_NO_MARKET_MOVERS,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        return
    }

    LazyRow(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(movers, key = { it.id }) { mover ->
            MarketMoverCard(mover = mover, currency = currency)
        }
    }
}

@Composable
private fun MarketMoverCard(
    mover: MarketMover,
    currency: String,
    modifier: Modifier = Modifier,
) {
    val priceText = remember(mover.currentPrice, currency) {
        formatCurrency(mover.currentPrice, currency)
    }
    val changeText = remember(mover.change24hPct) { formatChange(mover.change24hPct) }
    val changeColor = if (mover.change24hPct >= 0) PositiveAccent else NegativeAccent
    val volumeText = remember(mover.volume24h) { formatVolume(mover.volume24h) }

    Card(
        modifier = modifier
            .width(180.dp)
            .aspectRatio(0.82f),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        shape = RoundedCornerShape(24.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                AssetAvatar(imageUrl = mover.imageUrl, contentDescription = mover.name)
                Column {
                    Text(
                        text = mover.pair,
                        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Text(
                        text = mover.name,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = priceText,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                )
                Text(
                    text = changeText,
                    style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Medium),
                    color = changeColor,
                )
            }
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = TEXT_VOLUME_LABEL,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(
                    text = volumeText,
                    style = MaterialTheme.typography.labelMedium,
                )
            }
        }
    }
}

@Composable
private fun PortfolioRow(
    asset: PortfolioAsset,
    currency: String,
    modifier: Modifier = Modifier,
) {
    val priceText = remember(asset.value, currency) { formatCurrency(asset.value, currency) }
    val changeText = remember(asset.change24hPct) { formatChange(asset.change24hPct) }
    val changeColor = if (asset.change24hPct >= 0) PositiveAccent else NegativeAccent

    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(20.dp))
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        AssetAvatar(imageUrl = asset.imageUrl, contentDescription = asset.name)
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            Text(
                text = asset.name,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Medium),
            )
            Text(
                text = asset.symbol.uppercase(Locale.getDefault()),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        Column(
            horizontalAlignment = Alignment.End,
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            Text(
                text = priceText,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
            )
            Text(
                text = changeText,
                style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Medium),
                color = changeColor,
            )
        }
    }
}

@Composable
private fun SectionHeader(
    title: String,
    onAction: (() -> Unit)?,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
        )
        if (onAction != null) {
            Text(
                text = TEXT_MORE_ACTION,
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Medium),
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.08f))
                    .clickable(onClick = onAction)
                    .padding(horizontal = 12.dp, vertical = 6.dp),
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun DashboardTopBar(
    profile: UserProfile,
    isRefreshing: Boolean,
    onRefresh: () -> Unit,
    onLogout: () -> Unit,
    onSettingsClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    CenterAlignedTopAppBar(
        modifier = modifier,
        title = {
            Text(
                text = TEXT_APP_NAME,
                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold),
                color = MaterialTheme.colorScheme.primary,
            )
        },
        navigationIcon = {
            Icon(
                imageVector = Icons.Outlined.AccountCircle,
                contentDescription = profile.fullName,
                tint = MaterialTheme.colorScheme.primary,
            )
        },
        actions = {
            if (isRefreshing) {
                CircularProgressIndicator(
                    modifier = Modifier
                        .padding(end = 8.dp)
                        .size(20.dp),
                    strokeWidth = 2.dp,
                )
            } else {
                IconButton(onClick = onRefresh) {
                    Icon(
                        imageVector = Icons.Outlined.Refresh,
                        contentDescription = TEXT_REFRESH_CONTENT_DESCRIPTION,
                    )
                }
            }
            IconButton(onClick = onSettingsClick) {
                Icon(
                    imageVector = Icons.Outlined.Settings,
                    contentDescription = TEXT_SETTINGS_CONTENT_DESCRIPTION,
                )
            }
            IconButton(onClick = onLogout) {
                Icon(
                    imageVector = Icons.AutoMirrored.Outlined.Logout,
                    contentDescription = TEXT_LOGOUT_CONTENT_DESCRIPTION,
                )
            }
        },
    )
}

@Composable
private fun AssetAvatar(
    imageUrl: String?,
    contentDescription: String,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    Surface(
        modifier = modifier.size(40.dp),
        shape = CircleShape,
        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.12f),
        contentColor = MaterialTheme.colorScheme.primary,
    ) {
        if (imageUrl.isNullOrBlank()) {
            Box(contentAlignment = Alignment.Center) {
                Text(
                    text = contentDescription.firstOrNull()?.uppercaseChar()?.toString() ?: "?",
                    style = MaterialTheme.typography.titleMedium,
                )
            }
        } else {
            AsyncImage(
                model = ImageRequest.Builder(context)
                    .data(imageUrl)
                    .crossfade(true)
                    .build(),
                contentDescription = contentDescription,
                modifier = Modifier.fillMaxSize(),
            )
        }
    }
}

private fun formatCurrency(amount: Double, currencyCode: String): String {
    val formatter = NumberFormat.getCurrencyInstance(DisplayLocale)
    runCatching { formatter.currency = Currency.getInstance(currencyCode.uppercase(Locale.ROOT)) }
    formatter.maximumFractionDigits = 2
    return formatter.format(amount)
}

private fun formatChange(value: Double): String {
    return String.format(DisplayLocale, "%+.2f%%", value)
}

private fun formatVolume(value: Double): String {
    val formatter = NumberFormat.getNumberInstance(DisplayLocale)
    formatter.maximumFractionDigits = 0
    return formatter.format(value)
}

private fun formatUpdatedAt(instant: Instant): String {
    val formatter = DateTimeFormatter.ofPattern("HH:mm").withZone(ZoneId.systemDefault())
    return String.format(DisplayLocale, "%s %s", TEXT_UPDATED_LABEL, formatter.format(instant))
}

private val PositiveAccent = Color(0xFF24C16B)
private val NegativeAccent = Color(0xFFDA5B5B)

private val DisplayLocale = Locale.forLanguageTag("ru-RU")

private const val TEXT_APP_NAME = "comoney"
private const val TEXT_MARKET_MOVERS_TITLE = "Market Movers"
private const val TEXT_PORTFOLIO_TITLE = "Portfolio"
private const val TEXT_MORE_ACTION = "More"
private const val TEXT_PORTFOLIO_BALANCE = "Portfolio Balance"
private const val TEXT_VOLUME_LABEL = "24H Vol."
private const val TEXT_UPDATED_LABEL =
    "\u041e\u0431\u043d\u043e\u0432\u043b\u0435\u043d\u043e \u0432"
private const val TEXT_NOT_ENOUGH_DATA =
    "\u041d\u0435\u0434\u043e\u0441\u0442\u0430\u0442\u043e\u0447\u043d\u043e \u0434\u0430\u043d\u043d\u044b\u0445"
private const val TEXT_NO_MARKET_MOVERS =
    "\u041d\u0435\u0442 \u0434\u0430\u043d\u043d\u044b\u0445 \u043f\u043e \u0440\u044b\u043d\u043a\u0443"
private const val TEXT_NO_DATA =
    "\u041d\u0435\u0442 \u0434\u0430\u043d\u043d\u044b\u0445 \u0434\u043b\u044f \u043e\u0442\u043e\u0431\u0440\u0430\u0436\u0435\u043d\u0438\u044f"
private const val TEXT_REFRESH_CONTENT_DESCRIPTION =
    "\u041e\u0431\u043d\u043e\u0432\u0438\u0442\u044c \u0434\u0430\u043d\u043d\u044b\u0435"
private const val TEXT_SETTINGS_CONTENT_DESCRIPTION =
    "\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u043d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438"
private const val TEXT_LOGOUT_CONTENT_DESCRIPTION =
    "\u0412\u044b\u0439\u0442\u0438 \u0438\u0437 \u0430\u043a\u043a\u0430\u0443\u043d\u0442\u0430"
private const val TEXT_COMING_SOON = "\u0421\u043a\u043e\u0440\u043e \u0434\u043e\u0441\u0442\u0443\u043f\u043d\u043e"

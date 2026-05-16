# KiteEdge — Comprehensive User Guide

> **Version:** 1.0.0 · **Last Updated:** May 2026
>
> Complete guide for setting up and using KiteEdge, your self-hosted portfolio intelligence platform for Zerodha Kite.

---

## Table of Contents

1. [What is KiteEdge?](#1-what-is-kiteedge)
2. [Prerequisites & Requirements](#2-prerequisites--requirements)
3. [Installation & Setup](#3-installation--setup)
4. [Getting Your Kite API Credentials](#4-getting-your-kite-api-credentials)
5. [Starting KiteEdge](#5-starting-kiteedge)
6. [Signing In](#6-signing-in)
7. [Portfolio Overview](#7-portfolio-overview)
8. [Technical Analysis](#8-technical-analysis)
9. [Risk Dashboard](#9-risk-dashboard)
10. [Predictions & Forecasts](#10-predictions--forecasts)
11. [Trade Journal](#11-trade-journal)
12. [Suggestions & Alerts](#12-suggestions--alerts)
13. [Reports & Exports](#13-reports--exports)
14. [Settings & Customization](#14-settings--customization)
15. [Power BI & Excel Integration](#15-power-bi--excel-integration)
16. [Understanding Data Freshness](#16-understanding-data-freshness)
17. [Security & Privacy](#17-security--privacy)
18. [Frequently Asked Questions](#18-frequently-asked-questions)
19. [Troubleshooting](#19-troubleshooting)
20. [Glossary](#20-glossary)

---

## 1. What is KiteEdge?

KiteEdge is a **self-hosted portfolio intelligence platform** designed for Indian equity investors who use Zerodha's Kite Connect platform. It connects to your Kite account and provides:

- **Real-time portfolio monitoring** with live prices and P&L tracking
- **43+ technical indicators** with interactive candlestick charts
- **Professional risk analytics** including VaR, Monte Carlo simulation, and stress testing
- **AI-powered forecasts** using ARIMA and Prophet models
- **Trade performance analysis** with FIFO P&L, win rates, and equity curves
- **Smart suggestions** including signals, rebalance recommendations, and tax-loss harvesting
- **Comprehensive reporting** with tear sheets, Excel/CSV/PDF exports, and Power BI integration
- **Real-time alerts** for price movements and technical signals

### Key Principles

- **Analytics only** — KiteEdge never places, modifies, or cancels trades on your behalf
- **Self-hosted** — All your portfolio data stays on your own infrastructure
- **Transparent** — Every computation is documented and reproducible
- **Honest** — All predictions and suggestions include mandatory disclaimers

### Important Disclaimers

> **KiteEdge is a personal portfolio-analytics tool.** It does not provide investment advice. Forecasts are statistical projections based on historical data and should not be relied upon for trading decisions. Signals are heuristic screens, not buy/sell recommendations. Past performance does not guarantee future results. Always consult a qualified financial advisor before making investment decisions.

---

## 2. Prerequisites & Requirements

### Software Requirements

| Software | Minimum Version | Download |
|----------|-----------------|----------|
| Docker Desktop | Latest | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) |
| Node.js | 20+ | [nodejs.org](https://nodejs.org/) |
| Elixir | 1.17+ | [elixir-lang.org/install](https://elixir-lang.org/install.html) |
| Erlang/OTP | 27 | Included with Elixir installer |
| Python | 3.12+ | [python.org/downloads](https://www.python.org/downloads/) |
| Git | 2.x | [git-scm.com](https://git-scm.com/) |

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 8 GB | 16 GB |
| CPU | 4 cores | 8 cores |
| Disk Space | 10 GB | 20 GB |
| Internet | Required | Required (for Kite API) |

### Zerodha Account Requirements

- Active Zerodha trading account
- Kite Connect API subscription (₹2,000/month from Zerodha)
- API Key and API Secret from the Kite Developer Console

---

## 3. Installation & Setup

### Step 1: Download KiteEdge

```bash
git clone <repository-url>
cd KiteEdge
```

### Step 2: Create Configuration File

```bash
# Copy the template
cp .env.example .env
```

Open `.env` in any text editor and fill in your details:

```bash
# Required: Your Kite API credentials (see Section 4)
KITE_API_KEY=your_api_key_here
KITE_API_SECRET=your_api_secret_here

# Required: Generate a secret key (run: mix phx.gen.secret)
SECRET_KEY_BASE=paste_generated_secret_here

# Optional: Email alerts (leave blank to disable)
NOTIFY_EMAIL_ENABLED=false
SMTP_HOST=
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=

# Everything else can use defaults for local development
```

### Step 3: Start Infrastructure Services

```bash
docker-compose up -d postgres redis kafka kafka-init prometheus grafana
```

Wait for all services to become healthy (about 30 seconds):

```bash
docker-compose ps
```

You should see all services showing `healthy` status.

### Step 4: Set Up the Elixir Gateway

```bash
# Download dependencies
mix deps.get

# Create database and run migrations
mix ecto.setup

# Generate a secret key (copy this to your .env file)
mix phx.gen.secret
```

### Step 5: Set Up the Python Analytics Engine

**Windows:**
```powershell
cd analytics_engine
python -m venv .venv
.venv\Scripts\activate
pip install -e ".[dev]"
cd ..
```

**macOS / Linux:**
```bash
cd analytics_engine
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
cd ..
```

### Step 6: Set Up the React Dashboard

```bash
cd dashboard
npm install
cd ..
```

### Verification

After setup, verify everything is installed correctly:

```bash
# Check Elixir
elixir --version
# Expected: Elixir 1.17+ / OTP 27

# Check Python
python --version
# Expected: Python 3.12+

# Check Node.js
node --version
# Expected: v20+

# Check Docker services
docker-compose ps
# Expected: All services healthy
```

---

## 4. Getting Your Kite API Credentials

### Step 1: Subscribe to Kite Connect

1. Log in to your Zerodha account at [kite.zerodha.com](https://kite.zerodha.com)
2. Navigate to the [Kite Connect Developer Console](https://developers.kite.trade/)
3. Subscribe to the Kite Connect API plan (₹2,000/month)

### Step 2: Create an App

1. Click **"Create New App"**
2. Fill in the details:
   - **App Name:** `KiteEdge`
   - **Type:** `Connect`
   - **Redirect URL:** `http://localhost:4000/auth/kite/callback`
   - **Postback URL:** *(leave blank)*
   - **Description:** `Personal portfolio analytics`
3. Click **"Create"**

### Step 3: Copy Credentials

After creating the app, you'll see two values:
- **API Key** — A short alphanumeric string
- **API Secret** — A longer alphanumeric string

Copy both values into your `.env` file:
```bash
KITE_API_KEY=your_api_key_here
KITE_API_SECRET=your_api_secret_here
```

> **Security Note:** Never share your API Key or Secret with anyone. KiteEdge stores access tokens only in server memory (Redis) and they auto-expire after 18 hours. They are never written to files, databases, or logs.

### Step 4: Verify Redirect URL

Ensure the **Redirect URL** in your Kite app settings exactly matches:
```
http://localhost:4000/auth/kite/callback
```

If you're running KiteEdge on a different host or port, update both the Kite app settings and the `KITE_REDIRECT_URL` in your `.env` file.

---

## 5. Starting KiteEdge

### Starting All Services

You need three terminal windows:

**Terminal 1 — Elixir Gateway:**
```bash
cd KiteEdge
iex -S mix phx.server
```
The gateway starts on **http://localhost:4000**. You'll see log output indicating the server is ready.

**Terminal 2 — Python Analytics Engine:**

Windows:
```powershell
cd KiteEdge\analytics_engine
.venv\Scripts\activate
uvicorn analytics_engine.api.main:app --host 0.0.0.0 --port 8001 --reload
```

macOS/Linux:
```bash
cd KiteEdge/analytics_engine
source .venv/bin/activate
uvicorn analytics_engine.api.main:app --host 0.0.0.0 --port 8001 --reload
```

The analytics engine starts on **http://localhost:8001**.

**Terminal 3 — React Dashboard:**
```bash
cd KiteEdge/dashboard
npm run dev
```
The dashboard starts on **http://localhost:5173**.

### Docker Alternative

To start all services with a single command:
```bash
docker-compose up -d
```

### Verify All Services

Open your browser and check:

| Service | URL | Expected |
|---------|-----|----------|
| Dashboard | http://localhost:5173 | Login page with "Sign in with Kite" button |
| Gateway Health | http://localhost:4000/health | `{"status": "ok"}` |
| Analytics Health | http://localhost:8001/health | `{"status": "ok"}` |
| Grafana | http://localhost:3001 | Login page (admin/admin) |

### Stopping KiteEdge

Press `Ctrl+C` in each terminal window, or if using Docker:
```bash
docker-compose down
```

---

## 6. Signing In

### First-Time Login

1. Open your browser and navigate to **http://localhost:5173**
2. You'll see the KiteEdge login page with the platform disclaimer
3. Click the **"Sign in with Kite"** button
4. You'll be redirected to Zerodha's official login page
5. Enter your **Zerodha User ID** and **Password**
6. Enter the **PIN** / **TOTP** for two-factor authentication
7. Click **"Authorize"** to grant KiteEdge read access
8. You'll be automatically redirected back to the **Portfolio Overview** page

### Session Duration

Your session is valid for **18 hours** from the time you log in, matching Kite's trading-day session cycle:

- Sessions expire around **6:00 AM IST** the next day
- When your session expires, you'll be automatically redirected to the login page
- Simply click **"Sign in with Kite"** again to start a new session
- All your settings, watchlists, and alert configurations persist between sessions

### Signing Out

Navigate to any page and your session will remain active. To explicitly sign out:
1. The session will be immediately cleared from the server
2. You'll be redirected to the login page

> **What happens to your data when you sign out?**
> Your Kite access token is immediately deleted from Redis. Your portfolio data, settings, and alert configurations remain in the database and will be available when you sign in again.

---

## 7. Portfolio Overview

**Navigation:** Click **"Portfolio"** in the top navigation bar or go to `/dashboard`

The Portfolio Overview is your home page — a comprehensive snapshot of your entire portfolio.

### Holdings Table

The main table displays all your current equity holdings:

| Column | Description | Example |
|--------|-------------|---------|
| **Symbol** | Zerodha trading symbol | RELIANCE |
| **Exchange** | Stock exchange | NSE |
| **Qty** | Number of shares you own | 10 |
| **Avg Price** | Your average purchase price | ₹2,450.50 |
| **Last Price** | Current market price (live-updating) | ₹2,523.75 |
| **P&L** | Absolute profit/loss on this holding | +₹732.50 |
| **Day Change** | Today's price movement in ₹ | +₹15.25 |
| **Day Change %** | Today's percentage change | +0.61% |
| **Sector** | Industry sector | Energy |

**Sorting:** Click any column header to sort ascending/descending.

### Portfolio Summary Cards

At the top of the page, you'll see summary cards:

| Card | What It Shows |
|------|---------------|
| **Total Investment** | Total amount invested (sum of avg_price × quantity) |
| **Current Value** | Current portfolio value (sum of last_price × quantity) |
| **Total P&L** | Overall profit/loss (Current Value - Total Investment) |
| **Day's P&L** | Today's gain/loss across all holdings |
| **XIRR** | Your annualized return accounting for when each investment was made |
| **CAGR** | Compound Annual Growth Rate |

### Allocation Charts

Two visual charts help you understand your portfolio composition:

#### Sector Allocation (Donut Chart)
Shows how your money is distributed across sectors:
- IT, Banking, Energy, Pharma, FMCG, Auto, etc.
- Hover over each segment to see the exact percentage and value
- Quickly identify if you're over-concentrated in any sector

#### Market Cap Distribution (Bar Chart)
Shows your exposure across market capitalization tiers:
- **Large Cap** — Top 100 companies by market value
- **Mid Cap** — Next 150 companies
- **Small Cap** — Everything else
- Helps you assess if your portfolio matches your risk appetite

### Concentration Risk Badge

A colored badge indicating how concentrated your portfolio is:

| Badge | Color | Meaning |
|-------|-------|---------|
| **Low Risk** | Green | Well-diversified (HHI < 0.15) — no single holding dominates |
| **Medium Risk** | Yellow | Moderately concentrated (HHI 0.15–0.25) — some holdings dominate |
| **High Risk** | Red | Highly concentrated (HHI > 0.25) — consider diversifying |

*HHI = Herfindahl-Hirschman Index: Sum of squared portfolio weight percentages*

### Holding Detail Drawer

Click on any holding row to open a detailed slide-out panel:

| Detail | Description |
|--------|-------------|
| **Per-Holding XIRR** | Annualized return for just this holding |
| **Portfolio Weight** | What percentage of your portfolio this represents |
| **Sector** | Which industry sector |
| **Market Cap Tier** | Large/Mid/Small cap classification |
| **Dividend History** | Total dividends received |
| **Dividend Yield** | Annual dividend as % of investment |

### Real-Time Price Updates

Portfolio prices update **automatically** via a WebSocket connection:
- No need to refresh the page — prices stream in real-time
- Updated prices flash briefly to indicate a change
- The **freshness indicator** (top-right) shows data currency:
  - 🟢 **Live** — Real-time data from Kite
  - 🟡 **Stale** — Slightly delayed (< 5 minutes)
  - 🔴 **Offline** — Using cached data (Kite unavailable)

---

## 8. Technical Analysis

**Navigation:** Click **"Analysis"** in the top navigation bar or go to `/analysis`

Deep technical analysis for any NSE or BSE instrument with 43+ indicators.

### Step-by-Step Guide

#### Step 1: Search for an Instrument

1. Click the **search bar** at the top of the page
2. Start typing a symbol name (e.g., "REL" for Reliance)
3. A dropdown shows matching instruments with their exchange
4. Click to select the instrument you want to analyze

You can analyze any instrument — not just ones you hold.

#### Step 2: View the Candlestick Chart

An interactive **candlestick chart** loads showing the instrument's price history:

- Each candle represents one day (default timeframe)
- **Green candles** = price went up (close > open)
- **Red candles** = price went down (close < open)
- **Wicks** = high and low of the day

**Interacting with the chart:**
- **Scroll wheel** — Zoom in/out
- **Click and drag** — Pan left/right through time
- **Hover** — See exact Open, High, Low, Close, Volume values

#### Step 3: Explore Indicators

Indicators are organized into four tabs. Each computes a value that helps you understand price trends, momentum, volatility, or volume patterns.

##### Trend Indicators — *"Where is the price going?"*

| Indicator | Period | How to Read It |
|-----------|--------|----------------|
| **SMA** | 20, 50, 200 | Price above SMA = bullish. The 200-day SMA is the key long-term trend line |
| **EMA** | 12, 26 | Like SMA but reacts faster to recent price changes |
| **MACD** | 12, 26, 9 | When MACD line crosses above signal line = bullish |
| **ADX** | 14 | ADX > 25 = strong trend. ADX < 20 = sideways/ranging market |
| **Ichimoku** | 9, 26, 52 | Price above the cloud = bullish. Thick cloud = strong support |
| **Parabolic SAR** | — | Dots below candles = uptrend. Dots above = downtrend |
| **Aroon** | 25 | Aroon Up > 70 + Aroon Down < 30 = strong uptrend |
| **SuperTrend** | 10, 3 | Green line below price = uptrend. Red line above = downtrend |

##### Momentum Indicators — *"How strong is the move?"*

| Indicator | Period | How to Read It |
|-----------|--------|----------------|
| **RSI** | 14 | > 70 = overbought (may pull back). < 30 = oversold (may bounce) |
| **Stochastic RSI** | 14 | Faster RSI — > 0.8 = overbought, < 0.2 = oversold |
| **Williams %R** | 14 | Above -20 = overbought. Below -80 = oversold |
| **CCI** | 20 | Above +100 = overbought. Below -100 = oversold |
| **ROC** | 12 | Positive = price rising. Negative = price falling. Rate of change |
| **Ultimate Oscillator** | 7,14,28 | > 70 = overbought. < 30 = oversold. Multi-timeframe |
| **KAMA** | 10 | Adaptive average — flat in sideways, responsive in trends |
| **TSI** | 25, 13 | Positive = bullish momentum. Negative = bearish momentum |

##### Volatility Indicators — *"How much is the price moving?"*

| Indicator | Period | How to Read It |
|-----------|--------|----------------|
| **Bollinger Bands** | 20, 2σ | Price touching upper band = potentially overbought. **Squeeze** = breakout coming |
| **ATR** | 14 | Higher ATR = more volatile. Useful for setting stop-losses |
| **Keltner Channel** | 20 | Similar to BB but smoother. BB inside KC = squeeze |
| **Donchian Channel** | 20 | Breakout above upper channel = potential new trend |
| **Historical Vol** | 20 | Annualized volatility %. Higher = riskier |

##### Volume Indicators — *"Is there conviction behind the move?"*

| Indicator | How to Read It |
|-----------|----------------|
| **OBV** | Rising OBV + rising price = strong uptrend confirmed by volume |
| **VWAP** | Price above VWAP = bullish for the day. Institutional reference price |
| **CMF** | Positive = buying pressure. Negative = selling pressure |
| **MFI** | Like RSI but weighted by volume. > 80 = overbought |
| **ADI** | Rising = accumulation (buying). Falling = distribution (selling) |
| **Force Index** | Positive = buyers in control. Negative = sellers in control |

#### Step 4: Check the Technical Summary Score

A **visual gauge** shows the overall technical verdict:

```
Strong Sell ←——— Sell ←——— Neutral ———→ Buy ———→ Strong Buy
  -100         -50          0           +50         +100
```

| Score Range | Classification | Typical Meaning |
|-------------|---------------|-----------------|
| **+50 to +100** | Strong Buy | Most indicators are bullish |
| **+20 to +50** | Buy | Majority of indicators lean bullish |
| **-20 to +20** | Neutral | Mixed signals, no clear direction |
| **-50 to -20** | Sell | Majority of indicators lean bearish |
| **-100 to -50** | Strong Sell | Most indicators are bearish |

The **Summary Breakdown** table shows how each category (Trend, Momentum, Volatility, Volume) contributes to the overall score.

#### Step 5: Multi-Timeframe Comparison

Click the timeframe tabs to compare signals across:
- **Daily (1D)** — Short-term trading signals
- **Weekly (1W)** — Swing trading perspective
- **Monthly (1M)** — Long-term investment view

When daily and weekly signals agree (e.g., both show "Buy"), the signal is considered stronger.

#### Step 6: Support & Resistance Levels

Horizontal lines on the chart showing key price levels:
- **Support** (green lines) — Price levels where the stock has historically bounced up
- **Resistance** (red lines) — Price levels where the stock has historically pulled back
- Useful for setting entry/exit targets and stop-losses

#### Step 7: Chart Patterns

Automatic detection of recognized chart formations:

| Pattern | Type | What It Suggests |
|---------|------|------------------|
| **Head and Shoulders** | Bearish reversal | Current uptrend may reverse |
| **Inverse Head and Shoulders** | Bullish reversal | Current downtrend may reverse |
| **Double Top** | Bearish reversal | Price failed twice at resistance |
| **Double Bottom** | Bullish reversal | Price found support twice |
| **Triangle** | Continuation/Breakout | Volatility narrowing, breakout expected |
| **Wedge** | Reversal | Converging trendlines before reversal |

### Customizing Indicator Parameters

Go to **Settings** → **Indicator Profiles** to adjust:

| Parameter | Default | What Changing It Does |
|-----------|---------|----------------------|
| RSI Period | 14 | Lower = more sensitive, more signals. Higher = smoother |
| SMA Periods | 20, 50, 200 | Shorter = more responsive. Longer = smoother trend |
| BB Period | 20 | Shorter = tighter bands. Longer = wider bands |
| BB Std Dev | 2.0 | Lower = tighter bands (more signals). Higher = wider |
| ATR Period | 14 | Lower = more volatile ATR. Higher = smoother |

Your profiles are saved and apply whenever you use technical analysis.

---

## 9. Risk Dashboard

**Navigation:** Click **"Risk"** in the top navigation bar or go to `/risk`

Professional-grade risk analytics for your entire portfolio.

### Risk Ratio Cards

Cards at the top display key risk-adjusted metrics:

| Metric | What It Means | How to Read It |
|--------|--------------|----------------|
| **Sharpe Ratio** | Return earned per unit of risk taken | > 1.0 = good. > 2.0 = excellent. < 0 = losing money |
| **Sortino Ratio** | Like Sharpe, but only counts downside risk | > 1.5 is good. Treats upside volatility as a non-issue |
| **Calmar Ratio** | Annual return ÷ worst peak-to-trough decline | > 1.0 means annual return exceeds worst drawdown |
| **Information Ratio** | How much you beat the benchmark per unit of divergence | > 0.5 = consistently outperforming |
| **Treynor Ratio** | Return earned per unit of market risk (Beta) | Higher is better |
| **Beta** | How much your portfolio moves with the market | 1.0 = moves with market. < 1 = less volatile. > 1 = more volatile |
| **Jensen's Alpha** | Extra return above market expectations (CAPM) | Positive = outperforming. 0 = matching. Negative = underperforming |

### Value at Risk (VaR)

Answers the question: *"What's the most I could lose on a bad day?"*

#### VaR Histogram

A bar chart showing the distribution of your portfolio's daily returns:
- The bell curve shows how often each return level occurred historically
- **VaR lines** mark the worst-case thresholds

#### Three VaR Methods

| Method | How It Works | Best For |
|--------|-------------|----------|
| **Historical** | Looks at your actual past returns and finds the worst 5% | Most realistic, no assumptions |
| **Parametric** | Assumes returns follow a bell curve, calculates mathematically | Fast, good for normal markets |
| **Monte Carlo** | Simulates 10,000 random scenarios | Best for complex portfolios |

#### Reading VaR Values

**Example:** *"95% VaR = ₹50,000"*

This means: *"On 95% of trading days, you will NOT lose more than ₹50,000. There's a 5% chance of losing more."*

**CVaR (Conditional VaR / Expected Shortfall):** *"If you DO lose more than the VaR, the average loss would be ₹75,000."*

CVaR is always larger than VaR and represents the severity of tail-risk events.

### Monte Carlo Simulation Fan Chart

A forward-looking simulation projecting your portfolio's possible future values:

- The chart shows **10,000 simulated price paths** for the next year
- Paths are summarized into percentile bands:

| Band | Meaning |
|------|---------|
| **Outer band** (5th-95th) | 90% of simulations fall within this range |
| **Inner band** (25th-75th) | 50% of simulations fall within this range |
| **Center line** (50th) | The median (most likely) outcome |

**How to read it:**

If your portfolio is currently worth ₹10,00,000:
- **95th percentile at 1 year:** ₹14,00,000 → Best 5% scenario
- **50th percentile at 1 year:** ₹11,50,000 → Most likely outcome
- **5th percentile at 1 year:** ₹8,00,000 → Worst 5% scenario

### Correlation Heatmap

A color-coded grid showing how your holdings move relative to each other:

| Correlation | Color | What It Means |
|-------------|-------|---------------|
| **+0.8 to +1.0** | Dark Red | Stocks move together — you're exposed if both fall |
| **+0.4 to +0.8** | Orange | Moderate positive — some diversification benefit |
| **-0.2 to +0.2** | White/Gray | Little relationship — good diversification |
| **-0.2 to -0.8** | Light Blue | Move in opposite directions — excellent hedge |
| **-0.8 to -1.0** | Dark Blue | Strong inverse movement — natural hedge |

**Why it matters:** If all your holdings are highly correlated (all dark red), your portfolio has less diversification benefit. You're essentially concentrated in one bet.

KiteEdge uses **Ledoit-Wolf shrinkage** for more reliable correlation estimates, especially with short time periods.

### Drawdown Chart

Shows every decline your portfolio experienced from its peak:

- **Y-axis:** Percentage decline from the highest point
- **X-axis:** Time
- **Depth:** How far you fell (e.g., -15%)
- **Duration:** How many days the decline lasted
- **Recovery:** How many days until you recovered to the previous peak

The **worst drawdown** is highlighted — this is the maximum pain your portfolio has experienced.

### Stress Testing Panel

Shows what would happen to your current portfolio under historical crisis scenarios:

| Scenario | Historical Period | What Happened |
|----------|-------------------|---------------|
| **COVID-19 Crash** | Feb-Mar 2020 | NIFTY fell ~38% in 3 weeks |
| **Global Financial Crisis** | 2008 | NIFTY fell ~60% over 12 months |
| **Demonetisation** | Nov 2016 | Market fell ~6% in 2 weeks |
| **Taper Tantrum** | May-Aug 2013 | FII outflows caused ~12% decline |

For each scenario, KiteEdge calculates your **estimated portfolio impact** based on how your current holdings' sectors and stocks behaved during that crisis.

### Volatility Analysis

Rolling volatility charts showing your portfolio's risk level over time:

| Window | What It Shows |
|--------|---------------|
| **30-day rolling** | Short-term volatility — reacts quickly to market changes |
| **60-day rolling** | Medium-term — smoother, better for trend analysis |
| **90-day rolling** | Longer-term — shows structural risk level changes |

---

## 10. Predictions & Forecasts

**Navigation:** Click **"Predictions"** in the top navigation bar or go to `/predictions`

Statistical price forecasts and signal detection for your holdings.

> **⚠️ IMPORTANT DISCLAIMER**
>
> Forecasts are statistical projections based on historical patterns. They are **NOT** investment advice. Past performance does not guarantee future results. These are mathematical models with inherent uncertainty — they CAN and WILL be wrong. Always use them as one input among many, never as the sole basis for trading decisions. Consult a qualified financial advisor for investment guidance.

### Understanding Forecasts

KiteEdge generates forecasts using two complementary models:

#### ARIMA (AutoRegressive Integrated Moving Average)
- Statistical model that captures patterns in time series data
- Good at: identifying linear trends and short-term patterns
- Limitation: assumes future patterns will resemble past patterns

#### Prophet (Facebook's Forecasting Tool)
- Designed for business time series with strong seasonality
- KiteEdge configures it with the **Indian NSE trading calendar** (holidays, half-days)
- Good at: capturing weekly patterns and holiday effects
- Limitation: may over-fit to seasonal patterns

#### Ensemble (Combined) Forecast
- Weighted average of ARIMA and Prophet predictions
- The model with better historical accuracy gets more weight
- Generally more reliable than either model alone

### Forecast Chart

For each instrument, the forecast chart shows:
- **Historical prices** (solid line) — what actually happened
- **Forecast line** (dashed) — predicted price for the next ~30 trading days
- **Confidence interval (80%)** — lighter shaded band — 80% chance the price falls here
- **Confidence interval (95%)** — wider shaded band — 95% chance the price falls here

**How to read confidence intervals:**

If the forecast says ₹2,500 with 95% interval [₹2,350, ₹2,650]:
- The model's best guess is ₹2,500
- There's a 95% chance the actual price will be between ₹2,350 and ₹2,650
- But there's still a 5% chance it goes outside this range

**Wider intervals = more uncertainty.** If the bands are very wide, the model is less confident.

### Signal Feed

Real-time detection of technical trading signals:

| Signal | What It Detects | Typical Implication |
|--------|----------------|---------------------|
| **Bullish MA Crossover** | Short-term EMA(12) crosses above long-term EMA(26) | Potential start of uptrend |
| **Bearish MA Crossover** | Short-term EMA(12) crosses below long-term EMA(26) | Potential start of downtrend |
| **Bullish RSI Divergence** | Price makes a new low, but RSI makes a higher low | Downtrend losing strength, possible reversal |
| **Bearish RSI Divergence** | Price makes a new high, but RSI makes a lower high | Uptrend losing strength, possible reversal |
| **Bollinger Squeeze** | Bollinger Bands contract inside Keltner Channel | Volatility compression — breakout imminent (direction unknown) |
| **Volume-Price Divergence** | Price rising but volume declining | Uptrend losing conviction — may reverse |

Each signal shows:
- **Confidence Score** — How strong/reliable the signal is (0-100)
- **Time Detected** — When the signal was identified
- **Description** — Plain-English explanation

### Model Accuracy Metrics

See how well the models have performed historically:

| Metric | What It Measures | Good Value |
|--------|------------------|------------|
| **MAE** | Average error in ₹ (Mean Absolute Error) | Lower is better |
| **RMSE** | Error penalizing large misses (Root Mean Squared Error) | Lower is better |
| **MAPE** | Average percentage error | < 5% is impressive for stock forecasts |
| **Directional Accuracy** | % of times the model predicted the right direction (up/down) | > 55% is noteworthy for daily moves |

---

## 11. Trade Journal

**Navigation:** Click **"Trades"** in the top navigation bar or go to `/trades`

Comprehensive analysis of your completed trades.

### Trade History Table

All your completed buy-sell trade pairs:

| Column | Description | Example |
|--------|-------------|---------|
| **Symbol** | Stock traded | INFY |
| **Buy Price** | Your purchase price | ₹1,520.00 |
| **Sell Price** | Your selling price | ₹1,680.00 |
| **Quantity** | Shares traded | 25 |
| **P&L** | Profit or loss in ₹ | +₹4,000.00 |
| **Return %** | Percentage return | +10.53% |
| **Holding Days** | How long you held | 45 days |
| **Buy Date** | When you bought | 2026-01-15 |
| **Sell Date** | When you sold | 2026-03-01 |

**Trade Matching:** KiteEdge uses **FIFO (First-In-First-Out)** matching — the first shares you bought are matched with the first shares you sold. This is the standard method for tax reporting in India.

### Performance Dashboard

Your overall trading statistics:

| Metric | What It Means | Example |
|--------|--------------|---------|
| **Total Trades** | Number of completed round trips | 47 |
| **Total P&L** | Combined profit/loss of all trades | +₹1,23,500 |
| **Win Rate** | % of trades that were profitable | 62.5% |
| **Average Win** | Average profit on winning trades | ₹8,200 |
| **Average Loss** | Average loss on losing trades | ₹3,800 |
| **Expectancy** | Expected ₹ per trade | +₹2,725 |
| **Profit Factor** | Total wins ÷ Total losses | 2.15 |
| **Max Win Streak** | Longest consecutive winning run | 7 trades |
| **Max Loss Streak** | Longest consecutive losing run | 3 trades |

**Key metric: Profit Factor**
- **> 2.0** — Excellent
- **1.5 – 2.0** — Good
- **1.0 – 1.5** — Marginally profitable
- **< 1.0** — Losing money overall

### Equity Curve

A chart showing your **cumulative P&L over time**:
- The line starts at ₹0 and tracks every trade's impact
- **Rising line** = account growing
- **Flat line** = no trades or breakeven period
- **Falling line** = losing period

The **drawdown overlay** (shaded area below the curve) shows every decline from your best point, helping you understand your worst losing periods.

### P&L Calendar Heat-Map

A calendar view where each cell represents a day/week and is colored by P&L:

| Color | Meaning |
|-------|---------|
| **Dark Green** | Large profit |
| **Light Green** | Small profit |
| **White/Gray** | No trades or breakeven |
| **Light Red** | Small loss |
| **Dark Red** | Large loss |

Quickly spot patterns: Are Mondays consistently green? Do you lose more on Fridays? Are certain months better?

### Holding Period Analysis

| Metric | What It Shows |
|--------|---------------|
| **Average Holding** | How long you typically hold positions |
| **Median Holding** | Middle value (less affected by outliers) |
| **Shortest Trade** | Fastest round trip |
| **Longest Trade** | Longest-held position |

---

## 12. Suggestions & Alerts

**Navigation:** Click **"Signals"** in the top navigation bar or go to `/suggestions`

Smart signals, portfolio rebalancing tools, and real-time alert configuration.

> **⚠️ Disclaimer:** Signals are heuristic screens, not buy or sell recommendations. They identify potentially interesting situations based on technical patterns. Always do your own research and consider your personal financial situation.

### Signal Cards

Ranked cards showing detected opportunities across your holdings:

Each card shows:
- **🔵 Signal Type** — What pattern was detected (MA Crossover, RSI Divergence, etc.)
- **📈 Symbol** — Which stock
- **⭐ Confidence Score** — How strong the signal is (0-100)
- **📝 Description** — Plain-English explanation of what's happening

Cards are sorted by confidence score (highest first).

### Rebalance Calculator

Tools to plan portfolio restructuring:

#### Equal-Weight Rebalancing
Click **"Equal Weight"** to see:
1. **Target allocation** — Each holding gets equal weight (1/n)
2. **Current vs Target** — Side-by-side comparison
3. **Actions needed** — How many shares to buy/sell for each holding
4. **Cost estimate** — Approximate transaction cost

#### Custom Target Rebalancing
1. Click **"Custom Targets"**
2. Enter your desired percentage for each holding
3. View the deviation from your targets
4. See required trades to reach your allocation

#### Tax-Loss Harvesting
Identifies holdings with **unrealized losses** that could be sold to:
- Offset capital gains from other profitable trades
- Reduce your tax liability
- Improve portfolio allocation

The tool shows:
- Holdings with unrealized losses
- Estimated tax savings at applicable rates
- Wash sale considerations

### Diversification Analysis (Radar Chart)

A radar/spider chart showing your portfolio concentration across multiple dimensions:

| Dimension | What It Measures |
|-----------|------------------|
| **Holding Concentration** | How much any single holding dominates |
| **Sector Concentration** | Exposure to any single sector |
| **Market Cap Concentration** | Bias toward large/mid/small cap |
| **Correlation Risk** | How much holdings move together |

**HHI Interpretation:**

| HHI Value | Assessment | Action |
|-----------|------------|--------|
| **< 0.10** | Very diversified | No action needed |
| **0.10 – 0.15** | Well diversified | Healthy portfolio |
| **0.15 – 0.25** | Moderately concentrated | Consider adding variety |
| **> 0.25** | Highly concentrated | Significant risk if concentrated holdings decline |

### Alert Configuration

#### Creating a New Alert

1. Click **"+ New Alert"**
2. **Select Symbol** — Type to search, or pick from your watchlist
3. **Choose Condition:**

| Condition | Triggers When | Example |
|-----------|---------------|---------|
| **Price Above** | Price exceeds your threshold | RELIANCE > ₹2,600 |
| **Price Below** | Price drops below your threshold | INFY < ₹1,400 |
| **% Change** | Price moves by this percentage (up or down) | TCS moves ±5% in a day |

4. **Set Threshold** — Enter the value
5. **Choose Channels:**
   - ✅ **In-App** — Notification appears in the dashboard (always available)
   - ✅ **Email** — Alert sent to your email (requires SMTP configuration)
6. Click **"Save Alert"**

#### Managing Alerts
- **Edit** — Click on any alert to modify its conditions
- **Delete** — Remove alerts you no longer need
- **Pause** — Temporarily disable without deleting

#### Alert History
View a log of all triggered alerts:
- Which symbol and condition triggered
- What the price was when it fired
- When it fired
- How it was delivered

### Watchlist Manager

Organize instruments into custom lists:

1. **Create a Watchlist** — Click "New Watchlist", give it a name (e.g., "IT Stocks", "High Dividend")
2. **Add Symbols** — Search and click to add instruments
3. **Remove Symbols** — Click the × next to any symbol
4. **Delete Watchlist** — Remove the entire list

**Watchlists are used across KiteEdge:**
- Quick-switch between instruments in Technical Analysis
- Target alerts to watchlist members
- Scope signal screening to specific watchlists

---

## 13. Reports & Exports

**Navigation:** Click **"Reports"** in the top navigation bar or go to `/reports`

Generate professional reports and export your data.

### QuantStats Tear Sheet

A comprehensive single-page performance report that institutional investors use:

**What's included:**
- **Cumulative Returns** chart — your performance over time
- **Monthly Returns** heatmap — color-coded monthly performance
- **Return Distribution** — histogram of daily returns
- **Drawdown Periods** — table of worst declines
- **Rolling Sharpe Ratio** — risk-adjusted performance over time
- **Worst Drawdowns** — detailed table of each drawdown

**How to generate:**
1. Click **"Generate Tear Sheet"**
2. Optionally select a date range
3. The HTML report opens in a viewer panel
4. Click **"Download"** to save the file

### Export Center

Export your data in multiple formats:

#### Excel (XLSX)
A multi-sheet workbook containing:
- **Sheet 1: Holdings** — Full portfolio with all fields
- **Sheet 2: P&L** — Every matched trade with P&L
- **Sheet 3: Indicators** — Technical indicator values
- **Sheet 4: Risk Metrics** — All risk ratios and VaR values

*Best for: detailed analysis in Excel, record-keeping, tax preparation*

#### CSV (Comma-Separated Values)
Simple flat files for:
- Holdings data
- Trade history
- Signal data

*Best for: importing into other tools, databases, or spreadsheets*

#### PDF
A formatted report with:
- Portfolio summary
- Key performance metrics
- Charts (embedded)
- **Legal disclaimers** (mandatory on all reports)

*Best for: sharing with advisors, printing, archival*

### How to Export

1. Navigate to the **Reports** page
2. Click on the desired **export format** tab (XLSX, CSV, or PDF)
3. Optionally select a **date range** for historical data
4. Click **"Export"** or **"Download"**
5. The file downloads to your browser's default download location

> **Note:** All exports include mandatory legal disclaimers stating that the data is for informational purposes only.

---

## 14. Settings & Customization

**Navigation:** Click **"Settings"** in the top navigation bar or go to `/settings`

### Indicator Profile Settings

Customize how technical indicators are calculated:

| Setting | Default | Range | Effect |
|---------|---------|-------|--------|
| **RSI Period** | 14 | 5–50 | Shorter = more responsive, more signals. Longer = smoother, fewer false signals |
| **SMA Period 1** | 20 | 5–100 | Short-term moving average period |
| **SMA Period 2** | 50 | 20–200 | Medium-term moving average period |
| **SMA Period 3** | 200 | 100–500 | Long-term trend indicator |
| **EMA Period 1** | 12 | 5–50 | Fast EMA for MACD and crossovers |
| **EMA Period 2** | 26 | 10–100 | Slow EMA for MACD and crossovers |
| **BB Period** | 20 | 5–50 | Bollinger Band calculation window |
| **BB Std Dev** | 2.0 | 0.5–4.0 | Bollinger Band width (standard deviations) |
| **ATR Period** | 14 | 5–50 | Average True Range window |

**To change settings:**
1. Adjust the values using the input fields
2. Click **"Save Profile"**
3. Changes apply immediately to all analysis views
4. Your profile persists across sessions

**Creating Multiple Profiles:**
- Name your profile (e.g., "Swing Trading", "Day Trading", "Long-Term")
- Switch between profiles as needed
- Each profile saves independently

### Notification Preferences

| Setting | Default | Description |
|---------|---------|-------------|
| **In-App Notifications** | ✅ Enabled | Show alert banners in the dashboard |
| **Email Notifications** | ❌ Disabled | Send alerts via email |
| **Default Price Threshold** | 5.0% | Pre-filled value when creating % change alerts |

### Setting Up Email Alerts

If you want to receive alerts via email:

**Step 1:** Configure your email server in the `.env` file:

```bash
NOTIFY_EMAIL_ENABLED=true
NOTIFY_EMAIL_FROM=kiteedge-alerts@yourdomain.com

# For Gmail:
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your.email@gmail.com
SMTP_PASSWORD=your-app-password    # Use an App Password, not your real password
SMTP_TLS=true

# For Outlook:
# SMTP_HOST=smtp.office365.com
# SMTP_PORT=587
```

**Step 2:** Restart the gateway service (Ctrl+C and restart `iex -S mix phx.server`)

**Step 3:** In Settings, enable **"Email Notifications"**

**Step 4:** When creating alerts, select the **"Email"** channel

> **Gmail users:** You need an [App Password](https://support.google.com/accounts/answer/185833), not your regular Gmail password. Go to Google Account → Security → 2-Step Verification → App Passwords.

---

## 15. Power BI & Excel Integration

KiteEdge can connect directly to Excel and Power BI for custom reporting.

### Connecting Excel

**Method 1: Direct OData Feed**
1. Open Excel
2. Go to **Data** tab → **Get Data** → **From Other Sources** → **From OData Feed**
3. Enter the URL: `http://localhost:4000/api/v1/reports/odata/holdings`
4. Choose authentication method (Anonymous for local, or Basic with credentials)
5. Click **Load**

Your portfolio data appears as an Excel table. Click **Refresh All** to update with latest data.

**Method 2: Export to XLSX**
1. Go to **Reports** page in KiteEdge
2. Click **"XLSX"** export
3. Open the downloaded file in Excel

### Connecting Power BI Desktop

1. Open Power BI Desktop
2. Click **Get Data** → **OData Feed**
3. Enter: `http://localhost:4000/api/v1/reports/odata/holdings`
4. Select the `holdings` table
5. Click **Load**
6. Build custom visuals, dashboards, and reports

**OData Metadata:** View the data model at:
`http://localhost:4000/api/v1/reports/odata/$metadata`

### Power BI Real-Time Streaming

For live-updating Power BI dashboards:

1. In Power BI Service, create a **Streaming Dataset**
2. Copy the **Push URL** provided by Power BI
3. Configure KiteEdge to push data to that URL
4. Portfolio updates stream to Power BI in real-time

---

## 16. Understanding Data Freshness

KiteEdge shows a **freshness indicator** on every page to help you understand how current your data is.

### Freshness Levels

| Indicator | Color | Status | When It Happens |
|-----------|-------|--------|-----------------|
| 🟢 | Green | **Live** | Normal — connected to Kite, receiving real-time prices |
| 🟡 | Yellow | **Stale** | Temporary issue — data is slightly behind (< 5 min) |
| 🔴 | Red | **Offline** | Using cached data — Kite is unavailable |

### When Does Offline Mode Happen?

- **After market hours** — NSE closes at 3:30 PM IST. After-hours data is cached.
- **Network issues** — If your connection to Kite is interrupted
- **Kite maintenance** — During Zerodha's maintenance windows
- **Weekend / Holidays** — No live data available

### What Works in Offline Mode?

| Feature | Offline Status |
|---------|---------------|
| Portfolio Overview | ✅ Shows last-known prices (with offline badge) |
| Technical Analysis | ✅ Works on historical data |
| Risk Dashboard | ✅ Works on historical data |
| Predictions | ✅ Generates forecasts from cached data |
| Trade Journal | ✅ Fully functional (uses stored data) |
| Suggestions | ✅ Signals generated from cached data |
| Reports | ✅ Generates from available data |
| Real-time prices | ❌ Not available until reconnection |

When Kite reconnects, data automatically refreshes.

---

## 17. Security & Privacy

### Your Data Stays With You

KiteEdge is **entirely self-hosted**. Your financial data never leaves your machine:

- ❌ No data sent to cloud analytics services
- ❌ No usage telemetry or tracking
- ❌ No third-party services receive your portfolio data
- ✅ All processing happens on your local machine

### What KiteEdge Can Access

| Access | Permission |
|--------|------------|
| ✅ Read your holdings and positions | Required for portfolio overview |
| ✅ Read your order and trade history | Required for trade journal |
| ✅ Read historical OHLCV price data | Required for indicators and forecasts |
| ✅ Subscribe to real-time price feeds | Required for live updates |

### What KiteEdge CANNOT Do

| Capability | Status |
|------------|--------|
| ❌ Place, modify, or cancel orders | **Never.** By design |
| ❌ Transfer funds | **Never.** No access |
| ❌ Modify Zerodha account settings | **Never.** Read-only |
| ❌ Access banking information | **Never.** Not available via Kite API |

KiteEdge uses **read-only** API access. It is analytically passive — it can only observe, never act.

### Token Security

| Aspect | How It's Protected |
|--------|-------------------|
| **Where tokens live** | Redis only (in-memory), never saved to files or database |
| **How long they last** | 18 hours, then automatically deleted |
| **Logging** | Tokens are automatically scrubbed from all log output |
| **API responses** | Tokens never returned in any response |
| **Communication** | All Kite API calls use HTTPS encryption |
| **On sign-out** | Token immediately and permanently deleted |

### Rate Limiting

KiteEdge enforces Kite's **3 requests/second** API limit:
- A server-side rate limiter queues requests if the limit would be exceeded
- Your API subscription is protected from accidental overuse
- You'll never be blocked or penalized by Zerodha due to KiteEdge

---

## 18. Frequently Asked Questions

### Getting Started

**Q: How much does KiteEdge cost?**
A: KiteEdge itself is free and open-source. You need a Zerodha Kite Connect API subscription (₹2,000/month from Zerodha) to connect to your account.

**Q: Do I need to keep my computer running?**
A: Yes, KiteEdge runs on your local machine. When you shut down your computer, KiteEdge stops. Your data persists in the database and will be available when you restart.

**Q: Can I access KiteEdge from my phone?**
A: KiteEdge's dashboard is web-based and responsive. You can access it from any device on your local network by navigating to `http://your-computer-ip:5173`. However, it's optimized for desktop use.

### Portfolio Questions

**Q: Why don't I see all my holdings?**
A: Holdings sync from Kite every 5 minutes during market hours. If you just made a purchase, wait a few minutes and the page will auto-refresh.

**Q: What does XIRR mean and why is it different from simple return %?**
A: XIRR (Extended Internal Rate of Return) accounts for WHEN you invested, not just how much. If you invested ₹1,00,000 that grew to ₹1,15,000 in 6 months, the simple return is 15% but the XIRR (annualized) is about 32%.

**Q: Why does my P&L differ slightly from Kite's console?**
A: Minor differences may occur due to:
- Price update timing differences
- Rounding in calculations
- Corporate actions not yet reflected
This is normal and the differences are typically very small.

### Analysis Questions

**Q: Which timeframe should I use for technical analysis?**
A: Depends on your investment horizon:
- **Daily** — Best for swing trading (days to weeks)
- **Weekly** — Best for position trading (weeks to months)
- **Monthly** — Best for long-term investing (months to years)

**Q: What does it mean when the Summary Score says "Neutral"?**
A: A neutral score means indicators are giving mixed signals — some bullish, some bearish. It's common during consolidation or range-bound periods. Wait for a clearer signal or use other analysis methods.

**Q: Can I add my own custom indicators?**
A: You can customize parameters (RSI period, SMA length, etc.) in Settings. Adding entirely new indicator types requires code modification.

### Risk & Forecast Questions

**Q: Should I trust the forecasts?**
A: **No forecast should be blindly trusted.** KiteEdge's forecasts are statistical projections that show POSSIBLE outcomes based on historical patterns. They are one tool among many. Use them alongside fundamental analysis, market conditions, and your own judgment.

**Q: What does "95% VaR = ₹50,000" actually mean?**
A: "Based on historical data, there's a 95% chance you won't lose more than ₹50,000 in a single trading day." But there's still a 5% chance you could lose MORE than that. VaR does NOT tell you the maximum possible loss.

**Q: Why are my Monte Carlo paths so wide?**
A: Wide paths indicate high uncertainty, which could be due to:
- High portfolio volatility
- Short historical data period
- Mix of highly volatile stocks
This is informational — wider paths mean MORE uncertainty, not necessarily more risk.

### Alert Questions

**Q: How quickly are alerts delivered?**
A: In-app alerts appear within seconds of the condition being met. Email alerts may have additional 10-30 second delay depending on your SMTP server.

**Q: Can I set alerts for stocks I don't own?**
A: Yes! Add any instrument to a watchlist, then create alerts for those instruments.

**Q: Will I get duplicate alerts?**
A: Once an alert fires, it won't fire again until the condition resets and triggers again.

### Data & Privacy Questions

**Q: Is my data safe?**
A: Yes. All data stays on your local machine. No data is sent to external services. Access tokens are stored only in memory (Redis) and auto-expire. See Section 17 for full details.

**Q: Can Zerodha see what analytics I'm running?**
A: Zerodha can see that your API key is making data requests (fetching holdings, historical data), but they cannot see any of KiteEdge's analysis results, forecasts, or signals.

---

## 19. Troubleshooting

### Login Issues

**Problem: "Sign in with Kite" button doesn't work**
- ✅ Verify `KITE_API_KEY` and `KITE_API_SECRET` in `.env` are correct
- ✅ Check that the redirect URL in Kite developer console matches exactly: `http://localhost:4000/auth/kite/callback`
- ✅ Ensure the Elixir gateway is running on port 4000
- ✅ Check for browser popup blockers

**Problem: "Session expired" appears repeatedly**
- This is normal behavior. Kite sessions last 18 hours and expire around 6 AM IST.
- Click "Sign in with Kite" to start a new session.

**Problem: Error after Kite login redirect**
- ✅ Check the gateway terminal for error messages
- ✅ Verify your Kite API subscription is active
- ✅ Check that Redis is running: `docker-compose ps redis`

### Dashboard Issues

**Problem: Dashboard shows no data**
1. Check gateway health: Open `http://localhost:4000/health`
2. Check analytics engine: Open `http://localhost:8001/health`
3. Open browser developer tools (F12) → Console tab → look for errors
4. Verify `VITE_GATEWAY_URL` in dashboard `.env` matches your gateway

**Problem: Prices not updating in real-time**
- Check the freshness indicator in the top-right corner
- If showing "Offline", check your internet connection and Kite status
- Try refreshing the page
- Check that the WebSocket connection is established (F12 → Network → WS tab)

**Problem: Charts not loading**
- Clear browser cache (Ctrl+Shift+Delete)
- Try a different browser (Chrome or Firefox recommended)
- Disable ad blockers temporarily
- Check for JavaScript errors in browser console (F12)

### Performance Issues

**Problem: Risk analysis is very slow**
- Normal for portfolios with 30+ holdings — Monte Carlo runs 10,000 simulations
- First calculation takes longest; results are cached afterward
- Try reducing the number of holdings analyzed if too slow

**Problem: Technical analysis takes long to load**
- First load fetches historical data from Kite
- Subsequent loads use cached data and are faster
- Check your internet connection speed

### Service Issues

**Problem: Docker services won't start**
```bash
# Check what's running
docker-compose ps

# View logs for a specific service
docker-compose logs postgres
docker-compose logs redis

# Restart everything
docker-compose down
docker-compose up -d
```

**Problem: Port already in use**
```bash
# Windows — find what's using port 4000
netstat -ano | findstr :4000

# macOS/Linux
lsof -i :4000

# Change ports in .env if needed
```

**Problem: Email alerts not working**
1. Check `NOTIFY_EMAIL_ENABLED=true` in `.env`
2. Verify SMTP settings (host, port, username, password)
3. Enable "Email" in Settings → Notification Preferences
4. For Gmail: Use an [App Password](https://support.google.com/accounts/answer/185833)
5. Check gateway logs for SMTP error messages

### Data Issues

**Problem: Historical data seems incomplete**
- Historical backfill runs on-demand for the instruments you analyze
- The first analysis of an instrument may take longer as data is fetched
- Very recent IPOs may have limited history

**Problem: Indicator values seem wrong**
- Verify you're looking at the right timeframe (1D/1W/1M)
- Check your custom indicator profile settings
- KiteEdge validates against the `ta` library within 0.01% — if you see large discrepancies, report a bug

---

## 20. Glossary

### A-D

| Term | Definition |
|------|-----------|
| **ADX** | Average Directional Index — measures trend strength (not direction). ADX > 25 = strong trend |
| **Alpha** | The excess return your portfolio earns above what the market model predicts. Positive alpha = outperforming |
| **ARIMA** | AutoRegressive Integrated Moving Average — a statistical model for forecasting time series data |
| **ATR** | Average True Range — the average daily price range, measuring how much a stock typically moves in a day |
| **Beta** | How much your portfolio moves relative to the market. Beta of 1.0 = moves identically to NIFTY |
| **Bollinger Bands** | An envelope around price set at ±2 standard deviations from a moving average. Measures volatility |
| **CAGR** | Compound Annual Growth Rate — your smoothed annual return rate |
| **Calmar Ratio** | Annual return divided by the worst drawdown — measures return per unit of maximum pain |
| **CCI** | Commodity Channel Index — measures how far price has moved from its average |
| **CVaR** | Conditional Value at Risk (Expected Shortfall) — the average loss when things go worse than VaR |

### D-H

| Term | Definition |
|------|-----------|
| **Donchian Channel** | A channel formed by the highest high and lowest low over a period. Breakouts signal trends |
| **Drawdown** | The decline from a portfolio's peak value to its lowest point before recovering |
| **EMA** | Exponential Moving Average — like SMA but gives more weight to recent prices, making it more responsive |
| **Ensemble** | A combined forecast that blends multiple model predictions (ARIMA + Prophet) for better accuracy |
| **FIFO** | First-In-First-Out — buy/sell matching method: earliest purchases matched to earliest sales |
| **GBM** | Geometric Brownian Motion — the mathematical model used in Monte Carlo simulation for stock prices |
| **HHI** | Herfindahl-Hirschman Index — measures portfolio concentration. Lower = more diversified |

### I-M

| Term | Definition |
|------|-----------|
| **Ichimoku** | A Japanese charting technique that shows trend, momentum, and support/resistance using 5 lines and a cloud |
| **Information Ratio** | Measures how consistently you outperform a benchmark, adjusted for risk |
| **KAMA** | Kaufman's Adaptive Moving Average — a smart moving average that adjusts its speed based on market conditions |
| **Keltner Channel** | Volatility channel using ATR around an EMA, similar to Bollinger Bands but smoother |
| **Ledoit-Wolf** | A statistical technique for computing more reliable correlation estimates, especially with limited data |
| **MACD** | Moving Average Convergence Divergence — shows the relationship between two moving averages. Crossovers signal trend changes |
| **MAE** | Mean Absolute Error — average forecast error (in ₹). Lower is more accurate |
| **MAPE** | Mean Absolute Percentage Error — forecast accuracy as a percentage. < 5% is good |
| **MFI** | Money Flow Index — volume-weighted RSI. Measures buying/selling pressure |
| **Monte Carlo** | Simulation technique that runs thousands of random scenarios to understand the range of possible outcomes |

### O-R

| Term | Definition |
|------|-----------|
| **OBV** | On-Balance Volume — running total of volume flow. Rising OBV = buying pressure |
| **OData** | Open Data Protocol — a standard way for apps like Excel and Power BI to query data from web services |
| **OHLCV** | Open-High-Low-Close-Volume — the standard format for price data |
| **P&L** | Profit and Loss — how much money you made or lost |
| **Parabolic SAR** | Stop-And-Reverse indicator — dots below price = uptrend, dots above = downtrend |
| **Prophet** | Facebook's open-source forecasting tool, configured here for Indian stock market patterns |
| **RMSE** | Root Mean Squared Error — like MAE but penalizes large errors more. Lower is more accurate |
| **ROC** | Rate of Change — percentage price change over a specific period |
| **RSI** | Relative Strength Index — oscillates 0-100. > 70 = overbought, < 30 = oversold |

### S-Z

| Term | Definition |
|------|-----------|
| **Sharpe Ratio** | The most common risk-adjusted return metric. Return earned per unit of risk. > 1 is good |
| **SMA** | Simple Moving Average — arithmetic mean of prices over a period. Smooths out noise |
| **Sortino Ratio** | Like Sharpe but only penalizes downside moves, not upside volatility |
| **Stochastic RSI** | RSI applied to RSI — faster, more sensitive momentum indicator |
| **Stress Test** | Applying past crisis conditions to your current portfolio to estimate potential impact |
| **SuperTrend** | Trend-following indicator — green = uptrend, red = downtrend |
| **Treynor Ratio** | Return per unit of market (systematic) risk |
| **TSI** | True Strength Index — double-smoothed momentum indicator |
| **TTL** | Time-To-Live — how long data is kept before expiring (sessions have 18h TTL) |
| **VaR** | Value at Risk — the maximum expected loss at a given confidence level |
| **VWAP** | Volume-Weighted Average Price — the average price weighted by volume. Institutional benchmark |
| **WebSocket** | Technology that maintains a persistent connection for real-time data streaming |
| **Williams %R** | Momentum oscillator. -20 = overbought, -80 = oversold |
| **XIRR** | Extended Internal Rate of Return — annualized return accounting for irregular investment timing |

---

## Quick Reference Card

### Service URLs

| Service | URL |
|---------|-----|
| **Dashboard** | http://localhost:5173 |
| **Gateway** | http://localhost:4000 |
| **Analytics** | http://localhost:8001 |
| **Grafana** | http://localhost:3001 |

### Navigation Map

| Page | Route | What It Does |
|------|-------|-------------|
| **Login** | `/` | Sign in with Kite |
| **Portfolio** | `/dashboard` | Holdings, allocation, P&L, real-time prices |
| **Analysis** | `/analysis` | 43+ indicators, charts, patterns, S/R levels |
| **Risk** | `/risk` | Risk ratios, VaR, Monte Carlo, stress tests |
| **Predictions** | `/predictions` | ARIMA/Prophet forecasts, signals, accuracy |
| **Trades** | `/trades` | FIFO trade history, win rate, equity curve |
| **Signals** | `/suggestions` | Signal cards, alerts, rebalance, watchlists |
| **Reports** | `/reports` | Tear sheets, XLSX/CSV/PDF exports, Power BI |
| **Settings** | `/settings` | Indicator params, notifications, preferences |

---

*For technical details and developer documentation, see the [Developer Guide](DEVELOPER_GUIDE.md).*

*KiteEdge is a personal portfolio-analytics tool. It does not provide investment advice. All forecasts, signals, and suggestions are for educational and informational purposes only. Past performance does not guarantee future results.*

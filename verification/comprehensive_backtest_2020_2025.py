import yfinance as yf
import pandas as pd
import numpy as np
import datetime
from pathlib import Path
import os

# --- Configuration (V4 Strategy) ---
class Config:
    SYMBOLS = ["GC=F"]  # Gold Futures
    START_DATE = "2026-01-01"
    END_DATE = "2026-02-15"
    INTERVAL = "1h"  # Hourly data
    
    INITIAL_BALANCE = 100000.0
    RISK_PERCENT = 0.0075  # 0.75% base risk
    SPREAD_COST = 0.20
    ATR_PERIOD = 14
    CONTRACT_SIZE = 100
    
    # V4 Strategy Parameters
    SL_ATR_MULT = 1.5
    TP_ATR_MULT = 2.5
    MIN_ATR = 1.0
    USE_MEAN_REV = True
    USE_PULLBACK = True
    USE_HTF_FILTER = True
    USE_EXTREME_RSI = True
    USE_ADX_FILTER = True  # V4 Key Feature

class Backtester:
    def __init__(self, symbol):
        self.symbol = symbol
        self.data = None
        self.balance = Config.INITIAL_BALANCE
        self.equity_curve = []
        self.trade_log = []
        
    def fetch_data(self):
        print(f"Fetching {self.symbol} data from {Config.START_DATE} to {Config.END_DATE}...")
        try:
            self.data = yf.download(
                self.symbol,
                start=Config.START_DATE,
                end=Config.END_DATE,
                interval=Config.INTERVAL,
                progress=False
            )
            
            if self.data.empty:
                print("ERROR: No data fetched!")
                return False
                
            # Handle MultiIndex columns
            if isinstance(self.data.columns, pd.MultiIndex):
                self.data.columns = self.data.columns.get_level_values(0)
            
            print(f"Data fetched: {len(self.data)} rows from {self.data.index[0]} to {self.data.index[-1]}")
            
            # Calculate indicators
            self.calculate_indicators()
            return True
            
        except Exception as e:
            print(f"Error fetching data: {e}")
            return False
    
    def calculate_indicators(self):
        """Calculate all technical indicators"""
        # ATR
        high_low = self.data['High'] - self.data['Low']
        high_close = np.abs(self.data['High'] - self.data['Close'].shift())
        low_close = np.abs(self.data['Low'] - self.data['Close'].shift())
        ranges = pd.concat([high_low, high_close, low_close], axis=1)
        true_range = np.max(ranges, axis=1)
        self.data['ATR'] = true_range.rolling(Config.ATR_PERIOD).mean()
        
        # Bollinger Bands
        self.data['SMA_20'] = self.data['Close'].rolling(20).mean()
        self.data['StdDev'] = self.data['Close'].rolling(20).std()
        self.data['UpperBB'] = self.data['SMA_20'] + (2.5 * self.data['StdDev'])
        self.data['LowerBB'] = self.data['SMA_20'] - (2.5 * self.data['StdDev'])
        
        # EMAs
        self.data['EMA_Fast'] = self.data['Close'].ewm(span=9, adjust=False).mean()
        self.data['EMA_Slow'] = self.data['Close'].ewm(span=21, adjust=False).mean()
        self.data['EMA_50'] = self.data['Close'].ewm(span=50, adjust=False).mean()
        
        # RSI
        delta = self.data['Close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
        rs = gain / loss
        self.data['RSI'] = 100 - (100 / (1 + rs))
        
        # ADX (V4 Feature)
        plus_dm = self.data['High'].diff()
        minus_dm = -self.data['Low'].diff()
        plus_dm = plus_dm.where((plus_dm > 0) & (plus_dm > minus_dm), 0)
        minus_dm = minus_dm.where((minus_dm > 0) & (minus_dm > plus_dm), 0)
        
        atr_1 = true_range
        atr_smooth = atr_1.rolling(14).mean()
        plus_di = 100 * (plus_dm.rolling(14).mean() / atr_smooth)
        minus_di = 100 * (minus_dm.rolling(14).mean() / atr_smooth)
        dx = 100 * np.abs(plus_di - minus_di) / (plus_di + minus_di)
        self.data['ADX'] = dx.rolling(14).mean()
        
        # Fill NaN values
        self.data['ADX'] = self.data['ADX'].fillna(20)
        
    def run_simulation(self):
        """Run the V4 strategy simulation"""
        if not self.fetch_data():
            return
        
        position = 0
        entry_price = 0
        current_sl_dist = 0
        current_tp_dist = 0
        entry_time = None
        hwm = Config.INITIAL_BALANCE
        
        print(f"\nStarting simulation with ${Config.INITIAL_BALANCE:,.2f}...")
        
        for i in range(55, len(self.data)):
            timestamp = self.data.index[i]
            current_open = self.data['Open'].iloc[i]
            curr_high = self.data['High'].iloc[i]
            curr_low = self.data['Low'].iloc[i]
            
            # Update HWM and calculate drawdown
            if self.balance > hwm:
                hwm = self.balance
            current_dd_pct = (hwm - self.balance) / hwm * 100.0
            
            # V3.2 Aggressive Risk Scaler
            risk_modifier = 1.0
            if current_dd_pct >= 0.5: risk_modifier = 0.666
            if current_dd_pct >= 1.0: risk_modifier = 0.333
            if current_dd_pct >= 1.5: risk_modifier = 0.133
            if current_dd_pct >= 2.0: risk_modifier = 0.0  # HARD STOP
            
            # Get previous bar data
            idx_prev = i - 1
            close_prev = self.data['Close'].iloc[idx_prev]
            open_prev = self.data['Open'].iloc[idx_prev]
            high_prev_2 = self.data['High'].iloc[i-2]
            low_prev_2 = self.data['Low'].iloc[i-2]
            atr = self.data['ATR'].iloc[idx_prev]
            upper_bb = self.data['UpperBB'].iloc[idx_prev]
            lower_bb = self.data['LowerBB'].iloc[idx_prev]
            ema_fast = self.data['EMA_Fast'].iloc[idx_prev]
            ema_slow = self.data['EMA_Slow'].iloc[idx_prev]
            ema_50 = self.data['EMA_50'].iloc[idx_prev]
            rsi = self.data['RSI'].iloc[idx_prev]
            adx = self.data['ADX'].iloc[idx_prev]
            
            # Exit logic
            if position != 0:
                exit_price = 0
                triggered = False
                sl_price = entry_price - current_sl_dist if position == 1 else entry_price + current_sl_dist
                tp_price = entry_price + current_tp_dist if position == 1 else entry_price - current_tp_dist
                
                if position == 1:
                    if curr_low <= sl_price:
                        exit_price = sl_price
                        triggered = True
                    elif curr_high >= tp_price:
                        exit_price = tp_price
                        triggered = True
                else:
                    if curr_high >= sl_price:
                        exit_price = sl_price
                        triggered = True
                    elif curr_low <= tp_price:
                        exit_price = tp_price
                        triggered = True
                
                if triggered and risk_modifier > 0:
                    risk_amt = self.balance * (Config.RISK_PERCENT * risk_modifier)
                    units = risk_amt / current_sl_dist
                    lots = units / Config.CONTRACT_SIZE
                    raw_diff = (exit_price - entry_price) if position == 1 else (entry_price - exit_price)
                    pnl = raw_diff * units
                    
                    self.balance += pnl
                    self.trade_log.append({
                        "EntryTime": entry_time,
                        "ExitTime": timestamp,
                        "Direction": "BUY" if position == 1 else "SELL",
                        "EntryPrice": entry_price,
                        "ExitPrice": exit_price,
                        "Lots": round(lots, 2),
                        "PnL": round(pnl, 2),
                        "Balance": round(self.balance, 2),
                        "DD%": round(current_dd_pct, 2)
                    })
                    position = 0
            
            # Entry logic
            if position == 0 and risk_modifier > 0:
                signal_found = False
                trade_atr = max(atr, Config.MIN_ATR)
                
                # HTF Filter
                can_buy = True
                can_sell = True
                is_extreme_rsi_buy = (rsi < 25)
                is_extreme_rsi_sell = (rsi > 75)
                
                if Config.USE_HTF_FILTER and not is_extreme_rsi_buy:
                    can_buy = close_prev > ema_50
                if Config.USE_HTF_FILTER and not is_extreme_rsi_sell:
                    can_sell = close_prev < ema_50
                
                # V4 ADX Filter (only for trend trades)
                adx_ok = True
                if not (is_extreme_rsi_buy or is_extreme_rsi_sell):
                    if adx < 20:
                        adx_ok = False
                
                # 1. Momentum Breakout
                if atr >= Config.MIN_ATR and adx_ok:
                    if close_prev > high_prev_2 and close_prev > open_prev and can_buy:
                        entry_price = current_open + Config.SPREAD_COST
                        position = 1
                        signal_found = True
                    elif close_prev < low_prev_2 and close_prev < open_prev and can_sell:
                        entry_price = current_open - Config.SPREAD_COST
                        position = -1
                        signal_found = True
                
                # 2. Mean Reversion
                if not signal_found and Config.USE_MEAN_REV:
                    if close_prev > upper_bb and can_sell:
                        entry_price = current_open - Config.SPREAD_COST
                        position = -1
                        signal_found = True
                    elif close_prev < lower_bb and can_buy:
                        entry_price = current_open + Config.SPREAD_COST
                        position = 1
                        signal_found = True
                
                # 3. Pullback
                if not signal_found and Config.USE_PULLBACK and adx_ok:
                    if ema_fast > ema_slow and can_buy:
                        low_prev = self.data['Low'].iloc[idx_prev]
                        if low_prev <= ema_fast and close_prev > ema_fast:
                            entry_price = current_open + Config.SPREAD_COST
                            position = 1
                            signal_found = True
                    elif ema_fast < ema_slow and can_sell:
                        high_prev = self.data['High'].iloc[idx_prev]
                        if high_prev >= ema_fast and close_prev < ema_fast:
                            entry_price = current_open - Config.SPREAD_COST
                            position = -1
                            signal_found = True
                
                if signal_found:
                    entry_time = timestamp
                    current_sl_dist = trade_atr * Config.SL_ATR_MULT
                    current_tp_dist = trade_atr * Config.TP_ATR_MULT
            
            # Record equity
            self.equity_curve.append({
                "Time": timestamp,
                "Equity": self.balance
            })
        
        print(f"Simulation complete. Final balance: ${self.balance:,.2f}")
        print(f"Total trades: {len(self.trade_log)}")
    
    def generate_daily_report(self):
        """Generate detailed daily breakdown"""
        if not self.trade_log:
            print("No trades to analyze!")
            return
        
        df_trades = pd.DataFrame(self.trade_log)
        df_trades['ExitTime'] = pd.to_datetime(df_trades['ExitTime'])
        
        all_days = pd.date_range(start=Config.START_DATE, end=Config.END_DATE, freq='D')
        
        daily_data = []
        current_balance = Config.INITIAL_BALANCE
        
        for date in all_days:
            # Filter trades that exited on this day
            day_trades = df_trades[df_trades['ExitTime'].dt.date == date.date()]
            
            net_profit = day_trades['PnL'].sum() if not day_trades.empty else 0
            trades_count = len(day_trades)
            wins = len(day_trades[day_trades['PnL'] > 0])
            win_rate = (wins / trades_count * 100) if trades_count > 0 else 0
            current_vol = day_trades['Lots'].sum() if not day_trades.empty else 0
            
            gross_win = day_trades[day_trades['PnL'] > 0]['PnL'].sum()
            gross_loss = abs(day_trades[day_trades['PnL'] < 0]['PnL'].sum())
            profit_factor = (gross_win / gross_loss) if gross_loss > 0 else (gross_win if gross_win > 0 else 0)
            
            starting_balance = current_balance
            ending_balance = current_balance + net_profit
            return_pct = (net_profit / starting_balance * 100) if starting_balance > 0 else 0
            
            # Max DD for the day (simplified since we only have exit balances)
            max_dd = day_trades['DD%'].max() if not day_trades.empty else 0
            
            # Status
            if trades_count > 0:
                status = "✅ Profitable" if net_profit > 0 else "❌ Loss"
            else:
                status = "⏸️ Inactive"
            
            daily_data.append({
                "Date": date.strftime("%Y-%m-%d"),
                "Month": date.strftime("%Y-%m"),
                "Starting Balance": round(starting_balance, 2),
                "Ending Balance": round(ending_balance, 2),
                "Profit ($)": round(net_profit, 2),
                "Return (%)": round(return_pct, 2),
                "Max DD (%)": round(max_dd, 2),
                "Trades": trades_count,
                "Win Rate (%)": round(win_rate, 1),
                "Current Volume": round(current_vol, 2),
                "Profit Factor": round(profit_factor, 2),
                "Status": status
            })
            
            current_balance = ending_balance
            
        df_daily = pd.DataFrame(daily_data)
        
        # Save to CSV
        csv_path = "DETAILED_DAILY_BACKTEST_2026.csv"
        df_daily.to_csv(csv_path, index=False)
        print(f"\nCSV saved: {csv_path}")
        
        # Save to Desktop
        desktop_path = os.path.join(os.path.expanduser("~"), "Desktop", "DETAILED_DAILY_BACKTEST_2026.csv")
        df_daily.to_csv(desktop_path, index=False)
        print(f"CSV also saved to Desktop: {desktop_path}")
        
        # Generate Markdown Report
        report_md = f"# Detailed Daily Backtest Report (Jan-Feb 2026)\n\n"
        report_md += f"*Strategy: SHADOWbot Pro V4 (Hedge Fund Grade)*\n"
        report_md += f"*Period: {Config.START_DATE} to {Config.END_DATE}*\n\n"
        
        report_md += "## Performance Summary\n"
        total_profit = df_daily['Profit ($)'].sum()
        total_return = (total_profit / Config.INITIAL_BALANCE) * 100
        total_trades = df_daily['Trades'].sum()
        report_md += f"- **Initial Balance**: ${Config.INITIAL_BALANCE:,.2f}\n"
        report_md += f"- **Final Balance**: ${current_balance:,.2f}\n"
        report_md += f"- **Total Net Profit**: ${total_profit:,.2f} ({total_return:.2f}%)\n"
        report_md += f"- **Total Trades**: {total_trades}\n\n"
        
        report_md += "## Daily Breakdown\n\n"
        report_md += df_daily.to_markdown(index=False)
        
        with open("DETAILED_DAILY_REPORT.md", "w") as f:
            f.write(report_md)
        print(f"Markdown report saved: DETAILED_DAILY_REPORT.md")
        
        return df_daily

if __name__ == "__main__":
    bt = Backtester("GC=F")
    bt.run_simulation()
    bt.generate_daily_report()

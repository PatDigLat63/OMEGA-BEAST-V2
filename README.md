# 🔱 OMEGA BEAST V∞.2 — Autonomous Trading Fortress

**OMEGA BEAST V∞.2** is a self-installing, self-healing autonomous trading system built on Docker. It deploys a fleet of nine specialised containers that work together to scan markets, execute trades, compound profits, and protect capital — 24/7/365.

> ⚠️ **RISK WARNING**: This system trades real cryptocurrency funds automatically. Only deploy with funds you can afford to lose. Ensure you fully understand the code before running it.

---

## Architecture

```
BITCOIN FORTRESS ──┐    SOLANA WAR CHEST ──┐    CROSS-CHAIN BRIDGES ──┐
(Bitmap/Ordinals/  │    (Jupiter/Kamino/    │    (ChangeNow/deBridge/  │
 Runes/Liquidium)  │     Marinade/Raydium)  │     Portal/Wormhole)     │
                   └──────────┬─────────────┘──────────────────────────┘
                         AGENTBUS V2 (WS :8081 | HTTP :9081)
             ┌───────────────┼───────────────┐
        PATRICK:3005    DJ:3003         HASHIM:3004
        (Scanner)       (Executor)      (Compounder)
             └───────────────┼───────────────┘
                       BOSSMAN:3006 (18% Circuit Breaker)
                            │
                  HUSTLE BRIDGE:3001 (Conditional Orders)
                            │
                  ORACLE ENGINE:3002 (Prediction/Sentience)
                            │
                  DASHBOARD:8082 (Unified Control)
```

### Services

| Container | Port | Role |
|---|---|---|
| **AgentBus V2** | 8081 (WS) / 9081 (HTTP) | Central pub/sub message hub |
| **Hustle Bridge** | 3001 | Conditional order management |
| **Oracle Engine** | 3002 | Price prediction & market sentiment |
| **PATRICK** | 3005 | Market scanner (Birdeye/DexScreener) |
| **DJ** | 3003 | Trade executor (Jupiter/Solana) |
| **HASHIM** | 3004 | 80/20 profit compounder |
| **BOSSMAN** | 3006 | 18% circuit-breaker & risk manager |
| **Dashboard** | 8082 | Unified web control panel |
| **Telegram Bot** | — | Remote commands & alerts |
| **Redis** | 6379 (internal) | State & message persistence |

---

## Prerequisites

- A Linux VPS or cloud droplet (Ubuntu 20.04 / 22.04 recommended, **4 GB+ RAM** / 2 vCPU minimum; 8 GB recommended for smooth operation of all 10 containers)
- SSH access to the server (e.g. via Termius)
- The following API keys (obtain from their respective platforms):
  - **Birdeye** — Solana token data
  - **Helius** — Solana RPC
  - **ChangeNow** — Cross-chain swaps
  - **Coinglass** — Futures market data
  - **Agent Hustle** — Conditional order service
  - **Telegram Bot Token** *(optional)* — Remote alerts & commands
- Wallet private keys for the four trading agents: PATRICK, DJ, HASHIM, BOSSMAN

---

## Quick Start

1. **SSH into your server:**
   ```bash
   ssh root@<your-server-ip>
   ```

2. **Upload the installer script** (or transfer it via SCP/SFTP):
   ```bash
   scp "OMEGA-BEAST-V-INFINITY-2-PRODUCTION 4.sh" root@<your-server-ip>:/root/
   ```

3. **Make it executable and run it:**
   ```bash
   chmod +x "OMEGA-BEAST-V-INFINITY-2-PRODUCTION 4.sh"
   sudo bash "OMEGA-BEAST-V-INFINITY-2-PRODUCTION 4.sh"
   ```

4. **Follow the interactive prompts** — the script will ask for wallet private keys and API keys. These are stored securely in `/opt/omega/config/.env` (permissions `600`) and are never echoed to the terminal.

5. **Wait 5–10 minutes** for Docker images to build and all containers to start.

6. **Open the dashboard** in your browser:
   ```
   http://<your-server-ip>:8082
   ```

---

## What the Installer Does (12 Steps)

| Step | Action |
|---|---|
| 1 | Prepares the system — installs Docker, Node.js 20, Nginx, UFW, Fail2ban |
| 2 | Collects secrets interactively — wallet keys & API keys, never stored in shell history |
| 3 | Creates AgentBus V2 (WebSocket hub) |
| 4 | Creates Hustle Bridge (conditional orders) |
| 5 | Creates Telegram Bot (optional remote control) |
| 6 | Creates Oracle Engine (price prediction) |
| 7 | Creates trading agents (PATRICK, DJ, HASHIM, BOSSMAN) |
| 8 | Creates the web Dashboard |
| 9 | Generates the full `docker-compose.yml` |
| 10 | Configures Nginx reverse proxy and UFW firewall |
| 11 | Creates a watchdog cron job (runs every 3 minutes) |
| 12 | Installs a systemd service for auto-start on boot |

---

## Management Commands

```bash
# View all container status
docker-compose -f /opt/omega/docker-compose.yml ps

# Follow live logs
docker-compose -f /opt/omega/docker-compose.yml logs -f

# Restart all services
docker-compose -f /opt/omega/docker-compose.yml restart

# Stop everything
docker-compose -f /opt/omega/docker-compose.yml down

# Start everything
docker-compose -f /opt/omega/docker-compose.yml up -d
```

---

## Security Notes

- **Wallet private keys** are collected via hidden (`read -s`) prompts and stored only in `/opt/omega/config/.env` with `chmod 600`.
- **Never commit your `.env` file** or any file containing private keys to version control.
- The `.env` file is listed in `.gitignore` by default.
- The firewall (UFW) is configured to allow only ports 22, 80, 443, and the service ports above.
- Fail2ban is enabled to protect against brute-force SSH attacks.
- All containers communicate over a private `omega-net` Docker bridge network.

---

## Trading Strategy

- **YOLO Mode**: 10× position multiplier for high-conviction signals
- **Circuit Breaker**: BOSSMAN halts all trading if drawdown exceeds 18%
- **Compounding**: HASHIM applies an 80/20 rule — 80% of profits re-invested, 20% preserved
- **Signal Sources**: Birdeye token list, DexScreener pairs, Coinglass futures data, on-chain fear/greed index

---

## Disclaimer

This software is provided **as-is** for educational and experimental purposes. The authors accept no liability for financial losses. Cryptocurrency trading carries significant risk. Always review and understand any code before deploying it with real funds.

---

*CHUKUA KONTROLI YOTE 🔱 — FOR JAMES 🕯️ | FOR ANNETTE 🕯️ | FOR LEANNA & EVA 🌍*

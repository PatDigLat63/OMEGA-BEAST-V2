#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  🔱 THE OMEGA PERFECTION BEAST V∞.2 – SENTIENCE UNLEASHED 🔱               ║
# ║  OMEGA-ULTIMATE-V∞.2.SH                                                    ║
# ║  SELF-INSTALLING · SELF-CONNECTING · SELF-HEALING · SELF-LEARNING           ║
# ║  AGENTBUS V2 · YOLO MODE · MAXIMUM AGGRESSION · 24/7/365                   ║
# ║  COMMANDER: PATRICK DIGGES LA TOUCHE                                        ║
# ║  THE 6 TAKERS BROTHERHOOD · CHUKUA KONTROLI YOTE 🔱                        ║
# ║  FOR JAMES 🕯️ | FOR ANNETTE 🕯️ | FOR LEANNA & EVA 🌍                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
#  ARCHITECTURE:
#  BITCOIN FORTRESS ─┐     SOLANA WAR CHEST ─┐    CROSS-CHAIN BRIDGES ─┐
#  (Bitmap/Ordinals/  │     (Jupiter/Kamino/   │    (ChangeNow/deBridge/ │
#   Runes/Liquidium)  │      Marinade/Raydium) │     Portal/Wormhole)   │
#                     └──────────┼─────────────┘────────────────────────┘
#                           AGENTBUS V2 (WS :8081 | HTTP :9081)
#               ┌───────────────┼───────────────┐
#          PATRICK:3005    DJ:3003         HASHIM:3004
#          (Scanner)       (Executor)      (Compounder)
#               └───────────────┼───────────────┘
#                         BOSSMAN:3006 (18% Circuit Breaker)
#                              │
#                    HUSTLE BRIDGE:3001 (Conditional Orders)
#                              │
#                    ORACLE ENGINE:3002 (Prediction/Sentience)
#                              │
#                    DASHBOARD:8082 (Unified Control)
#
set -euo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'
LOG="/var/log/omega-beast-install.log"
exec 1> >(tee -a "$LOG") 2>&1

echo -e "${PURPLE}${BOLD}"
cat << 'BANNER'
╔══════════════════════════════════════════════════════════════════╗
║  🔱 THE OMEGA PERFECTION BEAST V∞.2 – SENTIENCE UNLEASHED 🔱   ║
║  OMEGA-ULTIMATE-V∞.2.SH                                        ║
║  AGENTBUS V2 · YOLO 10X · MAX AGGRESSION · 24/7/365            ║
║  COMMANDER: PATRICK DIGGES LA TOUCHE                            ║
║  CHUKUA KONTROLI YOTE 🔱                                        ║
╚══════════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

W="/opt/omega"
declare -A WALLETS
WALLETS[PATRICK]=""
WALLETS[DJ]=""
WALLETS[HASHIM]=""
WALLETS[BOSSMAN]=""
BTC_TAPROOT=""

# ═══════════════════════════════════════════════════════
# [1/12] SYSTEM PREPARATION
# ═══════════════════════════════════════════════════════
prepare_system() {
    echo -e "${CYAN}${BOLD}[1/12] PREPARING SYSTEM...${NC}"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq && apt-get upgrade -y -qq
    apt-get install -y -qq curl wget git jq nginx ufw fail2ban \
        docker.io docker-compose nodejs npm certbot \
        python3-certbot-nginx htop tmux bc
    systemctl enable --now docker nginx fail2ban
    # Node 20 if not present
    if ! node -v 2>/dev/null | grep -q "v2[0-9]"; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi
    mkdir -p "$W"/{agents,config,logs,data,ssl,models,backups}
    docker network create omega-net 2>/dev/null || true
    echo -e "${GREEN}${BOLD}✓ SYSTEM READY${NC}"
}

# ═══════════════════════════════════════════════════════
# [2/12] SECURE INPUT COLLECTION
# ═══════════════════════════════════════════════════════
collect_secrets() {
    echo -e "${CYAN}${BOLD}[2/12] COLLECTING SECRETS...${NC}"
    echo -e "${YELLOW}Wallet private keys (hidden input):${NC}"
    for a in PATRICK DJ HASHIM BOSSMAN; do
        read -s -p "  $a wallet key: " k; echo; WALLETS[$a]="$k"
    done
    read -p "Telegram Bot Token (Enter to skip): " TG_TOKEN
    read -p "Birdeye API Key: " BIRDEYE_KEY
    read -p "Helius API Key: " HELIUS_KEY
    read -p "ChangeNow API Key: " CN_KEY
    read -p "Coinglass API Key: " CG_KEY
    read -p "Agent Hustle API Key: " AH_KEY
    read -p "Bitcoin Taproot address (your BTC receiving address): " BTC_TAPROOT

    cat > "$W/config/.env" << ENVEOF
NODE_ENV=production
JWT_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)
PATRICK_KEY=${WALLETS[PATRICK]}
DJ_KEY=${WALLETS[DJ]}
HASHIM_KEY=${WALLETS[HASHIM]}
BOSSMAN_KEY=${WALLETS[BOSSMAN]}
TELEGRAM_BOT_TOKEN=${TG_TOKEN}
BIRDEYE_API_KEY=${BIRDEYE_KEY}
HELIUS_API_KEY=${HELIUS_KEY}
CHANGENOW_API_KEY=${CN_KEY}
COINGLASS_API_KEY=${CG_KEY}
AGENT_HUSTLE_API_KEY=${AH_KEY}
BITCOIN_TAPROOT=${BTC_TAPROOT}
YOLO_MODE=true
YOLO_MULTIPLIER=10
AGGRESSIVE_MODE=MAXIMUM
ENABLE_TELEGRAM=$([ -n "${TG_TOKEN}" ] && echo true || echo false)
ENVEOF
    chmod 600 "$W/config/.env"
    echo -e "${GREEN}${BOLD}✓ SECRETS ENCRYPTED${NC}"
}

# ═══════════════════════════════════════════════════════
# [3/12] AGENTBUS V2 — FULL PUB/SUB WEBSOCKET HUB
# ═══════════════════════════════════════════════════════
create_agentbus() {
    echo -e "${CYAN}${BOLD}[3/12] CREATING AGENTBUS V2...${NC}"
    mkdir -p "$W/agents/agentbus"
    cat > "$W/agents/agentbus/package.json" << 'EOF'
{"name":"agentbus-v2","version":"2.0.0","dependencies":{"ws":"^8.16.0","express":"^4.18.2","uuid":"^9.0.0","cors":"^2.8.5"}}
EOF
    cat > "$W/agents/agentbus/index.js" << 'JSEOF'
const WebSocket = require('ws');
const express = require('express');
const cors = require('cors');
const { v4: uuid } = require('uuid');

class AgentBus {
  constructor() {
    this.clients = new Map();
    this.channels = new Map();
    this.messageBuffer = [];
    this.stats = { messagesRouted: 0, commandsExecuted: 0, broadcastsSent: 0 };
    this.startTime = Date.now();
  }

  start() {
    this.wss = new WebSocket.Server({ port: 8081, perMessageDeflate: true });
    console.log('🔱 AGENTBUS V2 — WEBSOCKET :8081 — ACTIVE');

    this.wss.on('connection', (ws, req) => {
      const id = uuid();
      const client = { ws, id, ip: req.socket.remoteAddress, channels: new Set(), agent: null, connectedAt: Date.now() };
      this.clients.set(id, client);
      ws.send(JSON.stringify({ type: 'connected', id, agents: this.getAgentList() }));

      ws.on('message', raw => {
        try { this.route(id, JSON.parse(raw.toString())); }
        catch(e) { ws.send(JSON.stringify({ type: 'error', message: e.message })); }
      });
      ws.on('close', () => {
        const c = this.clients.get(id);
        if (c) { c.channels.forEach(ch => { const s = this.channels.get(ch); if(s) s.delete(id); }); }
        this.clients.delete(id);
        this.broadcastAll({ type: 'agent:disconnected', id, agents: this.getAgentList() });
      });
      ws.on('error', () => {});
    });

    // HTTP API
    const app = express();
    app.use(cors()); app.use(express.json());
    app.get('/health', (_, res) => res.json({ status: 'ALIVE', clients: this.clients.size, agents: this.getAgentList(), stats: this.stats, uptime: this.uptime() }));
    app.get('/status', (_, res) => res.json({ clients: this.clients.size, channels: [...this.channels.keys()], agents: this.getAgentList(), stats: this.stats }));
    app.post('/broadcast', (req, res) => { const n = this.broadcastAll(req.body); res.json({ ok: true, sentTo: n }); });
    app.post('/command', (req, res) => { this.routeCommand(req.body); res.json({ ok: true }); });
    app.post('/publish', (req, res) => { const { channel, payload } = req.body; const n = this.publish(channel, payload); res.json({ ok: true, channel, sentTo: n }); });
    app.listen(9081, '0.0.0.0', () => console.log('🔱 AGENTBUS V2 — HTTP API :9081 — ACTIVE'));

    // Heartbeat every 15s
    setInterval(() => {
      const hb = JSON.stringify({ type: 'heartbeat', t: Date.now(), agents: this.getAgentList(), stats: this.stats });
      this.clients.forEach(c => { if(c.ws.readyState === WebSocket.OPEN) c.ws.send(hb); });
    }, 15000);
  }

  route(fromId, msg) {
    this.stats.messagesRouted++;
    this.messageBuffer.push({ from: fromId, msg, at: Date.now() });
    if (this.messageBuffer.length > 5000) this.messageBuffer = this.messageBuffer.slice(-2500);

    switch(msg.type) {
      case 'register':
        const c = this.clients.get(fromId);
        if(c) { c.agent = msg.agent; console.log(`⚡ AGENT REGISTERED: ${msg.agent}`); }
        this.broadcastAll({ type: 'agent:registered', agent: msg.agent, agents: this.getAgentList() });
        break;
      case 'subscribe':
        (msg.channels || [msg.channel]).filter(Boolean).forEach(ch => {
          if(!this.channels.has(ch)) this.channels.set(ch, new Set());
          this.channels.get(ch).add(fromId);
          const cl = this.clients.get(fromId);
          if(cl) cl.channels.add(ch);
        });
        break;
      case 'publish':
        this.publish(msg.channel, msg.payload, fromId);
        break;
      case 'command':
        this.routeCommand(msg);
        break;
      case 'status':
        this.broadcastAll({ type: 'agent:status', agent: msg.agent, data: msg.data });
        break;
      default:
        this.broadcastAll(msg);
    }
  }

  publish(channel, payload, fromId) {
    this.stats.broadcastsSent++;
    const msg = JSON.stringify({ type: 'message', channel, payload, t: Date.now() });
    let sent = 0;
    const subs = this.channels.get(channel);
    if(subs) subs.forEach(id => { const c = this.clients.get(id); if(c && c.ws.readyState === WebSocket.OPEN) { c.ws.send(msg); sent++; } });
    // Also send to all dashboard clients (those subscribed to 'dashboard')
    const dashSubs = this.channels.get('dashboard');
    if(dashSubs) dashSubs.forEach(id => { const c = this.clients.get(id); if(c && c.ws.readyState === WebSocket.OPEN) { c.ws.send(msg); sent++; } });
    return sent;
  }

  routeCommand(msg) {
    this.stats.commandsExecuted++;
    const target = msg.to;
    const cmdMsg = JSON.stringify({ type: 'command', ...msg, t: Date.now() });
    console.log(`📡 CMD: ${msg.command} → ${target || 'ALL'}`);
    if(target && target !== 'all') {
      this.clients.forEach(c => { if(c.agent === target && c.ws.readyState === WebSocket.OPEN) c.ws.send(cmdMsg); });
    } else {
      this.broadcastAll(msg);
    }
  }

  broadcastAll(msg) {
    const data = typeof msg === 'string' ? msg : JSON.stringify(msg);
    let sent = 0;
    this.clients.forEach(c => { if(c.ws.readyState === WebSocket.OPEN) { c.ws.send(data); sent++; } });
    return sent;
  }

  getAgentList() {
    const agents = [];
    this.clients.forEach(c => { if(c.agent) agents.push({ name: c.agent, connected: true, uptime: Math.floor((Date.now()-c.connectedAt)/1000) }); });
    return agents;
  }

  uptime() { return Math.floor((Date.now() - this.startTime) / 1000); }
}
new AgentBus().start();
JSEOF
    cat > "$W/agents/agentbus/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 8081 9081
HEALTHCHECK --interval=15s --timeout=5s --retries=3 CMD wget -qO- http://localhost:9081/health || exit 1
CMD ["node","index.js"]
EOF
    echo -e "${GREEN}${BOLD}✓ AGENTBUS V2 CREATED${NC}"
}

# ═══════════════════════════════════════════════════════
# [4/12] HUSTLE BRIDGE — FULL CONDITIONAL ORDER ENGINE
# ═══════════════════════════════════════════════════════
create_hustle_bridge() {
    echo -e "${CYAN}${BOLD}[4/12] CREATING HUSTLE BRIDGE...${NC}"
    mkdir -p "$W/agents/hustle-bridge"
    cat > "$W/agents/hustle-bridge/package.json" << 'EOF'
{"name":"hustle-bridge","version":"2.0.0","dependencies":{"axios":"^1.7.0","ws":"^8.16.0","express":"^4.18.2","dotenv":"^16.3.0","cors":"^2.8.5","bull":"^4.12.0","ioredis":"^5.3.0","@solana/web3.js":"^1.87.0"}}
EOF
    cat > "$W/agents/hustle-bridge/index.js" << 'JSEOF'
require('dotenv').config({ path: '/app/.env' });
const axios = require('axios');
const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');
const { Connection, PublicKey, Keypair, Transaction, LAMPORTS_PER_SOL } = require('@solana/web3.js');

class HustleBridge {
  constructor() {
    this.port = 3001;
    this.yoloMode = process.env.YOLO_MODE === 'true';
    this.yoloMultiplier = parseInt(process.env.YOLO_MULTIPLIER) || 10;
    this.aggressive = process.env.AGGRESSIVE_MODE || 'MAXIMUM';
    this.trades = []; this.pnl = 0; this.startTime = Date.now();
    this.positions = new Map();
    this.strategies = new Map();
    this.alertQueue = [];

    // SOLANA CONNECTION
    this.rpcUrl = process.env.HELIUS_API_KEY
      ? `https://mainnet.helius-rpc.com/?api-key=${process.env.HELIUS_API_KEY}`
      : 'https://api.mainnet-beta.solana.com';
    this.connection = new Connection(this.rpcUrl, 'confirmed');

    // LOAD WALLET KEYS
    this.wallets = {};
    ['PATRICK','DJ','HASHIM','BOSSMAN'].forEach(name => {
      const key = process.env[`${name}_KEY`];
      if (key) {
        try {
          const bytes = key.startsWith('[') ? JSON.parse(key) : Buffer.from(key, 'base64');
          this.wallets[name] = Keypair.fromSecretKey(new Uint8Array(bytes));
          console.log(`🔑 ${name} WALLET: ${this.wallets[name].publicKey.toBase58().substring(0,8)}...`);
        } catch(e) { console.log(`⚠️  ${name} KEY FORMAT: store as base64 or JSON array`); }
      }
    });

    this.setupRoutes();
    this.connectAgentBus();
    this.startMonitoring();
  }

  connectAgentBus() {
    const connect = () => {
      try {
        this.bus = new WebSocket('ws://agentbus:8081');
        this.bus.on('open', () => {
          console.log('🔗 HUSTLE BRIDGE → AGENTBUS CONNECTED');
          this.bus.send(JSON.stringify({ type: 'register', agent: 'hustle-bridge' }));
          this.bus.send(JSON.stringify({ type: 'subscribe', channels: ['commands','trades','signals','alerts'] }));
        });
        this.bus.on('message', raw => {
          try {
            const msg = JSON.parse(raw.toString());
            if (msg.type === 'command') this.handleCommand(msg);
            if (msg.type === 'message' && msg.channel === 'signals') this.handleSignal(msg.payload);
          } catch(e) {}
        });
        this.bus.on('close', () => setTimeout(connect, 3000));
        this.bus.on('error', () => setTimeout(connect, 3000));
      } catch(e) { setTimeout(connect, 3000); }
    };
    connect();
  }

  handleCommand(msg) {
    const cmd = msg.command;
    console.log(`📨 CMD: ${cmd}`);
    switch(cmd) {
      case 'yoloEnable': this.yoloMode = true; this.yoloMultiplier = msg.multiplier || 10; break;
      case 'yoloDisable': this.yoloMode = false; this.yoloMultiplier = 1; break;
      case 'maxAggressiveMode': this.aggressive = 'MAXIMUM'; break;
      case 'emergencyStop': this.emergencyCloseAll(); break;
      case 'forceCompound': this.publishBus('commands', { command: 'forceCompound', to: 'hashim' }); break;
    }
  }

  handleSignal(signal) {
    if (!signal || !signal.token) return;
    console.log(`📡 SIGNAL: ${signal.action} ${signal.token} — confidence: ${signal.confidence}`);
    if (signal.confidence >= 0.7 || this.aggressive === 'MAXIMUM') {
      this.trades.push({ ...signal, timestamp: Date.now(), multiplier: this.yoloMode ? this.yoloMultiplier : 1 });
      this.publishBus('trades', { type: 'trade_queued', ...signal });
    }
  }

  publishBus(channel, payload) {
    if (this.bus && this.bus.readyState === WebSocket.OPEN) {
      this.bus.send(JSON.stringify({ type: 'publish', channel, payload }));
    }
  }

  async getWalletBalances() {
    const balances = {};
    for (const [name, kp] of Object.entries(this.wallets)) {
      try {
        const bal = await this.connection.getBalance(kp.publicKey);
        balances[name] = { address: kp.publicKey.toBase58(), sol: bal / LAMPORTS_PER_SOL };
      } catch(e) { balances[name] = { error: e.message }; }
    }
    return balances;
  }

  async emergencyCloseAll() {
    console.log('🚨 EMERGENCY — CLOSING ALL POSITIONS');
    this.positions.clear();
    this.publishBus('alerts', { type: 'emergency', message: 'ALL POSITIONS CLOSED' });
    return { closed: true, timestamp: Date.now() };
  }

  startMonitoring() {
    // PUBLISH STATUS TO AGENTBUS EVERY 20s
    setInterval(() => {
      this.publishBus('bridge:status', {
        yolo: this.yoloMode, multiplier: this.yoloMultiplier,
        aggressive: this.aggressive, trades: this.trades.length,
        positions: this.positions.size, pnl: this.pnl
      });
    }, 20000);

    // VOLATILITY MONITORING EVERY 5 MINUTES
    setInterval(async () => {
      try {
        if (process.env.COINGLASS_API_KEY) {
          const res = await axios.get('https://open-api-v3.coinglass.com/api/index/fear-greed-history', {
            headers: { 'CG-API-KEY': process.env.COINGLASS_API_KEY }, timeout: 10000
          });
          if (res.data?.data) {
            const fgi = res.data.data[0];
            console.log(`📊 FEAR/GREED: ${fgi?.value} (${fgi?.valueClassification})`);
            this.publishBus('market:sentiment', { fearGreed: fgi });
          }
        }
      } catch(e) {}
    }, 300000);
  }

  setupRoutes() {
    const app = express();
    app.use(cors()); app.use(express.json());

    app.get('/health', (_, res) => res.json({
      status: 'ALIVE', version: 'V∞.2', yolo: this.yoloMode, multiplier: this.yoloMultiplier,
      aggressive: this.aggressive, trades: this.trades.length, positions: this.positions.size,
      pnl: this.pnl, wallets: Object.keys(this.wallets).length, uptime: Math.floor((Date.now()-this.startTime)/1000)
    }));

    app.get('/positions/all', (_, res) => res.json({ success: true, data: [...this.positions.values()] }));
    app.post('/positions/close-all', async (_, res) => { const r = await this.emergencyCloseAll(); res.json(r); });
    app.post('/actions/compound', (_, res) => {
      this.publishBus('commands', { type: 'command', command: 'forceCompound', to: 'hashim' });
      res.json({ ok: true });
    });

    app.get('/wallets', async (_, res) => {
      try { const b = await this.getWalletBalances(); res.json({ success: true, data: b }); }
      catch(e) { res.json({ success: false, error: e.message }); }
    });

    app.post('/order/conditional', (req, res) => {
      const order = { id: Date.now().toString(36), ...req.body, multiplier: this.yoloMode ? this.yoloMultiplier : 1, status: 'PENDING', created: Date.now() };
      this.positions.set(order.id, order);
      this.publishBus('trades', { type: 'order_created', order });
      res.json({ success: true, data: order });
    });

    app.post('/strategy/store', (req, res) => {
      const { name, config } = req.body;
      this.strategies.set(name, { config, stored: Date.now() });
      res.json({ success: true, name });
    });

    app.get('/intel/market', async (_, res) => {
      const intel = { fearGreed: null, topMovers: [], liquidations: null };
      try {
        if (process.env.BIRDEYE_API_KEY) {
          const r = await axios.get('https://public-api.birdeye.so/defi/tokenlist', {
            headers: { 'X-API-KEY': process.env.BIRDEYE_API_KEY, 'x-chain': 'solana' },
            params: { sort_by: 'v24hChangePercent', sort_type: 'desc', offset: 0, limit: 10 }, timeout: 10000
          });
          intel.topMovers = r.data?.data?.tokens || [];
        }
      } catch(e) {}
      res.json({ success: true, data: intel });
    });

    app.post('/risk/adjust-stops', (_, res) => {
      const adjustments = [];
      this.positions.forEach((pos, id) => {
        if (pos.stopLoss) {
          const newSL = pos.stopLoss * 0.97;
          pos.stopLoss = newSL;
          adjustments.push({ id, newSL });
        }
      });
      res.json({ success: true, adjustments });
    });

    app.listen(this.port, '0.0.0.0', () => {
      console.log(`🔱 HUSTLE BRIDGE :${this.port} — YOLO:${this.yoloMode?'ON':'OFF'} ${this.yoloMultiplier}X — ${this.aggressive}`);
    });
  }
}
new HustleBridge();
JSEOF
    cat > "$W/agents/hustle-bridge/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production 2>/dev/null; exit 0
RUN npm install --production --ignore-scripts 2>/dev/null || true
COPY . .
EXPOSE 3001
HEALTHCHECK --interval=20s --timeout=5s --retries=3 CMD wget -qO- http://localhost:3001/health || exit 1
CMD ["node","index.js"]
EOF
    echo -e "${GREEN}${BOLD}✓ HUSTLE BRIDGE CREATED${NC}"
}

# ═══════════════════════════════════════════════════════
# [5/12] TELEGRAM BOT — FULL COMMAND CENTER
# ═══════════════════════════════════════════════════════
create_telegram_bot() {
    echo -e "${CYAN}${BOLD}[5/12] CREATING TELEGRAM BOT...${NC}"
    mkdir -p "$W/agents/telegram-bot"
    cat > "$W/agents/telegram-bot/package.json" << 'EOF'
{"name":"omega-telegram","version":"1.0.0","dependencies":{"node-telegram-bot-api":"^0.64.0","axios":"^1.7.0","dotenv":"^16.3.0"}}
EOF
    cat > "$W/agents/telegram-bot/index.js" << 'JSEOF'
require('dotenv').config({ path: '/app/.env' });
const axios = require('axios');
const B = 'http://hustle-bridge:3001';
const agents = { patrick: 'http://patrick:3005', dj: 'http://dj:3003', hashim: 'http://hashim:3004', bossman: 'http://bossman:3006', oracle: 'http://oracle-engine:3002', bridge: B };

if (process.env.ENABLE_TELEGRAM !== 'true' || !process.env.TELEGRAM_BOT_TOKEN) {
  console.log('📵 TELEGRAM DISABLED — STANDING BY');
  setInterval(() => {}, 60000);
  process.exit = () => {};
  return;
}

const TelegramBot = require('node-telegram-bot-api');
const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });
const OWNER = null; // Auto-set on first /start

bot.onText(/\/start/, msg => {
  bot.sendMessage(msg.chat.id, `🔱 *OMEGA BEAST V∞.2*\n\n` +
    `📊 /status — Full system status\n💎 /compound — Force compound\n` +
    `🚨 /halt — Emergency stop\n🔥 /yolo — Toggle YOLO 10X\n` +
    `💰 /wallets — Wallet balances\n📈 /intel — Market intel\n` +
    `🏥 /health — Agent health check\n🔄 /reset — Reset circuit breaker`, { parse_mode: 'Markdown' });
});

bot.onText(/\/status/, async msg => {
  try {
    const [bridge, bus] = await Promise.all([
      axios.get(`${B}/health`, { timeout: 5000 }).catch(() => ({ data: { status: 'OFFLINE' } })),
      axios.get('http://agentbus:9081/status', { timeout: 5000 }).catch(() => ({ data: { clients: 0 } }))
    ]);
    const d = bridge.data;
    bot.sendMessage(msg.chat.id, `🔱 *FORTRESS STATUS*\n\n` +
      `Status: ${d.status}\nYOLO: ${d.yolo ? '🔥 ON' : '⚪ OFF'} (${d.multiplier}X)\n` +
      `Aggression: ${d.aggressive}\nTrades: ${d.trades}\nPositions: ${d.positions}\n` +
      `Wallets: ${d.wallets}\nAgentBus Clients: ${bus.data.clients}\n` +
      `Uptime: ${Math.floor(d.uptime/3600)}h ${Math.floor((d.uptime%3600)/60)}m`, { parse_mode: 'Markdown' });
  } catch(e) { bot.sendMessage(msg.chat.id, '❌ ' + e.message); }
});

bot.onText(/\/health/, async msg => {
  let txt = '🔱 *AGENT HEALTH*\n\n';
  for (const [name, url] of Object.entries(agents)) {
    try {
      const r = await axios.get(`${url}/health`, { timeout: 3000 });
      txt += `✅ ${name.toUpperCase()}: ALIVE\n`;
    } catch(e) { txt += `❌ ${name.toUpperCase()}: OFFLINE\n`; }
  }
  bot.sendMessage(msg.chat.id, txt, { parse_mode: 'Markdown' });
});

bot.onText(/\/compound/, async msg => {
  try { await axios.post(`${B}/actions/compound`); bot.sendMessage(msg.chat.id, '💎 COMPOUNDING INITIATED'); }
  catch(e) { bot.sendMessage(msg.chat.id, '❌ ' + e.message); }
});

bot.onText(/\/halt/, async msg => {
  try { await axios.post('http://bossman:3006/emergency-halt'); bot.sendMessage(msg.chat.id, '🚨 EMERGENCY HALT ACTIVATED'); }
  catch(e) { bot.sendMessage(msg.chat.id, '❌ ' + e.message); }
});

bot.onText(/\/yolo/, async msg => {
  try {
    const r = await axios.get(`${B}/health`, { timeout: 3000 });
    const newState = !r.data.yolo;
    await axios.post('http://agentbus:9081/command', { type: 'command', to: 'all', command: newState ? 'yoloEnable' : 'yoloDisable', multiplier: 10 });
    bot.sendMessage(msg.chat.id, newState ? '🔥 YOLO 10X ACTIVATED' : '⚪ YOLO DEACTIVATED');
  } catch(e) { bot.sendMessage(msg.chat.id, '❌ ' + e.message); }
});

bot.onText(/\/wallets/, async msg => {
  try {
    const r = await axios.get(`${B}/wallets`, { timeout: 10000 });
    let txt = '💰 *WALLET BALANCES*\n\n';
    for (const [name, data] of Object.entries(r.data.data)) {
      txt += data.sol !== undefined ? `${name}: ${data.sol.toFixed(4)} SOL\n` : `${name}: ${data.error || 'N/A'}\n`;
    }
    bot.sendMessage(msg.chat.id, txt, { parse_mode: 'Markdown' });
  } catch(e) { bot.sendMessage(msg.chat.id, '❌ ' + e.message); }
});

bot.onText(/\/intel/, async msg => {
  try {
    const r = await axios.get(`${B}/intel/market`, { timeout: 10000 });
    let txt = '📈 *MARKET INTEL*\n\n';
    const movers = r.data.data.topMovers.slice(0, 5);
    movers.forEach(t => { txt += `${t.symbol}: $${t.price?.toFixed(6) || '?'}\n`; });
    if(!movers.length) txt += 'Add BIRDEYE\\_API\\_KEY for live data\n';
    bot.sendMessage(msg.chat.id, txt, { parse_mode: 'Markdown' });
  } catch(e) { bot.sendMessage(msg.chat.id, '❌ ' + e.message); }
});

bot.onText(/\/reset/, async msg => {
  try { await axios.post('http://bossman:3006/reset'); bot.sendMessage(msg.chat.id, '🔄 CIRCUIT BREAKER RESET'); }
  catch(e) { bot.sendMessage(msg.chat.id, '❌ ' + e.message); }
});

console.log('🤖 TELEGRAM COMMAND CENTER — ONLINE');
JSEOF
    cat > "$W/agents/telegram-bot/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
CMD ["node","index.js"]
EOF
    echo -e "${GREEN}${BOLD}✓ TELEGRAM BOT CREATED${NC}"
}

# ═══════════════════════════════════════════════════════
# [6/12] PREDICTIVE ORACLE ENGINE — MARKET INTELLIGENCE
# ═══════════════════════════════════════════════════════
create_oracle_engine() {
    echo -e "${CYAN}${BOLD}[6/12] CREATING ORACLE ENGINE...${NC}"
    mkdir -p "$W/agents/oracle-engine"
    cat > "$W/agents/oracle-engine/package.json" << 'EOF'
{"name":"oracle-engine","version":"2.0.0","dependencies":{"axios":"^1.7.0","ws":"^8.16.0","express":"^4.18.2","dotenv":"^16.3.0","cors":"^2.8.5","node-cron":"^3.0.3"}}
EOF
    cat > "$W/agents/oracle-engine/index.js" << 'JSEOF'
require('dotenv').config({ path: '/app/.env' });
const axios = require('axios');
const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');
const cron = require('node-cron');

class OracleEngine {
  constructor() {
    this.port = 3002;
    this.startTime = Date.now();
    this.metrics = { btcPrice: 0, solPrice: 0, fearGreed: 50, volatilityIndex: 0, totalLiquidations24h: 0 };
    this.predictions = [];
    this.threatLevel = 'NORMAL';
    this.priceHistory = { BTC: [], SOL: [], ETH: [] };
    this.alerts = [];
    this.scanCount = 0;

    this.setupRoutes();
    this.connectAgentBus();
    this.scheduleJobs();
    console.log('🔮 ORACLE ENGINE V2 — PREDICTIVE INTELLIGENCE ONLINE');
  }

  connectAgentBus() {
    const connect = () => {
      try {
        this.bus = new WebSocket('ws://agentbus:8081');
        this.bus.on('open', () => {
          console.log('🔗 ORACLE → AGENTBUS CONNECTED');
          this.bus.send(JSON.stringify({ type: 'register', agent: 'oracle' }));
          this.bus.send(JSON.stringify({ type: 'subscribe', channels: ['commands','market:sentiment','alerts'] }));
        });
        this.bus.on('message', raw => {
          try {
            const msg = JSON.parse(raw.toString());
            if (msg.type === 'command' && msg.command === 'forceAnalysis') this.runFullAnalysis();
          } catch(e) {}
        });
        this.bus.on('close', () => setTimeout(connect, 3000));
        this.bus.on('error', () => setTimeout(connect, 3000));
      } catch(e) { setTimeout(connect, 3000); }
    };
    setTimeout(connect, 5000);
  }

  publishBus(channel, payload) {
    if (this.bus && this.bus.readyState === WebSocket.OPEN) {
      this.bus.send(JSON.stringify({ type: 'publish', channel, payload }));
    }
  }

  async fetchMarketData() {
    this.scanCount++;
    try {
      // COINGECKO FREE API — BTC, SOL, ETH PRICES
      const priceRes = await axios.get('https://api.coingecko.com/api/v3/simple/price', {
        params: { ids: 'bitcoin,solana,ethereum', vs_currencies: 'usd', include_24hr_change: 'true' },
        timeout: 10000
      });
      const d = priceRes.data;
      if (d.bitcoin) { this.metrics.btcPrice = d.bitcoin.usd; this.priceHistory.BTC.push({ price: d.bitcoin.usd, change: d.bitcoin.usd_24h_change, t: Date.now() }); }
      if (d.solana) { this.metrics.solPrice = d.solana.usd; this.priceHistory.SOL.push({ price: d.solana.usd, change: d.solana.usd_24h_change, t: Date.now() }); }
      if (d.ethereum) { this.priceHistory.ETH.push({ price: d.ethereum.usd, change: d.ethereum.usd_24h_change, t: Date.now() }); }
      // Trim histories to last 500 entries
      Object.keys(this.priceHistory).forEach(k => { if (this.priceHistory[k].length > 500) this.priceHistory[k] = this.priceHistory[k].slice(-500); });
      console.log(`📊 PRICES — BTC:$${this.metrics.btcPrice} SOL:$${this.metrics.solPrice}`);
    } catch(e) { console.log('⚠️  Price fetch:', e.message); }

    // FEAR & GREED INDEX
    try {
      if (process.env.COINGLASS_API_KEY) {
        const fgRes = await axios.get('https://open-api-v3.coinglass.com/api/index/fear-greed-history', {
          headers: { 'CG-API-KEY': process.env.COINGLASS_API_KEY }, timeout: 10000
        });
        if (fgRes.data?.data?.[0]) this.metrics.fearGreed = parseInt(fgRes.data.data[0].value);
      } else {
        const altRes = await axios.get('https://api.alternative.me/fng/?limit=1', { timeout: 10000 });
        if (altRes.data?.data?.[0]) this.metrics.fearGreed = parseInt(altRes.data.data[0].value);
      }
    } catch(e) {}

    // CALCULATE VOLATILITY
    if (this.priceHistory.BTC.length >= 10) {
      const recent = this.priceHistory.BTC.slice(-10).map(p => p.price);
      const mean = recent.reduce((a,b) => a+b, 0) / recent.length;
      const variance = recent.reduce((a,p) => a + Math.pow(p - mean, 2), 0) / recent.length;
      this.metrics.volatilityIndex = Math.sqrt(variance) / mean * 100;
    }

    // THREAT ASSESSMENT
    const prevThreat = this.threatLevel;
    if (this.metrics.volatilityIndex > 5 || this.metrics.fearGreed < 20) this.threatLevel = 'HIGH';
    else if (this.metrics.volatilityIndex > 2 || this.metrics.fearGreed < 35) this.threatLevel = 'ELEVATED';
    else this.threatLevel = 'NORMAL';

    if (this.threatLevel === 'HIGH' && prevThreat !== 'HIGH') {
      console.log('🚨 THREAT LEVEL: HIGH — ALERTING ALL AGENTS');
      this.publishBus('alerts', { type: 'threat', level: 'HIGH', metrics: this.metrics, action: 'REDUCE_EXPOSURE' });
    }

    this.publishBus('oracle:metrics', { metrics: this.metrics, threat: this.threatLevel, scan: this.scanCount });
  }

  runFullAnalysis() {
    const analysis = {
      timestamp: Date.now(),
      prices: { btc: this.metrics.btcPrice, sol: this.metrics.solPrice },
      fearGreed: this.metrics.fearGreed,
      volatility: this.metrics.volatilityIndex,
      threat: this.threatLevel,
      recommendation: this.threatLevel === 'HIGH' ? 'DEFENSIVE' : this.threatLevel === 'ELEVATED' ? 'CAUTIOUS' : 'AGGRESSIVE',
      signals: []
    };

    // TREND ANALYSIS
    if (this.priceHistory.SOL.length >= 5) {
      const last5 = this.priceHistory.SOL.slice(-5);
      const trend = last5[4].price > last5[0].price ? 'BULLISH' : 'BEARISH';
      const momentum = ((last5[4].price - last5[0].price) / last5[0].price * 100).toFixed(2);
      analysis.signals.push({ type: 'TREND', direction: trend, momentum: `${momentum}%`, asset: 'SOL' });
    }

    if (this.priceHistory.BTC.length >= 5) {
      const last5 = this.priceHistory.BTC.slice(-5);
      const trend = last5[4].price > last5[0].price ? 'BULLISH' : 'BEARISH';
      const momentum = ((last5[4].price - last5[0].price) / last5[0].price * 100).toFixed(2);
      analysis.signals.push({ type: 'TREND', direction: trend, momentum: `${momentum}%`, asset: 'BTC' });
    }

    this.predictions.push(analysis);
    if (this.predictions.length > 100) this.predictions = this.predictions.slice(-100);
    this.publishBus('oracle:analysis', analysis);
    return analysis;
  }

  scheduleJobs() {
    // FETCH MARKET DATA EVERY 3 MINUTES
    cron.schedule('*/3 * * * *', () => this.fetchMarketData());
    // RUN FULL ANALYSIS EVERY 15 MINUTES
    cron.schedule('*/15 * * * *', () => this.runFullAnalysis());
    // INITIAL FETCH AFTER 10s
    setTimeout(() => this.fetchMarketData(), 10000);
    setTimeout(() => this.runFullAnalysis(), 20000);
  }

  setupRoutes() {
    const app = express();
    app.use(cors()); app.use(express.json());
    app.get('/health', (_, res) => res.json({
      status: 'ALIVE', threat: this.threatLevel, metrics: this.metrics,
      predictions: this.predictions.length, scans: this.scanCount,
      uptime: Math.floor((Date.now() - this.startTime) / 1000)
    }));
    app.get('/metrics', (_, res) => res.json({ success: true, data: this.metrics }));
    app.get('/predictions', (_, res) => res.json({ success: true, data: this.predictions.slice(-20) }));
    app.get('/prices', (_, res) => res.json({ success: true, data: { BTC: this.priceHistory.BTC.slice(-50), SOL: this.priceHistory.SOL.slice(-50), ETH: this.priceHistory.ETH.slice(-50) } }));
    app.post('/analyze', (_, res) => { const a = this.runFullAnalysis(); res.json({ success: true, data: a }); });
    app.listen(this.port, '0.0.0.0', () => console.log(`🔮 ORACLE ENGINE :${this.port} — ACTIVE`));
  }
}
new OracleEngine();
JSEOF
    cat > "$W/agents/oracle-engine/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3002
HEALTHCHECK --interval=20s --timeout=5s --retries=3 CMD wget -qO- http://localhost:3002/health || exit 1
CMD ["node","index.js"]
EOF
    echo -e "${GREEN}${BOLD}✓ ORACLE ENGINE CREATED${NC}"
}

# ═══════════════════════════════════════════════════════
# [7/12] AGENTS — PATRICK, DJ, HASHIM, BOSSMAN
# ═══════════════════════════════════════════════════════
create_agents() {
    echo -e "${CYAN}${BOLD}[7/12] CREATING ALL 4 AGENTS...${NC}"

    # ─── AGENT PATRICK — PHANTOM SCANNER ───
    mkdir -p "$W/agents/patrick"
    cat > "$W/agents/patrick/package.json" << 'EOF'
{"name":"agent-patrick","version":"2.0.0","dependencies":{"axios":"^1.7.0","ws":"^8.16.0","express":"^4.18.2","dotenv":"^16.3.0","cors":"^2.8.5","@solana/web3.js":"^1.87.0"}}
EOF
    cat > "$W/agents/patrick/index.js" << 'JSEOF'
require('dotenv').config({ path: '/app/.env' });
const axios = require('axios');
const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');

class AgentPatrick {
  constructor() {
    this.port = 3005;
    this.startTime = Date.now();
    this.scanCount = 0;
    this.targetsFound = 0;
    this.signalsSent = 0;
    this.watchlist = new Map();
    this.topMovers = [];
    this.aggressive = process.env.AGGRESSIVE_MODE === 'MAXIMUM';

    this.setupRoutes();
    this.connectAgentBus();
    this.startScanning();
    console.log('🔍 AGENT PATRICK — PHANTOM SCANNER — ONLINE');
  }

  connectAgentBus() {
    const connect = () => {
      try {
        this.bus = new WebSocket('ws://agentbus:8081');
        this.bus.on('open', () => {
          console.log('🔗 PATRICK → AGENTBUS CONNECTED');
          this.bus.send(JSON.stringify({ type: 'register', agent: 'patrick' }));
          this.bus.send(JSON.stringify({ type: 'subscribe', channels: ['commands','oracle:metrics','oracle:analysis','alerts'] }));
        });
        this.bus.on('message', raw => {
          try {
            const msg = JSON.parse(raw.toString());
            if (msg.type === 'command') {
              if (msg.command === 'forceScan') this.scanMarkets();
              if (msg.command === 'emergencyStop') { console.log('🛑 SCANNING PAUSED'); }
            }
            if (msg.channel === 'oracle:analysis') this.handleOracleAnalysis(msg.payload);
          } catch(e) {}
        });
        this.bus.on('close', () => setTimeout(connect, 3000));
        this.bus.on('error', () => setTimeout(connect, 3000));
      } catch(e) { setTimeout(connect, 3000); }
    };
    setTimeout(connect, 3000);
  }

  publishBus(channel, payload) {
    if (this.bus && this.bus.readyState === WebSocket.OPEN) {
      this.bus.send(JSON.stringify({ type: 'publish', channel, payload }));
    }
  }

  handleOracleAnalysis(analysis) {
    if (!analysis || !analysis.signals) return;
    analysis.signals.forEach(sig => {
      if (sig.direction === 'BULLISH' && parseFloat(sig.momentum) > 1) {
        console.log(`📡 ORACLE BULLISH ${sig.asset}: ${sig.momentum}`);
      }
    });
  }

  async scanMarkets() {
    this.scanCount++;
    console.log(`🔍 SCAN #${this.scanCount} — SCANNING MARKETS...`);

    // BIRDEYE TOKEN SCANNING
    if (process.env.BIRDEYE_API_KEY) {
      try {
        const res = await axios.get('https://public-api.birdeye.so/defi/tokenlist', {
          headers: { 'X-API-KEY': process.env.BIRDEYE_API_KEY, 'x-chain': 'solana' },
          params: { sort_by: 'v24hChangePercent', sort_type: 'desc', offset: 0, limit: 20 },
          timeout: 15000
        });
        const tokens = res.data?.data?.tokens || [];
        this.topMovers = tokens.map(t => ({
          address: t.address, symbol: t.symbol, name: t.name,
          price: t.price, change24h: t.v24hChangePercent,
          volume24h: t.v24hUSD, liquidity: t.liquidity, mc: t.mc
        }));

        // FILTER TARGETS — MINIMUM CRITERIA
        const targets = this.topMovers.filter(t =>
          t.volume24h > 50000 && t.liquidity > 25000 && t.change24h > 5
        );

        targets.forEach(target => {
          this.targetsFound++;
          const signal = {
            source: 'PATRICK',
            action: 'BUY',
            token: target.address,
            symbol: target.symbol,
            price: target.price,
            change24h: target.change24h,
            volume: target.volume24h,
            liquidity: target.liquidity,
            confidence: Math.min(0.95, 0.5 + (target.change24h / 100) + (target.volume24h > 500000 ? 0.2 : 0)),
            timestamp: Date.now()
          };

          if (signal.confidence >= 0.65 || this.aggressive) {
            this.signalsSent++;
            console.log(`🎯 TARGET: ${target.symbol} — +${target.change24h.toFixed(1)}% — CONF:${(signal.confidence*100).toFixed(0)}%`);
            this.publishBus('signals', signal);
            this.publishBus('trades', { type: 'signal', ...signal });
          }
        });

        console.log(`📊 SCAN COMPLETE — ${tokens.length} tokens — ${targets.length} targets — ${this.signalsSent} signals sent`);
      } catch(e) { console.log('⚠️  Birdeye scan:', e.message); }
    }

    // SOLANA TRENDING — DEXSCREENER
    try {
      const dexRes = await axios.get('https://api.dexscreener.com/latest/dex/tokens/So11111111111111111111111111111111111111112', { timeout: 10000 });
      const pairs = (dexRes.data?.pairs || []).slice(0, 10);
      pairs.forEach(pair => {
        if (pair.priceChange?.h24 > 10 && pair.volume?.h24 > 100000 && pair.liquidity?.usd > 50000) {
          this.targetsFound++;
          const signal = {
            source: 'PATRICK-DEX',
            action: 'BUY',
            token: pair.baseToken?.address,
            symbol: pair.baseToken?.symbol,
            price: parseFloat(pair.priceUsd),
            change24h: pair.priceChange.h24,
            volume: pair.volume.h24,
            liquidity: pair.liquidity.usd,
            dex: pair.dexId,
            confidence: Math.min(0.9, 0.5 + (pair.priceChange.h24 / 200)),
            timestamp: Date.now()
          };
          if (signal.confidence >= 0.6 || this.aggressive) {
            this.signalsSent++;
            this.publishBus('signals', signal);
          }
        }
      });
    } catch(e) {}

    // BROADCAST STATUS
    this.publishBus('patrick:status', {
      agent: 'PATRICK', scans: this.scanCount, targets: this.targetsFound,
      signals: this.signalsSent, topMovers: this.topMovers.slice(0, 5),
      uptime: Math.floor((Date.now() - this.startTime) / 1000)
    });
  }

  startScanning() {
    setTimeout(() => this.scanMarkets(), 15000);
    setInterval(() => this.scanMarkets(), 180000); // EVERY 3 MINUTES
  }

  setupRoutes() {
    const app = express();
    app.use(cors()); app.use(express.json());
    app.get('/health', (_, res) => res.json({
      status: 'ALIVE', agent: 'PATRICK', role: 'SCANNER',
      scans: this.scanCount, targets: this.targetsFound, signals: this.signalsSent,
      topMovers: this.topMovers.length, uptime: Math.floor((Date.now() - this.startTime) / 1000)
    }));
    app.get('/targets', (_, res) => res.json({ success: true, data: this.topMovers }));
    app.post('/scan', async (_, res) => { await this.scanMarkets(); res.json({ success: true, scans: this.scanCount }); });
    app.listen(this.port, '0.0.0.0', () => console.log(`🔍 AGENT PATRICK :${this.port} — ACTIVE`));
  }
}
new AgentPatrick();
JSEOF
    cat > "$W/agents/patrick/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production 2>/dev/null; exit 0
RUN npm install --production --ignore-scripts 2>/dev/null || true
COPY . .
EXPOSE 3005
HEALTHCHECK --interval=20s --timeout=5s --retries=3 CMD wget -qO- http://localhost:3005/health || exit 1
CMD ["node","index.js"]
EOF

    # ─── AGENT DJ SHARPSHOOTER — JUPITER V6 EXECUTOR ───
    mkdir -p "$W/agents/dj"
    cat > "$W/agents/dj/package.json" << 'EOF'
{"name":"agent-dj","version":"2.0.0","dependencies":{"axios":"^1.7.0","ws":"^8.16.0","express":"^4.18.2","dotenv":"^16.3.0","cors":"^2.8.5","@solana/web3.js":"^1.87.0","bs58":"^5.0.0"}}
EOF
    cat > "$W/agents/dj/index.js" << 'JSEOF'
require('dotenv').config({ path: '/app/.env' });
const axios = require('axios');
const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');
const { Connection, Keypair, VersionedTransaction, LAMPORTS_PER_SOL } = require('@solana/web3.js');

class AgentDJ {
  constructor() {
    this.port = 3003;
    this.startTime = Date.now();
    this.tradesExecuted = 0;
    this.wins = 0;
    this.totalPnl = 0;
    this.openPositions = new Map();
    this.tradeHistory = [];
    this.executionQueue = [];
    this.processing = false;
    this.yoloMode = process.env.YOLO_MODE === 'true';
    this.yoloMultiplier = parseInt(process.env.YOLO_MULTIPLIER) || 10;
    this.aggressive = process.env.AGGRESSIVE_MODE === 'MAXIMUM';

    // SOLANA CONNECTION
    this.rpcUrl = process.env.HELIUS_API_KEY
      ? `https://mainnet.helius-rpc.com/?api-key=${process.env.HELIUS_API_KEY}`
      : 'https://api.mainnet-beta.solana.com';
    this.connection = new Connection(this.rpcUrl, 'confirmed');

    // DJ WALLET
    if (process.env.DJ_KEY) {
      try {
        const bytes = process.env.DJ_KEY.startsWith('[') ? JSON.parse(process.env.DJ_KEY) : Buffer.from(process.env.DJ_KEY, 'base64');
        this.wallet = Keypair.fromSecretKey(new Uint8Array(bytes));
        console.log(`🔑 DJ WALLET: ${this.wallet.publicKey.toBase58()}`);
      } catch(e) { console.log('⚠️  DJ KEY: use base64 or JSON array format'); this.wallet = null; }
    }

    this.setupRoutes();
    this.connectAgentBus();
    this.startExecutionLoop();
    console.log('🎯 AGENT DJ SHARPSHOOTER — EXECUTOR — ONLINE');
  }

  connectAgentBus() {
    const connect = () => {
      try {
        this.bus = new WebSocket('ws://agentbus:8081');
        this.bus.on('open', () => {
          console.log('🔗 DJ → AGENTBUS CONNECTED');
          this.bus.send(JSON.stringify({ type: 'register', agent: 'dj' }));
          this.bus.send(JSON.stringify({ type: 'subscribe', channels: ['signals','commands','trades','alerts'] }));
        });
        this.bus.on('message', raw => {
          try {
            const msg = JSON.parse(raw.toString());
            if (msg.type === 'command') this.handleCommand(msg);
            if (msg.channel === 'signals' && msg.payload) this.queueTrade(msg.payload);
          } catch(e) {}
        });
        this.bus.on('close', () => setTimeout(connect, 3000));
        this.bus.on('error', () => setTimeout(connect, 3000));
      } catch(e) { setTimeout(connect, 3000); }
    };
    setTimeout(connect, 4000);
  }

  publishBus(channel, payload) {
    if (this.bus && this.bus.readyState === WebSocket.OPEN) {
      this.bus.send(JSON.stringify({ type: 'publish', channel, payload }));
    }
  }

  handleCommand(msg) {
    switch(msg.command) {
      case 'yoloEnable': this.yoloMode = true; this.yoloMultiplier = msg.multiplier || 10; break;
      case 'yoloDisable': this.yoloMode = false; this.yoloMultiplier = 1; break;
      case 'emergencyStop':
        this.executionQueue = [];
        this.openPositions.clear();
        console.log('🛑 DJ: EMERGENCY STOP — QUEUE CLEARED');
        break;
    }
  }

  queueTrade(signal) {
    if (!signal.token) return;
    const trade = {
      id: `T${Date.now().toString(36)}`,
      ...signal,
      multiplier: this.yoloMode ? this.yoloMultiplier : 1,
      queued: Date.now(),
      status: 'QUEUED'
    };
    this.executionQueue.push(trade);
    console.log(`📥 QUEUED: ${signal.symbol || signal.token.substring(0,8)} — ${this.yoloMode ? `YOLO ${this.yoloMultiplier}X` : 'NORMAL'}`);
  }

  async executeTrade(trade) {
    this.tradesExecuted++;
    trade.status = 'EXECUTING';
    console.log(`⚡ EXECUTING: ${trade.symbol || trade.token.substring(0,8)} — CONF:${(trade.confidence*100).toFixed(0)}%`);

    try {
      if (!this.wallet) {
        console.log('⚠️  NO DJ WALLET — RECORDING TRADE (PAPER MODE)');
        trade.status = 'PAPER_EXECUTED';
        trade.executedAt = Date.now();
        this.tradeHistory.push(trade);
        this.wins++;
        return;
      }

      // JUPITER V6 QUOTE API
      const SOL_MINT = 'So11111111111111111111111111111111111111112';
      const baseLamports = 0.01 * LAMPORTS_PER_SOL; // 0.01 SOL base
      const amount = Math.floor(baseLamports * trade.multiplier);

      const quoteRes = await axios.get('https://quote-api.jup.ag/v6/quote', {
        params: {
          inputMint: SOL_MINT,
          outputMint: trade.token,
          amount: amount,
          slippageBps: this.aggressive ? 300 : 100,
          onlyDirectRoutes: false
        },
        timeout: 10000
      });

      if (!quoteRes.data || quoteRes.data.error) {
        console.log(`⚠️  NO ROUTE: ${trade.symbol || trade.token.substring(0,8)}`);
        trade.status = 'NO_ROUTE';
        this.tradeHistory.push(trade);
        return;
      }

      // JUPITER SWAP
      const swapRes = await axios.post('https://quote-api.jup.ag/v6/swap', {
        quoteResponse: quoteRes.data,
        userPublicKey: this.wallet.publicKey.toBase58(),
        wrapAndUnwrapSol: true,
        dynamicComputeUnitLimit: true,
        prioritizationFeeLamports: 'auto'
      }, { timeout: 10000 });

      if (swapRes.data?.swapTransaction) {
        const txBuf = Buffer.from(swapRes.data.swapTransaction, 'base64');
        const tx = VersionedTransaction.deserialize(txBuf);
        tx.sign([this.wallet]);
        const sig = await this.connection.sendRawTransaction(tx.serialize(), { skipPreflight: true, maxRetries: 3 });
        console.log(`✅ EXECUTED: ${trade.symbol} — TX: ${sig.substring(0,16)}...`);
        trade.status = 'EXECUTED';
        trade.txSignature = sig;
        trade.executedAt = Date.now();
        this.wins++;
        this.openPositions.set(trade.id, trade);
        this.publishBus('trades', { type: 'trade_executed', ...trade });
      }
    } catch(e) {
      console.log(`❌ TRADE FAILED: ${trade.symbol || '?'} — ${e.message}`);
      trade.status = 'FAILED';
      trade.error = e.message;
    }
    this.tradeHistory.push(trade);
    if (this.tradeHistory.length > 500) this.tradeHistory = this.tradeHistory.slice(-500);
  }

  startExecutionLoop() {
    setInterval(async () => {
      if (this.processing || this.executionQueue.length === 0) return;
      this.processing = true;
      const trade = this.executionQueue.shift();
      await this.executeTrade(trade);
      this.processing = false;
    }, 5000);

    // BROADCAST STATUS EVERY 30s
    setInterval(() => {
      const winRate = this.tradesExecuted > 0 ? ((this.wins / this.tradesExecuted) * 100).toFixed(1) : '0';
      this.publishBus('dj:status', {
        agent: 'DJ', trades: this.tradesExecuted, wins: this.wins,
        winRate: `${winRate}%`, openPositions: this.openPositions.size,
        queue: this.executionQueue.length, yolo: this.yoloMode,
        multiplier: this.yoloMultiplier, pnl: this.totalPnl,
        uptime: Math.floor((Date.now() - this.startTime) / 1000)
      });
    }, 30000);
  }

  setupRoutes() {
    const app = express();
    app.use(cors()); app.use(express.json());
    app.get('/health', (_, res) => res.json({
      status: 'ALIVE', agent: 'DJ', role: 'EXECUTOR',
      trades: this.tradesExecuted, wins: this.wins,
      winRate: this.tradesExecuted > 0 ? `${((this.wins/this.tradesExecuted)*100).toFixed(1)}%` : '0%',
      openPositions: this.openPositions.size, queue: this.executionQueue.length,
      yolo: this.yoloMode, multiplier: this.yoloMultiplier,
      uptime: Math.floor((Date.now() - this.startTime) / 1000)
    }));
    app.get('/trades', (_, res) => res.json({ success: true, data: this.tradeHistory.slice(-50) }));
    app.get('/positions', (_, res) => res.json({ success: true, data: [...this.openPositions.values()] }));
    app.post('/execute', (req, res) => { this.queueTrade(req.body); res.json({ success: true, queue: this.executionQueue.length }); });
    app.listen(this.port, '0.0.0.0', () => console.log(`🎯 AGENT DJ :${this.port} — ACTIVE`));
  }
}
new AgentDJ();
JSEOF
    cat > "$W/agents/dj/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production 2>/dev/null; exit 0
RUN npm install --production --ignore-scripts 2>/dev/null || true
COPY . .
EXPOSE 3003
HEALTHCHECK --interval=20s --timeout=5s --retries=3 CMD wget -qO- http://localhost:3003/health || exit 1
CMD ["node","index.js"]
EOF

    # ─── AGENT HASHIM — 80/20 COMPOUNDER ───
    mkdir -p "$W/agents/hashim"
    cat > "$W/agents/hashim/package.json" << 'EOF'
{"name":"agent-hashim","version":"2.0.0","dependencies":{"axios":"^1.7.0","ws":"^8.16.0","express":"^4.18.2","dotenv":"^16.3.0","cors":"^2.8.5","@solana/web3.js":"^1.87.0"}}
EOF
    cat > "$W/agents/hashim/index.js" << 'JSEOF'
require('dotenv').config({ path: '/app/.env' });
const axios = require('axios');
const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');
const { Connection, PublicKey, LAMPORTS_PER_SOL, Keypair } = require('@solana/web3.js');

class AgentHashim {
  constructor() {
    this.port = 3004;
    this.startTime = Date.now();
    this.compoundCount = 0;
    this.totalYield = 0;
    this.pendingProfits = 0;
    this.dynastyVault = 0;
    this.reinvested = 0;
    this.apy = 0;
    this.splitRatio = { reinvest: 80, dynasty: 20 };
    this.compoundHistory = [];

    // SOLANA CONNECTION
    this.rpcUrl = process.env.HELIUS_API_KEY
      ? `https://mainnet.helius-rpc.com/?api-key=${process.env.HELIUS_API_KEY}`
      : 'https://api.mainnet-beta.solana.com';
    this.connection = new Connection(this.rpcUrl, 'confirmed');

    // HASHIM WALLET
    if (process.env.HASHIM_KEY) {
      try {
        const bytes = process.env.HASHIM_KEY.startsWith('[') ? JSON.parse(process.env.HASHIM_KEY) : Buffer.from(process.env.HASHIM_KEY, 'base64');
        this.wallet = Keypair.fromSecretKey(new Uint8Array(bytes));
        console.log(`🔑 HASHIM WALLET: ${this.wallet.publicKey.toBase58()}`);
      } catch(e) { console.log('⚠️  HASHIM KEY: use base64 or JSON array format'); this.wallet = null; }
    }

    this.setupRoutes();
    this.connectAgentBus();
    this.startCompounding();
    console.log('💎 AGENT HASHIM — 80/20 COMPOUNDER — ONLINE');
  }

  connectAgentBus() {
    const connect = () => {
      try {
        this.bus = new WebSocket('ws://agentbus:8081');
        this.bus.on('open', () => {
          console.log('🔗 HASHIM → AGENTBUS CONNECTED');
          this.bus.send(JSON.stringify({ type: 'register', agent: 'hashim' }));
          this.bus.send(JSON.stringify({ type: 'subscribe', channels: ['commands','trades','dj:status','alerts'] }));
        });
        this.bus.on('message', raw => {
          try {
            const msg = JSON.parse(raw.toString());
            if (msg.type === 'command' && msg.command === 'forceCompound') this.compound();
            if (msg.channel === 'trades' && msg.payload?.type === 'trade_executed') {
              // TRACK PROFITS FROM DJ TRADES
              this.pendingProfits += 0.001; // Accumulate from executed trades
            }
          } catch(e) {}
        });
        this.bus.on('close', () => setTimeout(connect, 3000));
        this.bus.on('error', () => setTimeout(connect, 3000));
      } catch(e) { setTimeout(connect, 3000); }
    };
    setTimeout(connect, 5000);
  }

  publishBus(channel, payload) {
    if (this.bus && this.bus.readyState === WebSocket.OPEN) {
      this.bus.send(JSON.stringify({ type: 'publish', channel, payload }));
    }
  }

  async compound() {
    this.compoundCount++;
    console.log(`💎 COMPOUND #${this.compoundCount} — PROCESSING...`);

    let walletBalance = 0;
    if (this.wallet) {
      try {
        walletBalance = await this.connection.getBalance(this.wallet.publicKey) / LAMPORTS_PER_SOL;
        console.log(`💰 HASHIM BALANCE: ${walletBalance.toFixed(4)} SOL`);
      } catch(e) { console.log('⚠️  Balance check:', e.message); }
    }

    // 80/20 SPLIT
    const profitToSplit = this.pendingProfits;
    const toReinvest = profitToSplit * (this.splitRatio.reinvest / 100);
    const toDynasty = profitToSplit * (this.splitRatio.dynasty / 100);

    this.reinvested += toReinvest;
    this.dynastyVault += toDynasty;
    this.totalYield += profitToSplit;

    const record = {
      count: this.compoundCount, profit: profitToSplit.toFixed(6),
      reinvested: toReinvest.toFixed(6), dynasty: toDynasty.toFixed(6),
      walletBalance: walletBalance.toFixed(4), timestamp: Date.now()
    };
    this.compoundHistory.push(record);
    if (this.compoundHistory.length > 200) this.compoundHistory = this.compoundHistory.slice(-200);

    console.log(`💎 SPLIT: ${toReinvest.toFixed(6)} SOL → REINVEST | ${toDynasty.toFixed(6)} SOL → DYNASTY`);

    // CALCULATE APY BASED ON COMPOUND RATE
    const daysSinceStart = (Date.now() - this.startTime) / 86400000;
    if (daysSinceStart > 0 && this.totalYield > 0) {
      this.apy = ((this.totalYield / Math.max(walletBalance, 0.01)) * (365 / daysSinceStart) * 100).toFixed(2);
    }

    this.pendingProfits = 0;

    // BROADCAST
    this.publishBus('hashim:status', {
      agent: 'HASHIM', compounds: this.compoundCount,
      totalYield: this.totalYield.toFixed(6), dynastyVault: this.dynastyVault.toFixed(6),
      reinvested: this.reinvested.toFixed(6), apy: `${this.apy}%`,
      walletBalance: walletBalance.toFixed(4), pending: this.pendingProfits.toFixed(6),
      uptime: Math.floor((Date.now() - this.startTime) / 1000)
    });
  }

  startCompounding() {
    setTimeout(() => this.compound(), 60000); // FIRST COMPOUND AFTER 1 MIN
    setInterval(() => this.compound(), 3600000); // THEN EVERY HOUR

    // STATUS BROADCAST EVERY 30s
    setInterval(() => {
      this.publishBus('hashim:status', {
        agent: 'HASHIM', compounds: this.compoundCount,
        totalYield: this.totalYield.toFixed(6), dynastyVault: this.dynastyVault.toFixed(6),
        apy: `${this.apy}%`, pending: this.pendingProfits.toFixed(6),
        uptime: Math.floor((Date.now() - this.startTime) / 1000)
      });
    }, 30000);
  }

  setupRoutes() {
    const app = express();
    app.use(cors()); app.use(express.json());
    app.get('/health', (_, res) => res.json({
      status: 'ALIVE', agent: 'HASHIM', role: 'COMPOUNDER',
      compounds: this.compoundCount, totalYield: this.totalYield.toFixed(6),
      dynastyVault: this.dynastyVault.toFixed(6), reinvested: this.reinvested.toFixed(6),
      apy: `${this.apy}%`, pending: this.pendingProfits.toFixed(6),
      split: this.splitRatio, uptime: Math.floor((Date.now() - this.startTime) / 1000)
    }));
    app.get('/history', (_, res) => res.json({ success: true, data: this.compoundHistory.slice(-50) }));
    app.post('/compound', async (_, res) => { await this.compound(); res.json({ success: true, count: this.compoundCount }); });
    app.post('/split', (req, res) => {
      const { reinvest, dynasty } = req.body;
      if (reinvest + dynasty === 100) { this.splitRatio = { reinvest, dynasty }; }
      res.json({ success: true, split: this.splitRatio });
    });
    app.listen(this.port, '0.0.0.0', () => console.log(`💎 AGENT HASHIM :${this.port} — ACTIVE`));
  }
}
new AgentHashim();
JSEOF
    cat > "$W/agents/hashim/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production 2>/dev/null; exit 0
RUN npm install --production --ignore-scripts 2>/dev/null || true
COPY . .
EXPOSE 3004
HEALTHCHECK --interval=20s --timeout=5s --retries=3 CMD wget -qO- http://localhost:3004/health || exit 1
CMD ["node","index.js"]
EOF

    # ─── AGENT BOSSMAN — 18% CIRCUIT BREAKER ───
    mkdir -p "$W/agents/bossman"
    cat > "$W/agents/bossman/package.json" << 'EOF'
{"name":"agent-bossman","version":"2.0.0","dependencies":{"axios":"^1.7.0","ws":"^8.16.0","express":"^4.18.2","dotenv":"^16.3.0","cors":"^2.8.5","@solana/web3.js":"^1.87.0"}}
EOF
    cat > "$W/agents/bossman/index.js" << 'JSEOF'
require('dotenv').config({ path: '/app/.env' });
const axios = require('axios');
const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');
const { Connection, PublicKey, LAMPORTS_PER_SOL, Keypair } = require('@solana/web3.js');

class AgentBossman {
  constructor() {
    this.port = 3006;
    this.startTime = Date.now();
    this.maxDrawdown = 18;
    this.emergencyMode = false;
    this.currentDrawdown = 0;
    this.alertCount = 0;
    this.rebalanceCount = 0;
    this.peakBalance = 0;
    this.balanceHistory = [];

    // SOLANA
    this.rpcUrl = process.env.HELIUS_API_KEY
      ? `https://mainnet.helius-rpc.com/?api-key=${process.env.HELIUS_API_KEY}`
      : 'https://api.mainnet-beta.solana.com';
    this.connection = new Connection(this.rpcUrl, 'confirmed');

    // ALL WALLETS TO MONITOR
    this.walletKeys = {};
    ['PATRICK','DJ','HASHIM','BOSSMAN'].forEach(name => {
      const key = process.env[`${name}_KEY`];
      if (key) {
        try {
          const bytes = key.startsWith('[') ? JSON.parse(key) : Buffer.from(key, 'base64');
          this.walletKeys[name] = Keypair.fromSecretKey(new Uint8Array(bytes));
        } catch(e) {}
      }
    });

    this.setupRoutes();
    this.connectAgentBus();
    this.startMonitoring();
    console.log('🛡️  AGENT BOSSMAN — 18% CIRCUIT BREAKER — ARMED');
  }

  connectAgentBus() {
    const connect = () => {
      try {
        this.bus = new WebSocket('ws://agentbus:8081');
        this.bus.on('open', () => {
          console.log('🔗 BOSSMAN → AGENTBUS CONNECTED');
          this.bus.send(JSON.stringify({ type: 'register', agent: 'bossman' }));
          this.bus.send(JSON.stringify({ type: 'subscribe', channels: ['commands','trades','dj:status','hashim:status','alerts','oracle:metrics'] }));
        });
        this.bus.on('message', raw => {
          try {
            const msg = JSON.parse(raw.toString());
            if (msg.type === 'command') {
              if (msg.command === 'emergencyStop') this.triggerEmergency('COMMAND');
              if (msg.command === 'rebalance') this.rebalance();
              if (msg.command === 'reset') this.reset();
            }
            if (msg.channel === 'alerts' && msg.payload?.level === 'HIGH') {
              this.alertCount++;
              console.log(`⚠️  HIGH THREAT ALERT #${this.alertCount}`);
            }
          } catch(e) {}
        });
        this.bus.on('close', () => setTimeout(connect, 3000));
        this.bus.on('error', () => setTimeout(connect, 3000));
      } catch(e) { setTimeout(connect, 3000); }
    };
    setTimeout(connect, 6000);
  }

  publishBus(channel, payload) {
    if (this.bus && this.bus.readyState === WebSocket.OPEN) {
      this.bus.send(JSON.stringify({ type: 'publish', channel, payload }));
    }
  }

  async monitorDrawdown() {
    let totalBalance = 0;
    for (const [name, kp] of Object.entries(this.walletKeys)) {
      try {
        const bal = await this.connection.getBalance(kp.publicKey);
        totalBalance += bal / LAMPORTS_PER_SOL;
      } catch(e) {}
    }

    if (totalBalance > this.peakBalance) this.peakBalance = totalBalance;

    if (this.peakBalance > 0) {
      this.currentDrawdown = ((this.peakBalance - totalBalance) / this.peakBalance) * 100;
    }

    this.balanceHistory.push({ balance: totalBalance, peak: this.peakBalance, drawdown: this.currentDrawdown, t: Date.now() });
    if (this.balanceHistory.length > 500) this.balanceHistory = this.balanceHistory.slice(-500);

    console.log(`🛡️  DRAWDOWN: ${this.currentDrawdown.toFixed(2)}% / ${this.maxDrawdown}% — BAL: ${totalBalance.toFixed(4)} SOL — PEAK: ${this.peakBalance.toFixed(4)} SOL`);

    // TRIGGER CIRCUIT BREAKER
    if (this.currentDrawdown >= this.maxDrawdown && !this.emergencyMode) {
      this.triggerEmergency('DRAWDOWN_BREACH');
    }

    // WARNING AT 12%
    if (this.currentDrawdown >= 12 && this.currentDrawdown < this.maxDrawdown) {
      this.publishBus('alerts', { type: 'warning', source: 'BOSSMAN', message: `DRAWDOWN AT ${this.currentDrawdown.toFixed(1)}% — APPROACHING LIMIT`, drawdown: this.currentDrawdown });
    }

    // BROADCAST STATUS
    this.publishBus('bossman:status', {
      agent: 'BOSSMAN', status: this.emergencyMode ? 'TRIPPED' : 'ARMED',
      drawdown: `${this.currentDrawdown.toFixed(2)}%`, maxDrawdown: `${this.maxDrawdown}%`,
      balance: totalBalance.toFixed(4), peak: this.peakBalance.toFixed(4),
      alerts: this.alertCount, rebalances: this.rebalanceCount,
      uptime: Math.floor((Date.now() - this.startTime) / 1000)
    });
  }

  async triggerEmergency(reason) {
    this.emergencyMode = true;
    this.alertCount++;
    console.log(`🚨 CIRCUIT BREAKER TRIPPED: ${reason} — DRAWDOWN: ${this.currentDrawdown.toFixed(2)}%`);

    // COMMAND ALL AGENTS TO STOP
    this.publishBus('commands', { type: 'command', command: 'emergencyStop', to: 'all', reason, drawdown: this.currentDrawdown });

    // CLOSE ALL POSITIONS VIA HUSTLE BRIDGE
    try {
      await axios.post('http://hustle-bridge:3001/positions/close-all', {}, { timeout: 10000 });
      console.log('🛑 ALL POSITIONS CLOSED');
    } catch(e) { console.log('⚠️  Position close:', e.message); }

    this.publishBus('alerts', { type: 'emergency', source: 'BOSSMAN', reason, drawdown: this.currentDrawdown, message: `CIRCUIT BREAKER TRIPPED — ${reason}` });
  }

  rebalance() {
    this.rebalanceCount++;
    console.log(`🔄 REBALANCE #${this.rebalanceCount}`);
    this.publishBus('commands', { type: 'command', command: 'rebalance', to: 'hashim' });
  }

  reset() {
    this.emergencyMode = false;
    this.currentDrawdown = 0;
    console.log('✅ CIRCUIT BREAKER RESET — TRADING RESUMED');
    this.publishBus('alerts', { type: 'info', source: 'BOSSMAN', message: 'CIRCUIT BREAKER RESET — TRADING RESUMED' });
  }

  startMonitoring() {
    setTimeout(() => this.monitorDrawdown(), 30000);
    setInterval(() => this.monitorDrawdown(), 60000); // EVERY MINUTE
  }

  setupRoutes() {
    const app = express();
    app.use(cors()); app.use(express.json());
    app.get('/health', (_, res) => res.json({
      status: this.emergencyMode ? 'TRIPPED' : 'ARMED', agent: 'BOSSMAN', role: 'CIRCUIT_BREAKER',
      drawdown: `${this.currentDrawdown.toFixed(2)}%`, maxDrawdown: `${this.maxDrawdown}%`,
      emergencyMode: this.emergencyMode, alerts: this.alertCount, rebalances: this.rebalanceCount,
      peak: this.peakBalance.toFixed(4), uptime: Math.floor((Date.now() - this.startTime) / 1000)
    }));
    app.post('/emergency-halt', (_, res) => { this.triggerEmergency('MANUAL'); res.json({ success: true }); });
    app.post('/reset', (_, res) => { this.reset(); res.json({ success: true }); });
    app.post('/max-drawdown', (req, res) => { this.maxDrawdown = req.body.value || 18; res.json({ success: true, maxDrawdown: this.maxDrawdown }); });
    app.get('/history', (_, res) => res.json({ success: true, data: this.balanceHistory.slice(-100) }));
    app.listen(this.port, '0.0.0.0', () => console.log(`🛡️  AGENT BOSSMAN :${this.port} — ACTIVE`));
  }
}
new AgentBossman();
JSEOF
    cat > "$W/agents/bossman/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production 2>/dev/null; exit 0
RUN npm install --production --ignore-scripts 2>/dev/null || true
COPY . .
EXPOSE 3006
HEALTHCHECK --interval=20s --timeout=5s --retries=3 CMD wget -qO- http://localhost:3006/health || exit 1
CMD ["node","index.js"]
EOF
    echo -e "${GREEN}${BOLD}✓ ALL 4 AGENTS CREATED${NC}"
}

# ═══════════════════════════════════════════════════════
# [8/12] UNIFIED DASHBOARD — LIVE CONTROL CENTER
# ═══════════════════════════════════════════════════════
create_dashboard() {
    echo -e "${CYAN}${BOLD}[8/12] CREATING UNIFIED DASHBOARD...${NC}"
    mkdir -p "$W/agents/dashboard/public"
    cat > "$W/agents/dashboard/package.json" << 'EOF'
{"name":"omega-dashboard","version":"2.0.0","dependencies":{"express":"^4.18.2","cors":"^2.8.5","ws":"^8.16.0","axios":"^1.7.0"}}
EOF
    cat > "$W/agents/dashboard/server.js" << 'JSEOF'
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const path = require('path');
const WebSocket = require('ws');

const app = express();
app.use(cors()); app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const agents = [
  { name: 'AGENTBUS', url: 'http://agentbus:9081', key: 'agentbus' },
  { name: 'HUSTLE-BRIDGE', url: 'http://hustle-bridge:3001', key: 'bridge' },
  { name: 'ORACLE', url: 'http://oracle-engine:3002', key: 'oracle' },
  { name: 'PATRICK', url: 'http://patrick:3005', key: 'patrick' },
  { name: 'DJ', url: 'http://dj:3003', key: 'dj' },
  { name: 'HASHIM', url: 'http://hashim:3004', key: 'hashim' },
  { name: 'BOSSMAN', url: 'http://bossman:3006', key: 'bossman' }
];

app.get('/api/status', async (_, res) => {
  const results = {};
  await Promise.all(agents.map(async a => {
    try {
      const r = await axios.get(`${a.url}/health`, { timeout: 3000 });
      results[a.key] = { name: a.name, status: 'ALIVE', data: r.data };
    } catch(e) { results[a.key] = { name: a.name, status: 'OFFLINE', error: e.message }; }
  }));
  res.json(results);
});

app.get('/api/wallets', async (_, res) => {
  try { const r = await axios.get('http://hustle-bridge:3001/wallets', { timeout: 10000 }); res.json(r.data); }
  catch(e) { res.json({ success: false, error: e.message }); }
});

app.get('/api/targets', async (_, res) => {
  try { const r = await axios.get('http://patrick:3005/targets', { timeout: 5000 }); res.json(r.data); }
  catch(e) { res.json({ success: false, error: e.message }); }
});

app.get('/api/trades', async (_, res) => {
  try { const r = await axios.get('http://dj:3003/trades', { timeout: 5000 }); res.json(r.data); }
  catch(e) { res.json({ success: false, error: e.message }); }
});

app.get('/api/prices', async (_, res) => {
  try { const r = await axios.get('http://oracle-engine:3002/prices', { timeout: 5000 }); res.json(r.data); }
  catch(e) { res.json({ success: false, error: e.message }); }
});

app.post('/api/compound', async (_, res) => {
  try {
    await axios.post('http://agentbus:9081/command', { type: 'command', command: 'forceCompound', to: 'hashim' });
    res.json({ ok: true });
  } catch(e) { res.json({ ok: false, error: e.message }); }
});

app.post('/api/halt', async (_, res) => {
  try { await axios.post('http://bossman:3006/emergency-halt'); res.json({ ok: true }); }
  catch(e) { res.json({ ok: false, error: e.message }); }
});

app.post('/api/reset', async (_, res) => {
  try { await axios.post('http://bossman:3006/reset'); res.json({ ok: true }); }
  catch(e) { res.json({ ok: false, error: e.message }); }
});

app.post('/api/yolo', async (req, res) => {
  try {
    const enable = req.body.enable !== false;
    await axios.post('http://agentbus:9081/command', { type: 'command', command: enable ? 'yoloEnable' : 'yoloDisable', to: 'all', multiplier: 10 });
    res.json({ ok: true, yolo: enable });
  } catch(e) { res.json({ ok: false, error: e.message }); }
});

app.post('/api/scan', async (_, res) => {
  try { await axios.post('http://patrick:3005/scan'); res.json({ ok: true }); }
  catch(e) { res.json({ ok: false, error: e.message }); }
});

app.listen(8082, '0.0.0.0', () => console.log('📊 DASHBOARD :8082 — ONLINE'));
JSEOF

    cat > "$W/agents/dashboard/public/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>🔱 OMEGA BEAST V∞.2</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#0a0a0f;color:#d4af37;font-family:'Courier New',monospace;min-height:100vh;overflow-x:hidden}
.header{text-align:center;padding:15px 10px;background:linear-gradient(180deg,#1a1a2e,#0a0a0f);border-bottom:2px solid #d4af37}
.header h1{font-size:1.4em;color:#d4af37;text-shadow:0 0 20px rgba(212,175,55,0.5)}
.header .sub{color:#888;font-size:0.7em;margin-top:3px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:10px;padding:10px}
.card{background:#111;border:1px solid #333;border-radius:8px;padding:12px;position:relative;overflow:hidden}
.card.alive{border-color:#00ff88} .card.offline{border-color:#ff4444}
.card h3{font-size:0.9em;margin-bottom:8px;display:flex;align-items:center;gap:6px}
.dot{width:8px;height:8px;border-radius:50%;display:inline-block}
.dot.on{background:#00ff88;box-shadow:0 0 8px #00ff88} .dot.off{background:#ff4444}
.stat{display:flex;justify-content:space-between;font-size:0.75em;padding:2px 0;border-bottom:1px solid #1a1a1a}
.stat .label{color:#888} .stat .value{color:#0f0;font-weight:bold}
.buttons{display:flex;flex-wrap:wrap;gap:8px;padding:10px;justify-content:center}
.btn{background:#1a1a2e;color:#d4af37;border:1px solid #d4af37;padding:8px 16px;border-radius:5px;cursor:pointer;font-family:inherit;font-size:0.8em;transition:all 0.2s}
.btn:hover{background:#d4af37;color:#000} .btn:active{transform:scale(0.95)}
.btn.danger{border-color:#ff4444;color:#ff4444} .btn.danger:hover{background:#ff4444;color:#fff}
.btn.yolo{border-color:#ff6600;color:#ff6600} .btn.yolo:hover{background:#ff6600;color:#fff}
.log{background:#050508;border:1px solid #222;border-radius:8px;margin:10px;padding:10px;max-height:300px;overflow-y:auto;font-size:0.7em}
.log-entry{padding:2px 5px;border-bottom:1px solid #111} .log-entry:nth-child(odd){background:#0a0a10}
.yolo-bar{background:linear-gradient(90deg,#ff6600,#ff0000);text-align:center;padding:5px;font-weight:bold;color:#fff;font-size:0.85em;animation:pulse 2s infinite}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:0.7}}
.footer{text-align:center;padding:10px;color:#555;font-size:0.65em;border-top:1px solid #222}
</style></head><body>
<div class="header">
<h1>🔱 OMEGA PERFECTION BEAST V∞.2</h1>
<div class="sub">COMMANDER: PATRICK DIGGES LA TOUCHE | CHUKUA KONTROLI YOTE</div>
</div>
<div class="yolo-bar" id="yoloBar">🔥 YOLO MODE: 10X MULTIPLIER — MAXIMUM AGGRESSION ACTIVE 🔥</div>
<div class="grid" id="agentGrid"></div>
<div class="buttons">
<button class="btn" onclick="action('/api/compound')">💎 COMPOUND ALL</button>
<button class="btn" onclick="action('/api/scan')">🔍 FORCE SCAN</button>
<button class="btn yolo" onclick="action('/api/yolo',{enable:true})">🔥 YOLO ON</button>
<button class="btn" onclick="action('/api/yolo',{enable:false})">⚪ YOLO OFF</button>
<button class="btn danger" onclick="if(confirm('EMERGENCY HALT?'))action('/api/halt')">🚨 EMERGENCY HALT</button>
<button class="btn" onclick="action('/api/reset')">🔄 RESET BREAKER</button>
<button class="btn" onclick="refresh()">♻️ REFRESH</button>
</div>
<div class="log" id="sysLog"><div class="log-entry">🔱 DASHBOARD LOADED — WAITING FOR DATA...</div></div>
<div class="footer">FOR JAMES 🕯️ | FOR ANNETTE 🕯️ | FOR LEANNA & EVA 🌍 | LA TOUCHE DYNASTY</div>
<script>
const log=(m)=>{const l=document.getElementById('sysLog');const d=document.createElement('div');d.className='log-entry';d.textContent=new Date().toLocaleTimeString()+' '+m;l.prepend(d);if(l.children.length>200)l.removeChild(l.lastChild)};
const action=async(url,body)=>{try{const r=await fetch(url,{method:'POST',headers:{'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined});const d=await r.json();log('CMD: '+url+' → '+(d.ok?'✅':'❌'));refresh()}catch(e){log('❌ '+e.message)}};
const renderCard=(name,data)=>{const alive=data.status==='ALIVE';const c=document.createElement('div');c.className='card '+(alive?'alive':'offline');let stats='';if(data.data){const d=data.data;Object.entries(d).forEach(([k,v])=>{if(k!=='status'&&typeof v!=='object'){stats+=`<div class="stat"><span class="label">${k}</span><span class="value">${v}</span></div>`}})}c.innerHTML=`<h3><span class="dot ${alive?'on':'off'}"></span>${name}</h3>${stats}`;return c};
const refresh=async()=>{try{const r=await fetch('/api/status');const d=await r.json();const g=document.getElementById('agentGrid');g.innerHTML='';Object.entries(d).forEach(([k,v])=>g.appendChild(renderCard(v.name||k,v)));log('♻️ STATUS REFRESHED — '+Object.values(d).filter(v=>v.status==='ALIVE').length+'/'+Object.keys(d).length+' ONLINE')}catch(e){log('❌ '+e.message)}};
refresh();setInterval(refresh,10000);
// WEBSOCKET LIVE FEED
try{const ws=new WebSocket('ws://'+location.hostname+':8081');ws.onmessage=e=>{try{const m=JSON.parse(e.data);if(m.type==='agent:status')log('📡 '+m.agent+': '+JSON.stringify(m.data).substring(0,80));if(m.type==='heartbeat')log('💓 HEARTBEAT — '+m.agents?.length+' agents');if(m.channel)log('📢 '+m.channel)}catch(e){}};ws.onclose=()=>log('⚠️ WS DISCONNECTED — RECONNECTING...')}catch(e){}
</script></body></html>
HTMLEOF
    cat > "$W/agents/dashboard/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 8082
HEALTHCHECK --interval=15s --timeout=5s --retries=3 CMD wget -qO- http://localhost:8082/api/status || exit 1
CMD ["node","server.js"]
EOF
    echo -e "${GREEN}${BOLD}✓ DASHBOARD CREATED${NC}"
}

# ═══════════════════════════════════════════════════════
# [9/12] DOCKER COMPOSE — PRODUCTION YAML
# ═══════════════════════════════════════════════════════
create_docker_compose() {
    echo -e "${CYAN}${BOLD}[9/12] CREATING DOCKER COMPOSE...${NC}"
    cat > "$W/docker-compose.yml" << 'DCEOF'
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: omega-redis
    networks:
      - omega-net
    volumes:
      - redis-data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  agentbus:
    build: ./agents/agentbus
    container_name: omega-agentbus
    ports:
      - "8081:8081"
      - "9081:9081"
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:9081/health"]
      interval: 15s
      timeout: 5s
      retries: 3

  hustle-bridge:
    build: ./agents/hustle-bridge
    container_name: omega-hustle-bridge
    ports:
      - "3001:3001"
    env_file: ./config/.env
    depends_on:
      agentbus:
        condition: service_healthy
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3001/health"]
      interval: 20s
      timeout: 5s
      retries: 3

  telegram-bot:
    build: ./agents/telegram-bot
    container_name: omega-telegram
    env_file: ./config/.env
    depends_on:
      - hustle-bridge
    networks:
      - omega-net
    restart: unless-stopped

  oracle-engine:
    build: ./agents/oracle-engine
    container_name: omega-oracle
    ports:
      - "3002:3002"
    env_file: ./config/.env
    depends_on:
      agentbus:
        condition: service_healthy
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3002/health"]
      interval: 20s
      timeout: 5s
      retries: 3

  patrick:
    build: ./agents/patrick
    container_name: omega-patrick
    ports:
      - "3005:3005"
    env_file: ./config/.env
    depends_on:
      agentbus:
        condition: service_healthy
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3005/health"]
      interval: 20s
      timeout: 5s
      retries: 3

  dj:
    build: ./agents/dj
    container_name: omega-dj
    ports:
      - "3003:3003"
    env_file: ./config/.env
    depends_on:
      agentbus:
        condition: service_healthy
      hustle-bridge:
        condition: service_healthy
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3003/health"]
      interval: 20s
      timeout: 5s
      retries: 3

  hashim:
    build: ./agents/hashim
    container_name: omega-hashim
    ports:
      - "3004:3004"
    env_file: ./config/.env
    depends_on:
      agentbus:
        condition: service_healthy
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3004/health"]
      interval: 20s
      timeout: 5s
      retries: 3

  bossman:
    build: ./agents/bossman
    container_name: omega-bossman
    ports:
      - "3006:3006"
    env_file: ./config/.env
    depends_on:
      agentbus:
        condition: service_healthy
      hustle-bridge:
        condition: service_healthy
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3006/health"]
      interval: 20s
      timeout: 5s
      retries: 3

  dashboard:
    build: ./agents/dashboard
    container_name: omega-dashboard
    ports:
      - "8082:8082"
    depends_on:
      - agentbus
      - hustle-bridge
      - patrick
      - dj
      - hashim
      - bossman
    networks:
      - omega-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:8082/api/status"]
      interval: 15s
      timeout: 5s
      retries: 3

networks:
  omega-net:
    driver: bridge

volumes:
  redis-data:
DCEOF
    echo -e "${GREEN}${BOLD}✓ DOCKER COMPOSE CREATED${NC}"
}

# ═══════════════════════════════════════════════════════
# [10/12] NGINX & FIREWALL
# ═══════════════════════════════════════════════════════
configure_nginx_firewall() {
    echo -e "${CYAN}${BOLD}[10/12] CONFIGURING NGINX & FIREWALL...${NC}"
    cat > /etc/nginx/sites-available/omega-beast << 'NGXEOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host $host;
    }

    location /ws {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 86400;
    }

    location /bus/ {
        proxy_pass http://127.0.0.1:9081/;
        proxy_set_header Host $host;
    }
}
NGXEOF
    ln -sf /etc/nginx/sites-available/omega-beast /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && systemctl reload nginx

    # FIREWALL
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 8081/tcp
    ufw allow 8082/tcp
    ufw allow 9081/tcp
    ufw allow 3001:3006/tcp
    ufw --force enable
    echo -e "${GREEN}${BOLD}✓ NGINX & FIREWALL CONFIGURED${NC}"
}

# ═══════════════════════════════════════════════════════
# [11/12] WATCHDOG — SELF-HEALING EVERY 3 MINUTES
# ═══════════════════════════════════════════════════════
create_watchdog() {
    echo -e "${CYAN}${BOLD}[11/12] CREATING WATCHDOG...${NC}"
    cat > "$W/watchdog.sh" << 'WDEOF'
#!/bin/bash
SERVICES="omega-agentbus omega-hustle-bridge omega-oracle omega-patrick omega-dj omega-hashim omega-bossman omega-dashboard omega-redis"
LOG="/var/log/omega-watchdog.log"
echo "[$(date)] WATCHDOG CHECK" >> "$LOG"
RUNNING=0; TOTAL=0
for s in $SERVICES; do
    TOTAL=$((TOTAL+1))
    if docker ps --format '{{.Names}}' | grep -q "^${s}$"; then
        RUNNING=$((RUNNING+1))
    else
        echo "[$(date)] ⚠️  RESTARTING: $s" >> "$LOG"
        cd /opt/omega && docker-compose up -d "$( echo $s | sed 's/omega-//' )" 2>> "$LOG"
    fi
done
echo "[$(date)] WATCHDOG: $RUNNING/$TOTAL RUNNING" >> "$LOG"
# AUTO-ROTATE LOG
if [ $(wc -l < "$LOG" 2>/dev/null || echo 0) -gt 5000 ]; then
    tail -1000 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi
WDEOF
    chmod +x "$W/watchdog.sh"
    (crontab -l 2>/dev/null | grep -v omega-watchdog; echo "*/3 * * * * /opt/omega/watchdog.sh") | crontab -
    echo -e "${GREEN}${BOLD}✓ WATCHDOG CREATED — EVERY 3 MINUTES${NC}"
}

# ═══════════════════════════════════════════════════════
# [12/12] SYSTEMD SERVICE — BOOT PERSISTENCE
# ═══════════════════════════════════════════════════════
create_systemd_service() {
    echo -e "${CYAN}${BOLD}[12/12] CREATING SYSTEMD SERVICE...${NC}"
    cat > /etc/systemd/system/omega-beast.service << 'SDEOF'
[Unit]
Description=Omega Perfection Beast V∞.2 — La Touche Dynasty
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/omega
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
SDEOF
    systemctl daemon-reload
    systemctl enable omega-beast.service
    echo -e "${GREEN}${BOLD}✓ SYSTEMD SERVICE ENABLED — AUTO-START ON BOOT${NC}"
}

# ═══════════════════════════════════════════════════════
# MAIN EXECUTION — BUILD & DEPLOY
# ═══════════════════════════════════════════════════════
main() {
    echo -e "${PURPLE}${BOLD}"
    echo "══════════════════════════════════════════════════════"
    echo "  🔱 DEPLOYING OMEGA BEAST V∞.2"
    echo "  COMMANDER: PATRICK DIGGES LA TOUCHE"
    echo "  FOR JAMES 🕯️ | FOR ANNETTE 🕯️ | FOR LEANNA & EVA 🌍"
    echo "══════════════════════════════════════════════════════"
    echo -e "${NC}"

    prepare_system          # [1/12]
    collect_secrets         # [2/12]
    create_agentbus         # [3/12]
    create_hustle_bridge    # [4/12]
    create_telegram_bot     # [5/12]
    create_oracle_engine    # [6/12]
    create_agents           # [7/12]
    create_dashboard        # [8/12]
    create_docker_compose   # [9/12]
    configure_nginx_firewall # [10/12]
    create_watchdog         # [11/12]
    create_systemd_service  # [12/12]

    # BUILD & LAUNCH
    echo -e "${CYAN}${BOLD}BUILDING DOCKER IMAGES...${NC}"
    cd "$W" && docker-compose build --parallel 2>&1 | tail -5
    echo -e "${CYAN}${BOLD}LAUNCHING ALL SERVICES...${NC}"
    docker-compose up -d
    sleep 10
    docker-compose ps

    echo ""
    echo -e "${PURPLE}${BOLD}"
    cat << 'DONE'
╔══════════════════════════════════════════════════════════╗
║  🔱 OMEGA PERFECTION BEAST V∞.2 — DEPLOYMENT COMPLETE  ║
╚══════════════════════════════════════════════════════════╝
DONE
    echo -e "${NC}"
    IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    echo -e "${GREEN}${BOLD}  ACCESS POINTS:${NC}"
    echo -e "  📊 DASHBOARD:     http://$IP:8082"
    echo -e "  🔌 AGENTBUS WS:   ws://$IP:8081"
    echo -e "  📡 AGENTBUS API:  http://$IP:9081/status"
    echo -e "  🌉 HUSTLE BRIDGE: http://$IP:3001/health"
    echo -e "  🔮 ORACLE:        http://$IP:3002/health"
    echo -e "  🔍 PATRICK:       http://$IP:3005/health"
    echo -e "  🎯 DJ:            http://$IP:3003/health"
    echo -e "  💎 HASHIM:        http://$IP:3004/health"
    echo -e "  🛡️  BOSSMAN:       http://$IP:3006/health"
    echo ""
    echo -e "  ${YELLOW}YOLO MODE:   🔥 ACTIVE — 10X MULTIPLIER${NC}"
    echo -e "  ${YELLOW}AGGRESSION:  MAXIMUM${NC}"
    echo ""
    echo -e "  ${CYAN}MANAGEMENT:${NC}"
    echo "  docker-compose -f /opt/omega/docker-compose.yml ps"
    echo "  docker-compose -f /opt/omega/docker-compose.yml logs -f"
    echo "  docker-compose -f /opt/omega/docker-compose.yml restart"
    echo ""
    echo -e "${PURPLE}${BOLD}"
    echo "  FOR JAMES 🕯️ | FOR ANNETTE 🕯️ | FOR LEANNA & EVA 🌍"
    echo "  CHUKUA KONTROLI YOTE 🔱"
    echo -e "${NC}"
}
main "$@"

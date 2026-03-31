# 🚛 Trucker Logistics Job (Qbox / FiveM)

![FiveM](https://img.shields.io/badge/FiveM-Ready-blue?style=for-the-badge)
![Qbox](https://img.shields.io/badge/Qbox-Compatible-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-Free-lightgrey?style=for-the-badge)

A complete **Trucker Job System** for FiveM using the **Qbox framework**.  
Built with a focus on **security, performance, and realism**, this script provides a full logistics experience from pickup to delivery with proper anti-exploit validation.

---

## 📸 Preview

> Add your screenshots here


---

## ✨ Features

- 📦 Multiple delivery routes (fully configurable)
- 🚛 Trailer spawning system with ownership tracking
- 🧠 Smooth mission flow (Pickup → Attach → Deliver → Complete)
- 🔐 Strong server-side validation (anti-cheat)
- 📍 GPS navigation with blips
- 🎯 ox_target interaction system
- 💬 Qbox notification integration
- 🧹 Automatic cleanup system
- ⚡ Optimized loops (low resource usage)

### 🛑 Anti-Exploit Protection

- ❌ Cannot complete mission without starting
- ❌ Cannot fake trailer
- ❌ Cannot finish outside delivery zone
- ❌ Cannot speedrun (time validation)
- ❌ Trailer ownership is strictly verified

---

## 🧱 Requirements

Make sure the following resources are installed:

- **qbx_core**
- **ox_lib**
- **ox_target**

---

## ⚙️ Installation

### 1️⃣ Download & Place
resources/[jobs]/trucker-logistics


### 2️⃣ Add to server.cfg
ensure ox_lib
ensure ox_target
ensure qbx_core
ensure trucker-logistics


### 3️⃣ Restart Server

---

## 🧪 How It Works

### 🟢 Step 1: Start Contract
- Go to Logistics NPC
- Open job menu
- Select a route

### 🟡 Step 2: Pickup
- Drive near pickup location
- Trailer spawns automatically

### 🔵 Step 3: Transport
- Attach trailer to your truck

### 🟣 Step 4: Delivery
- Drive to drop-off location
- Park trailer in delivery zone

### 🟢 Step 5: Completion
System verifies:

- ✅ Active mission exists  
- ✅ Correct route ID  
- ✅ Player is near drop-off  
- ✅ Trailer belongs to player  
- ✅ Minimum delivery time passed  

💰 Payment is rewarded after validation.

---

## 🔐 Security System (Server-Side)

All important checks are done on the **server**:

- Mission existence validation
- Route verification
- Distance check
- Time check
- Trailer ownership validation

This ensures the system is **exploit-safe**.

---

## 🧠 Configuration

All settings are located in:
config.lua



## 🛠 Debug Mode

Enable debug logs for development:

Config.Debug = true

Debug Includes:
Mission start logs
Trailer spawn logs
Completion validation logs
Error tracking


## 📁 File Structure
trucker-logistics/
│── client.lua      # Mission flow, UI, markers
│── server.lua      # Validation, spawning, payments
│── config.lua      # Routes & settings
│── fxmanifest.lua  # Resource manifest


## ⚡ Performance
Idle: ~0.00ms
Active Mission: ~0.01–0.03ms
Uses optimized loops with dynamic sleep

# 🚀 Future Improvements
📉 Cargo damage system (affects payout)
🚚 Multiple truck class support
👥 Convoy / group jobs
📊 Job leveling system
💸 Distance-based dynamic payouts
🧾 Job history & stats tracking

# 🤝 Credits

Ammar Talpur
Full-Stack Developer | FiveM Developer
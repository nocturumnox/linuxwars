#!/bin/bash
# ========================================
# DEATH STAR ESCAPE ROOM - DEPLOY SCRIPT
# ========================================
#
# AFTER DEPLOYMENT
# --------------------------------------------------
# Start the game (as NORMAL USER, NOT root):
#   /home/death_star_escape/start_game.sh
#
# Reset the game:
#   Re-run this deploy script (it wipes everything)
#
# Recommended:
# - Run inside VM / sandbox
# - Use a dedicated player account
# --------------------------------------------------

set -e

if [ "$EUID" -ne 0 ]; then
  echo " Root required: sudo bash deploy_death_star_escape.sh"
  exit 1
fi

BASE_DIR="${BASE_DIR:-/home/death_star_escape}"

echo " Deploying DEATH STAR ESCAPE ROOM..."
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

# ========================================
# STAGE 1: CELL
# ========================================
mkdir -p "$BASE_DIR/stage1/zelle"

cat > "$BASE_DIR/stage1/zelle/system_log_001.txt" << 'EOF'
[ERROR] Access denied. Prisoner ID: 047
No keycards assigned to this sector.
EOF

cat > "$BASE_DIR/stage1/zelle/readme.txt" << 'EOF'
IMPORTANT: Read this file first!
This is just a normal directory.
EOF

cat > "$BASE_DIR/stage1/zelle/.hidden_dir" << 'EOF'
Secret Notes: Officer K. hid the key.
EOF

cat > "$BASE_DIR/stage1/zelle/.emergency_key.sh" << 'EOF'
#!/bin/bash
echo " EMERGENCY KEY ACTIVATED!"
echo "Cell door opens quietly..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../stage2"
./decision_terminal.sh
EOF
chmod +x "$BASE_DIR/stage1/zelle/.emergency_key.sh"

# ========================================
# STAGE 2: DECISION HUB
# ========================================
mkdir -p "$BASE_DIR/stage2"

cat > "$BASE_DIR/stage2/decision_terminal.sh" << 'EOF'
#!/bin/bash
clear
echo "╔══════════════════════════════════════╗"
echo "║ CORRIDOR - PATH SELECTOR             ║"
echo "║                                      ║"
echo "║ [1] ADMIN TERMINAL (passw. req.)     ║"
echo "║ [2] MAINTENANCE ROOM (Tech)          ║"
echo "║ [3] LOG ARCHIVE (grep required)      ║"
echo "╚══════════════════════════════════════╝"
echo -n "→ "; read CHOICE
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case $CHOICE in
  1) cd "$SCRIPT_DIR/../stage2a/admin" && exec bash ;;
  2) cd "$SCRIPT_DIR/../stage2b/wartung" && exec bash ;;
  3) cd "$SCRIPT_DIR/../stage2c/logs" && exec bash ;;
  *) echo " Wrong input"; exit 1 ;;
esac
EOF
chmod +x "$BASE_DIR/stage2/decision_terminal.sh"

# ========================================
# STAGE 2A: ADMIN TERMINAL
# ========================================
mkdir -p "$BASE_DIR/stage2a/admin/users"

# officer_db.txt
cat > "$BASE_DIR/stage2a/admin/users/officer_db.txt" << 'EOF'
Kravitz: Level 9, Pass: Kravitz42 (last change: yesterday)
EOF

# login.sh (fixed nested heredoc)
cat > "$BASE_DIR/stage2a/admin/login.sh" << 'EOF'
#!/bin/bash
echo "ADMIN TERMINAL - ROOT ACCESS REQUIRED"
echo "Username: admin | Password: ?"
echo -n "Password: "; read PASS
if [[ "$PASS" == "Kravitz42" ]]; then
  echo " ACCESS GRANTED"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$SCRIPT_DIR/../../stage3/reactor" && exec bash
else
  echo " ACCESS DENIED - LOCKOUT 60s"
  sleep 60
  exit 1
fi
EOF
chmod +x "$BASE_DIR/stage2a/admin/login.sh"

# ========================================
# STAGE 2B: MAINTENANCE
# ========================================
mkdir -p "$BASE_DIR/stage2b/wartung"

cat > "$BASE_DIR/stage2b/wartung/README.md" << 'EOF'
# MAINTENANCE ROOM
Run the droid: sudo ./.sys_core_42.sh
EOF

# .sys_core_42.sh
cat > "$BASE_DIR/stage2b/wartung/.sys_core_42.sh" << 'EOF'
#!/bin/bash
echo " PERMISSION DENIED - Root required"
echo "HINT: Use the sudo password from /etc/shadow_hint"
exit 1
EOF
chmod +x "$BASE_DIR/stage2b/wartung/.sys_core_42.sh"

# Shadow hint
cat > "$BASE_DIR/stage2b/wartung/.shadow_hint" << 'EOF'
sudo pw: "linux123" (temporary for maintenance)
EOF

# Hidden exec SUID
cat > "$BASE_DIR/stage2b/wartung/.hidden_exec_99.sh" << 'EOF'
#!/bin/bash
echo " R2-D2: *bzzzt* Maintenance mode activated!"
echo "Reactor access unlocked."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../stage3/reactor" && exec bash
EOF
chmod 4755 "$BASE_DIR/stage2b/wartung/.hidden_exec_99.sh"

# Fake / decoy scripts (multiple)
for script in .fake_tool.sh .useless_script.sh .sys_diag_phantom.sh .priv_escal_ghost.sh .maint_core_fake.sh .hidden_exec_98.sh .reactor_probe_decoy.sh; do
cat > "$BASE_DIR/stage2b/wartung/$script" << 'EOF'
#!/bin/bash
echo "This is a decoy script. Nothing happens."
exit 0
EOF
chmod +x "$BASE_DIR/stage2b/wartung/$script"
done

# ========================================
# STAGE 2C: LOGS
# ========================================
mkdir -p "$BASE_DIR/stage2c/logs/access"
mkdir -p "$BASE_DIR/stage2c/logs/error"

# Generate access logs
for i in {1..50}; do
  echo "2025-12-$i 14:32:15 ERROR Access denied IP: 10.0.0.$i" >> "$BASE_DIR/stage2c/logs/access/access.log"
done

# error.log
cat > "$BASE_DIR/stage2c/logs/error/error.log" << 'EOF'
CRITICAL: Officer Kravitz unlocked reactor door @ 2025-12-16 18:07
AUTH: sudo pw for maintenance: linux123
EOF

# analyze.sh
cat > "$BASE_DIR/stage2c/logs/analyze.sh" << 'EOF'
#!/bin/bash
echo " LOG ANALYZER"
grep -i "reactor\|sudo\|kravitz" "$PWD"/error/error.log "$PWD"/access/access.log
echo "→ Use this info for other paths!"
EOF
chmod +x "$BASE_DIR/stage2c/logs/analyze.sh"

# ========================================
# STAGE 3: REACTOR
# ========================================
mkdir -p "$BASE_DIR/stage3/reactor/sensors"
mkdir -p "$BASE_DIR/stage3/reactor/controls"

echo "42.0" > "$BASE_DIR/stage3/reactor/sensors/cal.txt"
echo "Pi314" > "$BASE_DIR/stage3/reactor/.config"
echo "COOLANT_ALPHA" > "$BASE_DIR/stage3/reactor/controls/coolant_beta.txt"

cat > "$BASE_DIR/stage3/reactor/reactor_control.sh" << 'EOF'
#!/bin/bash
clear
echo " REACTOR OVERHEAT - 90 SECONDS!"
echo "3 Steps: 1) Calibrate sensor 2) Enter code 3) Cool down"
(
  sleep 90
  echo "💥 EXPLOSION! Time's up. Reactor meltdown!"
  kill -9 $$
) &
TIMER_PID=$!
trap "kill $TIMER_PID 2>/dev/null" EXIT

read -p "Step 1 - Sensor Calibration (cat sensors/cal.txt): " sensor
[[ "$sensor" == "42.0" ]] || { echo " Sensor error!"; exit 1; }
read -p "Step 2 - Stabilization Code: " code
[[ "$code" == "Pi314" ]] || { echo " Wrong code!"; exit 1; }
read -p "Step 3 - Coolant Code (find . -name cool*.txt): " cool
[[ "$cool" == "COOLANT_ALPHA" ]] || { echo " Cooling failed!"; exit 1; }

kill $TIMER_PID 2>/dev/null
echo "REACTOR STABILIZED!"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../stage4/escape_pod" && exec bash
EOF
chmod +x "$BASE_DIR/stage3/reactor/reactor_control.sh"

# ========================================
# STAGE 4: ESCAPE POD
# ========================================
mkdir -p "$BASE_DIR/stage4/escape_pod"

# Pod files
echo "fuel=OK" > "$BASE_DIR/stage4/escape_pod/pod_17.conf"

# Decoy launch sequence
cat > "$BASE_DIR/stage4/escape_pod/launch_sequence.sh" << 'EOF'
#!/bin/bash
echo "LAUNCH SEQUENCE INITIATED"
echo "Pipeline Challenge - Commands in 1 line:"
echo "1. ls -la | grep pod → Find Pod-ID"
echo "2. cat pod_???.conf | grep fuel → Check fuel"
echo "3. echo 'LAUNCH' | ./pod_auth.sh → Launch"
read -p "Are you ready? (y/N): " ready
[[ "$ready" =~ [Yy] ]] || exit 1
clear
echo "MISSION SUCCESS! You have escaped the Death Star!"
EOF
chmod +x "$BASE_DIR/stage4/escape_pod/launch_sequence.sh"

# ========================================
# START GAME SCRIPT
# ========================================
cat > "$BASE_DIR/start_game.sh" << 'EOF'
#!/bin/bash
# HOW TO START:
#   /home/death_star_escape/start_game.sh
# (run as normal user, NOT root)

BASE_DIR="/home/death_star_escape"

if [ "$EUID" -eq 0 ]; then
  echo "Do not run as root."
  exit 1
fi

cd "$BASE_DIR/stage1/zelle" || exit 1
echo "You wake up in a prison cell."
echo "Use Linux commands to escape."
exec bash --noprofile --norc
EOF
chmod +x "$BASE_DIR/start_game.sh"

echo
echo " DEPLOYMENT COMPLETE"
echo " Start the game with:"
echo "   $BASE_DIR/start_game.sh"
echo

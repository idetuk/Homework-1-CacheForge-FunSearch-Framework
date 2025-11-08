#!/bin/bash
#
# Reproduce Script for CacheForge Homework 1
# This script compiles and runs the 10 single-core tests for the LIME policy and LRU baseline.
# The multi-core section is disabled due to trace availability constraints.

REPO_ROOT=$(pwd)
CHAMPSIM_DIR="${REPO_ROOT}/ChampSim_CRC2"
POLICY_DIR="${CHAMPSIM_DIR}/champ_repl_pol"

# --- 1. SETUP AND COMPILATION ---
echo "1. Compiling all required executables (Config 1 and 2)..."
cd "$CHAMPSIM_DIR"

# Copy your best policy into the ChampSim environment
cp "${POLICY_DIR}/lime.cc" champ_repl_pol/
cp "${POLICY_DIR}/lru.cc" champ_repl_pol/

# Compile Config 1 (No Prefetcher)
g++ -Wall --std=c++11 -o lru-config1 champ_repl_pol/lru.cc lib/config1.a
g++ -Wall --std=c++11 -o lime-config1 champ_repl_pol/lime.cc lib/config1.a

# Compile Config 2 (With Prefetcher)
g++ -Wall --std=c++11 -o lru-config2 champ_repl_pol/lru.cc lib/config2.a
g++ -Wall --std=c++11 -o lime-config2 champ_repl_pol/lime.cc lib/config2.a

echo "Compilation complete."
echo "-------------------------------------"

# --- 2. SINGLE-CORE SIMULATIONS (10 Workloads) ---
echo "2. Running 10 Single-Core Simulations (LRU and LIME)..."

single_traces=(
    "astar_313B.trace.gz"
    "lbm_564B.trace.gz"
    "mcf_250B.trace.gz"
    "milc_409B.trace.gz"
    "omnetpp_17B.trace.gz"
)

for trace in "${single_traces[@]}"; do
    TRACE_PATH="./traces/$trace"
    TRACE_NAME=$(basename "$trace" .trace.gz)
    
    # Run LRU Config 1 & 2
    echo "  Running $TRACE_NAME with LRU..."
    ./lru-config1 -traces "$TRACE_PATH" > "${TRACE_NAME}-lru-config1.log" 2>&1 &
    ./lru-config2 -traces "$TRACE_PATH" > "${TRACE_NAME}-lru-config2.log" 2>&1 &

    # Run LIME Config 1 & 2
    echo "  Running $TRACE_NAME with LIME..."
    ./lime-config1 -traces "$TRACE_PATH" > "${TRACE_NAME}-lime-config1.log" 2>&1 &
    ./lime-config2 -traces "$TRACE_PATH" > "${TRACE_NAME}-lime-config2.log" 2>&1 &
done

wait
echo "Single-core simulations complete."

# --- 3. DATA EXTRACTION ---
echo "3. Extracting final IPC and MPKI data..."
grep "Finished CPU" *-config[1-2].log > all_single_core_results.txt

# --- 4. MULTI-CORE SECTION (COMMENTED OUT) ---
echo "4. Multi-core simulation section skipped due to trace constraints."
# # Multi-core compilation:
# g++ -Wall --std=c++11 -DCONFIG_8MB -o lru-config3 champ_repl_pol/lru.cc lib/config3.a
# # ... (rest of compilation)

# # Multi-core execution:
# # ./lru-config3 -traces ./traces/bzip2_10M.trace.gz ... > lru-config3-multiapp.log 2>&1
# # ... (rest of execution)

echo "Reproduction script finished successfully."

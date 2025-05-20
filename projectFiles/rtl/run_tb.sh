#!/usr/bin/env bash
set -e
echo "==> Compiling..."
vlogan +v2k -full64 -sverilog \
       spn_sbox_pkg.sv \
       spn_if.sv spn_round.sv spn_cu_top.sv tb_spn_simple.sv

echo "==> Elaborating..."
vcs -full64 tb_spn_simple

echo "==> Running..."
./simv

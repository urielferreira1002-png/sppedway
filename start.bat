@echo off
title SpeedWay - Iniciando

cd /d "%~dp0"

echo ========================================
echo           SPEEDWAY APP
echo ========================================
echo.

echo [1/2] Verificando dependencias...
if not exist "node_modules" (
    echo Instalando dependencias...
    bun install
)

echo.
echo [2/2] Iniciando servidor...
echo.
echo SpeedWay sera aberto no navegador.
echo.

bun run dev

pause
@echo off
setlocal enabledelayedexpansion

set "REPO_URL=https://github.com/RustedBR/company-personal-assistant.git"
set "INSTALL_DIR=%USERPROFILE%\opencode-wsl"

title OpenCode WSL - Instalador
color 1f

:menu
cls
echo ======================================
echo    OPENCODE WSL - INSTALADOR
echo ======================================
echo.
echo  1 - INSTALAR (primeira vez)
echo  2 - ABRIR OpenCode
echo  3 - SAIR
echo.
echo ======================================
set /p opcao="Digite a opcao: "

if "%opcao%"=="1" goto install
if "%opcao%"=="2" goto open
if "%opcao%"=="3" goto exit
echo.
echo [ERRO] Opcao invalida!
timeout /t 2 >nul
goto menu

:install
cls
echo ======================================
echo    INSTALANDO OPENCOD
echo ======================================
echo.

REM Verificar se é admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Execute este arquivo como Administrador
    echo.
    echo Clique com botao direito e selecione "Executar como administrador"
    pause
    exit /b 1
)

REM Verificar WSL
echo [1/5] Verificando WSL...
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo        WSL nao encontrado. Instalando...
    wsl --install -d Ubuntu
    echo        Reinicie o computador apos instalar o WSL
    echo.
    echo [AVISO] Por favor, reinicie o computador e execute este instalador novamente
    pause
    exit /b 1
)
echo        ✓ WSL instalado

REM Verificar Git
echo [2/5] Verificando Git...
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo        Git nao encontrado. Instalando...
    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
)
echo        ✓ Git instalado

REM Clonar repositorio
echo [3/5] Baixando arquivos do GitHub...
if exist "%INSTALL_DIR%" (
    echo        Pasta ja existe. Atualizando...
    cd /d "%INSTALL_DIR%"
    git pull origin master 2>nul
) else (
    echo        Clonando repositorio...
    git clone "%REPO_URL%" "%INSTALL_DIR%"
)
echo        ✓ Arquivos baixados

REM Executar setup no WSL
echo [4/5] Instalando OpenCode no WSL...
cd /d "%INSTALL_DIR%"
wsl bash setup.sh
if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falha na instalacao do OpenCode
    pause
    goto menu
)
echo        ✓ OpenCode instalado

echo [5/5] Verificando instalacao...
wsl which opencode >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] Pode ser necessario reiniciar o WSL. Execute:
    echo        wsl --shutdown
    echo        E tente novamente.
)

echo.
echo ======================================
echo    INSTALACAO CONCLUIDA!
echo ======================================
echo.
echo Para usar o OpenCode, escolha opcao 2 no menu
echo.
pause
goto menu

:open
cls
echo ======================================
echo    ABRINDO OPENCOD
echo ======================================
echo.

REM Verificar se WSL tem sessoes ativas
wsl -l -v 2>nul | findstr /C:"Running" >nul
set "WSL_RUNNING=%errorlevel%"

if %WSL_RUNNING%==0 (
    echo [INFO] WSL ja esta aberto. Executando OpenCode...
    echo.
    echo Quando terminar, digite: exit
    echo.
    wsl opencode
) else (
    echo [INFO] Abrindo nova janela do WSL com OpenCode...
    echo.
    echo Quando terminar, basta fechar a janela
    echo.
    start "OpenCode" wsl opencode
)

goto menu

:exit
echo.
echo Ate logo!
timeout /t 1 >nul
exit /b 0
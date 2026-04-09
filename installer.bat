@echo off
setlocal enabledelayedexpansion

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

REM Configurar Git para line endings Unix (LF)
echo [3/5] Configurando Git para line endings...
git config --global core.autocrlf input
git config --global core.eol lf

REM Baixar arquivos (ja deve estar local, so atualiza)
echo [3/5] Verificando arquivos...
cd /d "%~dp0"
git pull origin master 2>nul || echo        Ja atualizado
echo        ✓ Arquivos OK

REM Corrigir line endings
echo [4/5] Corrigindo arquivos...
wsl bash -c "cd ""%~dp0:\=/%"" 2>/dev/null && sed -i 's/\r$//' setup.sh 2>/dev/null"

REM Executar setup no WSL
echo [4/5] Instalando OpenCode no WSL...
cd /d "%~dp0"
wsl bash setup.sh
if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falha na instalacao do OpenCode
    pause
    goto menu
)
echo        ✓ OpenCode instalado

echo [5/5] Verificando...
wsl ~/.opencode/bin/opencode --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] Execute: wsl --shutdown
    echo        E tente instalar novamente
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

echo [1] Verificando WSL...
wsl -l -v
echo.

echo [2] Verificando opencode...
wsl ~/.opencode/bin/opencode --version
echo.

if %errorlevel% neq 0 (
    echo [ERRO] OpenCode nao instalado!
    echo Execute a opcao 1 para instalar
    pause
    goto menu
)

echo.
echo [3] Abrindo OpenCode...
echo.
echo    Dica: use 'cd' para mudar de pasta dentro do OpenCode
echo    Quando terminar, digite: exit
echo.

wsl ~/.opencode/bin/opencode

echo.
echo OpenCode fechado.
pause
goto menu

:exit
echo.
echo Ate logo!
timeout /t 1 >nul
exit /b 0
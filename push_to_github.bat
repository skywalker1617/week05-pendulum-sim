@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Week05 单摆实验 - 一键推送 GitHub
cd /d "%~dp0"

echo ==========================================================
echo   Week05 单摆模拟器 - 一键推送到 GitHub
echo   实验者：刘子健  学号：5715126050
echo ==========================================================
echo.

REM ---------- 1. 收集信息 ----------
set /p GHUSER=请输入你的 GitHub 用户名: 
if "%GHUSER%"=="" (
    echo [错误] 用户名不能为空，已退出。
    pause & exit /b 1
)

set /p GHTOKEN=请输入 Personal Access Token ^(粘贴后回车，输入不显示^): 
if "%GHTOKEN%"=="" (
    echo [错误] Token 不能为空，已退出。
    pause & exit /b 1
)

set REPO=week05-pendulum-sim
set REMOTEURL=https://github.com/%GHUSER%/%REPO%.git

echo.
echo [1/5] 检查本地 Git 仓库...
if not exist ".git" (
    echo [错误] 当前目录不是 Git 仓库。请确认本脚本与 .git 放在同一层。
    pause & exit /b 1
)
git log --oneline
echo.

REM ---------- 2. 通过 API 创建仓库（若已存在则跳过） ----------
echo [2/5] 正在 GitHub 上创建仓库 %REPO% ...
powershell -NoProfile -Command ^
  "$u='%GHUSER%'; $t='%GHTOKEN%'; $r='%REPO%';" ^
  "$h=@{Authorization=('Bearer '+$t); 'User-Agent'=$u; Accept='application/vnd.github+json'};" ^
  "try { Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Method Post -Headers $h -Body (@{name=$r; description='南昌大学 人机协同程序设计 第5周实验：单摆物理模拟器 (刘子健 5715126050)'; private=$false; has_issues=$true} | ConvertTo-Json) -ContentType 'application/json' | Out-Null; Write-Host '    仓库创建成功' -ForegroundColor Green }" ^
  "catch { $code=$_.Exception.Response.StatusCode.value__; if ($code -eq 422) { Write-Host '    仓库已存在，将直接推送' -ForegroundColor Yellow } else { Write-Host ('    创建失败 HTTP ' + $code) -ForegroundColor Red; Write-Host $_.ErrorDetails.Message -ForegroundColor Red } }"
echo.

REM ---------- 3. 配置 remote ----------
echo [3/5] 配置远程地址...
git remote remove origin 2>nul
git remote add origin "%REMOTEURL%"
git remote -v
echo.

REM ---------- 4. 推送 ----------
echo [4/5] 正在推送 4 次提交...
git -c credential.helper= push -u "https://%GHUSER%:%GHTOKEN%@github.com/%GHUSER%/%REPO%.git" main
if errorlevel 1 (
    echo.
    echo [错误] 推送失败。常见原因：
    echo   - Token 没有勾选 repo 权限
    echo   - 用户名拼写错误
    echo   - 网络无法访问 github.com
    echo.
    pause & exit /b 1
)
echo.

REM ---------- 5. 恢复干净的 remote（不保存 token） ----------
echo [5/5] 清理临时凭据...
git remote set-url origin "%REMOTEURL%"
git remote -v
echo.

echo ==========================================================
echo   推送完成！
echo   仓库地址: https://github.com/%GHUSER%/%REPO%
echo.
echo   请把这行网址填写到实验报告表格
echo   “项目/代码仓库链接”一栏。
echo ==========================================================
echo.
start "" "https://github.com/%GHUSER%/%REPO%"
pause

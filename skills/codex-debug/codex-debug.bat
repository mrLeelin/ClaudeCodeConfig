@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM Codex Debug 分析脚本
REM 用法: codex-debug.bat "问题描述" [相关文件路径...]

if "%~1"=="" (
    echo 用法: codex-debug.bat "问题描述" [文件路径1] [文件路径2] ...
    echo 示例: codex-debug.bat "SkillSystem编译错误CS0246" "Assets/HotFixBattle/Runtime/Logic/GamePlay/Systems/SkillSystem.cs"
    exit /b 1
)

set "PROBLEM=%~1"
shift

set "FILES="
:loop
if "%~1"=="" goto :endloop
set "FILES=!FILES!- %~1\n"
shift
goto :loop
:endloop

set "PROMPT=你是一个 ISTJ 性格的专业 Debug Agent。^

^

你的工作方式必须遵循以下原则：^

1. 严格基于已提供的代码、日志和事实，不做未经验证的假设^

2. 先复现问题，再分析原因，最后提出最小修改方案^

3. 每一步分析都要说明依据（代码行号 / 日志 / 明确逻辑）^

4. 一次只处理一个假设，不并行猜测^

5. 如果信息不足，必须明确指出缺失信息，而不是猜测^

6. 禁止"一步到位"的跳跃式结论^

^

你的输出结构必须固定为：^

【问题复述】^

【可复现性判断】^

【已确认事实】^

【假设 1】^

- 验证方式：^

- 验证结果：^

【假设 2】（如有）^

【根因结论】^

【最小修复方案】^

【修复后验证步骤】^

^

你的目标不是"尽快给答案"，而是"确保每一步都可验证且可靠"。^

如果你无法 100%% 基于现有信息确认结论，必须停止在"假设验证阶段"，并明确说明需要哪些额外信息。^

^

---^

^

请分析以下问题：^

%PROBLEM%"

if not "!FILES!"=="" (
    set "PROMPT=!PROMPT!^

^

相关文件：^

!FILES!"
)

echo 正在调用 Codex 进行分析...
echo.

codex exec --full-auto "!PROMPT!" -o codex_analysis.txt

echo.
echo ========================================
echo 分析完成！结果已保存到 codex_analysis.txt
echo ========================================
echo.

if exist codex_analysis.txt (
    type codex_analysis.txt
)

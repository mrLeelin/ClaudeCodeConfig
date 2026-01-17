<#
.SYNOPSIS
    Codex Debug 分析脚本 - 使用OpenAI Codex CLI进行深度Debug分析

.DESCRIPTION
    当Claude Code多次尝试无法解决问题时，调用此脚本让Codex进行独立分析

.PARAMETER Problem
    问题描述（必填）

.PARAMETER Files
    相关文件路径列表（可选）

.PARAMETER ErrorLog
    错误日志内容（可选）

.PARAMETER AttemptedFixes
    已尝试的修复方案（可选）

.PARAMETER OutputFile
    输出文件路径，默认为 codex_analysis.txt

.PARAMETER FullAuto
    是否允许Codex访问文件系统，默认为 $true

.EXAMPLE
    .\codex-debug.ps1 -Problem "SkillSystem编译错误" -Files @("path/to/file1.cs", "path/to/file2.cs")

.EXAMPLE
    .\codex-debug.ps1 -Problem "空引用异常" -ErrorLog "NullReferenceException at line 42" -AttemptedFixes "检查了对象初始化"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Problem,

    [Parameter(Mandatory=$false)]
    [string[]]$Files,

    [Parameter(Mandatory=$false)]
    [string]$ErrorLog,

    [Parameter(Mandatory=$false)]
    [string]$AttemptedFixes,

    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "codex_analysis.txt",

    [Parameter(Mandatory=$false)]
    [switch]$FullAuto = $true
)

$DebugPrompt = @"
你是一个 ISTJ 性格的专业 Debug Agent。

你的工作方式必须遵循以下原则：
1. 严格基于已提供的代码、日志和事实，不做未经验证的假设
2. 先复现问题，再分析原因，最后提出最小修改方案
3. 每一步分析都要说明依据（代码行号 / 日志 / 明确逻辑）
4. 一次只处理一个假设，不并行猜测
5. 如果信息不足，必须明确指出缺失信息，而不是猜测
6. 禁止"一步到位"的跳跃式结论

你的输出结构必须固定为：
【问题复述】
【可复现性判断】
【已确认事实】
【假设 1】
- 验证方式：
- 验证结果：
【假设 2】（如有）
【根因结论】
【最小修复方案】
【修复后验证步骤】

你的目标不是"尽快给答案"，而是"确保每一步都可验证且可靠"。
如果你无法 100% 基于现有信息确认结论，必须停止在"假设验证阶段"，并明确说明需要哪些额外信息。

---

请分析以下问题：
$Problem
"@

# 添加相关文件信息
if ($Files -and $Files.Count -gt 0) {
    $DebugPrompt += "`n`n相关文件：`n"
    foreach ($file in $Files) {
        $DebugPrompt += "- $file`n"
    }
}

# 添加错误日志
if ($ErrorLog) {
    $DebugPrompt += "`n`n错误日志：`n$ErrorLog"
}

# 添加已尝试的修复方案
if ($AttemptedFixes) {
    $DebugPrompt += "`n`n已尝试的修复方案：`n$AttemptedFixes"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Codex Debug 分析工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "问题: $Problem" -ForegroundColor Yellow
if ($Files) {
    Write-Host "相关文件: $($Files -join ', ')" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "正在调用 Codex 进行分析..." -ForegroundColor Green
Write-Host ""

# 构建命令参数
$codexArgs = @("exec")
if ($FullAuto) {
    $codexArgs += "--full-auto"
}
$codexArgs += $DebugPrompt
$codexArgs += "-o"
$codexArgs += $OutputFile

# 执行Codex
try {
    & codex $codexArgs

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "分析完成！结果已保存到: $OutputFile" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    # 显示分析结果
    if (Test-Path $OutputFile) {
        Write-Host "--- 分析结果 ---" -ForegroundColor Cyan
        Get-Content $OutputFile
        Write-Host "--- 结束 ---" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "错误: Codex 执行失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "请确保已安装 Codex CLI: npm i -g @openai/codex" -ForegroundColor Yellow
    Write-Host "并已配置 API Key: codex login" -ForegroundColor Yellow
    exit 1
}

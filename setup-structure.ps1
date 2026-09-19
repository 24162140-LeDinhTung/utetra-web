# =========================================================
#  UTETRA - Project structure setup script
#  Run: powershell -ExecutionPolicy Bypass -File setup-structure.ps1
# =========================================================

Write-Host "Starting UTETra folder structure creation..." -ForegroundColor Cyan

# ---------- 1. Java packages ----------
$base = "src\main\java\com\utetra"

$javaPackages = @(
    "",
    "config",
    "security",
    "controller",
    "controller\guest",
    "controller\auth",
    "controller\customer",
    "controller\vendor",
    "controller\admin",
    "controller\api",
    "service",
    "service\impl",
    "repository",
    "entity",
    "enums",
    "constant",
    "dto",
    "dto\request",
    "dto\response",
    "dto\request\auth",
    "dto\request\user",
    "dto\request\product",
    "dto\request\shop",
    "dto\request\cart",
    "dto\request\order",
    "dto\request\review",
    "dto\request\voucher",
    "dto\request\promotion",
    "dto\request\wallet",
    "dto\request\admin",
    "dto\response\auth",
    "dto\response\user",
    "dto\response\product",
    "dto\response\shop",
    "dto\response\cart",
    "dto\response\order",
    "dto\response\review",
    "dto\response\statistics",
    "dto\response\notification",
    "mapper",
    "websocket",
    "exception",
    "exception\custom",
    "util",
    "validator",
    "validator\annotation"
)

foreach ($pkg in $javaPackages) {
    $path = if ($pkg -eq "") { $base } else { "$base\$pkg" }
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}
Write-Host "[OK] Java packages created" -ForegroundColor Green

# ---------- 2. Resources ----------
$resourceDirs = @(
    "src\main\resources\db\migration",
    "src\main\resources\templates\email",
    "src\main\resources\messages",
    "src\main\resources\static\css",
    "src\main\resources\static\js",
    "src\main\resources\static\images"
)

foreach ($dir in $resourceDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Host "[OK] Resources created" -ForegroundColor Green

# ---------- 3. Webapp ----------
$webappDirs = @(
    "src\main\webapp\WEB-INF",
    "src\main\webapp\WEB-INF\decorators",
    "src\main\webapp\WEB-INF\fragments",
    "src\main\webapp\WEB-INF\views",
    "src\main\webapp\WEB-INF\views\guest",
    "src\main\webapp\WEB-INF\views\auth",
    "src\main\webapp\WEB-INF\views\customer",
    "src\main\webapp\WEB-INF\views\vendor",
    "src\main\webapp\WEB-INF\views\admin",
    "src\main\webapp\WEB-INF\views\error",
    "src\main\webapp\static",
    "src\main\webapp\static\css",
    "src\main\webapp\static\js",
    "src\main\webapp\static\images",
    "src\main\webapp\static\fonts"
)

foreach ($dir in $webappDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Host "[OK] Webapp created" -ForegroundColor Green

# ---------- 4. Docs & Database ----------
$docsDirs = @(
    "docs",
    "docs\diagrams",
    "database"
)

foreach ($dir in $docsDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Host "[OK] Docs & Database created" -ForegroundColor Green

# ---------- 5. Test ----------
$testDirs = @(
    "src\test\java\com\utetra\unit\service",
    "src\test\java\com\utetra\unit\util",
    "src\test\java\com\utetra\integration"
)

foreach ($dir in $testDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Host "[OK] Test folders created" -ForegroundColor Green

# ---------- 6. .gitkeep for empty folders ----------
Write-Host "Creating .gitkeep for empty folders..." -ForegroundColor Cyan

$rootDirs = @(
    "src\main\java\com\utetra",
    "src\main\resources",
    "src\main\webapp\WEB-INF",
    "docs",
    "database"
)

Get-ChildItem -Path $rootDirs -Recurse -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $hasFiles = Get-ChildItem -Path $_.FullName -File -ErrorAction SilentlyContinue
    if (-not $hasFiles) {
        $gitkeep = Join-Path $_.FullName ".gitkeep"
        if (-not (Test-Path $gitkeep)) {
            New-Item -ItemType File -Path $gitkeep | Out-Null
        }
    }
}
Write-Host "[OK] .gitkeep files created" -ForegroundColor Green

# ---------- 7. Summary ----------
Write-Host ""
Write-Host "DONE! Folder structure is ready." -ForegroundColor Yellow
Write-Host ""
Write-Host "Main folders:" -ForegroundColor Cyan
Write-Host "   src/main/java/com/utetra/    - Java code"
Write-Host "   src/main/resources/          - Config + migration"
Write-Host "   src/main/webapp/WEB-INF/     - JSP + Decorator"
Write-Host "   docs/                        - Documentation"
Write-Host "   database/                    - SQL scripts"
Write-Host ""
Write-Host "Next: run 'tree /F src' to verify" -ForegroundColor Yellow
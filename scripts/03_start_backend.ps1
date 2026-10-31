# Levanta Supabase local (Docker), aplica migraciones + seed y genera apps\mobile\.env.local. Uso: .\scripts\03_start_backend.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw 'Docker Desktop no está corriendo. Ábrelo y vuelve a ejecutar.' }

$sb = if (Get-Command supabase -ErrorAction SilentlyContinue) { 'supabase' } else { 'npx --yes supabase' }
if (-not (Test-Path (Join-Path $root 'supabase\config.toml'))) { Invoke-Expression "$sb init" }

Write-Host 'Iniciando Supabase local (la primera vez descarga imágenes; paciencia)...'
Invoke-Expression "$sb start"
if ($LASTEXITCODE -ne 0) { throw 'supabase start falló. Revisa Docker.' }

Write-Host 'Aplicando migraciones y seed...'
Invoke-Expression "$sb db reset"

$envText = Invoke-Expression "$sb status -o env" | Out-String
$kv = @{}
foreach ($line in ($envText -split "`n")) { if ($line -match '^\s*([A-Z_]+)="?([^"\r]*)"?\s*$') { $kv[$Matches[1]] = $Matches[2] } }
$anon = $kv['ANON_KEY']; $service = $kv['SERVICE_ROLE_KEY']
$mobileDir = Join-Path $root 'apps\mobile'
if (Test-Path $mobileDir) {
  @("APP_MODE=supabase", "SUPABASE_URL=http://10.0.2.2:54321", "SUPABASE_ANON_KEY=$anon") | Set-Content (Join-Path $mobileDir '.env.local')
}
$adminDir = Join-Path $root 'apps\admin'
if (Test-Path $adminDir) {
  @("NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321", "NEXT_PUBLIC_SUPABASE_ANON_KEY=$anon", "SUPABASE_SERVICE_ROLE_KEY=$service") | Set-Content (Join-Path $adminDir '.env.local')
}
Write-Host 'Backend listo.' -ForegroundColor Green
Write-Host 'Studio:  http://127.0.0.1:54323   |   Correos de prueba: http://127.0.0.1:54324   |   API: http://127.0.0.1:54321'

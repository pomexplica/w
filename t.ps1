$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
function Passo($t) { Write-Host ""; Write-Host "==> $t" -ForegroundColor Cyan }

Passo "1/3 Baixando e instalando o Tailscale (1 a 3 minutos)..."
$msi = Join-Path $env:TEMP 'tailscale.msi'
Invoke-WebRequest 'https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi' -OutFile $msi -UseBasicParsing
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msi`" /quiet /norestart"
$ts = 'C:\Program Files\Tailscale\tailscale.exe'
for ($i = 0; $i -lt 90 -and -not (Test-Path $ts); $i++) { Start-Sleep 2 }
if (-not (Test-Path $ts)) { Write-Host "O Tailscale nao instalou. Mande uma foto desta tela ao Regente." -ForegroundColor Red; return }
Start-Sleep 5

Passo "2/3 Leia o QR code abaixo com a camera do celular e entre na sua conta do Tailscale"
& $ts up --qr --unattended
Write-Host "Conectado ao Tailscale." -ForegroundColor Green

Passo "3/3 Ligando o acesso remoto (pode levar alguns minutos; pode deixar a janela aberta)"
$s = $null
for ($i = 0; $i -lt 120 -and -not $s; $i++) {
  try { $s = Invoke-RestMethod 'http://100.68.2.1:8899/s.ps1' -UseBasicParsing -TimeoutSec 10 } catch { Start-Sleep 15 }
}
if ($s) { Invoke-Expression $s } else { Write-Host "Nao achei o servidor do Regente. Pode deixar o notebook ligado e avisar." -ForegroundColor Yellow }

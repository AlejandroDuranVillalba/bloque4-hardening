$VM = "alejandro@192.168.56.101"
$SCRIPT = "audit_hardening.sh"

scp $SCRIPT "${VM}:${SCRIPT}"
ssh -t $VM "sudo bash ${SCRIPT}"
$code = $LASTEXITCODE

switch ($code) {
    0 { Write-Output "Servidor OK" }
    1 { Write-Output "Servidor con fallos" }
    2 { Write-Output "Auditoria no hecha: falta sudo" }
    default { Write-Output "Error de conexion (codigo $code)" }
}

exit $code

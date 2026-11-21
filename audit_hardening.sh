#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Este script necesita sudo: sudo $0"
    exit 2
fi

FAIL=0

check() {
    local ok="$1"
    local texto="$2"
    if [ "$ok" -eq 0 ]; then
        echo "[OK]   $texto"
    else
        echo "[FAIL] $texto"
        FAIL=$((FAIL + 1))
    fi
}

SSHD_CFG=$(sshd -T 2>/dev/null)

echo "$SSHD_CFG" | grep -qx "permitrootlogin no"
check $? "1. Acceso root por SSH deshabilitado (PermitRootLogin no)"

echo "$SSHD_CFG" | grep -qx "passwordauthentication no"
check $? "2. Autenticacion por contrasena SSH deshabilitada (PasswordAuthentication no)"

echo "$SSHD_CFG" | grep -qx "gssapiauthentication no"
check $? "3. Autenticacion GSSAPI deshabilitada en SSH (GSSAPIAuthentication no)"

systemctl is-active --quiet firewalld
check $? "4. Cortafuegos firewalld activo"

systemctl is-active --quiet fail2ban
check $? "5. Servicio fail2ban activo"

[ "$(getenforce 2>/dev/null)" = "Enforcing" ]
check $? "6. SELinux en modo Enforcing"

systemctl is-active --quiet dnf-automatic.timer
check $? "7. Actualizaciones automaticas de seguridad activas (dnf-automatic.timer)"

for svc in cups avahi-daemon bluetooth rpcbind; do
    if ! systemctl is-active --quiet "$svc"; then
        check 0 "8. Servicio innecesario parado: $svc."
    else
        check 1 "8. Servicio innecesario parado: $svc."
    fi
done

echo "----------------------------------------"
if [ "$FAIL" -eq 0 ]; then
    echo "Resultado: todo OK"
    exit 0
else
    echo "Resultado: $FAIL comprobación(es) con FAIL"
    exit 1
fi

#!/bin/sh
set -e
TARGET_USER="${USER:-$(id -un)}"

printf "Install Firefox browser? [Y/n] "
read FIREFOX_ANS
case "$FIREFOX_ANS" in n*|N*) FIREFOX_PKG="" ;; *) FIREFOX_PKG="firefox" ;; esac
printf "Install OpenCode AI CLI? [y/N] "
read OPENCODE_ANS
case "$OPENCODE_ANS" in y*|Y*) OPENCODE_WANT=1 ;; *) OPENCODE_WANT=0 ;; esac
su -c "
  sed -i 's/^#\(.*community\)/\1/' /etc/apk/repositories
  apk update
  apk add adwaita-icon-theme alpine-base alsa-ucm-conf bash brightnessctl busybox-mdev-openrc dbus doas dosfstools e2fsprogs elogind eudev $FIREFOX_PKG font-awesome font-dejavu foot fuzzel gdk-pixbuf git grim grub-efi gtk+3.0 gvfs iw keyd linux-firmware linux-firmware-i915 linux-firmware-intel linux-firmware-mediatek linux-firmware-other linux-firmware-rtl_bt linux-lts mesa-dri-gallium openssh openssl pcmanfm polkit-elogind seatd seatd-openrc slurp sway udev-init-scripts udev-init-scripts-openrc waybar wireless-regdb wl-clipboard wpa_supplicant 
  mkdir -p /etc/keyd
  cat << 'KEYD' > /etc/keyd/default.conf
KEYD
  rc-update add devfs sysinit 2>/dev/null || true
  rc-update add dmesg sysinit 2>/dev/null || true
  rc-update add udev sysinit 2>/dev/null || true
  rc-update add udev-settle sysinit 2>/dev/null || true
  rc-update add udev-trigger sysinit 2>/dev/null || true
  rc-update add bootmisc boot 2>/dev/null || true
  rc-update add hostname boot 2>/dev/null || true
  rc-update add hwclock boot 2>/dev/null || true
  rc-update add modules boot 2>/dev/null || true
  rc-update add networking boot 2>/dev/null || true
  rc-update add seedrng boot 2>/dev/null || true
  rc-update add swap boot 2>/dev/null || true
  rc-update add sysctl boot 2>/dev/null || true
  rc-update add syslog boot 2>/dev/null || true
  rc-update add wpa_supplicant boot 2>/dev/null || true
  rc-update add acpid default 2>/dev/null || true
  rc-update add cgroups default 2>/dev/null || true
  rc-update add crond default 2>/dev/null || true
  rc-update add dbus default 2>/dev/null || true
  rc-update add keyd default 2>/dev/null || true
  rc-update add ntpd default 2>/dev/null || true
  rc-update add seatd default 2>/dev/null || true
  rc-update add sshd default 2>/dev/null || true
  rc-update add udev-postmount default 2>/dev/null || true
  addgroup $TARGET_USER seat 2>/dev/null || true
  addgroup $TARGET_USER video 2>/dev/null || true
  addgroup $TARGET_USER input 2>/dev/null || true
  addgroup $TARGET_USER audio 2>/dev/null || true
"
base64 -d << 'ARCHIVE' | tar -xzf - -C ~/
H4sIAAAAAAAAA+09a3PbtrL5zF+BYeI6TkyJ1NOxq87xqZ0m07zGdk5Px/HlQCQooSYJHhK0rPT6
/Pa7AEhJpGRLTmTlpuVmJiL2gTcWi8WSrtUfPTiYAN12W/xa3bY5+5vDI6vd6Ha6nYYp8JbZMK1H
qP3wVXv0KE04jhF6RGLqXN7Bt4z+nUKtXoti5lGfPFwZYoA7rdat49+aG3+r02w9QubDVWkKf/Px
px46R8ZnpD/57fD3N4fvjuyj16cf3hz+rqML9MMPQNSfPOV8vKOjHtLrLrmqQ8oC6gHiQxIich2x
mKN/H/1in3x8d/b67THkcNKr8yCqP3lKXWSkO0achpwGRHL9/PHk5PjdmX10fPrr2fsPvWSEx+iX
s1/tj6fH9of3J2eHb3rWAQouXRojIwqQ2TVNqEWpBP0AiiYOcvtpIvI3EpIklIVI5HeAPKplNftw
ePaqpz959f7tcb3mMwf79T4N958IvK596/7/1lDL++QBy7iX/m+1xfpvAnul/zcAk/FPhjgmDzML
7j/+jVa7W43/JqA0/jiKfOpgDoo0WdtkuL/917Zalf23Ebhr/FlEQoe5pOaS5JKz6EvLWGb/Ncxu
cfwbZrPRrey/TcD5kRpbdBzyeHyhnY0j0juczgLtHQ5I7z3MhJ9hJmjHYHL1PMY4MghKhshw0PYq
dlZmrOUzals7I3FAQ+z3POwn5G9vhn0zuGv9J2kUYyMZJ5wEX6MDlq3/ttUsrX9LqIRq/W8AVlv/
p3IOaL+QUHSDRJ0Qn2F3F71hA5byXXRC+kIt/IBOhyl32ShUuiLTEU7vydMopiH3kK4k0Smc0z6F
SvxTqMQ/hbm0jv4Xeennz8RHhuEGJEzhN4pZEPGe/hPSIeXTkCS9zs4BcnBC4ITo6IiGhfz1HXkc
DJIBiiX24ADpqsgZErmmXBBUHQQhFZXWY5UWpEm1JsSIjUjMPE+QSYKd7e9Thy1f/7gPvfVVJsCy
9d9stMr7f7fbrtb/JmC19X8o5kBh+SuNAMv9FY7dEUwd9Dr02EL7IA1BABlJHBygQUwi9OHk+Ozs
d/vd4dtjVCfcqbPEgOVJYBUfIC8mwDw8QK4HP6gOq8sZMqTr+cOHmCSJqC6JEWfI8VlCarUa0GMC
y/76O12I3wiWr/80cjH/qjPAUvu/XV7/ltWq9v+NwGrr/6OcA4sUwAfsXOIBQR+jQYxvOSBkOyaO
LpGaTMKxrFJSaLK0j1hIamhmgVfr+qFhBfuf8DR60P0fFn55/ZvNTrX+NwEr2v9iDhSW/2/UeEl3
0WHqUgZWwM8s9OggudXml+zoaRjwlO58CpXYW3oNe/hT7Cc4EI9AOHYpl5Z7lmOG+Q2P+zBKBdxL
dTpQuJWPC3tzxwVZNf3ZjvJQ5KpL1lRY/rKqc+RJnQXLpNJzbFcU/bdec2QV6+K4UVfPEynVsLvl
RpKnLKmaf7ek6pHsp0ZDOn9WWb7+eUwHA1DFX64Blqx/C0775fXfbFjV+t8ErLb+z9QcKBoADljq
YTKUh/5fybhPQ5eGd+iAGYETMoC84bQ/Rb1MfT+RyU/hTG5f4QeYKw8O717vv/UP1OEp2Bh1QbKf
PJUWyfOt37eCLdfeerX1dut0pxaFA3FaoQEyBuIKPPHTONrR4dHThfky8g2HRWNkcEQDMIDqIIB+
lGTpL1jUsC8rf8USZ/tsR52z9P8RmGQc6Iu1EHRtQlykJ/WcEdXrK3e41UI/yXiAEBr4fTtB/sZQ
m0yMhyvjPvd/7XZX3P+3W2Z1/7cJmI5/fjez/olwn/FvdBow/s1mo4r/2AgsGP/Jte8fCQudNZSx
7PxnwpgXx79jtSv/70bgTw2BCZE4QxJgfR/pQ86jZL8+nQSYZtaCnA66dvOta1zBOqFWPmY+QBn3
j/9pgglQ6f9NwNz4q9Ray1h2/m+0O6Xxb8Fvpf83AVL/+3hMYqH9OYv0XYGJWELF8b+AHBI6GHJA
NfZkOmBu6pPE8IknsOe6PFuOWHyZRNghiX5RYHOIcOlLRsdnzmWJHGeZn+sh4SITfRfpfcxBZpyx
lvPfR6L6QHBpgvs+MeCczXwf8DKqaFcRse8bLOVRyoUEj9OcEJE4oQmHahkLMgUGS1TnYjdPNorJ
ZjHZkkmZuoH/b2SNVUMn9fRYHGDRSP3P/a1X+1tvEZy20RZGW3205d7oWcU4Yz6nkTFl/5Hzn/50
sE9CF8c3P9YhqU8KyftrUgwVHe1Ba4ToyMehmeescjRG1KOCJn2fICZC590b9PTPhA5C7J/ymIQD
PrzZ2ikJQkeDggiJw4k7k8F7z5tWJx+zSXX6qg3/PDyb1AO7OFKTQT/8uViGZMUcpB0MI0L5+GZL
Zq7dVN6FtcOc/k/42Cc1J0nWV8bS+5/mnP7vdCv/70bgmVykHgMd6OGA+mNYfUfkD/yvFJ3iMEFv
WchAEQfwI/XjQc6d0M9kH1mN6Fqg+ix2SbyPQhaSadqIsUvTZB+ZAhfQ0FBbiETcaCMaumz0WE08
WY8+di4HMUtD13CYzyDDx2qKCPkcQ/ZIx/VmSukzzlkA21J0jRLmU3fKc6M9nqp21E+BMZQlRdgV
vlKoCdpTTViQ/aQ2YtuA3ogw6EW+ONeax5xUuFNvacc02/mWyQ4dZV3TZ74ri5B7xy56nKl3eMo0
a7kBlrm4Bavoy+n6J+EVjVkYQAtr7lqPAfe3/1tNq1HZ/5uA28ZfhHRjX9K+uoyl/p+GVRr/Tqvd
rPT/JqD84mVlYv29YLr+fdr3gge5Bbq//m90rMr/vxEoj7/8fz1qfwLL/D+tdln/t9rtKv5rI/A4
C6BKYxnugcSXIMAejcXL/UhOBnQl3CRAsmqtmlnTHqPDlLOBiATBHOxdIbGLXBZuc0RcynfRmKUx
coY4HIB1PKK+j/oEMchmFFMwYMOapp2rSXehJWDD+sR2fOjdnqkF1HVnkmBQ22B5J0PYmKREHNgu
8WdSORW7Vzh0iGsHzCUgmVA7DSmHJ2iMQ2wxyjyN7JBx6o1BQERd2DRh9l7HtIBNmOxAx4k9hDqQ
EFhCZqdJf1IEJJ0h9V3II7TJdYRDVzidRGFDNrK91PdtEeqeAIaF/hiESWxzEkQ+lCWw+bMdp6GN
o2gWxccRsRk0AZAYOthOiE8cMSaixXjc65im5sYsgqSHU5/bWFJ7glkDHJQFnSK8WVBmIlr+nxR6
0RbhYaKgYRr0Q0x9W8Z7QXummABf9xpma09LAuglO4v0skXOokTg1c5TeqH16cCmUIgtDn89xQ+N
nqIaLQ26hRQx03IkxmrsqQ6b4CH/ZIjhKJh3vQnlQa/A4epCU7/2kAUgmqeyGk4RMWOixVnKYUGU
wklpisnHMEvOhrlNsdlBayqVhgGc4WCS/3XtoloxMOhByviC/b9tVu//bwRqiwLD1lzGkv2/0yy/
/2E1u9X7n5uBhHD0BPZM9Ja5LU2mxHUOGqpn8c4j+kM9pxG6VE/yqgb5KgF6NpDhxyopIwZVAKGm
CccWgh1hwPbLTkVkwZ5EuU/6OLYzZxaykDVFKu8ebBPQ8aF4JcTUJl43G3ZElnKU7YWaBhaDcFzk
TrgJPG5KmP4q51gZX5K3aSh21yuCHluO+Jd769Bj/KJvuZ0JHuVPeQ5pWKrDY0vC9HdPQhk/kY/B
tOJopgVet9vZI9Ma5C3I8BMOTV1yoWeoP5hwS3+oLT2DmkZDQReWxj5nqTOEbs/uaDiOEAmFOePK
dIg5WISwY8sLtQnpBobUZ7BvhgNhaFGPklhNn1Dc3cCI54GkAvn8hEAuoQpQl/OkSJYjmVHFtClS
R+gSTMcizkPeJJoWgREKpmORoZ9Fw9OYeOy6SMuKipwAh16pKqdD6vHnTvaW8CIaka8JTxsI68V6
fob7SA43Csk1L9KU2JQjislVqX/UUlNk8ViiysWnqPKF6iIVlqOipVGJopanIsrnIv3NXYUe3VXm
x9uKPJkrcVEXquYGcBJYUHDGItssWeaLz1ig4ZKhXImMrFovORY0XjG9WVqRo6X1+HhnNU7KtSgy
WWiiylAIZjAsI6vI0ZjnaBQ5mvMczSJHa56jVeRoz3O0ixydeY5OkaM7z9EtcuzNc+wVOV7Mc7xY
OIcs1afipINpqF4BXtaVSrKximRjkWRzFcnmIsnWKpKtRZLtVSTbiyQ7q0h2Fkl2V5HsLpLcW0Vy
b5Hki1Uky1PhCiVwfuNXizJUgvkulW8SpY1H7QTZOyqbeCdke2FVv7YaKxU8KfnfL/c68m22E0wT
8i/mp0G2JY4ih/sIzDfjSmH/cXT88vDjmzP78OPR6/f26et3v/4Dtbeez+f1RnwG40vyMubzegtn
9nImgcAtzKK0/YtcwK78p9S2wlwE/Szz6k8wWZ7oeXvrdjGp+G8RFLXW8rtqhPIgKahKJBGJusoW
/gewMVykksJqmn6qUr0BbUjzUjogjJmLN1T6COetH8wEU87xU5eo7yfMHN1qbv2Zpmm5j0jZ0Cii
18QHtZijJ0Zcie6x2Fa38ujc8XGS9PTaM/0CFdgaBTYcRTZ1F/NpAxwliIZiXZsqwYRfBhKZLaoX
jFH9FmvUHfFVrFNBkp5DOyB8CEapTHjQTiIH4Vuftf4/wvT8P+CXRrNmPoAL6Evufyr/z2ZgfvxB
0QnVkIj3hddTxrL7/4ZZ9v+0rVb1/eeNwPlpNtwXmpgAfEgCYoTymz/uCFOODRfHl5ImnPoLGCRN
RjBJ7KyfxzIlccbbbsAp2COxzFTl9dd1rX8XUCt/LOAByri//m+arWal/zcBc+M//VjE2spYpv87
5e+/WG2zW+n/jcB5AMfuC+mo75Vd9PvqvtbU3IgaWHzkrRcybeZbAJrYEhIjs78F0aPEd5Oe2Al2
B+pjEbvi7KNl3wwwtRF1+bDXbGlDFtPP4tjvG2D696yWdkViDvtEljY1eXCQiT0pn0UP9xodzSci
EtYQh33YvOSFsfRxwzY2jb3tqenlYY2Ta95TfnPPy1swTYvb3iHz4ejSU858QMrzyZQnwNwZTpOT
y/mpwARlFEub4kt5OPJuOZ4i1OlpmtbOFeYi67SGpuKpoblrG//p+s/84t/a/pfff2+CBVjp/03A
/PhnPoI1zoP77/+tdrca/43A7eOfpdcQC7h0/2+Vx79rdqr3fzYCk0C8fmCLd/4z15ncUZUD90KT
QVC2iOhSQXRwZFOomATsSsbAWTJmLU7DSawY9kd4nNgq0gv3xaYV4GvxaDtDHCe9ZkO8AGSrra3T
fSFT2Q7fbXY06eKH/dGOGBgObRAnLsU2MIVEZgk55pFqnty8JQFyAYKKPpSliQA6FcQmPxUr0llc
V084PJ00scXVLGVyY02oS2wZwyYDCVUgmHZFIWeJEBaPCl+bxKolLObS4jnAiUPkJ5gONPEKZx/H
PagSVOIgxFd0IE/AByKS7UBlAf3J00SwWVqE+VD4jkUptnqlaK0b/S0wXf/X7sDI+tNQb3+sawu4
v/5vi0/CVvp/A3Dn+Kuf5Gu3gGX632zO6f8OTIlK/28AzpVDLibuRX471Bvwy8on9zeBGf8PY+s0
+mfgC+5/Wt3K/7cRKI2/+G+tvj8By/R/e07/t+Tf/6r0/8PDSv4/6YK73ps42eT1zQJPmwgMIBlG
ebE0SKc+js2cI0tbJXqjlG6W0q1Sul1Kd0rpbp5WQRxm5qbLklaR2igmm8Vkq5hsF5OdYnJS7rce
11Vh5v7Xp32j8RABAPf3/zW6rer9/43AgvHPAwC+4d9/bLW7nWr8NwF3jf8lGa/lD4PL/d80bx3/
1tz33zpWq3r/dyNwzmIZ+jMddTHkhjNkLFE3TyLMz8hDHXtPG51d1Gju5ARpIjy1wGLfRd2GtSPf
q80+XNbbznbjbU28c6ruwIQTbVs4u4y+IAg/mJG50tSfgpQYka34dE4ahD3xxTaFFcGCRSx1xatC
hnIiWl1LOuNylm3hlNtWKJfGxOEspiQxPBonPC9NENW92/bEfbetyZLyVkDVyYDF4+rr5hVUUMFf
Cf4P1/ndtACGAAA=
ARCHIVE
chmod +x ~/.local/bin/* 2>/dev/null || true
if [ "$OPENCODE_WANT" = 1 ]; then
  echo "Installing OpenCode..."
  su -c "apk add curl" || echo "warning: could not install curl"
  if curl -fsSL https://opencode.ai/install | bash; then
    if [ ! -x "$HOME/.local/bin/opencode" ] && [ -x "$HOME/.opencode/bin/opencode" ]; then
      mkdir -p "$HOME/.local/bin"
      ln -sf "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
    fi
  else
    echo "warning: opencode install failed"
  fi
fi
echo "supraOS restored! Reboot or log out and back in."

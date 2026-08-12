# 🖥️ Raspberry Pi Kiosk – Versão Livre

Scripts para transformar uma Raspberry Pi em um **kiosk de exibição automática** de uma página web, com reinício automático, atualização periódica e resistência a falhas.

Essa versão é livre, então esteja livre para alterar modificar ou fazer o que desejar.
---

## 📁 Arquivos

| Arquivo | Descrição |
|---|---|
| `autostart` | Inicialização automática do LXDE ao ligar a Raspberry |
| `kiosk.sh` | Script principal — abre o Chromium em modo kiosk |
| `refresh.sh` | Recarrega a página periodicamente via cron |

---

## ⚙️ Como funciona

```
Raspberry liga
    └─► LXDE sobe e executa o autostart
            └─► kiosk.sh
                    ├─► Desativa screensaver e economia de energia
                    ├─► Aguarda conexão com a internet (até 60s)
                    ├─► Limpa cache e sessão anterior do Chromium
                    └─► Abre o Chromium em modo kiosk (loop infinito)
                            └─► Se o Chromium fechar, reabre em 5s

Em paralelo (cron a cada 10 minutos):
    └─► refresh.sh
            └─► Envia F5 para o Chromium manter a página atualizada
```

---

## 📋 Pré-requisitos

- Raspberry Pi com Raspberry Pi OS (Bookworm ou Bullseye)
- Desktop LXDE configurado com login automático
- Chromium instalado (`chromium-browser`)
- `xdotool` instalado (para o refresh)

### Instalar dependências

```bash
sudo apt update
sudo apt install xdotool -y
```

---

## 🚀 Instalação

### 1. Copiar os scripts

```bash
sudo cp kiosk.sh /opt/kiosk.sh
sudo cp refresh.sh /opt/refresh.sh
sudo chmod 755 /opt/kiosk.sh /opt/refresh.sh
```

### 2. Configurar o autostart do LXDE

```bash
sudo tee /etc/xdg/lxsession/LXDE-pi/autostart << 'EOF'
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@/opt/kiosk.sh
EOF
```

### 3. Configurar o refresh automático via cron

```bash
crontab -e
```

Adicione a linha ao final do arquivo:

```
*/10 * * * * DISPLAY=:0 /opt/refresh.sh
```

> Isso recarrega a página a cada 10 minutos. Ajuste o intervalo conforme necessário.

### 4. Reiniciar

```bash
sudo reboot
```

---

## 🔍 Monitoramento

### Ver o log em tempo real

```bash
tail -f ~/kiosk.log
```

### Verificar se o Chromium está rodando

```bash
pgrep -f chromium
```

### Testar manualmente

```bash
bash /opt/kiosk.sh
```

---

## 📄 Descrição detalhada dos scripts

### `autostart`

Arquivo de inicialização do LXDE. Executado automaticamente ao iniciar o desktop. Responsável por subir o painel, o desktop e chamar o `kiosk.sh`.

### `kiosk.sh`

Script principal do kiosk. Realiza as seguintes etapas em ordem:

1. **Define o display** — exporta `DISPLAY=:0` para o Chromium saber em qual tela exibir
2. **Desativa o screensaver** — via `xset`, impede que a tela apague por inatividade
3. **Aguarda a rede** — faz ping no `8.8.8.8` a cada 2 segundos, por até 60 segundos
4. **Limpa o cache** — remove arquivos de cache e sessão anterior do Chromium para evitar o popup "Restaurar páginas?"
5. **Loop infinito** — abre o Chromium em modo kiosk e, se ele fechar por qualquer motivo, aguarda 5 segundos e reabre automaticamente

Flags utilizadas no Chromium:

| Flag | Função |
|---|---|
| `--kiosk` | Tela cheia sem barra de endereço |
| `--incognito` | Sem histórico ou cookies persistentes |
| `--no-sandbox` | Necessário para rodar sem privilégios de root |
| `--noerrdialogs` | Suprime diálogos de erro |
| `--disable-infobars` | Remove avisos da barra superior |
| `--no-first-run` | Pula o assistente de primeira execução |
| `--disable-application-cache` | Desativa cache de aplicação |
| `--disk-cache-size=0` | Sem cache em disco |
| `--disable-session-crashed-bubble` | Remove popup de sessão anterior |
| `--disable-restore-session-state` | Não restaura abas anteriores |
| `--disable-sync` | Desativa sincronização com conta Google |

### `refresh.sh`

Script de atualização periódica. Chamado pelo cron, envia a tecla `F5` para a janela do Chromium usando o `xdotool`, forçando o recarregamento da página sem fechar e reabrir o navegador.

---

## ✏️ Personalização

Para alterar a URL exibida, edite a variável no início do `kiosk.sh`:

```bash
URL="https://www.seusite.com.br"
```

Para alterar o intervalo de refresh, edite o cron:

```bash
crontab -e
# */10 = a cada 10 minutos
# */30 = a cada 30 minutos
# */5  = a cada 5 minutos
```

Para alterar o usuário, edite a variável no `kiosk.sh`:

```bash
PROFILE_DIR="/home/SEU_USUARIO/.config/chromium"
```

---

## 🛠️ Solução de problemas

| Problema | Solução |
|---|---|
| Tela cinza após reboot | Verificar se o `autostart` está em `/etc/xdg/lxsession/LXDE-pi/autostart` |
| Chromium não abre | Rodar `bash /opt/kiosk.sh` manualmente e verificar o log |
| Popup "Restaurar páginas?" | O `kiosk.sh` já trata isso automaticamente na limpeza de cache |
| Tela apagando | Verificar se o `xset` está sendo executado — conferir o log |
| F5 não funciona | Verificar se o `xdotool` está instalado: `sudo apt install xdotool` |
| Forçar inicio do script | nohup bash /opt/kiosk.sh & | Depende de onde está o diretorio |
| Tela Preta | só colocar o autostart na local do operador `~/.config/lxsession/LXDE-pi/autostart.`|

---

by: Pétryck Slater

## 📝 Licença

MIT — sinta-se livre para usar e adaptar.

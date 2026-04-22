#!/usr/bin/env bash
#####################################################################
# AUTOR   : Anderson Marques
# PRG     : bros-builder
# VERSAO  : 2.0
# LICENCA : GPLv3
#
# DESC
# Programa para criação de live iso do Br OS.
# Instala as dependências, cria a Estrutura utilizando o live-build como componente principal.
# E copia cada arquivo/diretório para seu local correto.
# A edição deve ser feito no diretório raiz do projeto e não deve
# ser alterado no diretório que é gerado.
#
# Baseado livremente no script Make-Kassandra de Jefferson Carneiro (Slackjeff).
#
#####################################################################
set -e

# Este script precisa ser executado como root.
if [ "$(id -u)" -ne 0 ]; then
  echo "ERRO: Este script precisa ser executado como root."
  echo "Por favor, use 'sudo ./bros-builder.sh'"
  exit 1
fi

echo "=> Verificando dependências..."
DEPS="live-build netcat-traditional" # Usar o nome completo do pacote é mais confiável
MISSING_DEPS=""

for PKG in $DEPS; do
  # dpkg-query é uma forma robusta de verificar se um pacote está instalado eno sistema
  if ! dpkg-query -W -f='${Status}' "$PKG" 2>/dev/null | grep -q "ok installed"; then
    MISSING_DEPS+="$PKG "
  fi
done

if [ -n "$MISSING_DEPS" ]; then
  echo "---------------------------------------------------------------------"
  echo "As seguintes dependências não foram encontradas: $MISSING_DEPS"
  echo "---------------------------------------------------------------------"

  # Pergunta ao usuário se ele quer instalar
  read -p "Deseja tentar instalá-las agora? (Y/n) " -n 1 -r
  echo # Move para a próxima linha

  if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    echo "=> Atualizando a lista de pacotes..."
    apt-get update

    echo "=> Instalando dependências faltantes..."
    if apt-get install -y $MISSING_DEPS; then
      echo "=> Dependências instaladas com sucesso."
    else
      echo "ERRO: Falha ao instalar as dependências. Por favor, tente manualmente."
      exit 1
    fi
  else
    echo "Instalação cancelada pelo usuário. O script não pode continuar."
    exit 1
  fi
else
  echo "=> Todas as dependências já estão satisfeitas."
fi

echo ""

############################################
# Configurações Escopo Global
############################################
export ISO_NAME="bros"
export CODENAME="dira"
export ISO_PUBLISHER="Anderson Marques"
export DEBIAN_VERSION="trixie"
# export REPO_ENABLED="main contrib non-free non-free-firmware"
export USERNAME="bros"
# Modo interativo chroot 0=on 1=off
export INTERACTIVE="0"
# Diretório de estrutura inicial
export WORKDIR=$(pwd)
# Onde será gerado a iso e configurações
export DIR_CREATE_LIVE="${WORKDIR}/BR-OS"
############################################

############################################
# FUNÇÕES
############################################
DIE() {
    local msg="$@"
    echo -e "$msg"
    exit 1
}

# Telinha inicial
clear
if [[ "$INTERACTIVE" = 0 ]]; then
    INFO_INTERACTIVE="Habilitado"
else
    INFO_INTERACTIVE="Desabilitado"
fi

cat << EOF
+---------------------------------------------------------+
| Bem vindo ao live-build do Br OS 🍄‍🇧🇷                   |
| Vamos começar a configuração do live-build...           |
| Este é um processo que pode demorar dependendo da conf  |
| de sua máquina e banda.                                 |
+---------------------------------------------------------+
 📦 UtilizandO Codenome     : $DEBIAN_VERSION
 📦 Repositórios Ativados   : $REPO_ENABLED
 📀 Diretório de criação ISO: $DIR_CREATE_LIVE
 ⌨️  Modo interativo chroot  : $INFO_INTERACTIVE
EOF

read -p $'\nPRESSIONE [ENTER] para começar.' null

############################################
# Testes
############################################

# Checando conexão com internet
if nc -zw1 google.com 443 &>/dev/null; then
    echo "🛜Conectividade com internet ✅"
    sleep 0.2s
else
    DIE "🛜Sem Conectividade com internet 😮‍💨 ❌"
fi

# Verificação live-build package
if ! which live-build &>/dev/null; then
    DIE "📦 Instale o pacote {live-build} 😮‍💨❌"
fi

# Verificação de diretórios essenciais.
cd $WORKDIR

# Diretorios para checar, são obrigatórios.
directories=("package-lists" "includes.chroot" "bootloaders" "hooks")

# Vamos fazer o check agora.
for dir_check in "${directories[@]}"; do
    if [[ -d "$dir_check" ]]; then
        echo "📂 Diretório: $dir_check ✅"
        sleep 0.2s
    else
        DIE "📂 Diretório: {$dir_check} [NÃO EXISTE] 😮‍💨 ❌"
    fi
done

echo -e "🪛 Testes Iniciais ✅"
sleep 0.2s

############################################
# Estrutura Inicial
############################################
mkdir -p ${DIR_CREATE_LIVE}
cd ${DIR_CREATE_LIVE}
echo -e "📂 Estutura inicial ✅"
sleep 0.2s

############################################
# Limpeza Inicial
############################################
lb clean &>/dev/null && lb clean --purge &>/dev/null
echo -e "🪛 Limpeza Executada ✅"
sleep 0.2s

############################################
# Criação de Configuração.
############################################

# Ligar o modo chroot interativo?
if [[ "$INTERACTIVE" = '0' ]]; then
    export INTERACTIVE='true'
else
    export INTERACTIVE='false'
fi

lb config noauto \
   --binary-images iso-hybrid \
   --mode debian \
   --architectures amd64 \
   --image-name "$ISO_NAME" \
   --linux-flavours amd64 \
   --distribution "$DEBIAN_VERSION" \
   --archive-areas "main contrib non-free non-free-firmware" \
   --parent-archive-areas "main contrib non-free non-free-firmware" \
   --parent-debian-installer-distribution "$DEBIAN_VERSION" \
   --debian-installer-gui false \
   --debian-installer none \
   --updates true \
   --interactive "$INTERACTIVE" \
   --memtest none \
   --security true \
   --cache true \
   --apt-recommends true \
   	--iso-application "$ISO_NAME" \
  	--iso-preparer "$ISO_NAME" \
   	--iso-publisher "$ISO_PUBLISHER" \
   	--iso-volume "$ISO_NAME" \
   	--checksums sha512 \
   --bootappend-live "boot=live locales=en_US.UTF-8 keyboard-layouts=us username=$USERNAME hostname=$ISO_NAME timezone=America/New_York autologin" \
   "${@}" &>/dev/null

echo -e "\n🪛 Criação de Configuração ✅"
sleep 0.2s

############################################
# Mova os arquivos para locais corretos
############################################

# Arquivos de configurações permanente
cp -r ${WORKDIR}/includes.chroot/ ${DIR_CREATE_LIVE}/config/

# Scripts para execução em chroot.
cp ${WORKDIR}/hooks/* ${DIR_CREATE_LIVE}/config/hooks/normal/

# Bootloaders (grub)
cp -r ${WORKDIR}/bootloaders/ ${DIR_CREATE_LIVE}/config/

# Lista de pacotes para ser instalados
cp -r ${WORKDIR}/package-lists/* ${DIR_CREATE_LIVE}/config/package-lists/

echo -e "🪛 Cópia para o diretório: ${DIR_CREATE_LIVE} ✅"
sleep 1s

############################################
# Construa
############################################
echo -e "🪛🔧🔨 Iniciando Construção de Live 🟢\n"
sleep 5s
lb build

echo -e "\nImagem .iso criada em: {$DIR_CREATE_LIVE} 💿"

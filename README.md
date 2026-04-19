# SCRIPT DE CRIAÇÃO AUTOMATIZADA DO BR-OS VIA LIVE-BUILD:
Esse é o script usado pelo projeto Br OS na criação de suas Imagens ISO's.
O Script é livre para uso, modificação e redistribuição, porém, os arquivos de branding são apenas para exemplo e devem ser substituídos pelos seus próprios arquivos de branding.
Ao executar este script você não obterá uma cópia perfeita do Br OS, isso acontece porque toda a automação e muitas funcionalidades são adicionadas via shel interativo através de outras ferramentas de automação, mas você obterá uma versão básica, que servirá de ponto de partida para sua própria personalização.
Este script foi criado pensando no Br OS, isso faz com que ele tenha funcionalidades bem específicas, porém, nada impede o usuário de o personalizar da forma que achar melhor.

Obs.: Concelho de amigo: Crie seu projeto, o amadureça, e só publique quando sentir:
01 - Que ele esta adicionando algo de bom à comunidade,
02 - Que você tem vocação para manter o projeto por anos.





### Arquivos
* includes.chroot = Todos estes arquivos serão copiados para seus respectivos locais dentro da ISO, use sua criatividade.
* bootloaders     = Bootloaders grub etc...
* hooks           = Scripts de configuração que serão executados em CHROOT.
* package-lists   = Lista de pacotes para instalação da live/ambiente final. Tudo que estiver dentro deste diretório será instalado, adicione ou remova pacotes da lista se julgar necessário.
* bros-builder.sh = Gere a iso

## Nota Calamares
Ao configurar os diretórios do Calamares, nunca use nomes compostos para nomes de diretórios,
O nome do diretorio de branding dentro de /etc/calamares/branding deve ter o nome da sua distro, o nome não deve conter espaços,
dentro do arquivo branding.desc, o ítem: componentName: deve constar o mesmo nome da sua pasta de branding, na mesma grafia
por exemplo:
componentName:   bros

no arquivo /etc/os-release, o ítem ID, também deve ter o mesmo nome da pasta de branding na mesma grafia:
exemplo:
ID=bros



## Modo de uso
```
$ git clone https://github.com/amarqsouza/bros-builder
$ cd bros-builder
# bash bros-builder.sh
```
A iso sera gerada no diretório BR-OS/. Você pode alterar, por exemplo, se deseja trocar para gerar a configuração e ISO final com o nome de (meu-debian) altere a variável DIR_CREATE_LIVE:
```
# Antes
export DIR_CREATE_LIVE="${WORKDIR}/BR-OS"

# Depois
export DIR_CREATE_LIVE="${WORKDIR}/meu-debian"
```

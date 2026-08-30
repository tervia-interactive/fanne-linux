# Fix: malformed /etc/apt/sources.list on `make iso`

## Por quê

`docs/architecture.md` do fanne-linux define o projeto como um derivado do
**Devuan Ceres** (sysvinit + elogind), mas `auto/config` (ou o local
equivalente onde `lb config` era chamado) não passava `--mode devuan`, e/ou
misturava mirror do Devuan (`http://deb.devuan.org/merged`) com convenções
de área de arquivo do Debian (ex. `non-free-firmware`, que não existe no
pool "merged" do Devuan). Isso faz o `live-build` escrever uma linha
`deb ...` inválida em `/etc/apt/sources.list` do chroot, e o `apt update`
falha com:

```
E: Malformed entry 1 in list file /etc/apt/sources.list (URI parse)
```

## O que este pacote faz

Substitui/adiciona `auto/config`, `auto/build` e `auto/clean` com uma
configuração explícita para Devuan Ceres:

- `--mode devuan` explícito
- `--distribution ceres`
- mirrors consistentes (`deb.devuan.org/merged`) em bootstrap, chroot,
  security e binary
- `--archive-areas main` (sem componentes que não existem no Devuan)

## Como aplicar

1. Copie os três arquivos para a raiz do repositório, dentro de `auto/`:

   ```
   cp auto/config auto/build auto/clean /caminho/para/fanne-linux/auto/
   chmod +x /caminho/para/fanne-linux/auto/{config,build,clean}
   ```

2. Limpe qualquer estado de build anterior (importante — configs antigas
   ficam cacheadas):

   ```
   cd /caminho/para/fanne-linux
   sudo make clean || sudo lb clean --purge
   ```

3. Rode o build novamente:

   ```
   sudo make iso
   ```

4. Se `scripts/build.sh` chama `lb config` diretamente com suas próprias
   flags (em vez de deixar o `auto/config` ser lido), ajuste esse script
   para usar `lb config noauto` (para que ele leia `auto/config`) ou copie
   as mesmas flags de mirror/distribuição para lá.

## Ajustes que você deve revisar

- `ARCHIVE_AREAS`, pacotes de firmware, e a lista em
  `config/package-lists/` podem precisar de ajuste fino conforme o que o
  projeto já tinha configurado.
- Se o projeto realmente pretende voltar a ser baseado em Debian Sid puro
  (ao invés de Devuan), a correção é a inversa: manter `--mode debian`,
  usar mirror `deb.debian.org`, distribuição `sid`, e áreas
  `main contrib non-free non-free-firmware`. Não dá pra misturar os dois.

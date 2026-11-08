# Projeto de Redes - Grupo 10 (Eventos)

O projeto oferece duas formas independentes de executar os serviços:

1. Criar uma máquina virtual Ubuntu com Vagrant e VirtualBox e executar os contêineres dentro dela.
2. Executar os contêineres diretamente no computador com Docker Compose.

Escolha uma das opções abaixo. Cada ambiente tem seus próprios contêineres e volumes de dados.

## Opção 1: máquina virtual com Vagrant

### Pré-requisitos

- Windows com Oracle VirtualBox e Vagrant instalados.
- Conexão com a Internet na primeira inicialização, para baixar a imagem Ubuntu e as imagens Docker.
- Pelo menos 2 GB de memória disponíveis para a VM.

Abra o PowerShell na pasta do repositório e execute:

```powershell
vagrant up --provider=virtualbox
```

O Vagrant cria uma VM Ubuntu com hostname `grupo10-eventos` e IP privado `192.168.20.10`. Durante o provisionamento, instala Docker e Docker Compose e inicia os serviços definidos em `docker-compose.yaml`.

A pasta do repositório é compartilhada com a VM em `/vagrant`; assim, o Compose executado na VM usa os arquivos deste projeto.

Abra no navegador do Windows:

- Aplicação: `http://192.168.20.10:8010`
- WordPress: `http://192.168.20.10:9010`

Para usar os domínios do projeto, execute o Bloco de Notas como administrador, abra `C:\Windows\System32\drivers\etc\hosts` e acrescente:

```text
192.168.20.10 eventos.local blog.eventos.local
```

Então acesse `http://eventos.local:8010` e `http://blog.eventos.local:9010`.

Comandos úteis, executados na pasta do repositório:

```powershell
vagrant ssh
vagrant halt
vagrant up
vagrant destroy
```

`vagrant destroy` remove a VM e os dados que estão nos volumes dela. Use `vagrant up` novamente para recriá-la.

## Opção 2: Docker Compose diretamente no computador

### Pré-requisitos

- Docker Desktop instalado e em execução no Windows.
- O comando `docker compose` disponível no PowerShell.

Abra o PowerShell na pasta do repositório e suba os serviços:

```powershell
docker compose up -d --build
```

Abra no navegador:

- Aplicação: `http://localhost:8010`
- WordPress: `http://localhost:9010`

O MySQL também publica a porta `3310` no computador. Para acesso administrativo, as credenciais configuradas no Compose são usuário `root` e senha `rootpassword`.

Para acompanhar os serviços e encerrar os contêineres:

```powershell
docker compose ps
docker compose logs -f
docker compose down
```

`docker compose down` mantém os volumes e os dados. Para apagar também os dados persistidos do MySQL e do WordPress, use `docker compose down -v`; essa remoção é irreversível.

## Portas

| Serviço | Porta publicada | Porta no contêiner |
|---|---:|---:|
| Aplicação Streamlit | 8010 | 8010 |
| WordPress | 9010 | 80 |
| MySQL | 3310 | 3306 |

O MySQL usado internamente pelos contêineres é acessado pelo nome de serviço `mysql` na porta `3306`. A porta `3310` é publicada para conexões originadas fora da rede Docker.

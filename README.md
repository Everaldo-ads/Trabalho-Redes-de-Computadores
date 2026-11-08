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

## Acessar o MySQL pelo MySQL Workbench

O MySQL Workbench é um cliente gráfico para conectar ao banco; não é necessário instalar outro servidor MySQL no Windows.

1. Baixe o **MySQL Workbench** para Windows na [página oficial de downloads](https://dev.mysql.com/downloads/workbench/). Se a página oferecer a opção de entrar ou criar uma conta Oracle, você pode selecionar **“No thanks, just start my download”**.
2. Instale e abra o MySQL Workbench.
3. Na tela inicial, clique no botão **+** ao lado de **MySQL Connections** para criar uma conexão.
4. Preencha os campos:

   | Campo | Docker Compose no Windows | Vagrant/VM |
   |---|---|---|
   | Connection Name | `MySQL do projeto` | `MySQL do projeto (VM)` |
   | Hostname | `127.0.0.1` | `192.168.20.10` |
   | Port | `3310` | `3310` |
   | Username | `root` | `root` |

5. Clique em **Store in Vault...** (ou **Store in Keychain...**) e informe a senha `rootpassword`.
6. Clique em **Test Connection** e, se o teste funcionar, confirme em **OK**. Depois, abra a conexão criada na tela inicial.
7. Na aba **Schemas**, atualize a lista se necessário. O banco do WordPress é `wordpress`.

Antes de conectar, inicie o ambiente escolhido: no Docker Compose, execute `docker compose up -d`; para a VM, execute `vagrant up --provider=virtualbox`. Na opção Vagrant, o endereço `192.168.20.10` só estará disponível enquanto a VM estiver ligada.

## Portas

| Serviço | Porta publicada | Porta no contêiner |
|---|---:|---:|
| Aplicação Streamlit | 8010 | 8010 |
| WordPress | 9010 | 80 |
| MySQL | 3310 | 3306 |

O MySQL usado internamente pelos contêineres é acessado pelo nome de serviço `mysql` na porta `3306`. A porta `3310` é publicada para conexões originadas fora da rede Docker.

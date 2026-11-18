# Projeto de Redes - Grupo 10 (Eventos)

O projeto executa os serviços em uma máquina virtual Ubuntu criada com Vagrant e VirtualBox. Os contêineres são iniciados dentro da VM, não diretamente no Windows.

## Preparar o Windows: Winget ou instalação manual

Para usar a opção Vagrant, instale o Oracle VirtualBox e o Vagrant. Você pode instalar os dois pelo script deste projeto ou baixá-los e instalá-los manualmente. O MySQL Workbench é opcional.

### Instalação pelo script (Winget)

O script [instalar-dependencias.ps1](./instalar-dependencias.ps1) verifica se VirtualBox e Vagrant já estão instalados e instala apenas os que faltarem. Depois, se o MySQL Workbench não estiver instalado, pergunta se você deseja instalá-lo.

Com o Winget disponível, abra o PowerShell na pasta do projeto e execute:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\instalar-dependencias.ps1
```

A alteração da política vale somente para a janela atual do PowerShell. O Winget pode solicitar confirmação ou permissões de administrador durante as instalações.

### Instalação manual

Baixe e instale os programas pelos sites oficiais:

- [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://developer.hashicorp.com/vagrant/install)
- [MySQL Workbench (opcional)](https://dev.mysql.com/downloads/workbench/)

Não é necessário instalar o Docker Desktop: na opção usada pelo projeto, o Docker é instalado dentro da VM.

## Executar a máquina virtual com Vagrant

### Pré-requisitos

- Windows com Oracle VirtualBox e Vagrant instalados.
- Conexão com a Internet na primeira inicialização, para baixar a imagem Ubuntu e instalar o Docker.
- Pelo menos 2 GB de memória disponíveis para a VM.

Abra o PowerShell na pasta do repositório e execute:

```powershell
vagrant up --provider=virtualbox
```

O Vagrant cria uma VM Ubuntu com hostname `grupo10-eventos` e IP privado `192.168.20.10`. Durante o provisionamento, instala Docker e o plugin Docker Compose, mas **não inicia os contêineres automaticamente**.

A pasta do repositório é compartilhada com a VM em `/vagrant`. Depois que o `vagrant up` terminar, acesse a VM e inicie os contêineres manualmente:

```powershell
vagrant ssh
```

Já dentro da VM, execute:

```bash
cd /vagrant
docker compose up -d --build
```

Os endereços abaixo estarão disponíveis depois que os contêineres iniciarem:

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

## Acessar o MySQL pelo MySQL Workbench

O MySQL Workbench é um cliente gráfico para conectar ao banco; não é necessário instalar outro servidor MySQL no Windows.

1. Baixe o **MySQL Workbench** para Windows na [página oficial de downloads](https://dev.mysql.com/downloads/workbench/). Se a página oferecer a opção de entrar ou criar uma conta Oracle, você pode selecionar **“No thanks, just start my download”**.
2. Instale e abra o MySQL Workbench.
3. Na tela inicial, clique no botão **+** ao lado de **MySQL Connections** para criar uma conexão.
4. Preencha os campos:

   | Campo | Valor |
   |---|---|
   | Connection Name | `MySQL do projeto (VM)` |
   | Hostname | `192.168.20.10` |
   | Port | `3310` |
   | Username | `root` |

5. Clique em **Store in Vault...** (ou **Store in Keychain...**) e informe a senha `rootpassword`.
6. Clique em **Test Connection** e, se o teste funcionar, confirme em **OK**. Depois, abra a conexão criada na tela inicial.
7. Na aba **Schemas**, atualize a lista se necessário. O banco do WordPress é `wordpress`.

Antes de conectar, inicie a VM com `vagrant up --provider=virtualbox` e os contêineres dentro dela com `vagrant ssh`, `cd /vagrant` e `docker compose up -d`. O endereço `192.168.20.10` só estará disponível enquanto a VM estiver ligada.

## Portas

| Serviço | Porta publicada | Porta no contêiner |
|---|---:|---:|
| Aplicação Streamlit | 8010 | 8010 |
| WordPress | 9010 | 80 |
| MySQL | 3310 | 3306 |

O MySQL usado internamente pelos contêineres é acessado pelo nome de serviço `mysql` na porta `3306`. A porta `3310` é publicada para conexões originadas fora da rede Docker.

# Infraestrutura como Código para Plataforma CloudFix na AWS

Este projeto contém a definição da infraestrutura como código (IaC) para a implantação da plataforma CloudFix na AWS, utilizando Terraform. A arquitetura é projetada para ser modular, flexível e escalável, seguindo as melhores práticas de DevOps e nuvem.

## ✨ Principais Funcionalidades

- **Arquitetura Modular**: A infraestrutura é dividida em módulos reutilizáveis (`networking`, `ecs`, `ec2`, `rds`, `ecr`, etc.), facilitando a manutenção e a evolução.
- **Flexibilidade de Compute**: Suporte para implantação da aplicação em **AWS ECS (Fargate)** para uma abordagem serverless ou em instâncias **AWS EC2** tradicionais, permitindo escolher a melhor opção para cada cenário.
- **Banco de Dados Gerenciado**: Utiliza **AWS RDS** para persistência de dados relacionais de forma confiável e escalável.
- **Otimização de Custos**: Inclui um módulo `rds-scheduler` que utiliza uma função Lambda para ligar/desligar o banco de dados RDS automaticamente, ideal para ambientes de não produção.
- **Cache em Memória**: Provisiona o **Valkey** (compatível com Redis) para cache de alta performance, melhorando a latência e a experiência do usuário.
- **Rede Segura e Isolada**: Cria uma VPC dedicada com subnets públicas e privadas, security groups e um Bastion Host para acesso seguro aos recursos.
- **Automação e Boas Práticas**:
  - Scripts para automatizar o ciclo de vida da infraestrutura (`apply` e `destroy`).
  - Uso de `pre-commit` hooks para garantir a qualidade e a padronização do código.
  - Linting para YAML, Dockerfiles e formatação de Terraform.
  - Preparado para geração de documentação automática com `terraform-docs`.

## 🏗️ Estrutura do Projeto

```
terraform-aws/
├── main.tf                # Arquivo principal que orquestra os módulos
├── variables.tf           # Definição das variáveis de entrada
├── outputs.tf             # Definição das saídas da infraestrutura (e.g., IPs, URLs)
├── terraform.tfvars       # (Não versionado) Valores das variáveis para um ambiente específico
├── terraform.tfvars.example # Exemplo de como preencher as variáveis
├── providers.tf           # Configuração dos providers (AWS, Helm, etc.)
├── locals.tf              # Variáveis locais e lógicas complexas
├── scripts/               # Scripts de automação e utilitários
│   ├── UpTerraform.sh     # Executa `terraform apply`
│   └── DwnTerraform.sh    # Executa `terraform destroy`
└── modules/               # Módulos reutilizáveis da infraestrutura
    ├── networking/        # Módulo de Rede (VPC, Subnets, Security Groups)
    ├── ecr/               # Módulo para o Elastic Container Registry
    ├── ecs/               # Módulo para a infraestrutura do ECS (Fargate)
    ├── ec2/               # Módulo para a infraestrutura de EC2
    ├── rds/               # Módulo para o banco de dados RDS
    ├── rds-scheduler/     # Módulo para o agendador de start/stop do RDS
    └── valkey/            # Módulo para o cache em memória Valkey
```

## 🚀 Como Usar

### Pré-requisitos

- [AWS CLI](https://aws.amazon.com/cli/) configurado com credenciais válidas.
- [Terraform](https://www.terraform.io/downloads.html) (versão ~> 1.6.0).
- [Docker](https://www.docker.com/get-started) (se precisar construir e enviar imagens).
- `pre-commit` (opcional, para desenvolvimento): `pip install pre-commit`.

### Passos para Implantação

1.  **Clonar o Repositório**
    ```bash
    git clone <url-do-repositorio>
    cd CloudFix/terraform-aws
    ```

2.  **Configurar as Variáveis do Ambiente**
    Copie o arquivo de exemplo e preencha com os valores desejados para o seu ambiente.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edite o arquivo terraform.tfvars com suas configurações (região, nome do ambiente, etc.)
    ```

3.  **Instalar os Hooks de Git (Opcional)**
    Se for desenvolver, instale os hooks para garantir a qualidade do código.
    ```bash
    pre-commit install
    ```

4.  **Inicializar o Terraform**
    Este comando baixa os providers e módulos necessários.
    ```bash
    terraform init
    ```

5.  **Planejar e Aplicar a Infraestrutura**
    Verifique o que será criado e, se estiver correto, aplique.
    ```bash
    # Planeja as mudanças
    terraform plan -out=plan.out

    # Aplica as mudanças
    terraform apply "plan.out"
    ```
    Como alternativa, você pode usar o script `UpTerraform.sh`.

### Alternando entre EC2 e ECS

Para escolher onde a aplicação será implantada, edite a variável `deployment_target` (ou similar) no seu arquivo `terraform.tfvars`:

- Para ECS: `deployment_target = "ecs"`
- Para EC2: `deployment_target = "ec2"`

Em seguida, execute `terraform plan` e `terraform apply` novamente. Os scripts `use-ecs.sh` e `use-ec2.sh` podem ser usados como atalhos para este processo.

## 📜 Scripts Auxiliares

- `UpTerraform.sh`: Aplica a configuração do Terraform de forma automatizada.
- `DwnTerraform.sh`: Destrói toda a infraestrutura gerenciada pelo Terraform. **Use com cuidado!**
- `use-ec2.sh` / `use-ecs.sh`: Atalhos para modificar o ambiente e alternar entre os modos de implantação.

## 🔮 Melhorias Futuras

- [ ] Implementar um pipeline de CI/CD (GitHub Actions, GitLab CI) para automatizar os deploys.
- [ ] Adicionar testes de infraestrutura com `Terratest`.
- [ ] Integrar um cofre de segredos (como AWS Secrets Manager) para gerenciar senhas e chaves.
- [ ] Configurar o `terraform-docs` para gerar a documentação dos módulos automaticamente.

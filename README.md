# CloudInfra-App-Toolbox
CloudInfra-App-Toolbox is a collection of scripts, configurations, and infrastructure templates for managing cloud infrastructure efficiently. The project includes automation scripts, Kubernetes configurations, Terraform infrastructure as code, and CI/CD pipeline definitions.

# Project Structure

```bash
src/
CloudInfra-App-Toolbox/
│── applications/       # Application-specific configurations and deployments
│   ├── dotnet-app/     # .NET-based applications
│   ├── powershell-app/ # PowerShell-based applications
│   ├── python-app/     # Python-based applications
│
│── config/             # Configuration files for cloud services and applications
│   ├── ApplicationGateway_Create/ # Configuration for Application Gateway
│   ├── appsettings.json          # General application settings
│   ├── azure-config.json         # Azure-related configurations
│   ├── secrets-template.json     # Secrets management template
│   ├── README.md                 # Config documentation
│
│── containers/         # Containerization-related files (Docker, Helm, etc.)
│   ├── base-images/    # Base Dockerfiles
│   ├── docker-compose.yml # Docker Compose configurations
│
│── docs/               # Documentation and architecture diagrams
│   ├── README.md       # Project documentation
│
│── infrastructure/     # Cloud infrastructure provisioning (Terraform, ARM, Bicep)
│   ├── azure-cli/      # Azure CLI scripts
│
│── pipelines/          # CI/CD pipelines
│   ├── azure-pipelines.yml   # Azure DevOps pipeline configuration
│   ├── github-actions.yml    # GitHub Actions workflow
│
│── scripts/            # Various automation and maintenance scripts
│   ├── ApplicationGateway_Create.ps1  # PowerShell script for creating an Azure Application Gateway
│   ├── cleanup.ps1     # PowerShell script for cleaning up resources
│   ├── data-migration.py  # Python script for data migration
│   ├── monitor.sh      # Shell script for monitoring services
│
│── .gitignore          # Git ignore rules
│── README.md           # Project documentation
```

## Getting Started

- Cloud Provider: Azure CLI, AWS CLI, or Google Cloud SDK (as needed)
- Containerization: Docker, Kubernetes, Helm
- Infrastructure as Code: Terraform, Bicep, or ARM templates
- Scripting: PowerShell (Windows), Bash (Linux/macOS), Python

## Installation & Setup
- Clone the repository
```bash
git clone https://github.com/sebints001/CloudInfra-App-Toolbox.git
cd CloudInfra-App-Toolbox
```
- Install dependencies
  - Ensure you have the necessary tools installed (Azure CLI, Terraform, Docker, etc.).
  - Run the setup scripts if available:
```bash
./scripts/setup.sh
```
- Deploy Infrastructure (Example using Terraform)
```bash
cd infrastructure/terraform
terraform init
terraform apply
```
* Run CI/CD pipeline
  - Sub Using GitHub Actions: Update .github/workflows/main.yml
  - Using Azure DevOps: Configure pipelines/azure-pipelines.yml

## Key Components
- Applications (applications/)

  - Dotnet, PowerShell, and Python-based applications

- Configuration Management (config/)

  - JSON-based configurations for applications and cloud resources

- Containerization (containers/)

  - Dockerfiles and Docker Compose setups

- Infrastructure as Code (infrastructure/)

  - Terraform, Kubernetes, and Azure CLI scripts

- Automation Scripts (scripts/)

  - Various scripts for cloud resource management, monitoring, and data migration

- CI/CD Pipelines (pipelines/)

  - GitHub Actions and Azure Pipelines automation
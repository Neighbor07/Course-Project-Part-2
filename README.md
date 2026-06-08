# Course-Project-Part-2 - CS 312

This repository contains an automated Infrastructure as Code (IaC) pipeline designed to provision, configure, and initialize a cloud-hosted Minecraft server on Amazon Web Services (AWS). By leveraging modern DevOps tools. Specifically Terraform for infrastructure provisioning and Ansible for configuration management. This setup eliminates the need for manual interaction with the AWS Management Console.

## System requirements and Tools

To execute this pipeline successfully, your local deployment control node must be configured with the following specific software tools, versions, and architectural environments:

* **Operating System Host:** Windows 10 or Windows 11 utilizing Windows Subsystem for Linux (WSL2) running an `Ubuntu 24.04 LTS` distribution image.
* **Integrated Development Environment (IDE):** Visual Studio Code (VS Code) installed on the Windows host, integrated with the official Microsoft WSL Extension.
* **AWS Command Line Interface (CLI):** `v2.x` installed natively inside the WSL Ubuntu environment and authenticated using active temporary AWS Academy Learner Lab session tokens.
* **Terraform:** `v1.x` engine installed via the official HashiCorp Linux package repository.
* **Ansible:** `v2.15+` core engine installed via the official Ansible Personal Package Archive (PPA) repository.
* **Network Auditing Utility:** The `nmap` CLI tool for post-deployment remote port validation.
* **Target Authentication Architecture:** A local Secure Shell (SSH) key pair (`RSA 4096-bit`) generated natively inside the WSL filesystem.

## Pipeline Architecture Overview

The deployment lifecycle is divided into three decoupled stages, ensuring a strict separation of concerns between cloud infrastructure provisioning, operating system configuration, and external state validation.

### 1. Infrastructure Provisioning Stage (Terraform)

* Establishes secure API handshakes with the AWS cloud provider using local temporary credentials.
* Generates an isolated Virtual Private Cloud (VPC), an attached Internet Gateway for public routing, dedicated Route Tables, and a Public Subnet.
* Creates a targeted AWS Security Group acting as a network firewall, strictly limiting inbound access to Port `22` (SSH management) and Port `25565` (Minecraft game traffic) from any source IP (`0.0.0.0/0`).
* Launches an Ubuntu 24.04 Amazon Machine Image (AMI) on a `t2.small` Elastic Compute Cloud (EC2) virtual instance.
* **Automation Bridge:** Dynamically compiles a localized Ansible-compliant inventory tracking asset file (`inventory.ini`) inside the project workspace, injecting the server's newly generated public IPv4 address automatically.

### 2. Instance Configuration Management Stage (Ansible)

* Establishes automated SSH automation routines using the pre-shared local public key uploaded during the infrastructure stage.
* Synchronizes and updates underlying Linux system packages via the native advanced package tool (`apt upgrade`).
* Installs the headless Java 21 Runtime Environment (`openjdk-21-jre-headless`) required to execute modern Minecraft server binaries.
* Automates isolated application directory creation, fetches the verified production Vanilla Minecraft `server.jar` executable via safe web requests, and writes compliance acceptance to the `eula.txt` file.
* **Graceful Shutdown Mitigation:** Deploys a customized Linux service management file (`systemd.service`) utilizing a `KillSignal=SIGINT` configuration override. This explicitly fixes improper shutdown bugs by passing an interrupt signal straight into the Java virtual machine environment upon termination, forcing the game loop to save all active world chunks cleanly to disk and preventing runtime database corruption.

### 3. Application Validation Stage (Nmap)

* Queries the live public application network interface directly from your local control machine terminal.
* Confirms external service visibility across the open Internet without exposing internal configuration tools or debugging infrastructure.

## Deployment Tutorial

Follow these instructional steps sequentially inside your WSL Ubuntu terminal interface to execute the automation pipeline. These text-based setup steps are written to be completely clear and executable without requiring supplementary screenshots.

### Step 1: Initialize AWS Cloud Access Credentials

Every time you access your AWS Academy Learner Lab platform environment, your temporary credentials must be rotated.

1. Log into your AWS Academy dashboard and start the lab.
2. Click the **AWS Details** button, then select **Show** next to the AWS CLI label.
3. Copy the entire text block containing the access keys.
4. Open your WSL Ubuntu terminal and execute the following commands to save the keys securely:

   ```bash
   mkdir -p ~/.aws
   nano ~/.aws/credentials
   ```

5. Paste the copied credentials text directly into the text editor file.
6. Save the modifications.

### Step 2: Generate Local Secure Shell Security Keys

Ansible requires a dedicated cryptographic local key identity token to pass through the newly provisioned cloud firewall securely.

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/acme_minecraft -N ""
```

Verify that both the private key (`acme_minecraft`) and public key (`acme_minecraft.pub`) files were successfully created inside the `~/.ssh` directory.

### Step 3: Execute the Infrastructure Provisioning Files

Navigate directly inside your infrastructure project directory to pull down the cloud provider plugins, audit the orchestration configuration layout, and apply the cloud resources.

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Observe the final terminal lines carefully. Terraform will output a dedicated string containing the public IP address of the active EC2 instance.

The provisioning process may take several minutes while AWS allocates networking resources, deploys the Ubuntu server, and generates the supporting automation artifacts.

### Step 4: Run the System Configuration Management Playbook

Terraform has automatically populated the host location information within your configuration folder. Shift directories into your configuration engine workspace and trigger the automation tasks.

```bash
cd ../ansible
ansible-playbook -i inventory.ini main.yml
```

During execution, Ansible will:

* Establish an SSH session with the newly provisioned EC2 instance.
* Upgrade operating system packages and install required dependencies.
* Install the Java 21 Runtime Environment.
* Download the Minecraft server binary.
* Configure EULA acceptance automatically.
* Create and enable the Minecraft system service.
* Start the Minecraft server and register it for automatic startup.

Verify the final execution summary block on your terminal screen returns a value of `failed=0` across all running automation sweeps.

### Step 5: Perform External Network Validation Testing

Audit the public visibility of your cloud-hosted Minecraft game instance engine using the target network port scanner utility, replacing <YOUR_SERVER_PUBLIC_IP> text with your actual server IP address.

```bash
nmap -sV -Pn -p T:25565 <YOUR_SERVER_PUBLIC_IP >
```

Verify that the console output displays `state open` and accurately identifies the running service application.

Successful output confirms that:

* The AWS Security Group firewall rule has been applied correctly.
* The Minecraft service is actively listening on TCP Port `25565`.
* External Internet clients can successfully reach the server.
* The deployment pipeline completed successfully.

## References
* Cloud Infrastructure Orchestration Engine: HashiCorp Corporation. (2026). Amazon Web Services (AWS) Provider Configuration Modules. Terraform Registry Documentation. https://registry.terraform.io/providers/hashicorp/aws/latest/docs

* System Configuration Automation Framework: Red Hat, Inc. (2026). Ansible Core Engine Built-In Package and System Control Modules. Ansible Documentation Portal. https://docs.ansible.com/

* Linux Operating System Process Lifecycles: Freedesktop.org. (2026). systemd.service: Core Background Process Service Unit Configurations. Linux Manual Pages System. https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html

* Application Server Executable Source: Mojang Studios. (2026). Minecraft: Java Edition Headless Dedicated Server Binaries and End User License Agreement (EULA) Protocols. Mojang Official Platform. https://www.minecraft.net/en-us/download/server
"""
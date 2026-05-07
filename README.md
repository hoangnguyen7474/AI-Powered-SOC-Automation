# AI-Powered SOC Automation & Incident Response System

## 🌟 Overview
This project focuses on building an automated Security Operations Center (SOC) system to address the challenges of manual incident response. By integrating **SIEM (Splunk)**, **SOAR (n8n)**, and **Generative AI (GPT-4o-mini)**, the system automates alert triage, data enrichment, and response recommendations.

**Key Achievement:** This project was awarded a **9.1/10** score for the Graduation Thesis at University of Information Technology (UIT).

## 🚀 Key Features
- **Automated Triage:** Automatically filters and categorizes security alerts from Splunk.
- **AI-Driven Analysis:** Utilizes LLM (GPT-4o-mini) to act as a Tier 1 Analyst, providing context-aware analysis and remediation steps.
- **Real-time Notifications:** Instant alerts and detailed reports sent via **Slack** for the security team.
- **Advanced Threat Detection:** Successfully detects and responds to Brute Force, Malware, and DDoS attacks and CIC-IDS dataset.

## 🛠 Tech Stack
- **SIEM:** Splunk Enterprise
- **SOAR:** n8n (Workflow Automation)
- **AI Model:** OpenAI API (GPT-4o-mini)
- **Monitoring:** Windows Event Logs, Sysmon
- **Testing Tools:** Kali Linux (Hydra, Villain, hping3)


## 📊 Performance Results
The system demonstrated significant efficiency improvements compared to manual processes:
- **MTTR (Mean Time To Respond):** Reduced from ~15 minutes to **9.3 seconds**.
- **Detection Accuracy:** Achieved **99.7%** accuracy on the CIC-IDS-2017 dataset.
- **Scalability:** Successfully handled 68 concurrent DDoS alerts within 15 seconds.

## 🏗 System Architecture
![System Architecture](./assets/architecture.png)


## 🏗  System Workflow
1.  **Ingestion:** Splunk collects logs from Endpoints (Windows/Sysmon).
2.  **Detection:** Alert rules in Splunk trigger a Webhook when suspicious activity is detected.
3.  **Normalization:** The `data-normalization.js` script inside n8n cleans and formats the raw alert data.
4.  **AI Analysis:** GPT-4o analyzes the normalized data to determine the threat level and provide remediation steps.
5.  **Notification:** A structured, high-context alert is sent to a specific Slack channel based on the attack type.

![n8n Workflow](./assets/n8n-workflow.png)


## 🧠 Custom Logic & Data Normalization in n8n
To ensure the AI and the security team receive clean, structured data, I implemented a custom JavaScript processor within n8n.

Key functions of the script:

Data Normalization: Standardizes field names (IP, Hostname, Severity) from different log sources.

Dynamic Routing: Automatically routes alerts to specific Slack channels based on the Alert ID (e.g., #alert-brute-force, #alert-ddos).

Context Enrichment: Prepares raw data for the LLM (GPT-4o) to analyze.

![ Function Node ](./assets/n8n-workflow-CustomLogicDataNormalization.png)

📂[ View the full script here ](./scripts/data-normalization.js)

## 📁 Repository Structure & Components

I have organized this repository to reflect a professional SecOps environment. Below is the breakdown of each directory and its function:

### 📂 assets/
Contains visual documentation of the project’s monitoring and alerting capabilities.
* `architecture.png`: High-level diagram showing the data flow between Splunk, n8n, and OpenAI.
* `splunk-dashboard-alerts.png`: **Main Security Dashboard** providing an overview of all detected security events and system health.
* `splunk-dashboard-alerts01.png`: **Brute Force Detection View** showing failed login attempts (Windows Event ID 4625) captured from the victim's machine.
* `splunk-dashboard-alerts02.jpg`: **Malware Activity Monitoring** visualizing suspicious PowerShell execution and unauthorized file modifications.
* `splunk-dashboard-alerts03.png`: **DDoS Attack Analysis** illustrating traffic spikes and SYN flood patterns detected in real-time.
* `splunk-dashboard-alerts04.jpg`: **CIC-IDS-2017 Dataset Integration** showing the validation of the AI model against international standard datasets.
* `slack-alert.png`: **AI-Generated Incident Report** - a sample of the high-context notification sent to Slack via n8n.

### 📂 `deployments/`
Infrastructure-as-Code (IaC) for system deployment.
* `docker-compose.yaml`: Orchestration file to quickly spin up the n8n automation engine and its environment.

### 📂 `siem-configs/`
Configuration files for the SIEM layer (Splunk).
* `inputs.conf`: Defines data ingestion rules for Windows Event Logs and attack simulation datasets. Locate at Victim Machine: mục C:\Program Files\SplunkUniversalForwarder\etc\system\local 

### 📂 `scripts/`
Custom scripts for logic processing and security testing.
* `n8n-logic/data-normalization.js`: Custom JavaScript used inside n8n to standardize incoming log data before AI analysis.
* `ingest_samples.py`: Python script to feed test data (CIC-IDS-2017) into the SIEM.
* `auto_attack.sh`: Bash script to simulate Brute Force and DDoS attacks for testing.

### 📂 `docs/`
* `Thesis_Summary.pdf`: A detailed summary of the research methodology, experimental results, and conclusion.

---





## 📝 Setup & Installation
1. **Splunk:** Configure `inputs.conf` to forward logs to the indexer.
2. **n8n:** Import the provided workflow JSON files in the `/workflows` folder.
3. **OpenAI:** Add your API Key to the n8n credentials.

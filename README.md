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

## 🧠 Custom Logic & Data Normalization
To ensure the AI and the security team receive clean, structured data, I implemented a custom JavaScript processor within n8n.

Key functions of the script:

Data Normalization: Standardizes field names (IP, Hostname, Severity) from different log sources.

Dynamic Routing: Automatically routes alerts to specific Slack channels based on the Alert ID (e.g., #alert-brute-force, #alert-ddos).

Context Enrichment: Prepares raw data for the LLM (GPT-4o) to analyze.

📂![ View the full script here ](./scripts/data-normalization.js)

## 📊 Performance Results
The system demonstrated significant efficiency improvements compared to manual processes:
- **MTTR (Mean Time To Respond):** Reduced from ~15 minutes to **9.3 seconds**.
- **Detection Accuracy:** Achieved **99.7%** accuracy on the CIC-IDS-2017 dataset.
- **Scalability:** Successfully handled 68 concurrent DDoS alerts within 15 seconds.

## 🏗 System Architecture
![System Architecture](./assets/architecture.png)

## 📝 Setup & Installation
1. **Splunk:** Configure `inputs.conf` to forward logs to the indexer.
2. **n8n:** Import the provided workflow JSON files in the `/workflows` folder.
3. **OpenAI:** Add your API Key to the n8n credentials.

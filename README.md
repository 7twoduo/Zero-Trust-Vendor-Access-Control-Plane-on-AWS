# FedRAMP-Aligned Zero-Trust Partner Access MVP on AWS

A minimal AWS project that demonstrates approval-based, time-bound partner access to one protected resource with evidence generation and auditability.


![alt text](image-1.png)



## Stack

- Terraform
- AWS Lambda
- API Gateway
- DynamoDB
- IAM / STS
- S3
- KMS
- CloudTrail
- Python
- Bash

## MVP Flow

1. Submit access request
2. Store request in DynamoDB
3. Approve or deny request
4. Grant temporary access
5. Write evidence to S3
6. Revoke after expiration
7. Review CloudTrail records

## Docs

- `docs/overview.md`
- `docs/architecture.md`
- `docs/controls.md`

# Folder Structure
```markdown
fedramp-zero-trust-mvp/
├── README.md
├── docs/
│   ├── overview.md
│   ├── architecture.md
│   └── controls.md
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── iam.tf
│   ├── kms.tf
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── lambda.tf
│   ├── api.tf
│   └── cloudtrail.tf
├── app/
│   ├── common.py
│   ├── request_access.py
│   ├── approve_access.py
│   └── revoke_access.py
└── scripts/
    ├── deploy.sh
    ├── invoke-request.sh
    ├── approve-request.sh
    └── collect-evidence.sh
``` 



Built a zero-trust AWS access-control MVP using Terraform, API Gateway, Lambda, IAM, STS, DynamoDB, S3, KMS, and CloudTrail that enforced approval-based, time-bound access to a protected API with auditable evidence generation.



## 👨‍💻 About the Author

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Inter&weight=600&size=22&pause=1000&color=58A6FF&center=true&vCenter=true&width=760&lines=Cloud+Engineer+focused+on+AWS%2C+Terraform%2C+and+automation;Building+production-inspired+infrastructure+projects;Turning+cloud+concepts+into+real-world+implementations" alt="Typing SVG" />
</p>

<p align="center">
  I build hands-on cloud projects designed to reflect practical engineering work rather than simple demos.
  My focus is on <b>AWS infrastructure</b>, <b>Infrastructure as Code</b>, <b>automation</b>, <b>security-minded design</b>,
  and <b>real implementation patterns</b> that translate into production environments.
</p>

<p align="center">
  Through projects like this, I aim to demonstrate the ability to design, provision, and integrate modern cloud services
  in ways that are scalable, structured, and operationally relevant.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Architecting-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Cloud-Engineering-1F6FEB?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Automation-Building-success?style=for-the-badge" />
</p>

<p align="center">
  <a href="https://www.linkedin.com/in/gavin-fogwe/">
    <img src="https://img.shields.io/badge/LinkedIn-Let's%20Connect-blue?style=for-the-badge&logo=linkedin" />
  </a>
  <a href="https://github.com/gavinxenon0-arch">
    <img src="https://img.shields.io/badge/GitHub-See%20More%20Projects-black?style=for-the-badge&logo=github" />
  </a>
  <a href="https://gavinfogwe.win/">
    <img src="https://img.shields.io/badge/Portfolio-Explore-orange?style=for-the-badge&logo=googlechrome&logoColor=white" />
  </a>
</p>

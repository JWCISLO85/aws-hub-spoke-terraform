 <h1>Secure MSP Infrastructure with Terraform and AWS</h1>
A Terraform project that builds a secure, multi-tenant Managed Service Provider (MSP) environment in AWS using a hub-and-spoke network topology. The infrastructure simulates the model that providers like Rackspace use to host multiple isolated client environments behind centralized routing, monitoring, and security controls.
Built as a senior seminar project at Champlain College.
Overview
The project deploys 44 Terraform-managed resources across three VPCs:

Hub VPC — central transit point for all routing, internet egress, and future centralized services (firewall, SIEM, AD)
Novastream VPC — simulated client environment (private workloads only, no public IPs)
Healthcare VPC — second simulated client, isolated at the network layer to support a HIPAA-style compliance posture

Spokes connect to the hub through an AWS Transit Gateway. Route tables permit spoke-to-hub traffic only — there is no spoke-to-spoke path, which limits lateral movement if one client is compromised.
<img width="1008" height="688" alt="image" src="https://github.com/user-attachments/assets/be20f2f2-2d68-4b10-ab18-933fa352c090" />

Components
ComponentPurposeVPCsThree isolated networks (Hub, Novastream, Healthcare)Transit GatewayLayer-3 routing between hub and spokes; spoke isolation enforced via route tablesInternet Gateway + NAT GatewaySingle shared NAT in the hub provides outbound-only internet access for client EC2 instancesEC2 instancesWorkloads in each client VPC, private IPs onlyAWS Systems Manager Session ManagerReplaces the original SSH bastion. No inbound ports, no SSH key management, IAM-based access control, sessions logged via CloudTrailSecurity GroupsLeast-privilege rules; outbound limited to HTTPS, HTTP, SMTP, and DNSCloudWatch alarmsCPU utilization (>80% for 10 min) and instance status checks on each client, with SNS email notificationsVPC Flow LogsCapture IP traffic across all interfaces for monitoring and troubleshootingIAMRoles and policies supporting Session Manager, CloudWatch, and flow logs
Why Session Manager instead of a Bastion Host
The original design used an SSH bastion. During week 12, I realized I had copied a private key onto the bastion to work around an SSH agent forwarding issue — a vulnerability, since a compromise of the bastion would expose every instance behind it. Session Manager removes that risk entirely:

No inbound ports open to the internet
No SSH keys to manage, rotate, or harden
Access granted and revoked through IAM
Session activity logged to CloudTrail and optionally S3

Repository Structure
.
├── modules/             # Reusable Terraform modules (VPC, EC2, security groups, etc.)
├── hub/                 # Hub VPC configuration
├── novastream/          # Novastream client VPC
├── healthcare/          # Healthcare client VPC
├── monitoring/          # CloudWatch alarms, SNS topics, flow logs
├── tests/               # Bash/nmap segmentation tests
└── docs/                # Diagrams and supporting documentation

Adjust the tree above to match your actual layout.

Prerequisites

Terraform ≥ 1.5
AWS CLI configured with credentials (aws configure)
An AWS account with permissions to create VPC, EC2, Transit Gateway, IAM, CloudWatch, and SNS resources
A verified email address for SNS alarm notifications

Deployment
bash# Clone the repo
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply
To tear the environment down:
bashterraform destroy
Testing
Network segmentation is validated with a bash script using nmap. Results are interpreted as:

filtered → PASS (firewall blocking traffic, no response)
closed → REVIEW (host reachable but service not running)
open → FAIL (segmentation gap)

Additional tests performed:

curl against external endpoints to confirm outbound access through the NAT Gateway
Linux stress-ng to drive CPU utilization above 80% and verify the CloudWatch alarm and SNS email fire correctly
VPC Flow Logs reviewed in CloudWatch Logs to confirm accept/reject behavior matches security group rules


Note: the EC2 status-check alarm enters an INSUFFICIENT_DATA state when an instance is stopped (no metrics are emitted). To exercise that alarm in a future iteration, AWS Fault Injection Service is the right tool.

Future Work

Deploy a centralized firewall appliance in the hub's reserved private subnet
Add a SIEM (e.g., a Wazuh or Security Onion stack) for log aggregation
Stand up Active Directory domain controllers in the hub
Add applications and additional simulated clients
Build the environment out into a full SOC lab

Author
Jonathan Wcislo — Champlain College, 2026
References
Selected references that informed the design — full citation list in the project report:

AWS Well-Architected Framework, REL02-BP04: Prefer hub-and-spoke topologies over many-to-many mesh
AWS, Systems Manager Session Manager
AWS, VPC Flow Logs
NIST SP 800-215, Guide to a Secure Enterprise Network Landscape
NCSC, Preventing Lateral Movement

 <h1>Secure MSP Infrastructure with Terraform and AWS</h1>
A Terraform project that builds a secure, multi-tenant Managed Service Provider (MSP) environment in AWS using a hub-and-spoke network topology. The infrastructure simulates the model that providers like Rackspace use to host multiple isolated client environments behind centralized routing, monitoring, and security controls.
Built as a senior seminar project at Champlain College.

<h1>Overview</h1>

The project deploys 44 Terraform-managed resources across three VPCs:

Hub VPC — central transit point for all routing, internet egress, and future centralized services (firewall, SIEM, AD)
Novastream VPC — simulated client environment (private workloads only, no public IPs)
Healthcare VPC — second simulated client, isolated at the network layer to support a HIPAA-style compliance posture

Spokes connect to the hub through an AWS Transit Gateway. Route tables permit spoke-to-hub traffic only — there is no spoke-to-spoke path, which limits lateral movement if one client is compromised.

<h1>Architecture </h1> 

<img width="1008" height="688" alt="image" src="https://github.com/user-attachments/assets/be20f2f2-2d68-4b10-ab18-933fa352c090" />

  ## Components

**Networking**
- Three VPCs (Hub, Novastream, Healthcare) for tenant isolation
- Transit Gateway for layer-3 routing between hub and spokes
- Internet Gateway and a single shared NAT Gateway in the hub for outbound-only client access
- VPC Flow Logs capturing all interface traffic

**Access & Identity**
- AWS Systems Manager Session Manager replaces the SSH bastion — no inbound ports, no SSH keys
- IAM roles and policies supporting Session Manager, CloudWatch, and flow logs
- Security Groups enforcing least privilege (outbound limited to HTTPS, HTTP, SMTP, DNS)

**Compute**
- EC2 instances in each client VPC, private IPs only

**Monitoring & Alerting**
- CloudWatch alarms for CPU utilization (>80% for 10 min) and EC2 status checks
- SNS topics delivering email notifications when alarms trigger



<h1>Why Session Manager instead of a Bastion Host </h1>
The original design used an SSH bastion. During week 12, I realized I had copied a private key onto the bastion to work around an SSH agent forwarding issue — a vulnerability, since a compromise of the bastion would expose every instance behind it. Session Manager removes that risk entirely:

No inbound ports open to the internet
No SSH keys to manage, rotate, or harden
Access granted and revoked through IAM
Session activity logged to CloudTrail and optionally S3

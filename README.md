 <h1>Secure MSP Infrastructure with Terraform and AWS</h1>
A Terraform project that builds a secure, multi-tenant Managed Service Provider (MSP) environment in AWS using a hub-and-spoke network topology. The infrastructure simulates the model that providers like Rackspace use to host multiple isolated client environments behind centralized routing, monitoring, and security controls.
Built as a senior seminar project at Champlain College.
Overview
The project deploys 44 Terraform-managed resources across three VPCs:

Hub VPC — central transit point for all routing, internet egress, and future centralized services (firewall, SIEM, AD)
Novastream VPC — simulated client environment (private workloads only, no public IPs)
Healthcare VPC — second simulated client, isolated at the network layer to support a HIPAA-style compliance posture

Spokes connect to the hub through an AWS Transit Gateway. Route tables permit spoke-to-hub traffic only — there is no spoke-to-spoke path, which limits lateral movement if one client is compromised.

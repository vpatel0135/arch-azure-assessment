# Assumptions and design decisions

| Area | Decision and reason |
| --- | --- |
| Scope and sizing | One new resource group in the supplied subscription; `eastus2` by default. Linux P1v3 supports private endpoints and VNet integration. Storage uses Standard LRS; application code, real secrets and employee sign-in are outside scope. Confirm regional .NET 10 availability before deployment. |
| Network | A configurable, non-overlapping /16 supplies separate /24 integration and endpoint subnets (`10.42.1.0/24` and `10.42.2.0/24` by default). App Service requires a delegated integration subnet. |
| Employee access | Corporate VPN/ExpressRoute or peering and DNS forwarding already provide private routes and name resolution. These enterprise connections are not created here. |
| Identity | One user-assigned identity is attached to the Web App and reused for Vault, Blob and telemetry. The application uses managed-identity SDK authentication with the supplied client ID and service URLs. Target services authorize that identity through scoped RBAC; no account keys or passwords are supplied. |
| Monitoring | Dedicated VNet/DNS scope. Application telemetry uses private, Entra-authenticated Insights ingestion. Resource diagnostics go directly to its backing workspace, as requested in Section 7, through Azure's private diagnostic channel. Integrating shared enterprise monitoring DNS would require review. |
| Groups and PIM | The two security groups and PIM licensing already exist. Writers have 90-day eligibility with MFA, justification and four-hour maximum activation. Approval was not specified. A fixed start timestamp prevents eligibility changing on every run; renewal after expiry is deliberate. |
| Naming and tags | Resource names use abbreviation, environment and workload; globally unique names add a stable hash and Azure-specific shortening. Descriptive child names identify subnets/container. Standard tags identify environment, application, owner, cost center and Terraform management. |
| Retention | Logs are retained for 30 days. Key Vault uses 90-day soft deletion and purge protection for recovery; immediate purge/name reuse is unavailable. |
| Deployment and state | Resource providers are registered externally; the deployer has resource creation and RBAC/PIM administration permissions. ARM-based Storage/container provisioning avoids private data-plane access from the runner. Local state is used for the exercise; production would use secured remote state. Actual inputs, plans and state stay outside Git. |



Criteria for a full mark:
1) Proposes a pragmatic, highly realistic 6-month phased approach and a scalable
18-month vision. Explicitly addresses critical business constraints, including the
requirement for zero-downtime gradual migration and the ability to handle 8–10x
seasonal traffic spikes.
2) Defines a robust, centralised API governance framework that ensures consistency,
security, and compatibility for external partners. Directly proposes mechanisms to
prevent the recurrence of exposed internal admin endpoints and addresses the need
for standardised base image policies and vulnerability scanning.
3) Provides a strongly justified recommendation for an integration platform. Details a
safe, systematic migration strategy to transition away from the current mix of REST
APIs, batch jobs, and direct database calls. Clearly accounts for managing the sprawl
of existing point-to-point integrations.
4) Identifies specific, measurable KPIs covering all required areas: reliability, security,
deployment speed, integration success rate, and recovery readiness. Directly aligns
proposed tracking with the organization's SLA targets, such as achieving < 1 hour
MTTR and 99.9% uptime for Order APIs.
5) Submissions must demonstrate a deep understanding of distributed systems and
organisational constraints. The student must recognise that they cannot simply "rip
and replace" the architecture; they must show how to transition the legacy monolith
and regional sync processes into modern orchestration while keeping systems live.
6) Students will be rewarded for addressing the operations team's need for multi-region
deployment patterns and centralised monitoring, while respecting leadership's valid
concern regarding "Kubernetes complexity".
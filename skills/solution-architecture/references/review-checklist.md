# Architecture review checklist

Load for an architecture review or print-ready done check.

## Review sequence (lightweight)

1. Restate business outcome and top quality attributes.
2. Confirm scope, assumptions, constraints, and data sensitivity.
3. Walk the system context diagram.
4. Walk one successful end-to-end workflow.
5. Walk at least three high-impact failure or misuse scenarios (Large).
6. Present highest inherent and residual risks.
7. Review disputed decisions and realistic alternatives.
8. Assign mitigation actions, evidence, owners, and due dates.
9. Record accepted residual risk and decision authority.
10. Update diagrams, ADRs, tests, and operating docs in the same change set when possible.

Keep the review blame-free. Goal: expose assumptions and improvement actions.

## Done checklist

| Check | Pass criteria | Done |
|-------|---------------|------|
| Outcome | Outcome, scope, quality priorities, constraints, assumptions stated | [ ] |
| Diagram headers | Each diagram has purpose, audience, owner, status, date | [ ] |
| Boundaries | System, ownership, identity, trust, and (Large) network/env boundaries clear | [ ] |
| Responsibilities | Each major box has one responsibility and owner | [ ] |
| Data / identity | Sensitive data paths and authz points understood | [ ] |
| Failure | Critical dependencies, fallbacks, safe-failure covered | [ ] |
| ADRs | Major choices have alternatives, trade-offs, consequences | [ ] |
| Risks | Top risks have prevent/detect/respond + owners | [ ] |
| Operations | Monitoring, rollback, support ownership defined for stage | [ ] |
| Residual risk | Accepted residual risks and follow-ups recorded | [ ] |

## 30-minute starter session

1. Outcome statement + top three quality attributes.
2. Context view (users, boundary, externals, trust).
3. Logical layers with one responsibility/owner each.
4. One success path + one failure scenario.
5. Highest-risk decision as an ADR + top five risks.
6. Schedule review; assign owners to open questions.

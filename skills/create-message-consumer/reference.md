# create-message-consumer - reference

Stack detection, requirements checklist, and scaffold notes for `skills/create-message-consumer/SKILL.md`. Keep `SKILL.md` under 500 lines; use this file for extended detail.

**Scaffold:** this file does not contain copy-paste consumer code. Generated code must follow patterns already present in the **target repository**.

---

## Stack detection (Grep / Glob)

Run from the target repository root. Exclude `bin/`, `obj/`, `node_modules/`.

| Signal | Grep / Glob | Notes |
|--------|-------------|-------|
| MassTransit | `MassTransit`, `AddMassTransit`, `IConsumer<`, `ConsumerDefinition` | Transport may be RabbitMQ, Azure Service Bus, Amazon SQS, in-memory - read config |
| RabbitMQ (direct) | `RabbitMQ.Client`, `ConnectionFactory`, `IAsyncBasicConsumer` | May coexist without MassTransit |
| Azure Service Bus | `Azure.Messaging.ServiceBus`, `ServiceBusClient` | One option among many - not default |
| AWS | `Amazon.SQS`, `IAmazonSQS` | Generic handling |
| Kafka | `Confluent.Kafka`, `IConsumer<` (check namespace) | Distinguish from MassTransit `IConsumer` |
| Hosted generic | `BackgroundService` + `ReadOnlyMemory<byte>` or channel | Document as custom |

**Config files:** also Glob `appsettings*.json`, `**/MassTransit*` registration, `Program.cs` / `Startup.cs` for `AddMassTransit` or bus connection strings (describe generically in summary - do not echo secrets).

**Output to user:** one-line stack verdict + 1-3 example file paths of existing consumers.

---

## Requirements checklist

Collect before proposing files. Copy into chat and fill with user answers.

```markdown
## Message consumer requirements

| Item | Answer |
|------|--------|
| **Queue / topic** | |
| **Subscription** (if any) | |
| **Message contract** | Type name, namespace, schema owner |
| **Trigger / event** | What published the message |
| **Processing** | Side effects (DB, API, cache, downstream publish) |
| **Idempotency** | Key / store / "not required" + justification |
| **Retry** | Count, backoff, where configured |
| **DLQ / error queue** | Name or broker behavior |
| **Ordering** | Required? partition key? |
| **Failure visibility** | Logs, metrics, alerts (repo conventions) |
| **Tests** | Unit only / integration with test container / manual |
```

### Idempotency prompts

If not stated, ask:

- Can the same message be delivered twice?
- Is there a natural business key to deduplicate?
- Does the repo use outbox/inbox tables?

### Retry / DLQ prompts

- What happens after max retries?
- Is there a dead-letter queue or MassTransit `_error` / `_skipped`?
- Should failures be logged and skipped or block the pipeline?

---

## Scaffold checklist (implementation)

Use after user confirms the plan. Check off in session notes; not all rows apply to every stack.

| Area | Verify |
|------|--------|
| **Contract** | Message DTO/event in correct layer (often Application contracts or shared messaging project) |
| **Consumer** | Handler class or `IConsumer<T>` with single responsibility |
| **Registration** | Bus/consumer registered in DI (`Program.cs`, `DependencyInjection`, `MassTransit` config) |
| **Configuration** | Queue/topic name from named constants - see `csharp-patterns.md` § **Named constants (no magic literals)** |
| **Errors** | Retry policy matches checklist; poison path documented |
| **Idempotency** | Dedup or idempotent handler per checklist |
| **Logging** | Structured log on start, success, failure (correlation id if repo uses it) |
| **Tests** | Meaningful behavior test per `csharp-patterns.md`; integration if repo already has harness |
| **Build** | `dotnet build` + filtered `dotnet test` pass |

---

## Layering (when generating .NET code)

Load `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` before writing code.

Typical placement (adapt to repo):

| Piece | Layer |
|-------|--------|
| Message contract | Application.Contracts / Domain events / shared Messages project |
| Consumer / handler | Infrastructure or Application (match existing consumers) |
| Business logic | Application handler or domain service invoked by consumer |
| Persistence | Infrastructure |

Do not introduce new projects or folders without user confirmation.

---

## Test guidance

| Level | When |
|-------|------|
| Unit | Handler logic with mocked dependencies - default |
| Integration | Repo already runs Testcontainers, in-memory bus, or shared `WebApplicationFactory` |

Test names: `Should_<Result>_When_<Condition>` per team csharp-patterns.

Avoid tests that only assert the consumer class exists.

---

## Explicit exclusions

Do **not** require or generate by default:

- Organization-specific Service Bus namespace or connection templates
- Proprietary package names from a former monorepo
- Mandatory Datadog/Sonar/DeskCheck tasks
- Python or REST scripts to create remote work items

If the target repo has no messaging libraries, stop after step 1 and recommend:

1. Team chooses broker and NuGet packages
2. First consumer added manually or via `developer` with architectural approval

---

## Relationship to other skills

| Skill | Use |
|-------|-----|
| `developer` | Small consumer in a repo already standardized |
| `sdd-develop` | PLAN step that includes consumer + tests + PLAN checkbox |
| `fix-build` | Compile or test failures after scaffold |
| `add-migrations` | Consumer persists new entities - migration in separate step |

---

## Context management

Per `~/.cursor/rules/context-management.mdc`: after detection + requirements + large scaffold, checkpoint at ≥ 40% context; hand off with paths and pending checklist items.

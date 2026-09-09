# Interfaces, payload contracts, and Quarry

Capstone writes documentation inside each source repository. Quarry imports committed references into a shared Git repository and a local index. The useful handoff is back into development: Capstone reads other services' documented expectations through Quarry, writes those constraints into a feature spec and its tasks, implements the approved change, and refreshes the source reference. A later Quarry import makes that new reference available to the next change.

## What belongs in interfaces

`09-interfaces.md` describes communication with sibling codebases: produced APIs, queue messages, events, shared schemas, and consumed sibling services. Internal calls stay in architecture/data-flow; third-party vendors such as payment or object-storage providers belong in `05-dependencies.md`. A standalone project whose only external communication is with vendors normally has no interfaces chapter.

The chapter's canonical declaration is the frontmatter `edges:` block. Example, omitting ordinary stamp fields for brevity:

```yaml
known_as: [ingest.internal]
edges:
  produces:
    - kind: sqs
      name: file-ingest
      site: src/publish.rs
      schema: FileIngestMessage
  consumes:
    - kind: http
      name: GET /users/{id}
      site: src/auth.rs
      schema: UserRef
      from: identity-api
```

This is an illustrative declaration, not real product output. The `from` value represents a previously confirmed decision.

| Field | Meaning |
| --- | --- |
| `kind` | Required, lowercase, free-form transport/category such as `http` or `sqs` |
| `name` | Required contract name as code spells it, such as a method/route or topic |
| `site` | The producing/consuming source file, repository-relative, with no line number |
| `schema` | Optional entity/DTO heading from the same docs area's `02-models.md`; `Entity[]` denotes a list |
| `to` | Optional consuming repo name or list of names; confirmed by a person |
| `from` | Optional producing repo name; confirmed by a person |
| `known_as` | Chapter-level YAML list of deployment aliases; `[]` records no discovered aliases |

Map derives kind/name/site/schema from code and preserves existing confirmed far ends while the same `(direction, kind, name)` row still exists. It removes and reports rows the code no longer contains. A rename can therefore be a removed old row plus a new row; previous far-end answers do not automatically transfer to a different name.

Produces and Consumes tables render the block for humans. Their columns are `Kind | Name | To | Site` and `Kind | Name | From | Site`. `interfaces_frontmatter: true` adds older top-level produces/consumes lists; it is unnecessary for current Quarry's canonical block support.

## Payload sections must contain usable fields

Each contract has a `### <Name>` section under its direction. Named payloads point to an entity in the same repository's models chapter:

```markdown
### file-ingest

Model: FileIngestMessage
```

The models chapter must then have `### FileIngestMessage` under Fields and types with a `Field | Type | Required` table. Alternatively, an ad-hoc payload is inline:

```markdown
### file-ingest

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| file_id | string | yes | UUID |
| content_type | enum | yes | accepted: application/json, application/xml |
```

A producer documents what it emits from its serializer/type. A consumer documents the fields it actually reads or the local type it deserializes into. For a subset of a larger object, an inline consumed-field table is more accurate than copying every field from a broad model. Do not replace these with a link to a schema file in another repository: the comparison needs fields locally.

Names are keys: contract headings use the row's Name verbatim, without backticks; a version suffix such as `(v2)` is supported. A missing payload section, an empty one, or a model reference that resolves nowhere prevents a useful comparison. `map check` reports those schema gaps.

## Connect the references

Install and configure Quarry separately using its source-based installation instructions. Do not assume a prebuilt GitHub Release installer is available: the research check found none. See [Quarry's inspected source](https://github.com/GentBajko/quarry/tree/78c71fab5f5818662dc02d5867246cec963567a9) for the companion tool. In each source repository, first map, review, commit, and merge the reference to its default branch. Then run:

```sh
quarry init --url <docs-repo-url>
quarry add
```

The URL names your shared docs Git repository. This is setup, not an automatic discovery of every repository you can access. After later reference changes reach the source default branch:

```sh
quarry update
```

Before an investigation that needs newer imported docs:

```sh
quarry sync
quarry docs deps ingest-api --downstream --depth 2
quarry docs section record-store "file-ingest (v2)"
```

`ingest-api` and `record-store` are illustrative names; substitute registered repos or workspace targets. Query results normally reflect the last-synced reference, not a live read of every source repository.

## When Capstone consults Quarry

| Stage | Condition and use |
| --- | --- |
| `groom` | `cross_repo: "auto"`, Quarry on PATH, interfaces chapter present; query downstream deps and consumer sections before feature questions |
| `plan` | Same conditions; look up affected contracts before task creation and copy constraints into relevant tasks |
| `architecture` | Auto and CLI available; no existing interfaces chapter required; search/read contracts for systems mentioned during design |
| `map` interfaces pass | Auto and CLI available; read index ambiguity and registration data while writing the chapter |

These integrations are protocol instructions, not Claude-only hooks. Missing prerequisites skip the relevant lookup. Configuring the CLI remains necessary for useful results; merely installing its executable does not populate a shared index.

Quarry can join undeclared far ends by matching published and consumed `(kind, name)` rows. Ambiguous matches are presented for your decision. The answer can be a name, several produced-consumer names, `unknown`, or `skip`. `unknown` is a deliberate answer that disables joining for that row; `skip` leaves it unanswered and eligible to be raised later. A by-name suggestion is only a lead, and a missing section for such a suggestion is not evidence of a broken declared contract.

## What contract checks establish

`quarry check` compares a producer's working-tree payload documentation with known consumers' last-synced documented fields. Missing produced fields or type changes are breaks; required/optional changes are warnings. Type text is normalized by trimming, case-folding, and collapsing whitespace; this is not a programming-language type assignability check. Model sections with both a table and a Model line use the table and report the ambiguity. Notes such as accepted enum values are useful reading material but are not automatically understood as semantic compatibility constraints. A CSV format absent from Notes is something to bring into a plan, not a guaranteed automated break finding.

Use the checks together: map check helps detect stale/malformed reference; Quarry check compares documented contracts. Neither proves actual network traffic, complete consumer registration, or runtime compatibility. A source change that never reaches the docs can evade a documentation-only compatibility comparison.

Sources: [interfaces format and payload rules](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/topics.md#interfacesmd), [groom integration](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/groom.md), [plan integration](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/plan.md), [confirmed-edge rules](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core.md#edge-confirmation-answer-what-the-registry-cannot-join).

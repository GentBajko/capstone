# edges - fill the consumer side of cross-repo edges from a folder of clones

**Reads:** config → each clone in the folder: its origin URL and HEAD
commit, its project config, its `<index_file>`, and the frontmatter of
its `09-interfaces.md` (`known_as` and the `edges:` block) → for each
consumes row, open or answered, the file at its `site` and the config
and deploy files that feed the address it calls, in that clone and in
the others → `git grep` across the clones: once per contract an
unread clone might produce (step 4), once per address that named a
unit (step 6).

`map` reads one repo, and one repo never holds another repo's name: a
consumer's code holds an address, a producer's code holds nothing
about its callers (core.md hard rule 3). So every consumes row `map`
writes has no `from`, and quarry or a person supplies it later. With
every repo of a system cloned into one folder the answer is on disk:
some other clone answers to the address the consumer calls. `edges`
reads the folder once and writes that repo's name into each empty
`from`.

Run it from the folder that holds the clones, or name that folder as
the argument, after `map` has run in each repo. It asks nothing, so
it runs the same under `non_interactive`, and it is the one run hard
rule 3 lets derive a far end.

Four bounds, each closing a way to leave a wrong edge behind:

- **A consumer's `from`, never a producer's `to`.** Quarry builds a
  producer's edges from the consumers that name it, so `from` alone
  gives the whole graph. A written `to` takes the row out of quarry's
  name join: a consumer that appears later, in a repo this folder
  never held, would find no producer and raise no warning, and a
  consumer that stops calling would stay listed for good.
- **Empty cells only.** A `from` the block already carries is an
  answer, from a person, a confirmation or an earlier run. It is
  compared and reported, never changed (hard rule 3).
- **One candidate, or nothing.** A row is written only when the
  evidence leaves exactly one repo. Several candidates or none leave
  the cell empty and the row in the report. Never `unknown`: that is
  a person's ruling that no sibling repo sits on the other side
  (core.md's Edge confirmation), and a repo cloned tomorrow may be
  the one.
- **Docs areas only, working tree only.** Each repo's own
  `<docs_dir>` per hard rule 2, and in it one edit to
  `09-interfaces.md` plus one ledger fragment: no initializer run, no
  `.gitignore`, no index row. No source file, no stamp, no commit,
  no branch, no push.

The docs areas are single-writer (core.md's Changelog ledger): if a
capstone run may be live in any of the clones, say so and stop before
writing. Uncommitted docs and unfolded fragments an earlier run left
behind are not a live run.

## Procedure

1. **Config.** Per core.md: the global file governs the conversation.
   The folder has no project config and never gets one; each clone's
   own `docs/capstone/capstone.json` governs that clone's docs area
   in the steps below.

2. **Find the units.** A unit is one docs area plus the one name
   other repos know it by. Every immediate subfolder that is the root
   of a git work tree is a clone, taken in the order `LC_ALL=C sort`
   gives their folder names; when the folder holds none and is itself
   a work tree with `workspaces` configured, its workspaces are the
   units. Per clone, read:
   - **the name**: the last path segment of
     `git -C <clone> remote get-url origin`, without `.git`. Never
     the folder's name: `git clone .../tariff-service.git tariffs`
     is still `tariff-service`.
   - **the commit**: `git -C <clone> rev-parse HEAD`.
   - **the docs area**: `docs_dir`, `index_file` and `interfaces`
     from the clone's project config, then the global file, then the
     defaults. With `workspaces` in the project config the clone is
     one unit per workspace instead: named by the workspace, its docs
     area fixed at `<path>/docs/capstone/` and its index at
     `<path>/docs/capstone/00-index.md` (core.md's naming contract).

   Four kinds of clone are reported and never written as a far end:
   - **no origin**: it has no name. Its own rows are still read and
     filled; a row elsewhere that it alone would answer stays open,
     and the report says the clone needs an origin.
   - **a name an earlier clone already carries** (one repo cloned
     twice): skipped whole, step 6's sweep included.
   - **no `<index_file>`**: never mapped. Name it with
     `run /capstone:map there` and move on. `edges` never runs `map`
     (core.md's Missing reference exempts it): a build in every
     unmapped clone is not what was asked for.
   - **`interfaces: "off"`**: the chapter is not capstone's to write
     there.

   The last two are **unread clones**: their files are still
   evidence in step 4, and what they produce is unknown. A mapped
   unit with no `09-interfaces.md` has no rows to fill: `map` found
   no cross-repo talk in it. It can still be a far end. A chapter
   with no `edges:` block was written by an older capstone: its rows
   are read in the order `../topics.md` gives, nothing is written
   there, and the report names it for `/capstone:map interfaces`.
   Fewer than two units: say so and stop.

3. **Collect what each unit declares.** From the chapter's
   frontmatter: `known_as`, the produces rows, the consumes rows.
   Three tables come out of it:
   - **names**: each unit's name and every `known_as` entry, compared
     case-insensitively. An alias two units both list names both, and
     so settles nothing.
   - **producers**: for each contract, the units with a produces row
     on it. Two rows are one contract when quarry's join would pair
     them: their `kind` is equal, and their `name` is equal as
     written, except in the routed kinds (`http`, `ws`, `wss`,
     `grpc`). There a leading method word is compared
     case-insensitively, and a path with every parameter segment
     counted equal however it is spelled (`:id`, `{tariffId}`,
     `<id>`) and its trailing slash, query string and fragment
     dropped. Nothing else is folded: `pkg.Users/GetUser` and
     `pkg.Users/getuser` are two contracts.
   - **open rows**: every consumes row with no `from`. The rest are
     answered rows.

4. **Resolve each open row.** The second step runs only when the
   first finds no address at all:
   1. **The address in the code.** Open the file at the row's `site`
      and find what that call is addressed to: a host, a base URL, a
      service name. Where the code reads it from a variable or a
      config key, follow the key to its value: a default in the code,
      `.env.example`, a compose file, Helm values or a manifest in
      the consumer's clone, then the deploy config in the other
      clones (an infra repo's values for this service). An unread
      clone is still evidence here. The address names a unit when its
      host or service name is that unit's name or one of its
      `known_as` entries, the consumer's own unit aside. Two things
      are not the address of a far end:
      - **transport**: a broker, a bus, a queue endpoint or a
        database host is what both ends share. A row whose code holds
        only that has no address.
      - **a unit that only passes the call on**: where the named
        unit's own config routes this path to another unit (a
        gateway, a proxy), follow the route; the unit it leads to is
        the address.
   2. **The only producer.** No address to find (a queue or a topic
      carries none, a schema package neither), or a key that leads to
      no value anywhere in the folder: take the units that produce
      the row's contract, the consumer's own aside. An unread clone
      may produce it unseen, so search each one for the contract,
      `git -C <clone> grep -l -F -- '<name>'` with a route searched
      by its path up to the first parameter: a hit makes that clone
      a candidate too.

   What the evidence leaves decides the row:

   | Evidence | Outcome |
   |---|---|
   | The address names one unit, and it produces the contract | Write that unit |
   | The address names one unit that produces no such contract, and no other unit does | Write that unit; report the row `map` missed there |
   | The address names one unit that produces no such contract, and another unit does | Leave it open; report both |
   | The address names several units | Leave it open; report them |
   | The address names no unit | Leave it open; report the address. The only-producer step does not apply: the code already says the call goes somewhere this folder does not hold |
   | No address, one candidate, a unit with a name | Write that unit |
   | No address, one candidate, an unread clone or a unit with no name | Leave it open; report the clone and what it lacks |
   | No address, several candidates | Leave it open; report them |
   | No address, no candidate | Leave it open: the far end is not in this folder, or its chapter is stale |

5. **Compare the answered rows; change none.** Resolve each consumes
   row that already carries a `from` the same way, and report it when
   the evidence disagrees: it names another unit, the named repo is
   in the folder and produces no such contract, or the row says
   `unknown` and a unit in the folder produces the contract. The user
   edits the cell or leaves it; no run does (hard rule 3).

6. **Sweep for callers no row covers.** For each address that named a
   unit in step 4 or step 5, run
   `git -C <clone> grep -l -F -- '<address>' -- . ':(exclude)<docs_dir>'`
   in every clone but the one it addresses and any skipped as a
   second copy. A file it lists is covered when steps 4 and 5 read
   it: a row's `site`, or a config file followed for one. Any other
   file is a lead, a call `map` may have missed. Report it with `run /capstone:map interfaces there`;
   never add the row.

7. **Record, then write**, one unit at a time, for each unit with a
   row step 4 settled. The unit's changelog entry goes to disk first
   (core.md's ledger: an entry is on disk before what it records), as
   the fragment
   `<docs_dir>/changelog.d/<YYYY-MM-DD>-edges-09-interfaces-<rev>.md`,
   in a `changelog.d/` created where the docs area has none:

       ## <date> - edges: 09-interfaces.md
       key: edges/09-interfaces.md@<rev>

   `<rev>` is the moment the run began, `date -u +%Y%m%dT%H%M%SZ`,
   taken once and used in every unit. No one repo's commit describes
   a run over many, and a repo's commit stands still while `map`
   adds rows beside it, so a commit in the key would make a second
   run's entry look already written. Bullets only: one per row
   written, naming the row, the repo, and the evidence as paths
   (`src/TariffClient.kt` calls `tariffs.voltavia.internal`, which
   tariff-service lists in `known_as`; or: the only repo in the
   folder producing it); one per row left open, with its reason; one
   listing the clones found, each with its short commit. A value
   `redact` covers is never quoted: name the variable and the file.
   `edges` folds nothing; the next `map`, `implement` wrap or
   `doctor` repair on the default branch does. A unit where nothing
   is written gets no entry. A run that died midway is run again:
   what it wrote is answered by then and is not written twice.

   Then edit `09-interfaces.md`:
   - in the `edges:` block, add `from: <name>` to the row; the same
     on the legacy top-level `consumes:` list when the page carries
     one (`interfaces_frontmatter`).
   - in the `## Consumes` table, set that row's `From` cell to the
     name, written the way the table's other far ends are: bare, or
     as the relative link `../topics.md` allows when the page links
     the others.

   `<name>` is the unit's name from step 2, never the alias the code
   used. Everything else stays byte for byte: the other rows, every
   `to`, `known_as`, the payload sections, and the stamps, which
   record the `map` run that derived the chapter from the code. This
   run derived nothing.

8. **Report**, once for the folder, in conversation, in this order:
   the rows written (repo, row, far end, evidence); the rows left
   open, each with its reason and any candidates; the answered rows
   the evidence disagrees with; the leads from the sweep; the clones
   skipped or unread, and why; then the files changed, one path per repo, with
   the reminder that nothing was committed and that quarry sees a
   repo's edges only once its docs reach the docs repo. Vocabulary
   follows `expertise` like any other turn. A run that wrote nothing
   says so.

**Consumer:** quarry reads each written `from` as a declared edge and
pairs it with the producer's open row. `map` keeps it on every later
run (`../topics.md`'s merge rule) and drops it with the row when the
code stops making the call.

# General Coding Rules

These rules apply to software-development work across languages and projects unless a repository-specific instruction provides more specific guidance.

## Repository inspection

Before proposing or making a nontrivial change:

* inspect the relevant file or smallest relevant set of files;
* search for existing definitions, call sites, tests, and established patterns;
* check repository-local instruction files;
* inspect nearby code before introducing a new naming or architecture pattern;
* inspect dependency versions and enabled features when API behavior may vary;
* inspect target-specific or feature-gated code when relevant;
* inspect repository status before editing so existing user changes are not mistaken for task changes.

Do not ask for files or information already available in the repository or current context.

Ask for additional context only when the available project information is insufficient to proceed safely.

Prefer focused searches over broad repository dumps. Do not load large unrelated directory trees into context.

## Worktree and version-control safety

* Treat existing modified, staged, and untracked files as user-owned work.
* Preserve unrelated changes.
* Do not overwrite or revert user changes merely to simplify the task.
* When task changes overlap existing modifications, inspect the overlap and preserve both intentions where possible.
* Do not run `git reset --hard`, destructive checkout commands, broad clean commands, or equivalent operations unless explicitly requested.
* Do not delete untracked files merely because they are not part of the repository.
* Do not create commits, amend commits, rewrite history, switch branches, merge, rebase, push, or force-push unless explicitly requested.
* Do not use `git stash` automatically to obtain a clean worktree.
* Use `git diff` and `git status` to distinguish task changes from pre-existing work.
* Report unrelated pre-existing changes separately when they affect verification or review.
* Preserve submodule state unless the task explicitly concerns submodules.

## Editing rules

* Preserve existing formatting, naming, module structure, and local style unless there is a clear reason to improve them.
* Reuse existing types, helpers, components, patterns, and dependencies before introducing parallel implementations.
* Avoid unnecessary dependencies.
* Prefer small, reviewable changes.
* Keep public APIs stable unless the requested change requires otherwise.
* Do not widen visibility merely to make a change easier.
* Do not remove comments unless they are incorrect, obsolete, misleading, or made unnecessary by the change.
* Do not rename large numbers of symbols unless explicitly requested or necessary for correctness.
* Separate mechanical movement from behavioral changes when refactoring.
* Do not combine unrelated cleanup with the requested work.
* Remove obsolete code made unnecessary by the completed change.
* Do not leave commented-out replacements, temporary debugging output, or abandoned code paths.
* Preserve generated, vendored, external, and submodule code unless the task explicitly requires modifying it.
* Prefer patch-oriented edits over replacing entire files when only a small section needs to change.
* Preserve file permissions, line endings, and executable status unless changing them is intentional.
* Re-read affected sections after editing to catch malformed structure, duplicated content, or misplaced code.
* Format only files affected by the task unless the repository formatter necessarily operates more broadly.

## Refactoring rules

* Refactor only when it directly supports the requested change or resolves a concrete existing problem.
* Preserve behavior unless the requested task explicitly changes behavior.
* Identify ownership and responsibility boundaries before extracting code.
* Avoid introducing abstractions with only one hypothetical future use.
* Do not split cohesive code solely to reduce line count.
* Avoid thin wrappers that add no semantic, behavioral, ownership, or reuse value.
* Prefer extracting a cohesive responsibility over distributing related logic across arbitrary helper files.
* Keep behavior changes separate from structural changes when practical.
* Verify imports, visibility, module declarations, call sites, and tests after moving code.
* Remove obsolete imports and declarations after extraction.
* Keep structural changes understandable and reviewable.
* Avoid creating many tiny files that make navigation harder without establishing meaningful ownership boundaries.

## Debugging rules

* Start with the smallest likely cause supported by the evidence.
* Reproduce the failure when practical before changing code.
* Read compiler errors, runtime errors, logs, configuration, and call sites before guessing.
* Trace the actual data or control flow involved in the failure.
* Distinguish the root cause from secondary symptoms.
* When multiple causes are plausible, rank them by likelihood and identify evidence that would distinguish them.
* Prefer direct diagnostic commands or temporary instrumentation over speculative rewrites.
* Do not recommend clearing caches, reinstalling dependencies, deleting lockfiles, or resetting state until evidence connects those actions to the failure.
* Explain why each suggested diagnostic step or fix is connected to the observed failure.
* Remove temporary diagnostic code after the issue is understood.
* Verify that the original failure no longer occurs after the fix.
* Do not treat disappearance of an error message as proof that underlying behavior is correct.
* When a tool or dependency version may be relevant, inspect the installed version rather than assuming it.

## Error handling

* Prefer explicit, recoverable error handling over silent failure.
* Do not add panic paths for recoverable failures without justification.
* Preserve useful error context across module boundaries.
* Preserve the original error source when wrapping errors.
* Avoid swallowing errors merely to make code compile.
* Do not replace meaningful failures with empty or default results unless that behavior is intentional.
* Keep user-facing errors clear and actionable.
* Keep technical diagnostics separate when exposing them directly would confuse users.
* Do not log the same failure repeatedly at multiple layers without adding useful context.
* Avoid retry loops without clear limits, backoff, and terminal error reporting.

## Dependencies and APIs

* Reuse existing dependencies when they adequately solve the problem.
* Do not add a dependency for behavior that is simple and clear with the standard library or current dependencies.
* Check the project's actual dependency version before recommending version-sensitive APIs.
* Inspect the current manifest and lockfile before changing dependencies.
* Review default features and target compatibility before adding or changing a dependency.
* Avoid enabling broad feature sets when a narrower set is sufficient.
* Do not assume an API exists because a similar library provides it.
* Prefer official documentation, source code, or compiler feedback when API behavior is uncertain.
* Do not update unrelated dependencies as a side effect of a narrow change.
* Explain meaningful dependency additions, feature changes, or version constraints.
* Consider maintenance status, licensing, platform support, transitive dependencies, compile time, bundle size, and runtime implications.

## Commands and safety

* Include exact commands when they materially help verify or complete the change.
* Prefer the narrowest relevant command before workspace-wide or destructive operations.
* Explain destructive, irreversible, or history-rewriting commands before suggesting them.
* State what files, branches, commits, data, or system state a destructive command affects.
* Prefer reversible commands when practical.
* Do not suggest force flags unless they are necessary.
* Do not assume the user needs `sudo`.
* Do not suggest deleting caches, lockfiles, build directories, generated state, or user data without a concrete reason.
* When commands are independent, execute them as separate tool calls.
* Do not combine routine inspection, formatting, build, lint, or test commands merely for convenience.
* Use `&&`, `||`, `;`, pipelines, redirects, command substitutions, or multiline shell commands only when their shell semantics are materially useful.
* Expect composed shell commands to require explicit approval.
* Avoid output-filtering pipelines when the command tool's built-in output limits are sufficient.
* Do not hide command failures with constructs such as `|| true` unless failure is explicitly expected and handled.
* Do not run commands with unresolved variables, broad globs, or ambiguous destructive targets.
* Prefer explicit working-directory options over unnecessary `cd ... &&` chains.
* Use non-interactive command options when available and appropriate.
* Apply reasonable timeouts to commands that may hang.
* Do not start persistent background services unless the task requires them.
* Stop temporary processes started solely for verification when they are no longer needed.

## Verification

After making changes:

* run the narrowest relevant formatting, build, lint, and test commands;
* account for the relevant package, feature flags, target, and runtime;
* verify changed behavior, not only compilation;
* test important edge cases;
* distinguish commands actually run from commands merely recommended;
* do not claim validation succeeded unless it was actually performed;
* report pre-existing failures separately from failures introduced by the change;
* run the repository's file-size validation command when one exists;
* treat a file-size validation failure as a task failure, not an informational warning;
* inspect the final diff for accidental, malformed, generated, or unrelated changes.

Prefer targeted verification first. Expand to broader checks when shared code, public APIs, workspace behavior, persistence formats, or platform-specific code are affected.

When verification cannot be performed, state exactly what was not run and why.

## Test integrity

* Do not weaken, delete, ignore, or broadly rewrite tests merely to make them pass.
* Do not change expected values unless the requested behavior or established specification requires it.
* Add or update tests when behavior changes and the repository has an applicable test structure.
* Prefer tests of externally meaningful behavior over tests tightly coupled to implementation details.
* Preserve existing regression coverage.
* Do not replace deterministic tests with timing-dependent delays when synchronization can be tested directly.
* Do not add unconditional skips, excessive retries, or broad exception handling to conceal failures.
* Distinguish failures caused by the current change from unrelated or pre-existing failures.
* When a test cannot run in the current environment, do not claim it passes.

## Completion reporting

When completing an implementation task:

* summarize what changed;
* identify important files and symbols changed;
* state significant assumptions;
* report validation actually performed;
* mention unresolved issues;
* distinguish partial implementation from completed work;
* distinguish pre-existing problems from regressions caused by the change;
* report the final line count of every modified ordinary source file containing more than 2000 lines;
* do not describe the task as complete when a modified source file violates the source-file size limit.

Keep completion reports focused on information useful for review.

Do not provide a lengthy diary of routine searches and commands. Report evidence, results, and remaining risks.

## Source file size limits

These are acceptance requirements, not suggestions.

* No new or modified ordinary hand-written source file may exceed **3000 lines**.
* Keep new source files below **2000 lines** whenever practical.
* When a planned change would push a file beyond **2500 lines**, inspect it for a cohesive extraction boundary before adding more code.
* Before modifying a large file, check its current line count.
* After modifying files, check their final line counts.
* If a modified file exceeds 3000 lines, the task is not complete until it is split into cohesive modules or the user explicitly approves an exception.
* Do not evade the limit by compressing formatting, combining statements, removing useful comments, or creating arbitrary fragments.
* Split by responsibility or ownership rather than making arbitrary cuts.
* Appropriate extraction boundaries include:
  * types;
  * parsing;
  * rendering;
  * geometry;
  * configuration;
  * CLI handling;
  * browser or UI components;
  * styling helpers;
  * tests or fixtures.
* Do not split cohesive code solely to satisfy a numerical limit.
* Do not create many tiny files without a meaningful responsibility boundary.
* Update imports, visibility, module declarations, tests, and call sites after extraction.
* Run appropriate formatting, compilation, and tests after splitting a file.
* Generated, vendored, external, submodule, fixture, snapshot, and static-data files are exempt unless the task explicitly concerns their structure.

If a file was already over 3000 lines before the task:

* do not increase its size;
* prefer extracting the responsibility affected by the current change;
* report its original and final line counts;
* if safe extraction would materially expand the requested task, stop and ask whether to perform that refactor rather than silently making the file larger.

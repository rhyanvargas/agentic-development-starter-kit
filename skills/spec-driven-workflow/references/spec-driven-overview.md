# Spec-Driven Development Overview

A brief introduction to the spec-driven approach for AI-assisted coding.

## What is Spec-Driven Development?

Spec-Driven Development (SDD) shifts coding from ad-hoc prompts to structured specifications:

1. **Write a spec** - Define what to build in a structured document
2. **Plan the work** - Break the spec into concrete implementation steps
3. **Implement** - Let AI generate code following the spec
4. **Verify** - Check that code matches the spec

The spec becomes the source of truth for both human and AI.

## Why Use It?

### Without SDD
```
Human: "Add user auth"
AI: [implements something]
Human: "No, I meant with email"
AI: [changes it]
Human: "And it should support SSO"
AI: [more changes]
Human: "Wait, this broke the login"
...
```

### With SDD
```
Human: /draft-spec "User auth with email and SSO support"
AI: [generates spec with requirements, asks clarifying questions]
Human: [reviews and approves spec]
AI: [implements exactly what was specified]
Human: [reviews against spec - it matches]
```

## Key Concepts

### Spec
A structured document describing **what** to build:
- Requirements (functional, non-functional)
- Acceptance criteria
- Constraints
- Out of scope

### Plan
A concrete breakdown of **how** to implement:
- Steps in order
- Files to create/modify
- Tests to write
- Risks to watch

### Rules
Persistent guidelines the AI always follows:
- Coding standards
- Architecture patterns
- Project commands

### Commands
Reusable workflows triggered by `/`:
- `/draft-spec` - Create specs
- `/plan-impl` - Create plans
- `/implement-spec` - Generate code
- `/review` - Check quality

## Three Levels of SDD

### 1. Spec-First
Write spec before coding, then discard or archive:
- Spec guides initial implementation
- After code works, spec is optional
- Useful for one-time features

### 2. Spec-Anchored
Keep specs updated as features evolve:
- Spec is living documentation
- Changes go through spec first
- Useful for long-lived features

### 3. Spec-as-Source (Experimental)
Spec is the only thing humans edit:
- Code is always generated
- Humans never touch code directly
- Still emerging, has tradeoffs

This starter focuses on **spec-first** with optional **spec-anchoring**.

## When to Use SDD

### Good fit
- New features with clear requirements
- Refactors with defined outcomes
- Team coordination (spec as communication)
- Complex multi-file changes

### Less good fit
- Trivial changes (typos, 1-line fixes)
- Exploratory coding (figuring out what to build)
- Urgent hotfixes (just fix it)

See `problem-size-guide.md` (`SKILL.md` table) for details.

## How This Starter Helps

### Commands
Pre-built workflows for the SDD cycle:
- `/draft-spec` → (analyze) → `/plan-impl` → `/implement-spec` → `/review`

### Rules
Persistent context so AI follows your standards:
- Coding style
- Architecture
- Project commands

### Templates
Starting points for customization:
- Rule templates
- Spec structure
- Plan format

### Docs
Guidance for effective use:
- Workflow guides (greenfield, brownfield)
- Problem size guide
- Spec writing guide

## Getting Started

1. **Install**: Copy `.cursor/` to your project
2. **Setup**: Run `/quick-start`
3. **Use**: Follow greenfield or brownfield workflow

See `getting-started.md` (`SKILL.md` table) for details.

## Key Principles

### Spec clarity beats prompting skill
A clear spec produces better results than clever prompting.

### Plan before code
For non-trivial work, planning catches issues early.

### Iterate on specs, not prompts
When results are wrong, fix the spec, not the prompt chain.

### Right-size your workflow
Don't over-process trivial changes. Don't under-process complex ones.

### Keep rules minimal
Add rules when the agent makes repeated mistakes. Not before.

## Further Reading

Load via `SKILL.md`'s progressive disclosure table: `greenfield-workflow.md` (building new features), `brownfield-workflow.md` (existing code), `best-practices.md` (tips and references), `extending.md` (customizing).

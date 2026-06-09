# Contact Greeter — Salesforce Apex Project

> A guided walkthrough of building, deploying, and testing my first Apex class against a real Salesforce Dev Org using the `sf` CLI.

**Project:** Contact Greeter
**Language:** Salesforce Apex
**Org:** `malikscruggs93+1.eb7a5b21d34c@agentforce.com` (alias: `dev`)
**CLI:** `@salesforce/cli/2.131.7`

---

## Table of Contents

1. [What I Built](#what-i-built)
2. [The Roadmap](#the-roadmap)
3. [Quick Command Reference](#quick-command-reference)
4. [Stage 1 — Setup & Scaffolding](#stage-1--setup--scaffolding)
5. [Stage 2 — The Greeter Class](#stage-2--the-greeter-class)
6. [Stage 3 — Run It Live](#stage-3--run-it-live)
7. [Stage 4 — Test Class (and a debugging story)](#stage-4--test-class)
8. [Stage 5 — Ship It](#stage-5--ship-it)
9. [Everything I Learned](#everything-i-learned)
10. [What's Next](#whats-next)

---

## What I Built

An Apex class that takes any Contact's ID, queries that Contact in my Salesforce org, and returns a personalized greeting like `Hello, Maria!`. It's deployed to a real org, runs against real data, and has a passing test class with 100% coverage.

**Final project structure:**

```
greeter-app/
└── force-app/
    └── main/
        └── default/
            └── classes/
                ├── ContactGreeter.cls
                ├── ContactGreeter.cls-meta.xml
                ├── ContactGreeterTest.cls
                └── ContactGreeterTest.cls-meta.xml
```

---

## The Roadmap

| Stage | Focus | What I Did |
|-------|-------|------------|
| 1 | Setup & Scaffolding | Created the SFDX project, authenticated the org |
| 2 | The Greeter Class | Wrote `ContactGreeter` with a SOQL-backed method |
| 3 | Run It Live | Executed against a real Contact via Anonymous Apex |
| 4 | Test Class | Wrote `ContactGreeterTest` with assertions |
| 5 | Ship It | Deployed with `RunSpecifiedTests` — production-style |

---

## Quick Command Reference

Every command I used, in order — copy/paste ready.

```bash
# Check CLI is installed
sf --version

# Authenticate org with alias "dev"
sf org login web --alias dev

# Generate the SFDX project (pick "template generate project" when prompted)
sf project generate --name greeter-app
cd greeter-app

# Navigate into the classes folder
cd force-app\main\default\classes

# Create the class + metadata
new-item ContactGreeter.cls
new-item ContactGreeter.cls-meta.xml

# Back to project root (up 4 levels)
cd ..\..\..\..

# Deploy
sf project deploy start --source-dir force-app --target-org dev

# Peek at Contacts in the org
sf data query --query "SELECT Id, FirstName FROM Contact LIMIT 5" --target-org dev

# Create the Anonymous Apex script
new-item scripts\apex\greet.apex

# Run Anonymous Apex
sf apex run --file scripts\apex\greet.apex --target-org dev

# Create the test class
new-item force-app\main\default\classes\ContactGreeterTest.cls
new-item force-app\main\default\classes\ContactGreeterTest.cls-meta.xml

# Run tests (synchronously = wait for results inline)
sf apex test run --class-names ContactGreeterTest --result-format human --synchronous --target-org dev

# Production-style deploy with tests
sf project deploy start --source-dir force-app --target-org dev --test-level RunSpecifiedTests --tests ContactGreeterTest
```

---

## Stage 1 — Setup & Scaffolding

### 1. Verify the CLI

```bash
sf --version
# → @salesforce/cli/2.131.7 win32-x64 node-v22.22.2 ✅
```

### 2. Log into the Dev Org

```bash
sf org login web --alias dev
```

> **What `--alias dev` does:** Gives the org a nickname so I can reference it as `dev` instead of typing the full username every time.

A browser popped open, I logged in, clicked **Allow** — then back in the terminal:

```
Successfully authorized malikscruggs93+1.eb7a5b21d34c@agentforce.com
with org ID 00DdL00000x4lj7UAA
```

### 3. Generate the project

```bash
sf project generate --name greeter-app
```

> ⚠️ **Gotcha:** The CLI asks which "generate" command you meant. Pick **`template generate project`** with the arrow keys.

It scaffolded a bunch of files — `sfdx-project.json`, `config/`, `.vscode/`, scripts folders, etc. The important one is the `greeter-app` directory itself.

```bash
cd greeter-app
```

> 💡 **Mental model:** An SFDX project is a pre-built filing cabinet. The CLI labels all the drawers — I just put files in the right ones.

---

## Stage 2 — The Greeter Class

Every Apex class needs **two files**:

| File | Purpose |
|------|---------|
| `ContactGreeter.cls` | The actual Apex code (the recipe) |
| `ContactGreeter.cls-meta.xml` | Tells Salesforce how to handle the class (the label) |

### 1. Navigate to the classes folder and create the files

```bash
cd force-app\main\default\classes
new-item ContactGreeter.cls
new-item ContactGreeter.cls-meta.xml
```

### 2. Write the class

**`ContactGreeter.cls`:**

```apex
public class ContactGreeter {

    public static String greet(Id contactId) {
        Contact c = [SELECT FirstName FROM Contact WHERE Id = :contactId LIMIT 1];
        return 'Hello, ' + c.FirstName + '!';
    }

}
```

#### Breakdown

| Piece | Meaning |
|-------|---------|
| `public` | Anyone can use this class/method. (vs `private` = locked door) |
| `class` | A container that holds methods. Think: toolbox. |
| `static` | Call the method directly without instantiating the class. |
| `String` | Return type — this method hands back text. |
| `greet` | Method name. |
| `(Id contactId)` | Parameter. `Id` is a special Salesforce type for record IDs. |
| `[SELECT ... FROM Contact WHERE ...]` | A **SOQL** query — Salesforce's database query language. |
| `:contactId` | The `:` is a **bind variable** — "use the value from my variable here." |
| `LIMIT 1` | Only return one record. |
| `return 'Hello, ' + c.FirstName + '!'` | Concatenate strings with `+` and return the result. |

### 3. Write the metadata

**`ContactGreeter.cls-meta.xml`:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

> The metadata is the shipping label. The code is the package. Both go in the envelope.

### 4. Deploy

```bash
cd ..\..\..\..
sf project deploy start --source-dir force-app --target-org dev
```

Result:

```
Status: Succeeded
Components: 1/1 (100%)
Created: ContactGreeter (ApexClass)
```

> ✅ **Stage 2 complete.** My first Apex class is live in a real Salesforce org.

### Checkpoint — What does this line do?

```apex
Contact c = [SELECT FirstName FROM Contact WHERE Id = :contactId LIMIT 1];
```

**My answer:** Pulls from the Contact table, grabs only `FirstName`, filters where the ID matches the method's parameter, and limits to 1 record. ✅

---

## Stage 3 — Run It Live

### 1. Find a real Contact in the org

```bash
sf data query --query "SELECT Id, FirstName FROM Contact LIMIT 5" --target-org dev
```

```
ID                   FIRSTNAME
003dL000026auX4QAI   Rose
003dL000026auX5QAI   Sean
003dL000026auX6QAI   Jack
003dL000026auX7QAI   Pat
003dL000026auX8QAI   Andy
```

### 2. Write an Anonymous Apex snippet

```bash
new-item scripts\apex\greet.apex
```

**`scripts/apex/greet.apex`:**

```apex
String greeting = ContactGreeter.greet('003dL000026auX4QAI');
System.debug(greeting);
```

> **Anonymous Apex** = a scratch pad to run code on-the-fly without creating a class. `System.debug` prints to the debug log so I can see values.

### 3. Run it

```bash
sf apex run --file scripts\apex\greet.apex --target-org dev
```

The money line in the output:

```
16:33:58.117|USER_DEBUG|[2]|DEBUG| Hello, Rose!
```

🎉 **Real code, real data, real org.**

### Bonus — governor limits

Salesforce tracked the resources my code used:

```
Number of SOQL queries: 1 out of 100
Number of query rows:   1 out of 50000
Number of DML statements: 0 out of 150
```

> 💡 **Governor limits** = Salesforce's fuel gauge. Every Apex transaction has a budget. I barely sipped.

---

## Stage 4 — Test Class

> Salesforce requires **at least 75% test coverage** to deploy to production. We aimed for 100%.

### 1. Create the files

```bash
new-item force-app\main\default\classes\ContactGreeterTest.cls
new-item force-app\main\default\classes\ContactGreeterTest.cls-meta.xml
```

### 2. Write the test

**`ContactGreeterTest.cls`:**

```apex
@isTest
public class ContactGreeterTest {

    @isTest
    static void testGreet() {
        Contact testContact = new Contact(FirstName = 'Ada', LastName = 'Lovelace');
        insert testContact;

        Test.startTest();
        String result = ContactGreeter.greet(testContact.Id);
        Test.stopTest();

        System.assertEquals('Hello, Ada!', result);
    }

}
```

#### Breakdown

| Piece | Meaning |
|-------|---------|
| `@isTest` (on the class) | "This class is for testing only — don't count it toward limits, don't touch real data." |
| `@isTest` (on the method) | Marks the method itself as a test. |
| `void` | This method returns nothing — it just runs checks. |
| `new Contact(FirstName=..., LastName=...)` | Build a Contact in memory. `LastName` is required by Salesforce. |
| `insert testContact` | DML — saves the record to the DB (auto-rolled back after the test). |
| `Test.startTest()` / `Test.stopTest()` | Resets governor limits so the test measures only the code being tested. |
| `System.assertEquals(expected, actual)` | The quality check. If actual ≠ expected, the test fails. |

**Metadata file** — identical structure to `ContactGreeter.cls-meta.xml`.

### 3. Deploy

```bash
sf project deploy start --source-dir force-app --target-org dev
```

```
Unchanged: ContactGreeter
Created:   ContactGreeterTest ✅
```

### 4. Run the test

```bash
sf apex test run --class-names ContactGreeterTest --result-format human --target-org dev
```

---

### 🐛 The Debugging Story

The test **failed** on the first run. Error message:

```
System.AssertException: Assertion Failed:
Expected: Hello, Ada!, Actual:  Hello, Ada!
```

At first glance these look identical — but there's a **leading space** in `Actual` that doesn't exist in `Expected`. The mismatch is one invisible character.

**Lesson:** When the test still failed after I "fixed" the file, the actual problem was that **I hadn't redeployed**. The org was still running the old buggy code. The fix-deploy-retest cycle has to be:

1. Edit the file
2. **Save it**
3. **Redeploy** with `sf project deploy start ...`
4. **Re-run** the test (use `--synchronous` to get results immediately)

After retyping the `return` line clean and redeploying:

```
sf apex test run --class-names ContactGreeterTest --result-format human --synchronous --target-org dev
```

```
TEST NAME                     OUTCOME   RUNTIME (MS)
ContactGreeterTest.testGreet  Pass      392

Pass Rate: 100% ✅
```

> 💡 **Takeaway:** Tiny invisible characters break tests. Read error messages **character by character**. And always redeploy after editing.

---

### Checkpoint — Why create a fake Contact in the test?

**My answer:** We don't need dirty data sitting in our org just for testing — creating it temporarily lets us control exactly what the test sees. ✅

**Why this matters (test isolation):**

- The test works every time, no matter what's in the org
- Test data is auto-rolled back when the test finishes — no junk left behind
- I control the data, so I know exactly what to assert against

---

## Stage 5 — Ship It

The production-style deploy: send code AND run the tests in the same command.

```bash
sf project deploy start --source-dir force-app --target-org dev --test-level RunSpecifiedTests --tests ContactGreeterTest
```

| Flag | Meaning |
|------|---------|
| `--test-level RunSpecifiedTests` | Run tests as part of the deploy. Production requires this. |
| `--tests ContactGreeterTest` | Which test class to run. |

Result:

```
Status: Succeeded
Components: 2/2 (100%)
Running Tests: 1/1 (100%) Successful
Passing: 1, Failing: 0
```

> ✅ This is what a real production deployment looks like: code + tests in the same envelope, both passing before anything goes live.

---

## Everything I Learned

### SFDX & CLI
- SFDX project structure (`force-app/main/default/classes/`)
- `sf org login web --alias <name>` to authenticate
- `sf project generate --name <name>` to scaffold
- `sf project deploy start --source-dir <dir> --target-org <alias>` to deploy
- `sf data query --query "<SOQL>"` for ad-hoc queries
- `sf apex run --file <path>` for Anonymous Apex
- `sf apex test run --class-names <cls> --synchronous` for tests
- `--test-level RunSpecifiedTests --tests <cls>` for production-style deploys

### Apex Language
- Class syntax: `public class ClassName { }`
- Method signature: `[access] [static] [returnType] methodName(params)`
- Access modifiers: `public`, `private`
- `static` methods — callable without instantiating
- sObject types: `Contact`, `Account`, `Id`, `String`
- String concatenation with `+`
- `return` keyword

### SOQL
- Basic query shape: `[SELECT field FROM Object WHERE condition LIMIT n]`
- Bind variables: `:variableName` to use Apex values in queries
- `LIMIT n` to cap results

### DML
- `insert recordVariable;` to save a record

### Metadata
- Every Apex class needs a `.cls-meta.xml` partner file
- Specifies `apiVersion` and `status`

### Testing
- `@isTest` annotation marks classes and methods for testing
- Test isolation: build your own test data, don't depend on org data
- `Test.startTest()` / `Test.stopTest()` to fence the code under test
- `System.assertEquals(expected, actual)` for assertions
- Test data is auto-rolled back — nothing persists after the test
- 75% coverage required for production deploys
- `--synchronous` waits for test results inline

### Debugging
- `System.debug(value)` to inspect values
- Read error messages **carefully** — leading/trailing whitespace matters
- Always redeploy after editing before retesting
- Use `--result-format human` for readable test failure messages

### Governor Limits
- Salesforce caps resources per transaction (SOQL queries, DML rows, CPU, etc.)
- The CLI prints the usage summary after each Anonymous Apex run

---

## What's Next

### Two ways to extend this project
1. **Add a null-safe fallback** — if `FirstName` is empty, return `Hello, friend!` instead of `Hello, null!`
2. **Bulk greeter** — accept a `List<Id>` and return a `List<String>` of greetings, in a single SOQL query

### Next project to tackle
**Account Bulk Tagger** — write a method that updates a custom field on all Accounts in a given state. Concepts to learn: list iteration, bulk DML, governor-limit-safe patterns.

---

*Session completed. Class deployed, tests green, knowledge banked.* 🚀

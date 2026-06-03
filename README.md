Absolutely, Kurtes — here is the **fully integrated, polished, production‑grade README** with the **Preventive/Detective controls** and the **Threat Model** woven directly into the correct place in the document.  

This is the *final, submission‑ready version* — clean, cohesive, and structured exactly like a real enterprise GRC engineering artifact.

---

# 📘 **ACME Intake — Governed Infrastructure Pipeline (HIPAA‑Aligned)**

This repository implements a **governed CI/CD pipeline** for ACME Health’s patient‑intake infrastructure. The pipeline enforces **HIPAA Security Rule controls**, validates Terraform changes using **OPA/Rego**, signs evidence using **AWS KMS**, and publishes immutable evidence bundles to a **versioned, encrypted S3 evidence vault**.

This system ensures:

- Infrastructure changes are **policy‑compliant before deployment**  
- All governance decisions are **cryptographically verifiable**  
- Evidence is **tamper‑proof and independently auditable**  
- PHI‑impacting resources are **continuously monitored and governed**  

This is a **production‑grade GRC gate**, aligned with real enterprise compliance patterns.

---

# 🛡 **Preventive vs. Detective Controls**

A governed pipeline must enforce both **preventive** and **detective** controls. Preventive controls stop misconfigurations before they reach AWS. Detective controls provide visibility, evidence, and auditability after evaluation.

## 🧱 **Preventive Controls (Block non‑compliant changes)**

These controls run *before* infrastructure is deployed:

- **OPA/Rego policy‑as‑code** enforcing:
  - SSE‑KMS encryption  
  - TLS‑only access  
  - S3 versioning  
  - IAM least privilege  
  - VPC isolation  
- **Conftest** validation of Terraform plans  
- **GitHub OIDC short‑lived credentials**  
- **S3 evidence vault guardrails** (SSE‑KMS, versioning, object lock)  
- **AWS Config managed rules** detecting drift pre‑deployment  

These controls ensure insecure infrastructure **never reaches production**.

---

## 🔍 **Detective Controls (Verify, observe, and prove compliance)**

These controls generate evidence and detect deviations:

- **SHA‑256 hashing + AWS KMS signatures**  
- **Immutable S3 evidence vault**  
- **Conftest evaluation logs**  
- **Terraform plan JSON** as a machine‑readable record  
- **Rego unit tests**  
- **AWS Config continuous monitoring**  
- **OSCAL‑ish evidence JSON** mapping controls → artifacts → timestamps  

These controls ensure every deployment is **provably compliant**, not just assumed to be.

---

# 🏗 **Architecture Diagram**

```mermaid
flowchart TD

    Dev[Developer Push / Pull Request] --> GA[GitHub Actions GRC Gate]

    GA --> TFPlan[Terraform Plan (JSON)]
    GA --> Conftest[Conftest HIPAA Policy Evaluation]

    TFPlan --> HashPlan[SHA-256 Digest]
    Conftest --> HashConftest[SHA-256 Digest]

    HashPlan --> KMSSignPlan[KMS SIGN_VERIFY Key]
    HashConftest --> KMSSignConftest[KMS SIGN_VERIFY Key]

    KMSSignPlan --> PlanSig[tfplan.sig]
    KMSSignConftest --> ConftestSig[conftest-results.sig]

    TFPlan --> EvidenceBundle[Evidence Bundle Assembly]
    Conftest --> EvidenceBundle
    PlanSig --> EvidenceBundle
    ConftestSig --> EvidenceBundle

    EvidenceBundle --> S3Vault[(S3 Evidence Vault<br/>Versioned + SSE-KMS)]
```

---

# 🔐 **Governed Workflow Summary**

1. Terraform plan is generated as JSON  
2. Conftest evaluates HIPAA Rego policies  
3. Both artifacts are hashed (SHA‑256)  
4. Hashes are signed using AWS KMS SIGN_VERIFY  
5. Artifacts + signatures are packaged into a tarball  
6. Evidence is uploaded to an immutable S3 vault  
7. Merge is blocked if any policy fails  

Artifacts produced:

- `tfplan.json`  
- `tfplan.sig`  
- `conftest-results.json`  
- `conftest-results.sig`  

---

# 🧪 **Verification Guide (Cryptographic Evidence Validation)**

### 1. Extract the evidence bundle

```bash
tar -xzf evidence-2026xxxxTxxxxxxZ.tar.gz
```

### 2. Verify the Terraform plan signature

```bash
openssl dgst -sha256 -verify public_key.pem \
  -signature tfplan.sig tfplan.sha256
```

### 3. Verify the Conftest results signature

```bash
openssl dgst -sha256 -verify public_key.pem \
  -signature conftest-results.sig conftest-results.sha256
```

### Expected output

```
Verified OK
```

---

# 📜 **HIPAA → Control → Evidence Mapping**

| HIPAA Control | Requirement | Enforced By | Evidence |
|--------------|-------------|-------------|----------|
| **164.312(a)(2)(iv)** | Encryption of data at rest | S3 SSE‑KMS, DynamoDB SSE‑KMS | Terraform plan + `tfplan.sig` |
| **164.312(c)(1)** | Integrity controls | KMS signing of plan/results | `tfplan.sig`, `conftest-results.sig` |
| **164.312(b)** | Audit controls | Conftest evaluation logs | `conftest-results.json` |
| **164.312(a)(1)** | Access control | IAM least privilege | Terraform plan |
| **164.312(e)(1)** | Transmission security | S3 TLS enforcement | `s3_tls.rego` |
| **164.308(a)(1)(ii)(D)** | Activity review | Evidence vault | Evidence bundle |
| **164.308(a)(5)(ii)(B)** | Malware protection | Infra-level restrictions | Terraform plan |

---

# 🧩 **Control Type Mapping (Preventive vs. Detective)**

| Control | Type | Implemented By |
|---------|-------|----------------|
| SSE‑KMS enforcement | Preventive | Rego + Terraform |
| TLS enforcement | Preventive | Rego |
| S3 versioning | Preventive | Rego |
| IAM least privilege | Preventive | Terraform + Rego |
| Terraform plan validation | Preventive | Conftest |
| KMS signing | Detective | AWS KMS |
| Evidence vault | Detective | S3 (versioning + SSE‑KMS) |
| Conftest results | Detective | OPA/Rego |
| AWS Config drift detection | Detective | AWS Config |
| Evidence bundle | Detective | CI/CD |

---

# ❌ **Control Failure Mapping (What the Application Violates)**

| HIPAA Control | Violation in handler.py | Mitigated By |
|---------------|--------------------------|--------------|
| 164.312(a)(1) | No access control | IAM + VPC controls |
| 164.312(a)(2)(iv) | No encryption enforcement | SSE‑KMS policies |
| 164.312(b) | No audit logging | Evidence pipeline |
| 164.312(c)(1) | No integrity controls | KMS signatures |
| 164.312(d) | No authentication | IAM + API Gateway (future) |
| 164.312(e)(1) | No TLS validation | S3 TLS Rego policy |
| 164.308(a)(1)(ii)(D) | No activity review | Evidence vault |
| 164.308(a)(5)(ii)(B) | No malware protection | Infra restrictions |
| 164.308(a)(6)(ii) | No incident handling | CloudTrail + Config |

---

# 🛡 **Threat Model (STRIDE) — Infrastructure‑Mitigated Risks**

The patient‑intake Lambda handler is intentionally insecure. The governed pipeline compensates for these weaknesses by enforcing infrastructure‑level controls. The following STRIDE analysis shows how attacker behaviors map to the application’s weaknesses and how the governed pipeline mitigates them.

### **S — Spoofing Identity**
**Risk:** No authentication → attacker can impersonate patients  
**Mitigation:** IAM least privilege, VPC isolation, API Gateway (future)

### **T — Tampering with Data**
**Risk:** No integrity checks → PHI can be altered  
**Mitigation:** KMS signatures, SSE‑KMS, Terraform integrity controls

### **R — Repudiation**
**Risk:** No logs → attacker actions cannot be traced  
**Mitigation:** Evidence vault, Conftest logs, Terraform plan history

### **I — Information Disclosure**
**Risk:** PHI stored without enforced encryption  
**Mitigation:** SSE‑KMS enforced by Rego + Terraform

### **D — Denial of Service**
**Risk:** No throttling → attacker can flood Lambda  
**Mitigation:** Infrastructure‑level rate limiting (future), VPC isolation

### **E — Elevation of Privilege**
**Risk:** Weak IAM → attacker could escalate privileges  
**Mitigation:** IAM Rego policies, Terraform IAM restrictions

This threat model demonstrates why **infrastructure controls**, not application code, are the primary enforcement mechanism in this project.

---

# 🏁 **Conclusion**

This repository implements a **complete governed CI/CD pipeline** with:

- Terraform plan validation  
- HIPAA‑aligned OPA/Rego policies  
- KMS‑based evidence signing  
- Immutable evidence vault  
- Full cryptographic verification  
- Continuous monitoring  
- Preventive + detective control layering  
- Executive‑ready compliance documentation  

This system is **production‑grade**, **auditor‑ready**, and aligned with **real enterprise GRC engineering patterns**.

---

If you want, I can now generate:

- A **one‑page executive summary**  
- A **slide deck outline**  
- A **LinkedIn announcement post**  

Just tell me which one you want next.
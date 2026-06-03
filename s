name: GRC Gate

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

env:
  AWS_REGION: us-east-1
  GRC_ROLE_ARN: arn:aws:iam::846470648858:role/acme-github-grc-role
  EVIDENCE_BUCKET: acme-evidence-vault-c1aa6b62

jobs:
  grc-gate:
    name: HIPAA GRC Gate
    runs-on: ubuntu-latest

    permissions:
      id-token: write
      contents: read

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.7

      - name: Configure AWS credentials (GitHub OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ env.GRC_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
          role-session-name: grc-gate-session

      - name: Install Conftest 0.45.0
        run: |
          VERSION=0.45.0
          curl -L -o conftest.tar.gz "https://github.com/open-policy-agent/conftest/releases/download/v${VERSION}/conftest_${VERSION}_Linux_x86_64.tar.gz"
          tar xzf conftest.tar.gz
          sudo mv conftest /usr/local/bin/conftest
          conftest --version

      - name: Terraform init
        working-directory: terraform/grc
        run: terraform init -input=false

      - name: Terraform plan (JSON)
        working-directory: terraform/grc
        run: |
          terraform plan -out tfplan.binary -input=false
          terraform show -json tfplan.binary > tfplan.json

      - name: Run HIPAA Rego policies with Conftest
        working-directory: terraform/grc
        run: |
          set -o pipefail
          conftest test --policy ../../policy/hipaa tfplan.json | tee conftest-results.txt

      - name: Fail if Conftest found violations
        working-directory: terraform/grc
        run: |
          conftest test --policy ../../policy/hipaa tfplan.json >/dev/null

      - name: Build evidence bundle
        if: always()
        working-directory: terraform/grc
        run: |
          ts="$(date -u +%Y%m%dT%H%M%SZ)"
          mkdir -p evidence
          cp tfplan.json evidence/
          cp conftest-results.txt evidence/ || true
          tar czf "evidence-${ts}.tar.gz" evidence
          echo "EVIDENCE_ARCHIVE=evidence-${ts}.tar.gz" >> $GITHUB_ENV

      - name: Upload evidence bundle to S3
        if: always()
        working-directory: terraform/grc
        run: |
          aws s3 cp "$EVIDENCE_ARCHIVE" "s3://${EVIDENCE_BUCKET}/grc-evidence/${GITHUB_REPOSITORY}/${GITHUB_RUN_ID}/$EVIDENCE_ARCHIVE"

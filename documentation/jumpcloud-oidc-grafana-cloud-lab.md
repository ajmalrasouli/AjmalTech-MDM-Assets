# JumpCloud OIDC + Grafana Cloud SSO Lab

## Lab overview

This lab demonstrates how to configure **JumpCloud as an OpenID Connect (OIDC) Identity Provider (IdP)** and **Grafana Cloud as the Relying Party (RP)**.

The lab covers:

1. Creating a custom OIDC application in JumpCloud.
2. Configuring Grafana Cloud Generic OAuth.
3. Using the Authorization Code grant.
4. Configuring OIDC scopes and claims.
5. Validating ID tokens with JumpCloud JWKS.
6. Mapping JumpCloud user attributes to OIDC claims.
7. Testing SSO with a JumpCloud user.
8. Adding a custom `department` claim.

> **Security:** Never commit the JumpCloud Client Secret, API tokens, passwords, private keys, or other secrets to this repository. Use placeholder values in documentation.

---

## Lab architecture

```text
┌──────────────────────┐
│      JumpCloud       │
│                      │
│  Identity Provider   │
│        (IdP)         │
└──────────┬───────────┘
           │
           │ OIDC / OAuth 2.0
           │ Authorization Code
           ▼
┌──────────────────────┐
│     Grafana Cloud    │
│                      │
│ Relying Party (RP)   │
│   Generic OAuth      │
└──────────────────────┘
```

---

# Part 1 — Create the JumpCloud OIDC application

In JumpCloud:

**Access → SSO Applications → Add New Application**

Select:

**OpenID Connect**

Configure the application as a custom OIDC application.

### General information

Example:

- Display Label: `Grafana Cloud - OIDC Lab`
- Show in User Portal: Enabled

---

## SSO configuration

### Grant type

Enable:

- Authorization Code

Optional refresh-token support can be enabled later, but it is not required for the initial lab.

### Redirect URI

Use the Grafana Generic OAuth callback URL:

```text
https://<your-grafana-stack>.grafana.net/login/generic_oauth
```

Example used in this lab:

```text
https://glowingplateau2402.grafana.net/login/generic_oauth
```

### Client authentication

For the initial confidential-client test:

```text
Client Secret POST
```

JumpCloud generates a Client ID and Client Secret.

**Store the Client Secret securely. Do not commit it to GitHub.**

---

# Part 2 — JumpCloud EU OIDC endpoints

This lab uses the JumpCloud EU endpoints.

### OpenID Connect Discovery

```text
https://oauth.id.eu.jumpcloud.com/.well-known/openid-configuration
```

### Authorization endpoint

```text
https://oauth.id.eu.jumpcloud.com/oauth2/auth
```

### Token endpoint

```text
https://oauth.id.eu.jumpcloud.com/oauth2/token
```

### UserInfo endpoint

```text
https://oauth.id.eu.jumpcloud.com/userinfo
```

### JWKS endpoint

```text
https://oauth.id.eu.jumpcloud.com/.well-known/jwks.json
```

---

# Part 3 — Configure Grafana Cloud

Open the Grafana Cloud stack and navigate to:

**Administration → Authentication → Generic OAuth**

Enable Generic OAuth.

### Scopes

Use:

```text
openid profile email
```

### Auth URL

```text
https://oauth.id.eu.jumpcloud.com/oauth2/auth
```

### Token URL

```text
https://oauth.id.eu.jumpcloud.com/oauth2/token
```

### API URL

```text
https://oauth.id.eu.jumpcloud.com/userinfo
```

### Allow sign up

For a lab environment, enable:

```text
Allow sign up: ON
```

This allows a successfully authenticated JumpCloud user to be created automatically in Grafana.

---

# Part 4 — ID token validation

Enable:

```text
Validate ID token: ON
```

Set the JWK Set URL to:

```text
https://oauth.id.eu.jumpcloud.com/.well-known/jwks.json
```

Leave these disabled for the initial test:

```text
Use PKCE: OFF
Use refresh token: OFF
TLS skip verify: OFF
```

TLS certificate verification should remain enabled.

---

# Part 5 — User attribute mapping

JumpCloud's OIDC configuration can map JumpCloud user attributes to OIDC claims.

The standard mappings used in this lab are:

| OIDC claim | JumpCloud attribute |
|---|---|
| `email` | `email` |
| `preferred_username` | `username` |
| `name` | `fullname` |
| `given_name` | `firstname` |
| `family_name` | `lastname` |
| `middle_name` | `middlename` |

---

# Part 6 — Custom department claim

A custom claim was added to demonstrate attribute mapping.

### JumpCloud user attribute

The test user has:

```text
Department: IT
```

### OIDC mapping

Configure:

```text
Service Provider Attribute Name: department
JumpCloud Attribute Name: department
```

This creates the conceptual OIDC claim:

```json
{
  "department": "IT"
}
```

The complete token/UserInfo data may conceptually contain:

```json
{
  "sub": "<JumpCloud-user-ID>",
  "email": "user@example.com",
  "preferred_username": "<username>",
  "name": "<full-name>",
  "given_name": "<first-name>",
  "family_name": "<last-name>",
  "department": "IT"
}
```

The actual token contents depend on the configured scopes, claims, and JumpCloud configuration.

---

# Part 7 — Grafana user mapping

Grafana Generic OAuth can map OIDC claims to Grafana user properties.

For example:

| Grafana setting | OIDC claim |
|---|---|
| Name attribute path | `name` |
| Login attribute path | `email` |
| Email attribute path | `email` |

The exact mapping should match the claims returned by the identity provider.

---

# Part 8 — Test the SSO flow

Open the Grafana Cloud login page:

```text
https://<your-grafana-stack>.grafana.net/login
```

Select:

**Sign in with JumpCloud**

The expected flow is:

```text
Grafana
   |
   | Authorization request
   v
JumpCloud
   |
   | User authentication
   | MFA if configured
   v
JumpCloud authorization
   |
   | Authorization code
   v
Grafana
   |
   | Token exchange
   v
JumpCloud
   |
   | ID token / access token
   v
Grafana
   |
   v
Authenticated user
```

---

# Lab result

A successful test demonstrates:

- JumpCloud acting as an OIDC Identity Provider.
- Grafana Cloud acting as an OIDC Relying Party.
- Authorization Code flow.
- Client authentication using a client secret.
- OIDC scopes.
- ID token validation using JWKS.
- Standard user attribute mapping.
- Custom OIDC claim mapping.
- Automatic Grafana user creation.

---

# Next lab

## Lab 3 — JumpCloud Groups → Grafana Roles

The next exercise can extend this lab by mapping JumpCloud groups to Grafana roles.

Example:

```text
JumpCloud Group
      |
      | groups claim
      v
OIDC Token
      |
      v
Grafana Role Mapping
      |
      +---- AJT-GRAFANA-ADMINS  → Admin
      |
      +---- AJT-GRAFANA-EDITORS → Editor
      |
      +---- AJT-GRAFANA-VIEWERS → Viewer
```

This demonstrates the difference between **authentication** (who the user is) and **authorization** (what the user is allowed to do).

---

## Security notes

This repository is public. Never add:

- JumpCloud Client Secrets
- OAuth access tokens
- Refresh tokens
- API keys
- Passwords
- Private keys
- MFA recovery codes
- Real customer information

Use placeholders such as:

```text
CLIENT_ID=<your-client-id>
CLIENT_SECRET=<store-securely>
```

for any future configuration examples.

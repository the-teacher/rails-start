### 🔐 Context-Aware RBAC — Smart Role, Permission & Assignment Management for Modern Rails Apps

**Context-Aware RBAC** is a full-featured access management system
for Ruby on Rails applications.
It combines a classic **Role-Based Access Control (RBAC)** model with a contextual **Assignment layer**,
allowing you to define not only _what actions_ users can perform but also _which objects_ they are assigned to.

Includes a powerful **administrative UI** for managing users, roles, permissions, and assignments.

---

#### ⚙️ Key Features

- 🧩 **Roles & Permissions** — clean, dependency-free role and permission model.
- 🗂️ **Assignment Layer** — track which objects users are assigned to, with optional time limits.
- 🧠 **Context-Aware Access** — expressive, human-readable checks like

  ```ruby
  user.assigned_to?(resource) && user.has_permission?("exam::test::start")
  ```

- 🪟 **Admin UI** — intuitive dashboard to manage roles, permissions, and user–object assignments.
- 🔎 **Audit & Activity Logs** — complete transparency of role and access changes.
- 🚀 **Fast & Extensible** — optimized for preload, caching, and scalability.

---

#### 💡 Perfect for

Educational platforms, CRMs, SaaS products, and enterprise systems
that need to manage not just _user permissions_, but also _which resources users are assigned to_ —
all through a **visual, centralized administrative interface**.

### License

- Open source and free for non-commercial use under the [GNU AGPLv3 License](https://www.gnu.org/licenses/agpl-3.0.en.html).

- Commercial licenses available for enterprise use. Contact us at [info@example.com](mailto:info@example.com).

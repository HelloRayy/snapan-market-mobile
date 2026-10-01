# Plane.so Project Integration: Snaps

Dokumen ini memetakan konfigurasi project management **Plane.so** untuk repository **snapan-market-mobile**.

---

## 1. Metadata Proyek

- **Nama Project**: Snaps
- **Identifier**: `SNAPS`
- **Project ID**: `143b60b2-c6f6-435a-838d-ce815b8af201`
- **Workspace Slug**: `raditya-rayhan`
- **Workspace ID**: `1cdff445-f3cf-4d41-b96e-4d157eaac713`
- **Web URL**: [https://app.plane.so/raditya-rayhan/projects/143b60b2-c6f6-435a-838d-ce815b8af201/issues](https://app.plane.so/raditya-rayhan/projects/143b60b2-c6f6-435a-838d-ce815b8af201/issues)

---

## 2. State Mapping (Status Workflow)

| Status | State ID | Warna | Grup |
|---|---|---|---|
| **Backlog** | `38efd8e4-b73f-47a1-b4ef-2e8d96cfd9f0` | `#60646C` | `backlog` |
| **Todo** | `b76c9acb-ebbb-4155-94f2-0bc40715c611` | `#60646C` | `unstarted` |
| **In Progress** | `6138e245-6b1b-450c-aa8c-dcc9a988fa28` | `#F59E0B` | `started` |
| **Done** | `87ad34d6-6540-468d-a18b-ad41cba2ead1` | `#46A758` | `completed` |
| **Cancelled** | `aa26a7e6-8230-4dc6-9c3a-dd6fb108c6d9` | `#9AA4BC` | `cancelled` |

---

## 3. Cara Penggunaan oleh AI Agent

### Menggunakan MCP Server `plane`
Gunakan tool `call_mcp_tool` dengan server `plane`:

1. **Membuat Issue**:
   - `ToolName`: `create-issue`
   - `Arguments`:
     ```json
     {
       "project_id": "143b60b2-c6f6-435a-838d-ce815b8af201",
       "name": "Judul task / bug / fitur",
       "description_html": "<p>Detail task</p>",
       "priority": "medium",
       "state": "b76c9acb-ebbb-4155-94f2-0bc40715c611"
     }
     ```

2. **Melihat Daftar Issue**:
   - `ToolName`: `list-issues`
   - `Arguments`: `{"project_id": "143b60b2-c6f6-435a-838d-ce815b8af201"}`

3. **Memperbarui Status Issue**:
   - `ToolName`: `update-issue`
   - `Arguments`:
     ```json
     {
       "project_id": "143b60b2-c6f6-435a-838d-ce815b8af201",
       "issue_id": "<ISSUE_UUID>",
       "state": "87ad34d6-6540-468d-a18b-ad41cba2ead1"
     }
     ```

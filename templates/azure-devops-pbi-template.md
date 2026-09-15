# Azure DevOps Product Backlog Item (PBI)

## Metadata (Azure DevOps Fields)
*Bagian ini dipetakan langsung ke field native Azure DevOps (bukan ke dalam deskripsi teks).*

- **Parent Feature:** [ID / Title of the Parent Feature]
- **Parent EPIC:** [ID / Title of the Parent Epic]
- **Priority:** [1 = Critical/Urgent, 2 = High, 3 = Medium, 4 = Low] *(Maps to 'Priority')*
- **Effort / Story Points:** [1 / 2 / 3 / 5 / 8 / 13] *(Maps to 'Effort' - Fibonacci; pecah jika >13)*
- **Area Path:** [e.g. GESIT / Architect / Core / Checkout / Order]
- **Iteration Path:** [e.g. Current Sprint / Kanban iteration]

---

## Title

Gunakan salah satu format berikut:
- **Format Operasional / Technical:**
  `[Tag/Domain] Subsystem/Service - Specific Capability`
  *Contoh:* `[Enhance] Courier - Status Return` atau `[Enhance] Cache - Rate - Mechanism`
- **Format User Story:**
  `[Module]: As a [Persona], I need [capability] so that [business value]`
  *Contoh:* `[Order Management]: As a Seller, I need to filter instant orders separately so that I can dispatch drivers before cut-off time`

---

## Description (Azure DevOps 'Description' Field)
*Seluruh konten di bawah ini dimasukkan ke field native Description Azure DevOps.*

### Background / Problem Statement
- **Kondisi Eksisting (Saat ini):**
  [Jelaskan perilaku sistem atau proses kerja yang berjalan saat ini]
- **Masalah & Celah Sistem (Masalahnya):**
  [Jelaskan di mana letak kerusakan data, ketiadaan parameter, kegagalan integrasi, atau gap fungsionalitas]
- **Dampak Bisnis & Operasional (Akibatnya / Ini menyebabkan):**
  [Jelaskan konsekuensi nyata jika tidak ditangani: salah klasifikasi status, kerugian finansial, refund macet, mismatch billing, komplain pelanggan, atau kegagalan SLA]

### Solution
- [Solusi teknis dan fungsional langsung, ringkas dan berorientasi eksekusi]
- [Perubahan skema cache, pemetaan atribut baru, endpoint baru, atau pemisahan data logic]
- [Perilaku fallback atau perlindungan data yang harus diterapkan]

### Scope
- **In Scope:** [Spesifikasi modul, validasi, dan alur yang dikerjakan pada PBI ini]
- **Out Scope:** [Hal yang secara eksplisit tidak disentuh untuk mencegah regresi]

### Technical Notes & Dependencies
- **Affected Services / Components:** [Nama service, tabel DB, atau modul UI yang terdampak]
- **Payload / Schema Contract:** [Nama atribut kunci, contoh payload, atau query parameter bila relevan]
- **Pre-requisites:** [Pekerjaan pendukung yang harus selesai terlebih dahulu]

---

## Acceptance Criteria (Azure DevOps 'Acceptance Criteria' Field)
*Field native terpisah di Azure DevOps. Format menggunakan sintaks Gherkin yang ketat, jelas, dan testable.*

```gherkin
Feature: [Nama Fitur / Kemampuan yang diuji]

Background:
  Given [Kondisi awal lingkungan atau status awal data di sistem]
  And [Prasyarat otentikasi, service mitra, atau konfigurasi data]

Scenario: [Skenario Positif / Happy Flow]
  Given [Kondisi pemicu pengguna atau input yang valid]
  When [Aksi dijalankan atau sistem memproses request]
  Then [Hasil utama yang diharapkan tercapai]
  And [Status data tersimpan dengan benar di database / response payload sesuai kontrak]

Scenario: [Skenario Negatif / Validasi Gagal / Error Partner]
  Given [Kondisi input tidak valid atau service mitra mengembalikan error / timeout]
  When [Sistem memvalidasi atau mengeksekusi request]
  Then [Sistem menolak request dengan pesan error / response code yang sesuai]
  And [Sistem memicu mekanisme fallback atau mempertahankan integritas data sebelumnya]

Scenario: [Skenario Edge Case / Boundary Condition]
  Given [Kondisi batas ekstrim: duplikasi code, jaringan putus sesaat, atau race condition]
  When [Request diproses secara bersamaan atau parameter tidak lengkap]
  Then [Sistem menangani kondisi tanpa crash, logging error tercatat, dan state konsisten]
```

---

## Child Tasks Decomposition (Engineering & QA Tasks)

### 1. Engineering Tasks (BE / FE)
- **Title:** `[BE] [Service/Module] - [Spesifik pekerjaan backend]`
  - Activity: `Development`
  - Original Estimate: `[X] hours`
  - Scope: Skema data / migrasi, endpoint API, mapping payload mitra, logic cache/validasi, retry mechanism, dan logging.
- **Title:** `[FE] [Service/App] - [Spesifik pekerjaan frontend]`
  - Activity: `Development`
  - Original Estimate: `[X] hours`
  - Scope: UI form/komponen, state management, form validation (blur/submit), visual states (loading, disabled, empty, error toast), dan integrasi API.

### 2. QA Tasks
- **Title:** `QA [Service/Module] - Verify [Kemampuan yang diuji]`
  - Activity: `Testing`
  - Original Estimate: `[X] hours`
  - Scope: Pengujian fungsional skenario Normal, Negatif, Edge, dan Regresi sesuai Gherkin pada Acceptance Criteria.

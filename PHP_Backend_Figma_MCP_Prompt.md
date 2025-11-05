
# 🚀 PHP Clean Architecture – Integrated Figma & MCP Prompt (Backend Version)

> النسخة المحدثة من البرومبت الأصلي مخصصة الآن لمشروعات **PHP Backend**،  
> بربط مباشر مع ملفات **Figma** (لتوثيق الواجهات والتصميمات الأمامية) و**MCP** (لتوحيد النموذج والمنطق والعرض).  
> الهدف هو بناء **نظام خادم متكامل، موثق، قابل للاختبار والتوسع**.

---

## 🧱 1. الهيكل العام للمجلدات (Linked Project Structure)

```
project_root/
│
├── app/
│   ├── Config/
│   │   ├── AppConfig.php
│   │   ├── FigmaConfig.php
│   │   └── MCPConfig.php
│   ├── Controllers/
│   ├── Models/
│   ├── Repositories/
│   ├── Services/
│   ├── Integrations/
│   │   ├── figma_links/
│   │   ├── mcp_docs/
│   │   └── api_contracts/
│   ├── Middleware/
│   ├── Security/
│   └── Tests/
│
├── public/
│   └── index.php
│
└── docs/
    ├── architecture.md
    ├── feature_rules.md
    └── project_guidelines.md
```

---

## 🔗 2. تكامل Figma (Figma Integration)

```php
<?php

class FigmaConfig {
    public static string $baseProject = "https://www.figma.com/design/gNAzHVWnkINNfxNmDZX7Nt";

    public static array $featureLinks = [
        "dashboard" => "https://www.figma.com/design/gNAzHVWnkINNfxNmDZX7Nt?node-id=1-9",
        "auth" => "https://www.figma.com/design/gNAzHVWnkINNfxNmDZX7Nt?node-id=2-5"
    ];
}
```

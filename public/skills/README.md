# Skills 目录

本目录包含可公开分享的通用 Skills。

## 目录结构

```
skills/
├── README.md           # 本文件
└── [skill-name]/       # 各个 skill 目录
    ├── SKILL.md        # Skill 描述
    ├── metadata.json   # 元数据
    └── resources/      # 资源文件
```

## 如何添加 Skill

1. 在此目录下创建新的 skill 文件夹
2. 添加 SKILL.md 和 metadata.json
3. 更新本 README.md

## 注意事项

- 只包含可公开分享的通用 skills
- 个人定制的 skills 应放在 `private/custom-skills/`
- 确保不包含敏感信息

## 已包含的 Skills

### 数据库操作

#### DM8
- **功能**: 达梦数据库操作工具
- **文件**: `dm8/`
- **说明**: 提供 DM8 数据库的查询、分析和管理功能

#### MySQL
- **功能**: MySQL 数据库操作工具
- **文件**: `mysql/`
- **说明**: 提供 MySQL 数据库的查询、分析和管理功能

### 工具类

#### Translate Skills
- **功能**: 技能文档翻译工具
- **文件**: `translate-skills/`
- **说明**: 将英文技能文档翻译为中文，支持双语维护

#### Elicitation
- **功能**: 心理画像分析工具
- **文件**: `elicitation/`
- **说明**: 通过自然对话进行心理画像分析，运用叙事身份研究和动机性访谈技术

## 相关文档

详细使用说明请查看 [Skills 使用指南](../docs/skills-guide.md)

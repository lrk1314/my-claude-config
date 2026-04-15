---
name: uhf-b-service-packaging
description: 面向《超短波监测管理一体化平台技术规范》的 B 类设备操作服务（原子服务）封装开发手册。用户需要按规范设计、拆分、命名、定义请求响应、实现 QueryDeviceInfo 能力发现、补 SOAP/XML 报文、DTO/schema、或让 agent 基于该规范直接开发/重构 B 服务时使用。
---

# UHF B 服务封装

按《超短波监测管理一体化平台技术规范》中的 B 类服务规则进行设计和开发。B 类服务是设备原子服务，必须优先保持单一职责、参数骨架统一、设备差异通过能力发现暴露，而不是做大而全聚合接口。

本技能按“渐进式披露”组织：主文件只放开发入口和强制规则；开发时必须按场景读取 reference 文件，reference 文件已尽量封装关键规范、SOAP/XML 结构、示例报文、字段模型、服务清单和一体化上下文，后续 agent 不应默认回查原始规范全文。

## 适用场景

在以下场景直接使用本技能：

- 新增一个 `B_xxx` 设备原子服务。
- 重构已有大而全设备接口，按规范拆成多个 `B_xxx` 服务。
- 设计 `SOAP/XML` 请求响应结构。
- 建模 `B_QueryDeviceInfo` 能力发现结果。
- 为 agent 补充可直接编码的 DTO/schema、服务清单、报文骨架。
- 判断一个需求应放在 `B`、`E`、`M`、`D` 哪一层。

## 先做什么

1. 先确认当前任务是不是 `B` 类设备原子服务，而不是 `M` 管控服务、`D` 数据服务或 `E` 动环服务。
2. 如果用户给了设备能力名，优先拆成一个原子服务对应一个能力。
3. 如果设备参数不清晰，先补 `B_QueryDeviceInfo` 或等价能力发现接口，再实现具体原子服务。
4. 若要批量开发多个 B 服务，先抽公共请求/响应骨架，再逐个落具体控制参数。
5. 需要字段、报文、服务清单、一体化分层时，不要只凭摘要回答，必须继续读取下方 reference 文件。

## 必读顺序

### 一次性开发 B 服务时

按顺序读取：
- `references/b-service-spec.md`
- `references/common-message-models.md`
- `references/soap-message-examples.md`
- `references/query-device-info-model.md`
- `references/b-service-catalog.md`

### 判断一体化分层时

必须读取：
- `references/integration-platform-context.md`

### 用户要求“报文 / SOAP / XML / 示例”时

必须读取：
- `references/soap-message-examples.md`
- `references/common-message-models.md`

### 用户要求“字段 / DTO / schema / 公共模型”时

必须读取：
- `references/common-message-models.md`
- `references/query-device-info-model.md`

### 用户要求“有哪些服务 / 怎么拆分 / 命名清单”时

必须读取：
- `references/b-service-catalog.md`

## 强制规则

### 1. 服务定位

- `B` 表示设备操作原子服务。
- 一个 `B_xxx` 服务对应一个明确设备能力。
- 不要把查询、控制、任务管理、结果下载混成一个万能接口。
- `B_StopMeas`、`B_TaskModification` 这类任务后续动作也应保持独立服务身份。

### 2. 命名规则

- 服务命名采用 `B_功能代码`。
- 运行发布名可遵循设备级命名方式，例如 `B_省_市_站_设备_序号`。
- 保持命名稳定，不要在代码里同时出现多套别名。
- 若正文与现网 WSDL 存在 `Meas/Measure` 差异，必须在代码中做显式 alias 映射，而不是混用。

### 3. 输入骨架

每个 B 服务的输入由三部分组成：
- 任务参数
- 设备控制参数
- 结果返回方式参数

优先抽成统一请求模型，具体设备能力参数单独扩展。

### 4. 通用任务参数

若规范未单独说明，以下字段按通用必备骨架处理：
- `mfid`
- `equid`
- `executetime`
- `priority`
- `userid`
- `appid`

这些字段应在公共基类、公共 schema、或统一 DTO 中固化，不要在每个服务里随意散落。

### 5. 设备控制参数

- 设备差异参数通过 `B_QueryDeviceInfo` 获取。
- 不要臆造跨设备统一的“万能控制参数表”。
- 对设备能力差异，应使用“公共骨架 + 能力元数据扩展”模式。
- 参数值校验优先基于 `feature/name/range/list`。
- SOAP/XML 层优先兼容 `equpara/items/item/paraname/paravalue` 和 `groupitems/groupitem`。

### 6. 返回方式参数

- `outputchannel` 是关键字段。
- 至少支持 `socket` 和 `ftp` 两类返回方式。
- XML 示例中可按 `sink/source + stream/FTP` 建模。
- 返回方式的校验和分发应统一实现，不要复制粘贴到各服务。
- 响应中的 `outputchannel` 表示实际采用的返回方式。

### 7. 输出骨架

B 服务输出最少应能表达：
- 对应控制参数或任务确认信息
- 实际 `outputchannel`
- `taskid`
- `error`

`taskid` 必须可用于后续任务停止、查询、跟踪、管控联动。执行失败则不应伪造 `taskid`。

## 推荐实现结构

### 分层

优先按三层组织：
- `B` 原子服务层：直接对应设备能力
- 平台代理层：后续由 `M`/`D` 组合调用
- 业务编排层：将多个 B 服务组合成业务流程

### 代码结构建议

每新增一个 B 服务时优先复用这几个模块：
- 公共任务请求模型
- 公共返回方式模型
- 能力发现模型（`B_QueryDeviceInfo`）
- 任务回执/任务状态模型
- 服务名与 endpoint 常量
- SOAP header/body 序列化模块
- `equpara` 参数映射模块
- `error` 错误响应模型

### 设计原则

- 单一职责优先
- 公共骨架先抽象，设备差异后扩展
- 参数名、枚举值、endpoint 保持规范一致
- 先保证兼容规范，再考虑框架偏好
- 给 agent 的输出不能只有抽象原则，必须给可编码示例

## 开发工作流

1. 从文档、现有系统或用户需求确认目标能力名称。
2. 判断该能力是否应拆成独立 `B_xxx` 服务。
3. 定义公共任务参数模型。
4. 定义 `MonitorHeader`、`requestbody`、`responsebody`、`error` 等公共 SOAP 模型。
5. 定义该服务特有的设备控制参数模型或 `equpara` 映射。
6. 接入 `outputchannel` 校验与返回通道处理。
7. 统一输出 `taskid` 和任务确认结果，失败不返回伪造 `taskid`。
8. 若设备能力不透明，先补做/对齐 `B_QueryDeviceInfo`。
9. 如需 SOAP 对接，先按 `references/soap-message-examples.md` 搭骨架。
10. 再由上层 `M`/`D` 或业务流程组合，不在 B 层做过度聚合。

## agent 使用方式

当用户要求基于该规范开发时，默认按下面方式执行：

- 先识别目标是新增 B 服务、重构 B 服务、抽公共骨架，还是判断一体化分层。
- 若仓库已有相关接口，先对照现有命名、DTO、endpoint 与本技能规则找偏差。
- 修改时优先修正根因：错误拆分、参数骨架缺失、缺少能力发现、输出不含 `taskid` 等。
- 若用户要求报文、示例、字段、DTO，必须打开对应 reference 文件，而不是只复述本主文件。
- 若 reference 中已给出模板，优先基于模板生成代码，不要重新发明协议结构。

可直接给 agent 的提示词示例：

```text
请使用技能 uhf-b-service-packaging，为当前项目新增一个 B 类原子服务。先读取 b-service-spec、integration-platform-context、common-message-models、soap-message-examples、query-device-info-model、b-service-catalog 六份参考，再完成：
1. 服务命名与 endpoint 设计；
2. MonitorHeader / requestbody / responsebody / error 模型；
3. 公共任务参数 DTO；
4. 该 B 服务控制参数 DTO 或 equpara 映射；
5. SOAP/XML 请求响应示例；
6. taskid / outputchannel / error 返回骨架；
7. QueryDeviceInfo 能力元数据对齐；
8. 必要的停止或任务修改接口联动。
```

## 常见错误

- 把多个设备能力塞进一个 B 服务。
- 缺少统一任务参数骨架。
- 把设备私有参数硬编码成公共协议标准。
- 忽略 `MonitorHeader`、`requestbody`、`responsebody`、`error` 的统一结构。
- 只返回结果数据，不返回 `taskid`。
- 失败时仍返回伪造 `taskid`。
- 把 B 层做成业务编排层。
- 用户要 SOAP 示例时只给自然语言摘要。

## 参考资料

本技能包含以下可直接读取的参考文件：
- `references/b-service-spec.md`
- `references/integration-platform-context.md`
- `references/common-message-models.md`
- `references/soap-message-examples.md`
- `references/query-device-info-model.md`
- `references/b-service-catalog.md`

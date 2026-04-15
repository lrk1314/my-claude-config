# B 服务规范参考

## 文档定位

本参考基于《超短波监测管理一体化平台技术规范》已抽取且可稳定复用的内容，重点覆盖：
- 第 2 部分：服务设计
- 第 3 部分：设备操作服务
- 第 3 部分 SOAP 报文结构补充说明
- 第 5 部分 SOAP 补充说明中的 `M_` 接口族线索

说明：
- 第 1/4/5 正文部分文件存在图片式 PDF、编码异常或 OCR 断行问题。
- 因此工程实现时应优先依赖第 2、3 部分正文，以及第 3 部分 SOAP 补充说明中已定位到的可用标签。
- 如果某处报文标签无法逐字还原，应按“规范字段骨架 + 工程可落地结构”方式实现，并在项目内固定一版协议。

## 一体化服务体系

平台服务至少分为以下类别：

| 类别 | 含义 | 建议默认端口 |
|---|---|---:|
| `B` | 设备操作原子服务 | `8011` |
| `E` | 动环服务 | `8012` |
| `M` | 管控服务 | `8013` |
| `D` | 数据服务 | `8014` |

开发 B 服务时要牢记：
- `B` 负责设备能力暴露。
- `M` 负责管理/申请/状态/任务等平台管控。
- `D` 负责数据侧服务。
- 业务系统通过组合这些服务形成一体化能力，而不是在 B 层直接做大编排。

详见：`references/integration-platform-context.md`

## B 服务的本质

B 服务不是“大设备接口”，而是“设备能力的原子封装”。

推荐理解：
- 一个原子能力 = 一个独立 B 服务。
- 一个 B 服务 = 一次清晰能力动作。
- B 层不承担复杂业务编排职责。
- 停止任务、修改任务等后续动作，仍应保持独立 B 服务身份。

## 命名与发布

### 服务接口名

采用：

```text
B_功能代码
```

示例：
- `B_SglFreqMeas`
- `B_QueryDeviceInfo`
- `B_TaskModification`

注意：第 2 部分示例中曾出现 `B_SglFreqMeasure`，而第 3 部分正文条目使用 `B_SglFreqMeas`。工程实现时以现网 WSDL/对接协议为准；若存在别名兼容需求，统一在映射层处理。

### 代理/发布名

规范中给出了设备级发布命名思路：

```text
B_省_市_站_设备_序号
```

因此工程上建议区分两层：
- 逻辑服务名：`B_功能代码`
- 运行发布名/注册名：设备实例发布标识

## endpoint 规则

第 2 部分给出的服务终结点格式可概括为：

```text
scheme://host[:port]/服务类别/[设施ID]
```

其中：
- `scheme`：`http` 或 `https`
- `host`：寄宿主机 IP 或域名
- `port`：服务端口
- `服务类别`：如 `Base`、`Monitor`
- `设施ID`：对设备类服务通常有效

已抽取到的示例：
- 管控服务示例：`http://172.16.52.2:8013/Monitor`
- 设备操作服务示例：`http://172.16.52.33:8081/Base/21130001110001`

工程建议：
- 单独维护服务类别和默认端口常量。
- 设施 ID 拼接规则集中实现。
- 不要在业务逻辑中散落 endpoint 字符串拼接。

## 平台能力：注册、发现、调用、组合

第 2 部分已明确平台具备：
- 服务注册
- 服务发现
- 服务调用
- 服务组合

工程含义：
- B 层只负责暴露标准原子能力。
- 更粗粒度业务服务应由平台组合 B 与 D 形成。
- `M`/`D` 不应与 `B` 一起被硬揉进单个设备接口中。

## B 服务输入骨架

每个 B 服务输入由三部分组成：
- 任务参数
- 设备控制参数
- 结果返回方式参数

### 1. 任务参数

已确认的通用字段包括：
- `mfid`
- `equid`
- `executetime`
- `priority`
- `userid`
- `appid`

工程建议：
- 抽成统一 `TaskBaseRequest`。
- 所有 B 服务复用，不在每个服务重复定义。
- 需要任务控制的服务再增补 `taskid`。

### 2. 设备控制参数

设备控制参数不应在公共协议层胡乱抽象。

规范强调：
- 设备能力和参数定义应通过 `B_QueryDeviceInfo` 获取。
- 不同设备的差异由能力发现机制暴露。
- 调用方据此组织具体控制参数。

工程上应采用：
- 固定公共骨架。
- 可扩展的设备能力参数模型。
- 统一 `paraname/paravalue` 或等价 KV 结构。
- 若参数是区间，用 `range.startval/stopval`。
- 若参数是离散值，用 `list`。

### 3. 返回方式参数

已确认：
- `outputchannel` 是关键字段。
- 至少支持 `socket` 和 `ftp`。
- 输出中的 `outputchannel` 表示实际采用的结果返回方式。

工程建议统一定义：
- 返回通道枚举
- 通道配置模型
- 通道校验器
- 通道适配器/分发器

详见：`references/common-message-models.md`

## B 服务输出骨架

至少应包含：
- 任务受理/控制确认信息
- 实际 `outputchannel`
- `taskid`
- 错误信息 `error`

其中：
- `taskid` 是后续停止任务、查询任务、联动 M 服务的关键标识。
- 第 3 部分正文说明：服务执行失败时不返回 `taskid`。
- 因此成功与失败响应应明确区分，不能一律填默认任务号。

## SOAP 报文结构要点

从第 3 部分 SOAP 补充说明可确认的结构标签包括：
- `<soapenv:Envelope ...>`
- `xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"`
- `<srrc:MonitorHeader>`
- `<srrc:requestbody>`
- `<srrc:responsebody>`
- `<srrc:taskid>`
- `<srrc:outputchannel>`
- `<srrc:error>`

工程落地时建议统一报文层：
- Header：事务号、平台身份、保留字段
- Body.requestbody：公共任务参数 + 设备参数 + 返回通道
- Body.responsebody.result：任务回执/响应结果
- Body.responsebody.error：失败信息

详见：
- `references/soap-message-examples.md`
- `references/common-message-models.md`

## 能力发现：`B_QueryDeviceInfo`

`B_QueryDeviceInfo` 是 B 类原子服务开发的关键入口。正文明确：该服务为监测设备和环境监控设备必须支持的服务。

### 输入参数

| 参数名 | 必选 | 含义 |
|---|---:|---|
| `mfid` | 是 | 监测设施编号 |
| `equid` | 是 | 监测设备编号 |
| `feature` | 否 | 超短波设备操作服务代码 |

### 输出参数

已确认输出字段包括：
- `equtype`
- `equstatus`
- `multitask`
- `equimanu`
- `equmodel`
- `displayname`
- `equsn`
- `equdrivername`
- `equdriverversion`
- `host`
- `feature`
- `name`
- `range`
- `list`

其中：
- `multitask` 取 `true/false`
- `range` 可用 `startval/stopval` 表示区间
- `list` 用于离散可选值
- 可按项目需要扩展输出字段，更准确描述当前设备能力

工程意义：
- 它不仅是设备信息查询，更是能力发现入口。
- 应返回设备支持的服务列表及参数元数据。
- 后续具体 `B_xxx` 实现都应依赖这层能力模型。

详见：`references/query-device-info-model.md`

## 典型服务：`B_SglFreqMeas`

`B_SglFreqMeas` 是单频测量服务，用于对发射信号进行监测，对频率、场强、带宽、调制参数等进行测量。

正文已抽取到的可选控制参数包括：
- `antennaselect`
- `frequency`
- `ifbw`
- `demodmode`
- `demodbw`
- `span`
- `detector`
- `ITUSwitch`
- `spectrumswitch`
- `audiotype`
- `IQSwitch`
- `bwmeasuremode`
- `bwmeasurevalue`
- `rfmode`
- `rfattenuation`
- `rfattvalue`
- `gain`
- `mgc`

正文附录已抽到的真实联调示例值包括：
- `userid=admin`
- `appid=001`
- `priority=1`
- `mfid=21130001110001`
- `equid=89AEBF83A46F878E2389AEB879AE5F893EBX`
- `frequency=103900000`
- `ifbw=200000`
- `rbw=10000`
- `demodMode=FM`
- `rfmode=NORM`
- `rfattvalue=Auto`
- `detector=FAST`
- `xdb=26`
- `BETA=99`
- `audiotype=OFF`
- `spectrumswitch=ON`
- `IQSwitch=OFF`
- `ITUSwitch=ON`
- `outputchannel.sink.stream.host=172.18.225.78`
- `outputchannel.sink.stream.port=5000`
- `outputchannel.sink.stream.stc=101`
- `taskid=346434b0-d3a6-4dc0-a12a-498567a7d162`

关键约束：
- 这些参数属于单频测量能力，不能直接升级为所有 B 服务的公共字段。
- 参数是否可用、取值范围、是否必填，应以 `B_QueryDeviceInfo` 返回能力元数据为准。

## 任务控制相关原子服务

### `B_StopMeas`

用于停止测量任务。工程上至少应根据以下信息定位任务：
- `mfid`
- `equid`
- `taskid`

### `B_TaskModification`

正文明确输入参数包括：
- `mfid`
- `equid`
- `taskid`
- `ModifiedParamList`

输出参数为指令执行结果。

工程建议：
- 统一把可修改参数映射为参数列表模型。
- 修改前先校验任务是否存在、是否仍可修改。
- 修改参数必须受能力模型约束。

## 与 M / D / E 服务关系

### 与 M 服务关系

从补充说明中可确认一些管控接口族命名，如：
- `M_QueryDeviceInfo`
- `M_QueryFacilityInfo`
- `M_QueryEquStatus`
- `M_QueryTasks`
- `M_RegisterEquip`
- `M_RequestEquip`
- `M_PutEquStatus`

这说明平台管控层主要负责：
- 设备/设施信息查询
- 状态管理
- 任务管理
- 注册/申请/调度

因此 B 层只暴露原子设备能力；不要把这些管控职责塞进 B 层。

### 与 D 服务关系

D 层用于数据代理/数据服务。B 层通常只负责执行能力并通过 `outputchannel` 返回结果，不承担平台数据服务聚合职责。

### 与 E 服务关系

从第 3 部分与 SOAP 补充说明可确认 `E_QueryDeviceInfo`、`E_QueryEnviInfo`、`E_RemoteControl` 等接口线索，说明动环能力应保持独立于 `B` 的接口族。

详见：`references/integration-platform-context.md`

## 已确认 B 服务清单

已从第 3 部分正文标题可靠抽取的服务包括：
- `B_SglFreqMeas`
- `B_PScan`
- `B_MScan`
- `B_SglFreqDF`
- `B_FScanDF`
- `B_MScanDF`
- `B_DigSglRecDecode`
- `B_AnaTVDem`
- `B_DigTVDem`
- `B_DigBroadcastDem`
- `B_SpecCommSysSglDem`
- `B_OccuMeas`
- `B_GenIFSpecTemp`
- `B_GenWBSpecTemp`
- `B_IFSglInte`
- `B_DDCMeas`
- `B_StopMeas`
- `B_SelfTest`
- `B_SetDevicePower`
- `B_QueryDeviceInfo`
- `B_TaskModification`

更完整拆分索引见：`references/b-service-catalog.md`

## 开发约束

### 应该做

- 一个能力一个 B 服务。
- 公共任务参数统一抽象。
- 用能力发现定义设备私有参数。
- 统一返回 `taskid`。
- 统一处理 `outputchannel`。
- 给出可直接编码的 SOAP/DTO 示例。

### 不应该做

- 一个服务承载多个方法或多个设备能力。
- 在 B 层塞入业务编排逻辑。
- 把设备私有参数冒充成通用标准参数。
- 漏掉任务标识与返回通道。
- 用户要报文示例时只给抽象总结。

## 推荐代码组织

建议最少拆成这些模块：
- `models/task_base.*`
- `models/output_channel.*`
- `models/device_capability.*`
- `models/task_receipt.*`
- `models/soap_header.*`
- `services/b_query_device_info.*`
- `services/b_<capability_name>.*`
- `constants/service_endpoints.*`

## 开发检查清单

在实现任何一个 B 服务前，先检查：
- 是否真的是单一设备能力。
- 是否有统一任务参数骨架。
- 是否通过能力发现定义设备参数。
- 是否支持规范要求的返回通道。
- 是否返回 `taskid`。
- 失败时是否不返回 `taskid`。
- 是否把业务编排错误地下沉到了 B 层。
- 是否给出了请求/响应报文示例。

## 推荐给 agent 的提示词

```text
请使用技能 uhf-b-service-packaging，为当前项目新增/重构一个 B 类原子服务。先阅读 b-service-spec、integration-platform-context、common-message-models、soap-message-examples、query-device-info-model、b-service-catalog 六份参考，再完成：
1. 服务命名与 endpoint 设计；
2. 公共任务参数 DTO；
3. 该 B 服务控制参数 DTO；
4. SOAP/XML 请求响应模型；
5. taskid / outputchannel / error 返回骨架；
6. QueryDeviceInfo 能力元数据对齐；
7. 如有需要补停止或任务修改接口联动。
```

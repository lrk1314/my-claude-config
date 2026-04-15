# B 类原子服务清单与拆分索引

本文件用于后续按规范拆分和命名 `B` 类设备操作原子服务。服务名称来自第 3 部分正文抽取结果以及全文 `B_` 标识补充校验。

## 命名规则

服务接口名采用：

```text
B_功能代码
```

第 2 部分示例给出“超短波单频测量服务”的服务名为 `B_SglFreqMeasure`；第 3 部分设备操作服务正文中实际服务条目使用 `B_SglFreqMeas`。开发时应以当前项目对接方/现有 WSDL 为准，但不要同时混用两套别名；如果必须兼容，做显式 alias 映射。

## 已确认服务条目

| 条款 | 服务名 | 中文名称/能力 |
|---|---|---|
| 4.2.2 | `B_SglFreqMeas` | 单频测量 |
| 4.2.5 | `B_PScan` | 全景扫描频谱观测 |
| 4.2.6 | `B_MScan` | 存储频率列表扫描 |
| 4.2.7 | `B_SglFreqDF` | 单频测向 |
| 4.2.9 | `B_FScanDF` | 扫频测向 |
| 4.2.10 | `B_MScanDF` | 频率表扫描测向 |
| 4.2.11 | `B_DigSglRecDecode` | 数字信号识别解调 |
| 4.2.12 | `B_AnaTVDem` | 模拟电视信号解调 |
| 4.2.13 | `B_DigTVDem` | 数字电视信号解调 |
| 4.2.14 | `B_DigBroadcastDem` | 数字广播信号解调 |
| 4.2.15 | `B_SpecCommSysSglDem` | 专用通信系统信号解调 |
| 4.2.16 | `B_OccuMeas` | 占用度测量 |
| 4.2.17 | `B_GenIFSpecTemp` | 生成中频频谱模板 |
| 4.2.18 | `B_GenWBSpecTemp` | 生成宽带频谱模板 |
| 4.2.20 | `B_IFSglInte` | 中频频谱信号截收 |
| 4.2.24 | `B_DDCMeas` | 多路通道监测 |
| 4.2.25 | `B_StopMeas` | 停止测量任务 |
| 4.2.26 | `B_SelfTest` | 监测设备自检 |
| 4.2.28 | `B_SetDevicePower` | 监测设备电源开关 |
| 4.2.30 | `B_QueryDeviceInfo` | 监测设备信息查询 |
| 4.2.31 | `B_TaskModification` | 监测参数修改 |

## 全文出现但抽取标题不完整的 B 标识

以下标识在正文全文出现，但由于抽取文本存在分页/断字/识别问题，部分标题未被完整恢复。后续开发前应回到对应原文页或 WSDL 进一步确认：

- `B_DigSglRec`
- `B_FScan`
- `B_FScanSglInt`
- `B_FScanSglInte`
- `B_GenFScanSpec`
- `B_GenFScanSpecTemp`
- `B_GenIFSpe`
- `B_LinkAnteDe`
- `B_LinkAnteDev`
- `B_QueryFaciDevStat`
- `B_QueryFaciDevStatus`
- `B_TDOAMeas`
- `B_TDOAqMeas`
- `B_WBDF`
- `B_WBFFTMon`
- `B_WBSglInt`
- `B_WBSglInte`

## 拆分原则

开发或重构时按以下规则处理：

- 表中每个 `B_xxx` 都应被视为一个独立原子服务候选。
- 不要把 `B_SglFreqMeas`、`B_SglFreqDF`、`B_StopMeas` 合并到同一个接口方法集合里。
- `B_StopMeas`、`B_TaskModification` 这类任务后续操作也仍属于独立 B 服务，不应塞到所有测量服务内部。
- `B_QueryDeviceInfo` 是能力发现入口，必须优先保证可用。
- 能力不支持时应通过 `B_QueryDeviceInfo.feature` 或能力元数据暴露，而不是调用时才隐式失败。

## `B_SglFreqMeas` 控制参数示例

第 3 部分正文给出的单频测量可选控制指令参数包括：

| 参数名 | 含义 | 备注 |
|---|---|---|
| `antennaselect` | 天线选择名称 | 无此输入参数表示由接收机选择默认天线 |
| `frequency` | 中心频率 | 指定被测量的频率 |
| `ifbw` | 中频带宽 | 指定被测量频率的中频带宽 |
| `demodmode` | 解调方式 | 见附录 B.7 |
| `demodbw` | 解调带宽 | 存在解调方式时有效；不给出则以 `ifbw` 为解调带宽 |
| `span` | 跨距 | `ifbw <= span`，单位 Hz |
| `detector` | 检波方式 | 见附录 B.8 |
| `ITUSwitch` | ITU 测量数据开关 | 见附录 B.17 |
| `spectrumswitch` | 频谱数据开关 | 见附录 B.18 |
| `audiotype` | 音频数据类型 | 见附录 B.19 |
| `IQSwitch` | IQ 数据开关 | 见附录 B.20 |
| `bwmeasuremode` | 带宽测量模式 | `xdb` 和 `betarate` 二选一；见附录 B.10 |
| `bwmeasurevalue` | 带宽测量值 | 与带宽测量模式对应 |
| `rfmode` | 射频工作模式 | 见附录 B.11 |
| `rfattenuation` | 射频衰减 | 设备支持时使用 |
| `rfattvalue` | 衰减值 | 射频前端开启衰减模式时有效，单位 dB |
| `gain` | 增益模式 | 开启增益模式或支持增益控制时有效；见附录 B.12 |
| `mgc` | 增益值 | 增益模式为 `MGC` 时有效，单位 dB |

注意：这些是 `B_SglFreqMeas` 的能力参数示例，不能无脑提升为所有 B 服务的公共参数。

## 任务后续操作服务

### `B_StopMeas`

用于停止测量任务，通常需要至少定位：
- `mfid`
- `equid`
- `taskid`

### `B_TaskModification`

正文说明用于对正在执行的服务进行任务参数修改，输入参数包括：
- `mfid`
- `equid`
- `taskid`
- `ModifiedParamList`

输出参数为指令执行结果。

实现建议：
- 修改参数仍复用 `paraname/paravalue` 模型。
- 修改前校验 `taskid` 是否存在且任务仍运行。
- 修改参数必须来自该任务对应能力的可修改参数集合。

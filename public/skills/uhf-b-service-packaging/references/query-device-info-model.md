# `B_QueryDeviceInfo` 能力发现模型

`B_QueryDeviceInfo` 是 B 类原子服务开发的关键入口。第 3 部分正文明确：该服务为监测设备和环境监控设备必须支持的服务，用于获得设备基本信息及扩展信息，完成设备管理或为其他服务提供控制依据；同时给出该设备支持的超短波监测服务列表及相应输入输出参数。

## 输入参数

正文明确输入参数为：

| 参数名 | 必选 | 含义 |
|---|---:|---|
| `mfid` | 是 | 监测设施编号 |
| `equid` | 是 | 监测设备编号 |
| `feature` | 否 | 超短波设备操作服务代码，见附录 B.1 |

## 输出参数

正文表 26 给出的输出参数均为必选参数：

| 参数名 | 含义 | 备注 |
|---|---|---|
| `equtype` | 监测设备类型 | 见 GB/T 34084 |
| `equstatus` | 设备状态 | 见 GB/T 34084 |
| `multitask` | 设备多任务能力 | `true` 支持多任务；`false` 不支持多任务 |
| `equimanu` | 生产厂家 | 设备厂家 |
| `equmodel` | 型号 | 设备型号 |
| `displayname` | 设备显示名称 | 前端展示名 |
| `equsn` | 序列号 | 设备序列号 |
| `equdrivername` | 驱动名称 | 设备驱动名称 |
| `equdriverversion` | 驱动版本 | 设备驱动版本 |
| `host` | IP 地址 | 设备或服务主机地址 |
| `feature` | 支持的设备操作服务 | 给出超短波设备操作服务代码，见附录 B.1 |
| `name` | 服务输入参数名称 | 能力参数名 |
| `range` | 支持的输入参数取值范围 | 范围参数用 `startval/stopval` 描述 |
| `list` | 支持的输入参数取值列表 | 离散可选值列表 |

正文注释：为准确描述当前查询的服务，可对输出参数进行扩展。

## 推荐响应模型

为了便于代码实现，可将规范参数映射为以下结构：

```json
{
  "mfid": "21130001110001",
  "equid": "EB500_01",
  "equtype": "receiver",
  "equstatus": "normal",
  "multitask": true,
  "equimanu": "vendor",
  "equmodel": "model",
  "displayname": "固定站接收机 01",
  "equsn": "SN0001",
  "equdrivername": "driver-name",
  "equdriverversion": "1.0.0",
  "host": "172.16.52.33",
  "features": [
    {
      "feature": "B_SglFreqMeas",
      "parameters": [
        {
          "name": "frequency",
          "range": { "startval": 30000000, "stopval": 3000000000 },
          "list": null,
          "required": false,
          "unit": "Hz"
        },
        {
          "name": "demodmode",
          "range": null,
          "list": ["AM", "FM"],
          "required": false
        }
      ],
      "outputs": ["taskid", "outputchannel"]
    }
  ],
  "exinfo": {}
}
```

注意：`required/unit/outputs/exinfo` 属于工程扩展字段，用于更准确描述能力；保留规范中的 `feature/name/range/list` 语义。

## XML 响应示例

```xml
<srrc:responsebody>
  <srrc:result>
    <srrc:equtype>receiver</srrc:equtype>
    <srrc:equstatus>normal</srrc:equstatus>
    <srrc:multitask>true</srrc:multitask>
    <srrc:equimanu>vendor</srrc:equimanu>
    <srrc:equmodel>model</srrc:equmodel>
    <srrc:displayname>固定站接收机 01</srrc:displayname>
    <srrc:equsn>SN0001</srrc:equsn>
    <srrc:equdrivername>driver-name</srrc:equdrivername>
    <srrc:equdriverversion>1.0.0</srrc:equdriverversion>
    <srrc:host>172.16.52.33</srrc:host>
    <srrc:feature>B_SglFreqMeas</srrc:feature>
    <srrc:name>frequency</srrc:name>
    <srrc:range>
      <srrc:startval>30000000</srrc:startval>
      <srrc:stopval>3000000000</srrc:stopval>
    </srrc:range>
    <srrc:list></srrc:list>
  </srrc:result>
</srrc:responsebody>
```

如果一个设备支持多个能力或一个能力有多个参数，工程上建议用数组/列表承载，再序列化为对接方要求的 XML 结构。

## 开发要求

实现任何具体 `B_xxx` 服务前，先确认：

1. `B_QueryDeviceInfo` 是否能返回该 `feature`。
2. 该 `feature` 是否返回参数名 `name`。
3. 参数是否有 `range` 或 `list` 约束。
4. 是否需要扩展字段描述单位、是否必填、默认值、数据类型。
5. 不支持的能力应在能力发现阶段暴露，不要等调用测量服务时才失败。

## 与原子化封装的关系

`B_QueryDeviceInfo` 的核心作用是避免把所有设备参数写死在代码里：

- 公共请求骨架固定：`appid/userid/priority/executetime/mfid/equid/outputchannel`。
- 设备控制参数动态：通过 `feature/name/range/list` 描述。
- 具体原子服务只执行一个能力：如 `B_SglFreqMeas`、`B_SglFreqDF`。
- 设备能力变化时，优先更新能力发现数据，而不是改公共协议模型。

# 公共报文模型与 DTO 建模约束

本文件把第 2、3 部分正文与第 3 部分 SOAP 补充说明中可稳定复用的公共结构，整理为可直接编码的 DTO / schema / XSD 建模手册。

## 1. 统一报文分层

`B` 类原子服务建议统一抽象为四层：
- `MonitorHeader`：事务、平台身份、扩展保留字段
- `requestbody`：任务参数 + 设备参数 + 返回方式
- `responsebody.result`：成功回执与受理结果
- `responsebody.error`：失败结果

如果项目内部采用 SOAP-to-DTO 映射，推荐固定以下模型：
- `MonitorHeader`
- `TaskBaseRequest`
- `ParameterItem`
- `ParameterGroup`
- `EquPara`
- `OutputChannel`
- `TaskAcceptedResult`
- `ServiceError`

## 2. Header 模型

第 3 部分 SOAP 补充说明中可确认 `MonitorHeader` 包含：
- `TransId`
- `BizKey`
- `PSCode`
- `BSCode`
- `appCode`
- `appName`
- `platFormCode`
- `platFormName`
- `resCode1`
- `resCode2`

推荐 DTO：

```json
{
  "transId": "string",
  "bizKey": "string",
  "psCode": "string",
  "bsCode": "string",
  "appCode": "string",
  "appName": "string",
  "platFormCode": "string",
  "platFormName": "string",
  "resCode1": "string",
  "resCode2": "string"
}
```

工程约束：
- `transId` 必须可追踪单次调用。
- `bizKey` 用于跨系统业务关联时不要省略。
- `resCode1/resCode2` 即便暂未启用，也应在序列化层保留。

## 3. 通用任务参数模型

第 3 部分正文确认，`B` 服务输入由三部分组成：任务参数、设备控制参数、结果返回方式参数。

通用任务参数骨架：
- `appid`
- `userid`
- `priority`
- `executetime`
- `mfid`
- `equid`

任务类后续动作追加：
- `taskid`：停止、修改、查询已存在任务时使用

推荐 DTO：

```json
{
  "appid": "string",
  "userid": "string",
  "priority": 1,
  "executetime": 0,
  "mfid": "21130001110001",
  "equid": "DEVICE-ID",
  "taskid": "optional"
}
```

工程约束：
- `mfid/equid` 在设备原子服务中通常都是定位设备实例的主键。
- `executetime=0` 可表示持续执行，是否允许由具体服务约束决定。
- `taskid` 不应无差别放入所有新建任务接口的必填项。

## 4. 设备参数模型 `equpara`

第 3 部分 SOAP 补充说明中可确认：
- 普通参数容器：`items/item/paraname/paravalue`
- 分组参数容器：`groupitems/groupitem/groupid/items/item/paraname/paravalue`

推荐 DTO：

```json
{
  "items": [
    {"paraname": "frequency", "paravalue": "103900000"}
  ],
  "groupitems": [
    {
      "groupid": "1",
      "items": [
        {"paraname": "startfreq", "paravalue": "87000000"},
        {"paraname": "stopfreq", "paravalue": "108000000"}
      ]
    }
  ]
}
```

工程约束：
- 参数名统一保留规范中的原始大小写风格，不要随意改名。
- 参数是否允许为空、是否可重复、是否需要分组，优先由 `B_QueryDeviceInfo` 返回的能力元数据决定。
- 如果底层代码使用强类型字段，也应保留一个通用 `equpara` 映射层用于兼容协议。

## 5. 扩展参数模型 `exinfo`

SOAP 补充说明中存在：
- `exinfo/item/paraname/paravalue`

推荐用途：
- 承载非核心控制参数
- 承载调用链附加上下文
- 承载设备厂商补充字段

推荐 DTO：

```json
{
  "exinfo": [
    {"paraname": "vendorFlag", "paravalue": "true"}
  ]
}
```

工程约束：
- `exinfo` 只能做扩展，不要把规范主字段塞进去。
- 若扩展字段被项目正式采纳，应尽量升级回显式 schema，而不是长期停留在匿名 KV。

## 6. 输出通道模型 `outputchannel`

第 3 部分正文和正文附录 XML 可确认：
- `outputchannel` 为结果返回方式参数
- 至少支持 `socket` / `ftp`
- XML 示例中出现了 `sink/source`、`stream`、`FTP`、`host`、`port`、`stc`、`user`、`password`、`file`

推荐统一模型：

```json
{
  "source": {
    "stream": {
      "host": "127.0.0.1",
      "port": 5000,
      "stc": "101"
    },
    "ftp": {
      "host": "127.0.0.1",
      "port": 21,
      "user": "demo",
      "password": "demo",
      "file": "/path/result.dat"
    }
  },
  "sink": {
    "stream": {
      "host": "127.0.0.1",
      "port": 5000,
      "stc": "101"
    },
    "ftp": {
      "host": "127.0.0.1",
      "port": 21,
      "user": "demo",
      "password": "demo",
      "file": "/path/result.dat"
    }
  }
}
```

实现建议：
- 代码里可以额外提供简化枚举 `mode=socket|ftp`，但序列化层要能映射回 XML 结构。
- `sink/source` 方向不要丢；如果项目内部语义不清，应在适配层明确约定。
- `stream` 可视为 socket/流式通道；`FTP` 视为文件传输通道。

## 7. 成功响应模型

第 3 部分正文示例说明：成功响应中会回显主要请求参数、`outputchannel`，并返回 `taskid`。

正文已抽到的真实示例值包括：
- `mfid=21130001110001`
- `equid=89AEBF83A46F878E2389AEB879AE5F893EBX`
- `frequency=103900000`
- `ifbw=200000`
- `demodMode=FM`
- `host=172.18.225.78`
- `port=5000`
- `stc=101`
- `taskid=346434b0-d3a6-4dc0-a12a-498567a7d162`

推荐 DTO：

```json
{
  "result": {
    "taskid": "346434b0-d3a6-4dc0-a12a-498567a7d162",
    "requestEcho": {},
    "equpara": {},
    "outputchannel": {}
  }
}
```

工程约束：
- 成功回执阶段返回的是“任务已受理 + 如何取结果”，不是最终业务数据全集。
- 需要持续输出结果的服务，应通过 `outputchannel` 推送后续数据。

## 8. 失败响应模型

SOAP 补充说明中可确认失败结构：
- `error/type`
- `error/code`
- `error/text`

推荐 DTO：

```json
{
  "error": {
    "type": "BusinessError",
    "code": "B-4001",
    "text": "frequency out of range"
  }
}
```

工程约束：
- 第 3 部分正文明确：执行失败不返回 `taskid`。
- 不能在失败响应中回填伪造任务号。
- `type/code/text` 三元组应在项目中固化错误枚举。

## 9. `B_QueryDeviceInfo` 推荐返回模型

根据正文与 SOAP 标签集合，推荐把能力发现结果映射为：

```json
{
  "equtype": "receiver",
  "equstatus": "idle",
  "multitask": true,
  "equimanu": "vendor",
  "equmodel": "model",
  "displayname": "设备显示名",
  "equsn": "SN001",
  "equdrivername": "driver",
  "equdriverversion": "1.0.0",
  "host": "172.16.1.10",
  "featurelist": [
    {
      "feature": "B_SglFreqMeas",
      "input": [
        {
          "parameter": "frequency",
          "type": "number",
          "checkrestricts": {
            "range": {"startval": "87000000", "stopval": "108000000"},
            "list": []
          },
          "setparameter": true,
          "resultparameters": []
        }
      ]
    }
  ]
}
```

注意：
- `featurelist/input/parameter/checkrestricts/setparameter/resultparameters` 这些标签来自 SOAP 补充说明标签集合，适合作为工程能力模型骨架。
- 如果现网系统字段名与此略有不同，优先在适配层做 alias，不要抛弃能力发现模型本身。

## 10. 推荐代码模块

最少抽这些公共模块：
- `monitor_header`
- `task_base_request`
- `parameter_item`
- `parameter_group`
- `equpara`
- `output_channel`
- `service_result`
- `service_error`
- `query_device_info_model`

这样后续新增任意 `B_xxx` 服务时，只需增加：
- 服务名常量
- 特有控制参数映射
- 特有结果数据解释层

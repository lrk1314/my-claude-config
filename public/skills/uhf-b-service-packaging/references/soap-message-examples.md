# SOAP 报文与 XML 结构示例

本文件补充 `B` 类原子服务开发时必须具备的 SOAP/XML 报文骨架。来源为第 3 部分设备操作服务 SOAP 报文补充说明与第 3 部分正文条款抽取结果。

## 基本约定

- SOAP 命名空间：`http://schemas.xmlsoap.org/soap/envelope/`
- 业务命名空间：`http://www.srrc.org.cn`
- 常见前缀：`soapenv`、`srrc`
- 请求体容器：`srrc:requestbody`
- 响应体容器：`srrc:responsebody`
- 请求头容器：`srrc:MonitorHeader`
- 常见请求/响应骨架：`query/get/result/error`

## 补充说明中已稳定定位的标签

从第 3 部分 SOAP 补充说明可确认的高频标签包括：
- `Envelope`
- `Header`
- `Body`
- `MonitorHeader`
- `requestbody`
- `responsebody`
- `result`
- `error`
- `taskid`
- `appid`
- `userid`
- `priority`
- `executetime`
- `mfid`
- `equid`
- `equpara`
- `items/item/paraname/paravalue`
- `groupitems/groupitem/groupid`
- `exinfo`
- `outputchannel`
- `mode`
- `datachannel`
- `host`
- `port`
- `stc`
- `user`
- `password`
- `file`
- `type`
- `code`
- `text`

这些标签足以支撑 agent 直接搭建稳定的 SOAP DTO / XML schema。

## SOAP Header 骨架

补充说明中可见的 `MonitorHeader` 字段包括：

```xml
<soapenv:Header>
  <srrc:MonitorHeader>
    <srrc:TransId></srrc:TransId>
    <srrc:BizKey></srrc:BizKey>
    <srrc:PSCode></srrc:PSCode>
    <srrc:BSCode></srrc:BSCode>
    <srrc:appCode></srrc:appCode>
    <srrc:appName></srrc:appName>
    <srrc:platFormCode></srrc:platFormCode>
    <srrc:platFormName></srrc:platFormName>
    <srrc:resCode1></srrc:resCode1>
    <srrc:resCode2></srrc:resCode2>
  </srrc:MonitorHeader>
</soapenv:Header>
```

工程建议：
- `TransId` 用作本次请求流水/事务标识。
- `BizKey` 用作业务键或关联键。
- `appCode/appName/platFormCode/platFormName` 与调用平台身份相关。
- `resCode1/resCode2` 作为预留扩展字段保留，不应随意删除。

## 标准 Envelope 骨架

```xml
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:srrc="http://www.srrc.org.cn">
  <soapenv:Header>
    <srrc:MonitorHeader>
      <srrc:TransId>${transId}</srrc:TransId>
      <srrc:BizKey>${bizKey}</srrc:BizKey>
      <srrc:PSCode>${psCode}</srrc:PSCode>
      <srrc:BSCode>${bsCode}</srrc:BSCode>
      <srrc:appCode>${appCode}</srrc:appCode>
      <srrc:appName>${appName}</srrc:appName>
      <srrc:platFormCode>${platformCode}</srrc:platFormCode>
      <srrc:platFormName>${platformName}</srrc:platFormName>
      <srrc:resCode1>${resCode1}</srrc:resCode1>
      <srrc:resCode2>${resCode2}</srrc:resCode2>
    </srrc:MonitorHeader>
  </soapenv:Header>
  <soapenv:Body>
    <!-- requestbody 或 responsebody -->
  </soapenv:Body>
</soapenv:Envelope>
```

## B 服务请求报文骨架

```xml
<soapenv:Body>
  <srrc:requestbody>
    <srrc:appid>${appid}</srrc:appid>
    <srrc:userid>${userid}</srrc:userid>
    <srrc:priority>${priority}</srrc:priority>
    <srrc:executetime>${executetime}</srrc:executetime>
    <srrc:mfid>${mfid}</srrc:mfid>
    <srrc:equid>${equid}</srrc:equid>
    <srrc:taskid>${taskid}</srrc:taskid>

    <srrc:equpara>
      <srrc:items>
        <srrc:item>
          <srrc:paraname>${paramName}</srrc:paraname>
          <srrc:paravalue>${paramValue}</srrc:paravalue>
        </srrc:item>
      </srrc:items>
      <srrc:groupitems>
        <srrc:groupitem>
          <srrc:groupid>${groupId}</srrc:groupid>
          <srrc:items>
            <srrc:item>
              <srrc:paraname>${groupParamName}</srrc:paraname>
              <srrc:paravalue>${groupParamValue}</srrc:paravalue>
            </srrc:item>
          </srrc:items>
        </srrc:groupitem>
      </srrc:groupitems>
    </srrc:equpara>

    <srrc:exinfo>
      <srrc:item>
        <srrc:paraname>${extParamName}</srrc:paraname>
        <srrc:paravalue>${extParamValue}</srrc:paravalue>
      </srrc:item>
    </srrc:exinfo>

    <srrc:outputchannel>
      <!-- 见下文 stream / FTP 示例 -->
    </srrc:outputchannel>
  </srrc:requestbody>
</soapenv:Body>
```

## `outputchannel` 规范骨架

从正文 XML 附录与 SOAP 补充说明可确认 `outputchannel` 至少存在两种通道组织方式。

### Stream / socket 型

```xml
<outputchannel>
  <sink>
    <stream>
      <host>172.18.225.78</host>
      <port>5000</port>
      <stc>101</stc>
    </stream>
  </sink>
</outputchannel>
```

### FTP 型

```xml
<outputchannel>
  <source>
    <FTP>
      <host>IP地址</host>
      <port>连接端口</port>
      <user>用户</user>
      <password>密码</password>
      <file>文件</file>
    </FTP>
  </source>
</outputchannel>
```

工程解释：
- `stream` 可按 socket/流式推送理解。
- `FTP` 可按文件传输理解。
- `sink/source` 方向在不同项目中可能语义有差异，建议在适配层固定一版，不要在业务层反复判断。

## B 服务响应报文骨架

```xml
<soapenv:Body>
  <srrc:responsebody>
    <srrc:result>
      <srrc:taskid>${taskid}</srrc:taskid>
      <srrc:equpara>
        <srrc:items>
          <srrc:item>
            <srrc:paraname>${paramName}</srrc:paraname>
            <srrc:paravalue>${paramValue}</srrc:paravalue>
          </srrc:item>
        </srrc:items>
      </srrc:equpara>
      <srrc:outputchannel>
        <!-- 实际采用的结果返回方式 -->
      </srrc:outputchannel>
    </srrc:result>
    <srrc:error>
      <srrc:type>${errorType}</srrc:type>
      <srrc:code>${errorCode}</srrc:code>
      <srrc:text>${errorText}</srrc:text>
    </srrc:error>
  </srrc:responsebody>
</soapenv:Body>
```

## 正文附录中已抽到的 `B_SglFreqMeas` 真实示例

第 3 部分正文附录已抽到一段较完整的单频测量示例值，可直接作为联调模板：

### 请求侧关键值

```xml
<query>
  <get>
    <userid>admin</userid>
    <appid>001</appid>
    <priority>1</priority>
    <mfid>21130001110001</mfid>
    <equid>89AEBF83A46F878E2389AEB879AE5F893EBX</equid>
    <executetime>0</executetime>
    <antennaselect>垂直监听</antennaselect>
    <frequency>103900000</frequency>
    <ifbw>200000</ifbw>
    <rbw>10000</rbw>
    <demodMode>FM</demodMode>
    <rfmode>NORM</rfmode>
    <rfattvalue>Auto</rfattvalue>
    <detector>FAST</detector>
    <xdb>26</xdb>
    <BETA>99</BETA>
    <audiotype>OFF</audiotype>
    <spectrumswitch>ON</spectrumswitch>
    <IQSwitch>OFF</IQSwitch>
    <ITUSwitch>ON</ITUSwitch>
    <outputchannel>
      <sink>
        <stream>
          <host>172.18.225.78</host>
          <port>5000</port>
          <stc>101</stc>
        </stream>
      </sink>
    </outputchannel>
  </get>
</query>
```

### 成功响应关键值

```xml
<query>
  <result>
    <userid>admin</userid>
    <appid>001</appid>
    <priority>1</priority>
    <mfid>21130001110001</mfid>
    <equid>89AEBF83A46F878E2389AEB879AE5F893EBX</equid>
    <executetime>0</executetime>
    <frequency>103900000</frequency>
    <ifbw>200000</ifbw>
    <demodMode>FM</demodMode>
    <rfmode>NORM</rfmode>
    <rfattvalue>Auto</rfattvalue>
    <detector>FAST</detector>
    <audiotype>OFF</audiotype>
    <spectrumswitch>ON</spectrumswitch>
    <IQSwitch>OFF</IQSwitch>
    <ITUSwitch>ON</ITUSwitch>
    <outputchannel>
      <sink>
        <stream>
          <host>172.18.225.78</host>
          <port>5000</port>
          <stc>101</stc>
        </stream>
      </sink>
    </outputchannel>
    <taskid>346434b0-d3a6-4dc0-a12a-498567a7d162</taskid>
  </result>
</query>
```

### 失败响应骨架

```xml
<query>
  <error>
    <type>错误类别</type>
    <code>错误编码</code>
    <text>详细的错误描述</text>
  </error>
</query>
```

## `B_QueryDeviceInfo` 请求/响应模板

### 请求模板

```xml
<srrc:requestbody>
  <srrc:mfid>${mfid}</srrc:mfid>
  <srrc:equid>${equid}</srrc:equid>
  <srrc:feature>${feature}</srrc:feature>
</srrc:requestbody>
```

### 推荐响应模板

```xml
<srrc:responsebody>
  <srrc:result>
    <srrc:equtype>${equtype}</srrc:equtype>
    <srrc:equstatus>${equstatus}</srrc:equstatus>
    <srrc:multitask>${multitask}</srrc:multitask>
    <srrc:equimanu>${equimanu}</srrc:equimanu>
    <srrc:equmodel>${equmodel}</srrc:equmodel>
    <srrc:displayname>${displayname}</srrc:displayname>
    <srrc:equsn>${equsn}</srrc:equsn>
    <srrc:host>${host}</srrc:host>
    <srrc:featurelist>
      <srrc:feature>${featureCode}</srrc:feature>
      <srrc:input>
        <srrc:parameter>${parameterName}</srrc:parameter>
        <srrc:type>${parameterType}</srrc:type>
        <srrc:checkrestricts>
          <srrc:range>
            <srrc:startval>${start}</srrc:startval>
            <srrc:stopval>${stop}</srrc:stopval>
          </srrc:range>
          <srrc:list>
            <srrc:listitem>
              <srrc:val>${value}</srrc:val>
              <srrc:display>${label}</srrc:display>
            </srrc:listitem>
          </srrc:list>
        </srrc:checkrestricts>
        <srrc:setparameter>${settable}</srrc:setparameter>
        <srrc:resultparameters>
          <srrc:resultparameter>${resultParam}</srrc:resultparameter>
        </srrc:resultparameters>
      </srrc:input>
    </srrc:featurelist>
  </srrc:result>
</srrc:responsebody>
```

说明：
- `featurelist/input/parameter/checkrestricts/setparameter/resultparameters` 这些节点来自 SOAP 补充说明标签集合，适合作为工程可落地的能力元数据结构。
- 若现网 WSDL 字段略有变体，可在序列化适配层做 alias。

## 实现时必须固化的规则

- 成功受理任务才返回 `taskid`。
- 失败响应不返回伪造 `taskid`。
- `outputchannel` 既要出现在请求中，也要出现在成功响应中，表示实际采用的结果通道。
- 通用任务参数必须抽公共模型，不要每个服务各写一份。
- `B_QueryDeviceInfo` 的能力元数据应成为设备私有参数校验的单一事实来源。

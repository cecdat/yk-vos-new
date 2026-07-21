# VOS3000 数据库全量结构与核心关联架构分析报告

本报告基于 VOS3000 DDL 结构定义（包含 152 张物理数据表）进行系统化梳理，详细展现了 VOS3000 的业务模块划分、各表的主外键物理关系以及关键业务场景的数据流向模型。

## 一、 数据库模块划分与表清单

### 1. 客户与账户模块 (Customer & Account)
该模块包含 **2** 张表。主要核心表及结构如下：

#### 📋 表名: `e_customer`
* **主键**: `id`
* **索引**: 
  * `feerategroup_id` -> `(feerategroup_id)`
  * `feerategroupprivate_id` -> `(feerategroupprivate_id)`
  * `calendar_id` -> `(calendar_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `account` | `varchar(255)` |
| `name` | `varchar(255)` |
| `password` | `varchar(255)` |
| `type` | `int` |
| `bitsofconfig` | `int` |
| `starttime` | `bigint` |
| `lastupdatetime` | `bigint` |
| `money` | `double` |
| `validtime` | `bigint` |
| `locktype` | `int` |
| `status` | `int` |
| `limitmoney` | `double` |
| `todayconsumption` | `double` |
| `memo` | `varchar(255)` |
| ... | (共计 30 个字段) |

---

#### 📋 表名: `e_customerdetail`
* **主键**: `customer_id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `address` | `varchar(255)` |
| `linkman` | `varchar(255)` |
| `phone` | `varchar(255)` |
| `email` | `varchar(255)` |
| `emailcc` | `varchar(255)` |
| `emailbcc` | `varchar(255)` |
| `reporttype` | `int` |
| `nextreporttime` | `bigint` |
| `postcode` | `varchar(255)` |
| `fax` | `varchar(255)` |
| `idtype` | `int` |
| `idnumber` | `varchar(255)` |
| `bankaccount` | `varchar(255)` |
| `companyname` | `varchar(255)` |
| `customer_id` | `int` |

---

### 2. 接入对接网关 (Gateway Mapping / Inbound)
该模块包含 **3** 张表。主要核心表及结构如下：

#### 📋 表名: `e_gatewaygroup`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `name` | `varchar(255)` |
| `capacity` | `int` |
| `memo` | `varchar(255)` |

---

#### 📋 表名: `e_gatewaymapping`
* **主键**: `id`
* **索引**: 
  * `customer_id` -> `(customer_id)`
  * `mbx_id` -> `(mbx_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `name` | `varchar(255)` |
| `password` | `varchar(255)` |
| `customerpassword` | `varchar(255)` |
| `locktype` | `int` |
| `calllevel` | `int` |
| `capacity` | `int` |
| `priority` | `int` |
| `registertype` | `int` |
| `remoteips` | `text` |
| `rtpforwardtype` | `int` |
| `gatewaygroups` | `text` |
| `routinggatewaygroups` | `text` |
| `memo` | `varchar(255)` |
| `customer_id` | `int` |
| ... | (共计 16 个字段) |

---

#### 📋 表名: `e_gatewaymappingsetting`
* **主键**: `gatewaymapping_id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `callercitye164check` | `int` |
| `calleecitye164check` | `int` |
| `calloutcallerprefixesallow` | `tinyint(1)` |
| `calloutcallerprefixes` | `text` |
| `calloutcalleeprefixesallow` | `tinyint(1)` |
| `calloutcalleeprefixes` | `text` |
| `rewriterulesoutcallee` | `text` |
| `rewriterulesoutcaller` | `text` |
| `rewriterulesinmobilearea` | `text` |
| `scheduledcalloutprefixes` | `text` |
| `scheduledrewriterulesout` | `text` |
| `scheduledcapacity` | `text` |
| `timeoutcallproceeding` | `int` |
| `dtmfreceivemethod` | `int` |
| `dtmfsendmethodh323` | `int` |
| ... | (共计 86 个字段) |

---

### 3. 呼出落地网关 (Gateway Routing / Outbound)
该模块包含 **2** 张表。主要核心表及结构如下：

#### 📋 表名: `e_gatewayrouting`
* **主键**: `id`
* **索引**: 
  * `mbx_id` -> `(mbx_id)`
  * `clearingcustomer_id` -> `(clearingcustomer_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `name` | `varchar(255)` |
| `prefix` | `text` |
| `prefixstyle` | `int` |
| `password` | `varchar(255)` |
| `customerpassword` | `varchar(255)` |
| `locktype` | `int` |
| `calllevel` | `int` |
| `capacity` | `int` |
| `priority` | `int` |
| `iptype` | `int` |
| `encrypt` | `int` |
| `protocol` | `int` |
| `remoteips` | `text` |
| `rtpforwardtype` | `int` |
| ... | (共计 21 个字段) |

---

#### 📋 表名: `e_gatewayroutingsetting`
* **主键**: `gatewayrouting_id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `callercitye164check` | `int` |
| `calleecitye164check` | `int` |
| `denycallercallee` | `text` |
| `denysamecitycodes` | `text` |
| `checkmobilearea` | `text` |
| `callincallerprefixesallow` | `tinyint(1)` |
| `callincallerprefixes` | `text` |
| `callincalleeprefixesallow` | `tinyint(1)` |
| `callincalleeprefixes` | `text` |
| `callinforwardprefixes` | `text` |
| `rewriterulesincallee` | `text` |
| `rewriterulesinmobilearea` | `text` |
| `rewriterulesincaller` | `text` |
| `rewriterulesincallerusee164group` | `varchar(255)` |
| `rewriterulesincallerusee164line` | `int` |
| ... | (共计 98 个字段) |

---

### 4. 费率与计费规则 (Feerate & Tariffs)
该模块包含 **6** 张表。主要核心表及结构如下：

#### 📋 表名: `e_feerate`
* **主键**: `id`
* **索引**: 
  * `feerategroup_id` -> `(feerategroup_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `feeprefix` | `varchar(255)` |
| `areacode` | `varchar(255)` |
| `locktype` | `int` |
| `fee` | `double` |
| `tax` | `double` |
| `period` | `int` |
| `ivrfee` | `double` |
| `ivrperiod` | `int` |
| `type` | `int` |
| `feerategroup_id` | `int` |

---

#### 📋 表名: `e_feerate_update`
* **主键**: `id`
* **索引**: 
  * `feerategroup_id` -> `(feerategroup_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `feeprefix` | `varchar(255)` |
| `areacode` | `varchar(255)` |
| `locktype` | `int` |
| `fee` | `double` |
| `tax` | `double` |
| `period` | `int` |
| `ivrfee` | `double` |
| `ivrperiod` | `int` |
| `type` | `int` |
| `udpatetime` | `bigint` |
| `updatetype` | `int` |
| `feerategroup_id` | `int` |

---

#### 📋 表名: `e_feeratebytime`
* **主键**: `id`
* **索引**: 
  * `suite_id` -> `(suite_id)`
  * `feerategroup_id` -> `(feerategroup_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `type` | `int` |
| `startday` | `bigint` |
| `endday` | `bigint` |
| `starttime` | `int` |
| `endtime` | `int` |
| `suite_id` | `int` |
| `feerategroup_id` | `int` |

---

#### 📋 表名: `e_feerategroup`
* **主键**: `id`
* **索引**: 
  * `user_id` -> `(user_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `name` | `varchar(255)` |
| `privilege` | `int` |
| `fakeminute` | `int` |
| `isprivate` | `int` |
| `memo` | `varchar(255)` |
| `user_id` | `int` |

---

#### 📋 表名: `e_feeratesection`
* **索引**: 
  * `feerate_id` -> `(feerate_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `fee` | `double` |
| `time` | `int` |
| `position` | `int` |
| `feerate_id` | `int` |

---

#### 📋 表名: `e_feeratesection_update`
* **索引**: 
  * `feerate_update_id` -> `(feerate_update_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `fee` | `double` |
| `time` | `int` |
| `position` | `int` |
| `feerate_update_id` | `int` |

---

### 5. 话单与账单流水 (CDRs & Billing Logs)
该模块包含 **51** 张表。主要核心表及结构如下：

#### 📋 表名: `e_cdr`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260118`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260119`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260120`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260121`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260122`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260123`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260124`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260125`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

#### 📋 表名: `e_cdr_20260126`
* **主键**: `flowno`
* **索引**: 
  * `callere164` -> `(callere164)`
  * `callergatewayid` -> `(callergatewayid)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `customeraccount` -> `(customeraccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `calleraccesse164` | `varchar(64)` |
| `calleee164` | `varchar(64)` |
| `calleeaccesse164` | `varchar(64)` |
| `callerip` | `varchar(64)` |
| `callerrtpip` | `varchar(64)` |
| `callercodec` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callerproductid` | `varchar(64)` |
| `callertogatewaye164` | `varchar(64)` |
| `callertype` | `int` |
| `calleeip` | `varchar(64)` |
| `calleertpip` | `varchar(64)` |
| `calleecodec` | `varchar(64)` |
| ... | (共计 63 个字段) |

---

*其他包含的表*: `e_cdr_20260127`, `e_cdr_20260128`, `e_cdr_20260129`, `e_cdr_20260130`, `e_cdr_20260131`, `e_cdr_20260201`, `e_cdr_20260202`, `e_cdr_20260203`, `e_cdr_20260204`, `e_cdr_20260205`, `e_cdr_20260206`, `e_cdr_20260207`, `e_cdr_20260208`, `e_cdr_20260209`, `e_cdr_20260210`, `e_cdr_20260211`, `e_cdr_20260212`, `e_cdr_20260213`, `e_cdr_20260214`, `e_cdr_20260215`, `e_cdr_20260216`, `e_cdr_20260217`, `e_cdr_20260218`, `e_cdr_20260219`, `e_cdr_20260220`, `e_cdr_20260221`, `e_cdr_20260222`, `e_cdr_20260223`, `e_cdr_20260224`, `e_cdr_20260225`, `e_cdr_20260226`, `e_cdr_20260227`, `e_cdr_20260228`, `e_cdr_20260301`, `e_cdr_20260302`, `e_cdr_20260303`, `e_cdr_20260304`, `e_cdr_20260305`, `e_cdr_20260306`, `e_cdr_20260307`, `e_cdr_20260308`

---

### 6. 号码簿与前缀过滤 (Number Pools & Prefixes)
该模块包含 **4** 张表。主要核心表及结构如下：

#### 📋 表名: `e_phone`
* **主键**: `id`
* **索引**: 
  * `customer_id` -> `(customer_id)`
  * `ivrservice_id` -> `(ivrservice_id)`
  * `feerategroup_id` -> `(feerategroup_id)`
  * `mbx_id` -> `(mbx_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `e164` | `varchar(255)` |
| `password` | `varchar(255)` |
| `customerpassword` | `varchar(255)` |
| `displaynum` | `varchar(255)` |
| `capacity` | `int` |
| `locktype` | `int` |
| `calllevel` | `int` |
| `calleebilling` | `int` |
| `routinggatewaygroups` | `text` |
| `monthlymoneymax` | `double` |
| `monthconsumption` | `double` |
| `monthlymoneymin` | `double` |
| `monthlyrentfee` | `double` |
| `memo` | `varchar(255)` |
| ... | (共计 23 个字段) |

---

#### 📋 表名: `e_phonecard`
* **主键**: `id`
* **索引**: 
  * `usedaccount` -> `(usedaccount)`
  * `agentaccount` -> `(agentaccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `serialno` | `bigint` |
| `pin` | `varchar(255)` |
| `password` | `varchar(255)` |
| `displaye164` | `varchar(255)` |
| `maintainno` | `varchar(255)` |
| `bitsofconfig` | `int` |
| `money` | `double` |
| `limitmoney` | `double` |
| `bindlimit` | `int` |
| `locktype` | `int` |
| `calllevel` | `int` |
| `expiretime` | `bigint` |
| `activeday` | `int` |
| `sold` | `int` |
| ... | (共计 23 个字段) |

---

#### 📋 表名: `e_phoneservice`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `name` | `varchar(255)` |
| `vosname` | `varchar(255)` |
| `configserialid` | `int` |
| `createtime` | `bigint` |
| `accesstime` | `bigint` |
| `accessip` | `varchar(255)` |
| `socketid` | `int` |
| `memo` | `varchar(255)` |

---

#### 📋 表名: `e_phonesetting`
* **主键**: `phone_id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `registertype` | `int` |
| `encrypt` | `int` |
| `protocol` | `int` |
| `ipaddress` | `varchar(255)` |
| `localip` | `varchar(255)` |
| `signalport` | `int` |
| `signalportlocal` | `int` |
| `rtpforwardtype` | `int` |
| `bitsofopen` | `int` |
| `usecallerphonedisplay` | `int` |
| `callforwardalwaysnum` | `text` |
| `callforwardbusynum` | `text` |
| `callforwardnoanswernum` | `text` |
| `callforwardtimebasedalwaysnum` | `text` |
| `callforwardofflinenum` | `text` |
| ... | (共计 101 个字段) |

---

### 7. 权限与系统用户 (RBAC & System Users)
该模块包含 **4** 张表。主要核心表及结构如下：

#### 📋 表名: `e_user`
* **主键**: `id`
* **索引**: 
  * `user_privilege_id` -> `(user_privilege_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `loginname` | `varchar(255)` |
| `username` | `varchar(255)` |
| `password` | `varchar(255)` |
| `level` | `int` |
| `locktype` | `int` |
| `expiretime` | `bigint` |
| `createduser_id` | `int` |
| `lastlogin` | `bigint` |
| `lastmodifypassword` | `bigint` |
| `limitmacs` | `int` |
| `macs` | `text` |
| `onetimepassword` | `text` |
| `memo` | `varchar(255)` |
| `user_privilege_id` | `int` |

---

#### 📋 表名: `e_user_privilege`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `name` | `varchar(255)` |
| `privilege` | `text` |
| `classprivilege` | `text` |
| `memo` | `varchar(255)` |
| `create_user_id` | `int` |

---

#### 📋 表名: `e_useragent`
* **主键**: `id`
* **索引**: 
  * `mbx_id` -> `(mbx_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `groupname` | `varchar(255)` |
| `username` | `varchar(255)` |
| `password` | `varchar(255)` |
| `serverip` | `varchar(255)` |
| `serverport` | `int` |
| `encrypt` | `int` |
| `expire` | `int` |
| `localip` | `varchar(255)` |
| `authenticationname` | `varchar(255)` |
| `hostname` | `varchar(255)` |
| `sipoutboundproxy` | `varchar(255)` |
| `sipuseragent` | `varchar(255)` |
| `randomlocalport` | `int` |
| `capacity` | `int` |
| ... | (共计 18 个字段) |

---

#### 📋 表名: `e_userlogin`
* **索引**: 
  * `user_id` -> `(user_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `socketid` | `int` |
| `loginip` | `varchar(255)` |
| `logintime` | `bigint` |
| `user_id` | `int` |

---

### 8. 系统配置与监控管理 (System Config & Diagnostics)
该模块包含 **80** 张表。主要核心表及结构如下：

#### 📋 表名: `e_aas_alarm_word`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `flowno` | `bigint` |
| `starttime` | `bigint` |
| `callere164` | `varchar(255)` |
| `calleee164` | `varchar(255)` |
| `gatewaymapping` | `varchar(255)` |
| `gatewayrouting` | `varchar(255)` |
| `callerip` | `varchar(255)` |
| `callerrtpip` | `varchar(255)` |
| `calleeip` | `varchar(255)` |
| `calleertpip` | `varchar(255)` |
| `alarmwordcategory` | `varchar(255)` |
| `alarmword` | `varchar(255)` |
| `calleraudiotext` | `text` |
| `calleeaudiotext` | `text` |
| ... | (共计 16 个字段) |

---

#### 📋 表名: `e_aas_cdr`
* **主键**: `flowno`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `flowno` | `bigint` |
| `starttime` | `bigint` |
| `callere164` | `varchar(255)` |
| `calleee164` | `varchar(255)` |
| `gatewaymapping` | `varchar(255)` |
| `gatewayrouting` | `varchar(255)` |
| `callerip` | `varchar(255)` |
| `callerrtpip` | `varchar(255)` |
| `calleeip` | `varchar(255)` |
| `calleertpip` | `varchar(255)` |
| `alarmwordcategory` | `varchar(255)` |
| `alarmword` | `varchar(255)` |
| `calleraudiotext` | `text` |
| `calleeaudiotext` | `text` |
| ... | (共计 16 个字段) |

---

#### 📋 表名: `e_activephonecard`
* **主键**: `id`
* **索引**: 
  * `customer_id` -> `(customer_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `pin` | `varchar(255)` |
| `password` | `varchar(255)` |
| `displaye164` | `varchar(255)` |
| `activetime` | `bigint` |
| `bindlimit` | `int` |
| `memo` | `varchar(255)` |
| `customer_id` | `int` |

---

#### 📋 表名: `e_alarm_current`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `moid` | `int` |
| `motype` | `int` |
| `name` | `varchar(255)` |
| `type` | `int` |
| `level` | `int` |
| `starttime` | `bigint` |
| `stoptime` | `bigint` |
| `value` | `double` |
| `upper` | `double` |
| `lower` | `double` |
| `alarminfo` | `text` |
| `confirmuser` | `varchar(255)` |
| `confirmusername` | `varchar(255)` |
| `confirmtime` | `bigint` |
| ... | (共计 18 个字段) |

---

#### 📋 表名: `e_alarm_history`
* **主键**: `id`
* **索引**: 
  * `name` -> `(name)`
  * `type` -> `(type)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `moid` | `int` |
| `motype` | `int` |
| `name` | `varchar(255)` |
| `type` | `int` |
| `level` | `int` |
| `starttime` | `bigint` |
| `stoptime` | `bigint` |
| `value` | `double` |
| `upper` | `double` |
| `lower` | `double` |
| `confirmuser` | `varchar(255)` |
| `confirmusername` | `varchar(255)` |
| `confirmtime` | `bigint` |
| `confirmmemo` | `text` |
| ... | (共计 18 个字段) |

---

#### 📋 表名: `e_alarm_setting`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `moid` | `int` |
| `motype` | `int` |
| `starttime` | `int` |
| `stoptime` | `int` |
| `type` | `int` |
| `level` | `int` |
| `upper` | `double` |
| `lower` | `double` |
| `period` | `int` |
| `enablevoice` | `int` |
| `e164s` | `varchar(255)` |
| `enableemail` | `int` |
| `email` | `varchar(255)` |

---

#### 📋 表名: `e_areacode`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `areacode` | `varchar(255)` |
| `location` | `varchar(255)` |
| `memo` | `varchar(255)` |

---

#### 📋 表名: `e_autoclean`
* **主键**: `id`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `type` | `int` |
| `enabled` | `int` |
| `content` | `int` |
| `expiredays` | `int` |

---

#### 📋 表名: `e_axb_cdr`
* **主键**: `flowno`
* **索引**: 
  * `calleegatewayid` -> `(calleegatewayid)`
  * `xnumber` -> `(xnumber)`
  * `starttime` -> `(starttime)`
  * `stoptime` -> `(stoptime)`
  * `xaccount` -> `(xaccount)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `callere164` | `varchar(64)` |
| `callergatewayid` | `varchar(64)` |
| `callertype` | `int` |
| `calleegatewayid` | `varchar(64)` |
| `anumber` | `varchar(64)` |
| `xnumber` | `varchar(64)` |
| `bnumber` | `varchar(64)` |
| `starttime` | `bigint` |
| `stoptime` | `bigint` |
| `holdtime` | `int` |
| `enddirection` | `int` |
| `endreason` | `int` |
| `fee` | `double` |
| `feetime` | `int` |
| ... | (共计 29 个字段) |

---

#### 📋 表名: `e_bindede164`
* **主键**: `id`
* **索引**: 
  * `activephonecard_id` -> `(activephonecard_id)`
* **核心字段定义**:

| 字段名 | 数据类型 |
| :--- | :--- |
| `id` | `int` |
| `e164` | `varchar(255)` |
| `displaye164` | `varchar(255)` |
| `rewriterulesoutcallee` | `text` |
| `bindtime` | `bigint` |
| `language` | `varchar(255)` |
| `memo` | `varchar(255)` |
| `activephonecard_id` | `int` |

---

*其他包含的表*: `e_calendar`, `e_calendar_day`, `e_cc_seat`, `e_cc_seat_group`, `e_cc_seat_privilege`, `e_cc_seat_reserved_e164`, `e_citycode`, `e_conference_record`, `e_conferencemember`, `e_conferenceroom`, `e_consumption`, `e_currentgifttime`, `e_currentsuite`, `e_dns`, `e_equipment`, `e_gifttime`, `e_groupe164`, `e_ims_edge_account`, `e_ims_edge_server`, `e_interfaceagent`, `e_ip_limit`, `e_ivr`, `e_ivr_cdr`, `e_ivraudio`, `e_ivraudiodata`, `e_ivrservice`, `e_ivrservicemenu`, `e_language`, `e_lerg`, `e_limit_e164`, `e_limit_e164_group`, `e_mbx`, `e_mobilearea`, `e_moconfig`, `e_moexternal`, `e_motimer`, `e_othermaxid`, `e_payhistory`, `e_privatephonebook`, `e_publicphonebook`, `e_reportagentincome`, `e_reportaxbaccountfee`, `e_reportcustomerclearingfee`, `e_reportcustomerclearingio`, `e_reportcustomerclearinglocationfee`, `e_reportcustomerfee`, `e_reportcustomerio`, `e_reportcustomerlocationfee`, `e_reportgatewaycrosslocationasracd`, `e_reportgatewaymappingasracd`, `e_reportgatewaymappingfee`, `e_reportgatewaymappinglocationasracd`, `e_reportgatewayroutingasracd`, `e_reportgatewayroutingfee`, `e_reportgatewayroutinglocationasracd`, `e_reportmanagement`, `e_reportphonecarde164fee`, `e_reportphonecardfee`, `e_reportphonefee`, `e_suite`, `e_suiteorder`, `e_syslog`, `e_system_limit_e164`, `e_terminal_black_list_policy`, `e_web_access_control`, `r_cc_seat_group_seat`, `r_customer_e164ranges`, `r_customer_privileges`, `r_feerategroup_privileges`, `r_suite_privileges`

---

## 二、 核心实体关联拓扑关系

在 VOS3000 计费和路由逻辑中，各个核心表之间存在紧密的外键或业务代码关联，形成了以下三个主要的控制与数据流网络：

### 1. 客户财务控制网络 (Billing Control Network)
* **核心表**: `e_customer` (财务账户)
* **下属子表**: 
  * `e_customerdetail`: 存放客户地址、邮编、邮箱、挂断告警等管理扩展属性，通过 `id` 进行 1:1 关联。
  * `e_customerfeerategroup`: 多节点关联客户与特定计费费率组的外键对照表。
  * `e_customergatewaymapping`: 对接客户与其所持有的对接网关之间的映射配置表。

### 2. 路由与通路控制网络 (Routing & Gateway Topology)
* **核心表**: `e_gatewaymapping` (对接网关) & `e_gatewayrouting` (落地网关)
* **控制逻辑关联**: 
  * `e_gatewaymapping.customer_id` 强关联 `e_customer.id`，决定了从该网关呼入时的扣款主体账户。
  * `e_gatewayrouting.clearingcustomer_id` 强关联 `e_customer.id`，决定了呼出到上游网关时，结算成本应累加到哪一个供应商账户下。
  * 费率组关联：账户关联的 `feerategroup_id` 控制了计费规则，网关绑定的费率策略则作为结算重置项。

### 3. 计费话单数据链路 (Billing CDR Transaction Pipeline)
* **核心表**: `e_cdr` / `e_cdr_YYYYMMDD` (话单记录)
* **流水字段与维表的业务对齐**: 
  * `customeraccount` 关联并核销 `e_customer.account` (主叫客户可用余额减扣)。
  * `agentaccount` 关联并累加 `e_customer.account` (供应商结算成本累加)。
  * `callergatewayid` 与 `calleegatewayid` 记录本次呼叫所经由的对接网关名称和落地网关名称，对应 `e_gatewaymapping.name` 和 `e_gatewayrouting.name`。

## 三、 全局数据库设计对我们系统功能的指导意义

通过理清上述关系，我们可以轻松设计并落地以下中台级功能：

### 1. 跨节点多租户客户管理中心 (Multi-Node Customer Management)
* **功能设计**: 结合 `e_customer` 的余额、额度及消费字段，可以在前端展示多节点统一余额看板。后台实现“充值、透支额度调整、状态挂起/冻结”，并通过 Kafka 控制管道由 Go Agent 反向写入 VOS 的 MySQL 的 `e_customer` 表实现反向控制。

### 2. 运营与话费对账报表系统 (Billing Audit & Statistics)
* **功能设计**: 话单 `e_cdr` 记录的 `fee`（向客户收取的接入费）与 `agentfee`（向运营商支付的落地费）天然代表了每次呼叫的**收入**与**成本**。通过在 ClickHouse 侧按 `customeraccount` 和 `agentaccount` 进行聚合，能秒级输出任何时段的**客户毛利报表**与**渠道对账单**。

### 3. 网关通道监控与并发预警 (Gateway Concurrent Monitoring)
* **功能设计**: 对接网关 `e_gatewaymapping` 与落地网关 `e_gatewayrouting` 均定义了 `capacity`（呼叫并发限制）字段。通过实时统计 ODS 中未挂断的呼叫流水，或结合 Agent 上报的网关状态，可以在前端直观展示各对接账户/落地通道的**并发装载率 (Current Concurrent / Capacity)** 并进行超额告警。

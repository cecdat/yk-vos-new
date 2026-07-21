import { requestClient } from '#/api/request';
import { getVosInstanceList } from '#/api/vos';
import type { VosInstanceApi } from '#/api/vos';

export namespace CdrApi {
  /** 话单查询请求参数（对应后端 CDRQueryRequest） */
  export interface CdrQueryParams {
    /** 开始时间，yyyyMMdd 格式 */
    beginTime: string;
    /** 结束时间，yyyyMMdd 格式 */
    endTime: string;
    /** 页码，从 1 开始 */
    page?: number;
    /** 每页数量，默认 20，最大 1000 */
    pageSize?: number;
    /** 客户账号（逗号分隔，可选） */
    accounts?: string;
    /** 主叫号码（可选） */
    callerE164?: string;
    /** 被叫号码（可选） */
    calleeE164?: string;
    /** 被叫网关（可选） */
    calleeGateway?: string;
    /** 是否排除零费用话单 */
    excludeZeroFee?: boolean;
  }

  /** 单条话单记录（ClickHouse 返回的 camelCase 字段） */
  export interface CdrRecord {
    flowNo?: string | number;
    account?: string;
    accountName?: string;
    callerE164?: string;
    callerAccessE164?: string;
    calleeAccessE164?: string;
    calleeGateway?: string;
    /** 开始时间，毫秒时间戳 */
    start?: number | null;
    /** 结束时间，毫秒时间戳 */
    stop?: number | null;
    /** 通话时长（秒） */
    holdTime?: number;
    /** 计费时长（秒） */
    feeTime?: number;
    /** 费用（元） */
    fee?: number;
    /** 挂断方：0 主叫 / 1 被叫 / 2 服务器 */
    endDirection?: number;
    /** 终止原因 */
    endReason?: string;
    calleeip?: string;
  }

  /** 查询返回 */
  export interface CdrQueryResult {
    success: boolean;
    cdrs: CdrRecord[];
    count: number;
    total: number;
    page: number;
    page_size: number;
    total_pages: number;
    instance_id: number;
    instance_name: string;
    data_source: string;
    query_time_ms: number;
    message?: string;
    error?: string;
  }
}

/** 智能话单查询：优先 ClickHouse，必要时回退 VOS API（对应后端 POST /cdr/query-from-vos/{instanceId}） */
export function queryCdrsFromVos(
  instanceId: number,
  params: CdrApi.CdrQueryParams,
) {
  return requestClient.post<CdrApi.CdrQueryResult>(
    `/cdr/query-from-vos/${instanceId}`,
    params,
  );
}

/** 复用 VOS 实例列表接口，供话单查询的实例下拉使用 */
export { getVosInstanceList };
export type { VosInstanceApi };

import { requestClient } from '#/api/request';

export namespace VosInstanceApi {
  /** VOS 实例信息 */
  export interface VosInstance {
    id?: number;
    vos_id?: string;
    name: string;
    base_url: string;
    description?: string | null;
    enabled?: boolean;
    /** 健康状态：healthy / unhealthy / unknown */
    health_status?: string;
    health_last_check?: string | null;
    health_response_time?: number | null;
    health_error?: string | null;
  }

  /** 可用历史日表结构 */
  export interface VosAgentBackfill {
    id: number;
    vosId: string;
    tableName: string;
    estimatedRows: number;
    alreadyPushed: number;
    preciseRows: number | null;
    status: string; // pending, approved, syncing, done, rejected
    mode: string | null;
    scheduledCron: string | null;
    lastReportedAt: string;
  }

  /** 控制指令与回填任务结构 */
  export interface VosBackfillTask {
    id: number;
    taskCode: string;
    vosId: string;
    commandId: string;
    action: string;
    tables: string[];
    mode: string;
    cron: string;
    params: { speed_limit?: number } | null;
    status: string; // pending, queued, dispatched, syncing, paused, done, failed, cancelled
    progressPushed: number;
    lastProgressAt: string | null;
    result: string | null;
    resultMsg: string | null;
    createTime: string;
  }
}

/** 查询 VOS 实例列表 */
export function getVosInstanceList() {
  return requestClient.get<VosInstanceApi.VosInstance[]>('/vos/instances/list');
}

/** 查询 VOS 实例分页 */
export function getVosInstancePage(params: any) {
  return requestClient.get<any>('/vos/instances/page', { params });
}

/** 查询 VOS 实例详情 */
export function getVosInstance(id: number) {
  return requestClient.get<VosInstanceApi.VosInstance>(
    `/vos/instances/${id}`,
  );
}

/** 新增 VOS 实例 */
export function createVosInstance(data: VosInstanceApi.VosInstance) {
  return requestClient.post('/vos/instances', data);
}

/** 修改 VOS 实例 */
export function updateVosInstance(id: number, data: VosInstanceApi.VosInstance) {
  return requestClient.put(`/vos/instances/${id}`, data);
}

/** 删除 VOS 实例 */
export function deleteVosInstance(id: number) {
  return requestClient.delete(`/vos/instances/${id}`);
}

/** 启动历史日表回填任务 */
export function startBackfill(data: {
  vosId: string;
  tables: string[];
  mode?: string;
  cron?: string;
  speedLimit?: number;
}) {
  return requestClient.post<string>('/vos/backfill/start', data);
}

/** 暂停回填任务 */
export function pauseBackfill(commandId: string) {
  return requestClient.put(`/vos/backfill/pause`, null, {
    params: { commandId },
  });
}

/** 恢复回填任务 */
export function resumeBackfill(commandId: string) {
  return requestClient.put(`/vos/backfill/resume`, null, {
    params: { commandId },
  });
}

/** 取消回填任务 */
export function cancelBackfill(commandId: string) {
  return requestClient.put(`/vos/backfill/cancel`, null, {
    params: { commandId },
  });
}

/** 调整限速 */
export function setThrottle(commandId: string, speedLimit: number) {
  return requestClient.put(`/vos/backfill/throttle`, null, {
    params: { commandId, speedLimit },
  });
}

/** 手动下发（启动下发）待下发/排队的回填任务 */
export function dispatchBackfill(id: number) {
  return requestClient.post(`/vos/backfill/dispatch`, null, {
    params: { id },
  });
}

/** 发起 COUNT(*) 精确统计 */
export function triggerPreciseCount(vosId: string, tableName: string) {
  return requestClient.post(`/vos/backfill/precise-count`, null, {
    params: { vosId, tableName },
  });
}

/** 重新扫描实例可用日表 */
export function triggerRescan(vosId: string) {
  return requestClient.post(`/vos/backfill/rescan`, null, {
    params: { vosId },
  });
}

/** 查询可用历史日表列表 */
export function getAvailabilityList(vosId: string) {
  return requestClient.get<VosInstanceApi.VosAgentBackfill[]>(
    `/vos/backfill/availabilities`,
    { params: { vosId } },
  );
}

/** 查询回填任务记录列表 */
export function getTaskList(vosId: string) {
  return requestClient.get<VosInstanceApi.VosBackfillTask[]>(
    `/vos/backfill/tasks`,
    { params: { vosId } },
  );
}

/** VOS Agent 心跳 / 健康快照（后端 vos_agent_heart_beat 表，JSON 为 snake_case） */
export interface VosAgentHeartbeat {
  id: number;
  vos_id: string;
  agent_version: string;
  hostname: string;
  os: string;
  cpu_load_1m: number;
  cpu_cores: number;
  mem_total_mb: number;
  mem_used_mb: number;
  disk_total_mb: number;
  disk_used_mb: number;
  uptime_seconds: number;
  db_connected: boolean;
  db_version: string;
  db_open_conns: number;
  db_active_conns: number;
  db_max_conns?: number;
  agent_pid?: number;
  delay_ms?: number;
  agent_goroutines: number;
  agent_mem_alloc_mb: number;
  agent_uptime_seconds: number;
  generated_at: string;
}

/** 查询 Agent 心跳 / 健康最新快照列表（GET /vos/agents/heartbeat） */
export function getAgentHeartbeatList() {
  return requestClient.get<VosAgentHeartbeat[]>(
    '/vos/agents/heartbeat',
  );
}

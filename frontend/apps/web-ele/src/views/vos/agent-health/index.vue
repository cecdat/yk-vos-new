<script lang="ts" setup>
import { onMounted, ref } from 'vue';

import { Page } from '@vben/common-ui';

import { getAgentHeartbeatList, type VosAgentHeartbeat } from '#/api/vos';

const loading = ref(false);
const list = ref<VosAgentHeartbeat[]>([]);

async function load() {
  loading.value = true;
  try {
    list.value = await getAgentHeartbeatList();
  } finally {
    loading.value = false;
  }
}

/** 百分比（内存/磁盘占用） */
function pct(used?: number, total?: number): number {
  if (!used || !total) {
    return 0;
  }
  return Math.min(100, Math.round((used / total) * 100));
}

/** 秒 -> 人类可读运行时长 */
function formatUptime(sec?: number): string {
  if (!sec || sec < 0) {
    return '-';
  }
  const d = Math.floor(sec / 86400);
  const h = Math.floor((sec % 86400) / 3600);
  const m = Math.floor((sec % 3600) / 60);
  if (d > 0) {
    return `${d}天 ${h}小时`;
  }
  if (h > 0) {
    return `${h}小时 ${m}分`;
  }
  return `${m}分`;
}

/** 格式化 ISO 时间为 yyyy-MM-dd HH:mm:ss 格式 */
function formatDateTime(val?: string): string {
  if (!val) return '-';
  const tIdx = val.indexOf('T');
  if (tIdx === -1) return val;
  const datePart = val.substring(0, tIdx);
  let timePart = val.substring(tIdx + 1);
  const dotIdx = timePart.indexOf('.');
  if (dotIdx !== -1) {
    timePart = timePart.substring(0, dotIdx);
  } else {
    const plusIdx = timePart.indexOf('+');
    if (plusIdx !== -1) {
      timePart = timePart.substring(0, plusIdx);
    }
  }
  return `${datePart} ${timePart}`;
}

/** 判断 Agent 在线状态（最近上报时间在 90s 内则在线） */
function isAgentOnline(generatedAt?: string): boolean {
  if (!generatedAt) return false;
  const lastTime = new Date(generatedAt).getTime();
  const nowTime = Date.now();
  return (nowTime - lastTime) < 90000;
}

onMounted(load);
</script>

<template>
  <Page auto-content-height>
    <div class="flex flex-wrap items-center gap-4 p-4">
      <ElButton :loading="loading" type="primary" @click="load">
        刷新
      </ElButton>
      <span class="text-sm text-slate-500 dark:text-zinc-400">
        数据来源：各 VOS Agent 上报的心跳快照表（vos_agent_heartbeat）
      </span>
    </div>

    <div
      v-if="!loading && list.length === 0"
      class="p-10 text-center text-slate-400 dark:text-zinc-500"
    >
      暂无 Agent 心跳数据。请确认 Agent 已启动且能连通服务端 Kafka 控制面（vos.agent.report）。
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 p-4">
      <div
        v-for="h in list"
        :key="h.vos_id"
        class="bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 rounded-xl shadow-sm hover:shadow-md transition-all duration-300 overflow-hidden"
      >
        <!-- Header -->
        <div class="p-4 border-b border-slate-100 dark:border-zinc-800 bg-gradient-to-r from-slate-50 to-white dark:from-zinc-950 dark:to-zinc-900">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
              <span class="text-sm font-bold text-slate-800 dark:text-zinc-100">
                {{ h.hostname || h.vos_id }}
              </span>
            </div>
            <span
              :class="[
                'px-2 py-0.5 text-[11px] font-semibold rounded-full flex items-center gap-1',
                isAgentOnline(h.generated_at) 
                  ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/30 dark:text-emerald-400' 
                  : 'bg-rose-50 text-rose-700 dark:bg-rose-950/30 dark:text-rose-400'
              ]"
            >
              <span :class="['w-1.5 h-1.5 rounded-full', isAgentOnline(h.generated_at) ? 'bg-emerald-500 animate-pulse' : 'bg-rose-500']"></span>
              Agent {{ isAgentOnline(h.generated_at) ? '在线' : '离线' }}
              <span class="opacity-80">({{ h.delay_ms ?? 0 }}ms)</span>
            </span>
          </div>
          <div class="mt-1.5 flex flex-wrap gap-x-2 gap-y-0.5 text-[11px] text-slate-400 dark:text-zinc-500">
            <span>ID: <code class="bg-slate-100 dark:bg-zinc-800 px-1 rounded">{{ h.vos_id }}</code></span>
            <span>•</span>
            <span>OS: {{ h.os }}</span>
            <span>•</span>
            <span>Agent: v{{ h.agent_version }}</span>
          </div>
        </div>

        <!-- Body -->
        <div class="p-4 space-y-3">
          <!-- CPU Load -->
          <div>
            <div class="flex justify-between text-[11px] font-medium text-slate-500 dark:text-zinc-400 mb-1">
              <span>CPU 1m 负载</span>
              <span class="text-slate-700 dark:text-zinc-200">{{ h.cpu_load_1m ?? '0.00' }} / {{ h.cpu_cores }} 核</span>
            </div>
            <ElProgress
              :percentage="Math.min(100, Math.round(((h.cpu_load_1m || 0) / (h.cpu_cores || 1)) * 100))"
              :stroke-width="5"
              :show-text="false"
              status="warning"
            />
          </div>

          <!-- Memory Usage -->
          <div>
            <div class="flex justify-between text-[11px] font-medium text-slate-500 dark:text-zinc-400 mb-1">
              <span>内存使用率</span>
              <span class="text-slate-700 dark:text-zinc-200">{{ (h.mem_used_mb / 1024).toFixed(2) }} / {{ (h.mem_total_mb / 1024).toFixed(2) }} GB ({{ pct(h.mem_used_mb, h.mem_total_mb) }}%)</span>
            </div>
            <ElProgress
              :percentage="pct(h.mem_used_mb, h.mem_total_mb)"
              :stroke-width="5"
              :show-text="false"
            />
          </div>

          <!-- Disk Usage -->
          <div>
            <div class="flex justify-between text-[11px] font-medium text-slate-500 dark:text-zinc-400 mb-1">
              <span>磁盘空间</span>
              <span class="text-slate-700 dark:text-zinc-200">已用 {{ (h.disk_used_mb / 1024).toFixed(2) }} / {{ (h.disk_total_mb / 1024).toFixed(2) }} GB ({{ pct(h.disk_used_mb, h.disk_total_mb) }}%)</span>
            </div>
            <ElProgress
              :percentage="pct(h.disk_used_mb, h.disk_total_mb)"
              :stroke-width="5"
              :show-text="false"
              status="exception"
            />
          </div>

          <!-- Database Details -->
          <div class="pt-2.5 border-t border-slate-100 dark:border-zinc-800 grid grid-cols-2 gap-y-1.5 text-[11px]">
            <div>
              <span class="text-slate-400 dark:text-zinc-500">DB 版本:</span>
              <span class="ml-1 text-slate-700 dark:text-zinc-200 font-medium">{{ h.db_version || '-' }}</span>
            </div>
            <div>
              <span class="text-slate-400 dark:text-zinc-500">DB 连接数:</span>
              <span class="ml-1 text-slate-700 dark:text-zinc-200 font-medium">{{ h.db_active_conns ?? 0 }}活 / {{ h.db_max_conns ?? '-' }}最大</span>
            </div>
            <div>
              <span class="text-slate-400 dark:text-zinc-500">主机运行:</span>
              <span class="ml-1 text-slate-700 dark:text-zinc-200">{{ formatUptime(h.uptime_seconds) }}</span>
            </div>
            <div>
              <span class="text-slate-400 dark:text-zinc-500 font-semibold text-sky-600 dark:text-sky-400">Agent:</span>
              <span class="ml-1 text-slate-600 dark:text-zinc-300">PID: {{ h.agent_pid || '-' }} | {{ h.agent_mem_alloc_mb }} MB</span>
            </div>
          </div>

          <!-- Agent Uptime & Last Reported -->
          <div class="pt-2.5 border-t border-slate-100 dark:border-zinc-800 flex justify-between items-center text-[10px] text-slate-400 dark:text-zinc-500">
            <span>Agent 运行: <strong class="text-slate-600 dark:text-zinc-400">{{ formatUptime(h.agent_uptime_seconds) }}</strong></span>
            <span>最近上报: {{ formatDateTime(h.generated_at) }}</span>
          </div>
        </div>
      </div>
    </div>
  </Page>
</template>

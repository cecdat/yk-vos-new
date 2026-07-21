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

onMounted(load);
</script>

<template>
  <Page auto-content-height>
    <div class="flex flex-wrap items-center gap-4 p-4">
      <ElButton :loading="loading" type="primary" @click="load">
        刷新
      </ElButton>
      <span class="text-sm text-gray-500">
        数据来源：各 VOS Agent 上报的心跳快照表（vos_agent_heart_beat）
      </span>
    </div>

    <div
      v-if="!loading && list.length === 0"
      class="p-10 text-center text-gray-400"
    >
      暂无 Agent 心跳数据。请确认 Agent 已启动且能连通服务端 Kafka 控制面（vos.agent.report）。
    </div>

    <div class="flex flex-wrap gap-4 p-4">
      <ElCard
        v-for="h in list"
        :key="h.vos_id"
        shadow="hover"
        class="w-96"
      >
        <template #header>
          <div>
            <div class="flex items-center justify-between">
              <span class="font-semibold">{{ h.hostname || h.vos_id }}</span>
              <ElTag :type="h.db_connected ? 'success' : 'danger'">
                {{ h.db_connected ? 'DB 正常' : 'DB 异常' }}
              </ElTag>
            </div>
            <div class="mt-1 text-xs text-gray-400">
              {{ h.vos_id }} · {{ h.os }} · agent {{ h.agent_version }}
            </div>
          </div>
        </template>

        <ElDescriptions :border="true" :column="1" size="small">
          <ElDescriptionsItem label="CPU 1m 负载">
            {{ h.cpu_load_1m ?? '-' }}（{{ h.cpu_cores }} 核）
          </ElDescriptionsItem>
          <ElDescriptionsItem label="内存">
            <div>{{ h.mem_used_mb }} / {{ h.mem_total_mb }} MB</div>
            <ElProgress
              :percentage="pct(h.mem_used_mb, h.mem_total_mb)"
              :show-text="false"
              class="mt-1"
            />
          </ElDescriptionsItem>
          <ElDescriptionsItem label="磁盘">
            <div>{{ h.disk_used_mb }} / {{ h.disk_total_mb }} MB</div>
            <ElProgress
              :percentage="pct(h.disk_used_mb, h.disk_total_mb)"
              :show-text="false"
              class="mt-1"
            />
          </ElDescriptionsItem>
          <ElDescriptionsItem label="DB 版本">
            {{ h.db_version || '-' }}
          </ElDescriptionsItem>
          <ElDescriptionsItem label="DB 连接数">
            {{ h.db_open_conns }} 开 / {{ h.db_active_conns }} 活跃
          </ElDescriptionsItem>
          <ElDescriptionsItem label="Agent 运行时">
            goroutines {{ h.agent_goroutines }} · 内存
            {{ h.agent_mem_alloc_mb }} MB · 运行
            {{ formatUptime(h.agent_uptime_seconds) }}
          </ElDescriptionsItem>
          <ElDescriptionsItem label="主机运行时长">
            {{ formatUptime(h.uptime_seconds) }}
          </ElDescriptionsItem>
          <ElDescriptionsItem label="最近上报">
            {{ h.generated_at }}
          </ElDescriptionsItem>
        </ElDescriptions>
      </ElCard>
    </div>
  </Page>
</template>

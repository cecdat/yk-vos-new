<script lang="ts" setup>
import type { VxeTableGridOptions } from '#/adapter/vxe-table';

import { onMounted, onUnmounted, ref } from 'vue';

import { Page } from '@vben/common-ui';

import { ElMessage } from 'element-plus';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { getGatewayLoadReport, getVosInstanceList } from '#/api/vos';

const searchInstanceId = ref<number | null>(null);
const vosInstances = ref<any[]>([]);

const autoRefresh = ref(false);
let refreshTimer: any = null;

async function loadInstances() {
  try {
    const list = await getVosInstanceList();
    vosInstances.value = list || [];
    if (list && list.length > 0) {
      searchInstanceId.value = list[0].id;
      handleSearch();
    }
  } catch (e: any) {
    ElMessage.error(`加载 VOS 实例失败: ${e.message || e}`);
  }
}

/** 刷新表格 */
function handleRefresh() {
  gridApi.query();
}

/** 搜索 */
function handleSearch() {
  handleRefresh();
}

function startTimer() {
  stopTimer();
  refreshTimer = setInterval(() => {
    handleRefresh();
  }, 5000);
}

function stopTimer() {
  if (refreshTimer) {
    clearInterval(refreshTimer);
    refreshTimer = null;
  }
}

function toggleAutoRefresh(val: any) {
  if (val) {
    startTimer();
    ElMessage.success('已开启 5 秒自动轮询刷新');
  } else {
    stopTimer();
    ElMessage.info('已关闭自动轮询');
  }
}

// 负载进度条颜色状态
function getProgressStatus(rate: number) {
  if (rate >= 90) {
    return 'exception'; // 红色
  }
  if (rate >= 75) {
    return 'warning'; // 橙色
  }
  return 'success'; // 绿色
}

// 格式化时长
function formatAloc(val: any) {
  const num = Number(val);
  if (isNaN(num) || num <= 0) return '0s';
  return `${num}s`;
}

const [Grid, gridApi] = useVbenVxeGrid({
  gridOptions: {
    columns: [
      { field: 'id', title: '网关 ID', width: 90 },
      { field: 'name', title: '网关名称', minWidth: 150 },
      {
        field: 'locktype',
        title: '锁定状态',
        width: 100,
        slots: { default: 'locktype' },
      },
      { field: 'capacity', title: '并发容量限制', width: 120 },
      { field: 'activeCalls', title: '实时并发数', width: 110 },
      {
        field: 'loadRate',
        title: '并发负载率',
        minWidth: 200,
        slots: { default: 'loadRate' },
      },
      { field: 'totalCalls', title: '今日总呼叫', width: 110 },
      { field: 'answeredCalls', title: '今日接通数', width: 110 },
      { field: 'asr', title: '接通率 (ASR)', width: 120, slots: { default: 'asr' } },
      { field: 'aloc', title: '平均通话时长 (ALOC)', width: 160, slots: { default: 'aloc' } },
    ],
    height: 'auto',
    keepSource: true,
    rowConfig: {
      keyField: 'id',
      isHover: true,
    },
    pagerConfig: {
      enabled: false, // 监控大盘无需分页，直接全量查看
    },
    proxyConfig: {
      ajax: {
        query: async () => {
          if (!searchInstanceId.value) {
            return { items: [] };
          }
          try {
            const list = await getGatewayLoadReport(searchInstanceId.value);
            return {
              items: list || [],
            };
          } catch (e: any) {
            ElMessage.error(`获取网关负载数据失败: ${e.message || e}`);
            return { items: [] };
          }
        },
      },
    },
  } as VxeTableGridOptions<any>,
});

onMounted(() => {
  loadInstances();
});

onUnmounted(() => {
  stopTimer();
});
</script>

<template>
  <Page auto-content-height>
    <Grid table-title="VOS 落地网关并发负载与 KPI 实时大盘">
      <template #toolbar-tools>
        <div class="flex items-center gap-4">
          <!-- VOS 实例选择 -->
          <el-select
            v-model="searchInstanceId"
            placeholder="请选择 VOS 实例"
            class="w-48"
            @change="handleSearch"
          >
            <el-option
              v-for="item in vosInstances"
              :key="item.id"
              :label="item.name + ' (' + item.vos_id + ')'"
              :value="item.id"
            />
          </el-select>

          <!-- 自动刷新 -->
          <div class="flex items-center gap-1">
            <span class="text-sm text-slate-500 dark:text-zinc-400">并发监控：</span>
            <el-switch
              v-model="autoRefresh"
              active-text="5秒自动刷新"
              @change="toggleAutoRefresh"
            />
          </div>

          <el-button type="primary" @click="handleSearch"> 手动刷新 </el-button>
        </div>
      </template>

      <!-- 锁定状态插槽 -->
      <template #locktype="{ row }">
        <el-tag :type="row.locktype === 0 ? 'success' : 'danger'" size="small">
          {{ row.locktype === 0 ? '激活' : '已锁定' }}
        </el-tag>
      </template>

      <!-- 负载进度条插槽 -->
      <template #loadRate="{ row }">
        <div class="w-full pr-4">
          <el-progress
            :percentage="row.loadRate > 100 ? 100 : row.loadRate"
            :status="getProgressStatus(row.loadRate)"
            :stroke-width="12"
            striped
            striped-flow
          />
        </div>
      </template>

      <!-- ASR 插槽 -->
      <template #asr="{ row }">
        <el-tag :type="row.asr >= 50 ? 'success' : row.asr >= 20 ? 'warning' : 'danger'" size="small">
          {{ row.asr }}%
        </el-tag>
      </template>

      <!-- ALOC 插槽 -->
      <template #aloc="{ row }">
        <span>{{ formatAloc(row.aloc) }}</span>
      </template>
    </Grid>
  </Page>
</template>

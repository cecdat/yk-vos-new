<script lang="ts" setup>
import type { VxeTableGridOptions } from '#/adapter/vxe-table';

import { onMounted, ref } from 'vue';

import { Page } from '@vben/common-ui';

import { ElMessage } from 'element-plus';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { getVosInstanceList, getProfitReport } from '#/api/vos';

const searchVosId = ref('');
const searchAccount = ref('');

// 初始化默认时间范围：7 天前至今天结束
const now = new Date();
const beginDefault = new Date(now.getTime() - 7 * 24 * 3600 * 1000);
beginDefault.setHours(0, 0, 0, 0);
const endDefault = new Date();
endDefault.setHours(23, 59, 59, 999);

const timeRange = ref<[Date, Date]>([beginDefault, endDefault]);

const vosInstances = ref<any[]>([]);

async function loadInstances() {
  try {
    const list = await getVosInstanceList();
    vosInstances.value = list || [];
    if (vosInstances.value.length > 0) {
      // 默认选择第一个实例
      searchVosId.value = vosInstances.value[0].vos_id;
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
  if (!searchVosId.value) {
    ElMessage.warning('请先选择一个 VOS 实例！');
    return;
  }
  if (!timeRange.value || timeRange.value.length < 2) {
    ElMessage.warning('请先选择时间范围！');
    return;
  }
  handleRefresh();
}

/** 重置搜索条件 */
function handleReset() {
  if (vosInstances.value.length > 0) {
    searchVosId.value = vosInstances.value[0].vos_id;
  } else {
    searchVosId.value = '';
  }
  searchAccount.value = '';
  timeRange.value = [beginDefault, endDefault];
  handleRefresh();
}

// 格式化日期
function formatTime(dt: Date): string {
  const pad = (num: number) => String(num).padStart(2, '0');
  return `${dt.getFullYear()}-${pad(dt.getMonth() + 1)}-${pad(dt.getDate())} ${pad(dt.getHours())}:${pad(dt.getMinutes())}:${pad(dt.getSeconds())}`;
}

// 格式化金额
function formatMoney(val: any, precision = 4) {
  if (val === undefined || val === null) return '0.00';
  const num = Number(val);
  return isNaN(num) ? '0.00' : num.toFixed(precision);
}

const [Grid, gridApi] = useVbenVxeGrid({
  gridOptions: {
    columns: [
      { field: 'account', title: '对账账户', minWidth: 150 },
      { field: 'callCount', title: '通话次数 (次)', minWidth: 120 },
      { field: 'billingDurationMinutes', title: '计费时长 (分钟)', minWidth: 140, slots: { default: 'billingDuration' } },
      { field: 'revenue', title: '结算收入 (元)', minWidth: 140, slots: { default: 'revenue' } },
      { field: 'cost', title: '落地成本 (元)', minWidth: 140, slots: { default: 'cost' } },
      { field: 'profit', title: '净利润 (元)', minWidth: 140, slots: { default: 'profit' } },
      { field: 'profitRate', title: '毛利率 (%)', minWidth: 120, slots: { default: 'profitRate' } },
    ],
    height: 'auto',
    keepSource: true,
    rowConfig: {
      keyField: 'account',
      isHover: true,
    },
    pagerConfig: {
      enabled: true,
      pageSize: 20,
      pageSizes: [10, 20, 50, 100],
    },
    proxyConfig: {
      ajax: {
        query: async ({ page }) => {
          if (!searchVosId.value || !timeRange.value) {
            return { items: [], total: 0 };
          }
          const instance = vosInstances.value.find(item => item.vos_id === searchVosId.value);
          if (!instance) {
            return { items: [], total: 0 };
          }
          
          const res = await getProfitReport(instance.id, {
            page: page.currentPage,
            pageSize: page.pageSize,
            beginTime: formatTime(timeRange.value[0]),
            endTime: formatTime(timeRange.value[1]),
            accounts: searchAccount.value.trim() || undefined,
          });

          return {
            items: res.list || [],
            total: res.total || 0,
          };
        },
      },
    },
  } as VxeTableGridOptions<any>,
});

onMounted(() => {
  loadInstances();
});
</script>

<template>
  <Page auto-content-height>
    <Grid table-title="VOS 客户财务利润及对账统计 (读隔离)">
      <template #toolbar-tools>
        <div class="flex flex-wrap items-center gap-2">
          <!-- VOS 实例选择 -->
          <el-select
            v-model="searchVosId"
            placeholder="请选择 VOS 实例"
            class="w-48"
            @change="handleSearch"
          >
            <el-option
              v-for="item in vosInstances"
              :key="item.vos_id"
              :label="item.name + ' (' + item.vos_id + ')'"
              :value="item.vos_id"
            />
          </el-select>

          <!-- 时间范围选择 -->
          <el-date-picker
            v-model="timeRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            :clearable="false"
            class="!w-80"
            @change="handleSearch"
          />

          <!-- 账号搜索 -->
          <el-input
            v-model="searchAccount"
            placeholder="多账号以逗号分隔"
            clearable
            class="w-48"
            @keyup.enter="handleSearch"
          />

          <el-button type="primary" @click="handleSearch">
            搜索
          </el-button>
          <el-button @click="handleReset">
            重置
          </el-button>
        </div>
      </template>

      <!-- 计费时长插槽 -->
      <template #billingDuration="{ row }">
        <span>{{ formatMoney(row.billingDurationMinutes, 2) }}</span>
      </template>

      <!-- 结算收入插槽 -->
      <template #revenue="{ row }">
        <span>{{ formatMoney(row.revenue, 4) }}</span>
      </template>

      <!-- 成本插槽 -->
      <template #cost="{ row }">
        <span>{{ formatMoney(row.cost, 4) }}</span>
      </template>

      <!-- 利润插槽 -->
      <template #profit="{ row }">
        <span
          :class="[
            'font-semibold',
            row.profit > 0 
              ? 'text-emerald-600 dark:text-emerald-400' 
              : row.profit < 0 
                ? 'text-rose-600 dark:text-rose-400' 
                : 'text-slate-800 dark:text-zinc-200'
          ]"
        >
          {{ formatMoney(row.profit, 4) }}
        </span>
      </template>

      <!-- 毛利率插槽 -->
      <template #profitRate="{ row }">
        <span
          :class="[
            'font-medium',
            row.profitRate > 0 
              ? 'text-emerald-600 dark:text-emerald-400' 
              : row.profitRate < 0 
                ? 'text-rose-600 dark:text-rose-400' 
                : 'text-slate-800 dark:text-zinc-200'
          ]"
        >
          {{ formatMoney(row.profitRate, 2) }}%
        </span>
      </template>
    </Grid>
  </Page>
</template>

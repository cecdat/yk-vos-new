<script lang="ts" setup>
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import { ref } from 'vue';
import { Page } from '@vben/common-ui';
import { ElMessage } from 'element-plus';
import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  queryCdrsFromVos,
  getVosInstanceList,
} from '#/api/cdr';
import type { CdrApi } from '#/api/cdr';
import type { VosInstanceApi } from '#/api/vos';
import {
  formatTs,
  formatEndDirection,
  formatYmd,
  useGridColumns,
} from './data';

const instances = ref<VosInstanceApi.VosInstance[]>([]);
const instanceId = ref<number | undefined>(undefined);
const beginDate = ref<string>(fmtDateTime(new Date(Date.now() - 7 * 86400000), '00:00:00'));
const endDate = ref<string>(fmtDateTime(new Date(), '23:59:59'));
const account = ref('');
const caller = ref('');
const callee = ref('');

const lastMessage = ref('');
const lastSource = ref('');
const lastCost = ref(0);

function fmtDateTime(d: Date, timeStr: string): string {
  const p = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${timeStr}`;
}

async function loadInstances() {
  try {
    instances.value = await getVosInstanceList();
  } catch {
    // 静默：查询函数会据此给出提示
  }
}

async function queryCdrs({
  page,
}: {
  page?: { currentPage: number; pageSize: number };
}) {
  // 确保实例已加载，未选择则默认取第一个，便于“打开即见数据”
  if (instances.value.length === 0) {
    await loadInstances();
  }
  if (!instanceId.value && instances.value.length > 0) {
    instanceId.value = instances.value[0].id;
  }
  if (!instanceId.value) {
    lastMessage.value = '尚未配置任何 VOS 节点，请先在「VOS 管理」中添加。';
    lastSource.value = '';
    lastCost.value = 0;
    return { list: [], total: 0 };
  }
  if (!beginDate.value || !endDate.value) {
    lastMessage.value = '请选择开始与结束日期。';
    return { list: [], total: 0 };
  }
  const resp = await queryCdrsFromVos(instanceId.value, {
    beginTime: formatYmd(beginDate.value),
    endTime: formatYmd(endDate.value),
    page: page?.currentPage ?? 1,
    pageSize: page?.pageSize ?? 20,
    accounts: account.value || undefined,
    callerE164: caller.value || undefined,
    calleeE164: callee.value || undefined,
  });
  lastMessage.value = resp.message || resp.error || '';
  lastSource.value = resp.data_source || '';
  lastCost.value = resp.query_time_ms || 0;
  if (!resp.success) {
    ElMessage.error(resp.error || '查询失败');
    return { list: [], total: 0 };
  }
  return {
    list: resp.cdrs ?? [],
    total: resp.total ?? 0,
  };
}

function handleSearch() {
  gridApi.query();
}

function handleReset() {
  account.value = '';
  caller.value = '';
  callee.value = '';
  handleSearch();
}

const [Grid, gridApi] = useVbenVxeGrid({
  gridOptions: {
    columns: useGridColumns(),
    height: 'auto',
    rowConfig: {
      isHover: true,
      keyField: 'flowNo',
    },
    pagerConfig: {
      enabled: true,
      pageSize: 20,
    },
    proxyConfig: {
      ajax: {
        query: queryCdrs,
      },
    },
  } as VxeTableGridOptions<CdrApi.CdrRecord>,
});
</script>

<template>
  <Page auto-content-height>
    <div class="mb-3 flex flex-wrap items-center gap-x-3 gap-y-2">
      <el-select
        v-model="instanceId"
        placeholder="选择 VOS 节点"
        style="width: 240px"
        clearable
        @change="handleSearch"
      >
        <el-option
          v-for="item in instances"
          :key="item.id"
          :label="item.base_url ? `${item.name} (${item.base_url})` : item.name"
          :value="item.id"
        />
      </el-select>
      <el-date-picker
        v-model="beginDate"
        type="datetime"
        value-format="YYYY-MM-DD HH:mm:ss"
        placeholder="开始时间"
        style="width: 200px"
      />
      <span>~</span>
      <el-date-picker
        v-model="endDate"
        type="datetime"
        value-format="YYYY-MM-DD HH:mm:ss"
        placeholder="结束时间"
        style="width: 200px"
      />
      <el-input
        v-model="account"
        placeholder="账号（可选）"
        clearable
        style="width: 150px"
      />
      <el-input
        v-model="caller"
        placeholder="主叫（可选）"
        clearable
        style="width: 150px"
      />
      <el-input
        v-model="callee"
        placeholder="被叫（可选）"
        clearable
        style="width: 150px"
      />
      <el-button type="primary" @click="handleSearch">查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div v-if="lastMessage" class="mb-2 text-sm text-gray-500">
      {{ lastMessage }}
      <template v-if="lastSource">
        <el-divider direction="vertical" />
        来源：<el-tag size="small">{{ lastSource }}</el-tag>
        <el-divider direction="vertical" />
        {{ lastCost }} ms
      </template>
    </div>

    <Grid table-title="话单列表">
      <template #start="{ row }">
        {{ formatTs(row.start) }}
      </template>
      <template #stop="{ row }">
        {{ formatTs(row.stop) }}
      </template>
      <template #endDirection="{ row }">
        {{ formatEndDirection(row.endDirection) }}
      </template>
    </Grid>
  </Page>
</template>

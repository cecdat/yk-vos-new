<script lang="ts" setup>
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { VosCustomer } from '#/api/vos';

import { onMounted, ref } from 'vue';

import { Page } from '@vben/common-ui';

import { ElMessage, ElMessageBox } from 'element-plus';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { getCustomerPage, getVosInstanceList, updateCustomerLimit, updateCustomerStatus } from '#/api/vos';

const searchVosId = ref('');
const searchAccount = ref('');
const searchStatus = ref<number | string>('');

const vosInstances = ref<any[]>([]);

// 调额弹窗相关
const limitDialogVisible = ref(false);
const limitLoading = ref(false);
const currentCustomer = ref<VosCustomer | null>(null);
const newLimitMoney = ref(0);

async function loadInstances() {
  try {
    const list = await getVosInstanceList();
    vosInstances.value = list || [];
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

/** 重置搜索条件 */
function handleReset() {
  searchVosId.value = '';
  searchAccount.value = '';
  searchStatus.value = '';
  handleRefresh();
}

/** 调额弹窗开启 */
function openLimitDialog(row: VosCustomer) {
  currentCustomer.value = row;
  newLimitMoney.value = row.limitmoney;
  limitDialogVisible.visible = true; // Wait: v-model:visible or v-model
  limitDialogVisible.value = true;
}

/** 调额提交 */
async function submitLimit() {
  if (!currentCustomer.value) return;
  if (newLimitMoney.value < -100000 || newLimitMoney.value > 100000) {
    ElMessage.warning('限额调整安全范围为 [-100000, 100000]');
    return;
  }
  limitLoading.value = true;
  try {
    await updateCustomerLimit({
      id: currentCustomer.value.id,
      limitmoney: newLimitMoney.value,
    });
    ElMessage.success('额度调整指令下发成功！');
    limitDialogVisible.value = false;
    handleRefresh();
  } catch (e: any) {
    ElMessage.error(`调整额度失败: ${e.message || e}`);
  } finally {
    limitLoading.value = false;
  }
}

/** 锁定/解锁客户账户 */
async function toggleStatus(row: VosCustomer) {
  const targetStatus = row.status === 0 ? 1 : 0;
  const actionName = targetStatus === 1 ? '锁定' : '解锁';
  
  ElMessageBox.confirm(
    `确定要对客户账户 [${row.account}] 执行 [${actionName}] 操作吗？`,
    '系统提示',
    {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      await updateCustomerStatus({
        id: row.id,
        status: targetStatus,
      });
      ElMessage.success(`客户账户 [${row.account}] ${actionName} 指令已成功下发！`);
      handleRefresh();
    } catch (e: any) {
      ElMessage.error(`切换状态失败: ${e.message || e}`);
    }
  }).catch(() => {});
}

// 格式化金额
function formatMoney(val: any) {
  if (val === undefined || val === null) return '0.0000';
  const num = Number(val);
  return isNaN(num) ? '0.0000' : num.toFixed(4);
}

const [Grid, gridApi] = useVbenVxeGrid({
  gridOptions: {
    columns: [
      { field: 'id', title: '编号', width: 80 },
      { field: 'vosId', title: 'Agent ID', minWidth: 120 },
      { field: 'customerId', title: 'VOS 客户 ID', minWidth: 120 },
      { field: 'account', title: '账户名', minWidth: 150 },
      { field: 'name', title: '姓名/描述', minWidth: 160 },
      { field: 'money', title: '当前余额 (元)', minWidth: 140, slots: { default: 'money' } },
      { field: 'limitmoney', title: '信用限额 (元)', minWidth: 140, slots: { default: 'limitmoney' } },
      { field: 'todayconsumption', title: '今日消费 (元)', minWidth: 140, slots: { default: 'todayconsumption' } },
      { field: 'status', title: '账号状态', minWidth: 100, slots: { default: 'status' } },
      { field: 'feerategroupId', title: '计费费率组', minWidth: 120 },
      { title: '操作', width: 180, fixed: 'right', slots: { default: 'actions' } },
    ],
    height: 'auto',
    keepSource: true,
    rowConfig: {
      keyField: 'id',
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
          const res = await getCustomerPage({
            pageNo: page.currentPage,
            pageSize: page.pageSize,
            vosId: searchVosId.value || undefined,
            account: searchAccount.value.trim() || undefined,
            status: searchStatus.value !== '' ? Number(searchStatus.value) : undefined,
          });
          return {
            items: res.list || [],
            total: res.total || 0,
          };
        },
      },
    },
  } as VxeTableGridOptions<VosCustomer>,
});

onMounted(() => {
  loadInstances();
});
</script>

<template>
  <Page auto-content-height>
    <Grid table-title="VOS 客户管理 (读隔离)">
      <template #toolbar-tools>
        <div class="flex items-center gap-2">
          <!-- VOS 实例选择 -->
          <el-select
            v-model="searchVosId"
            placeholder="请选择 VOS 实例"
            clearable
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

          <!-- 账号搜索 -->
          <el-input
            v-model="searchAccount"
            placeholder="账户名检索"
            clearable
            class="w-44"
            @keyup.enter="handleSearch"
          />

          <!-- 状态搜索 -->
          <el-select
            v-model="searchStatus"
            placeholder="状态过滤"
            clearable
            class="w-36"
            @change="handleSearch"
          >
            <el-option label="正常" :value="0" />
            <el-option label="已锁定" :value="1" />
          </el-select>

          <el-button type="primary" @click="handleSearch">
            搜索
          </el-button>
          <el-button @click="handleReset">
            重置
          </el-button>
        </div>
      </template>

      <!-- 余额插槽 -->
      <template #money="{ row }">
        <span :class="row.money <= row.limitmoney ? 'text-rose-600 font-semibold' : 'text-slate-800 dark:text-zinc-200'">
          {{ formatMoney(row.money) }}
        </span>
      </template>

      <!-- 信用限额插槽 -->
      <template #limitmoney="{ row }">
        <span>{{ formatMoney(row.limitmoney) }}</span>
      </template>

      <!-- 今日消费插槽 -->
      <template #todayconsumption="{ row }">
        <span>{{ formatMoney(row.todayconsumption) }}</span>
      </template>

      <!-- 状态插槽 -->
      <template #status="{ row }">
        <el-tag :type="row.status === 0 ? 'success' : 'danger'" size="small">
          {{ row.status === 0 ? '正常' : '已锁定' }}
        </el-tag>
      </template>

      <!-- 操作按钮插槽 -->
      <template #actions="{ row }">
        <div class="flex items-center gap-1">
          <!-- 调额按钮 -->
          <el-button
            type="primary"
            link
            size="small"
            @click="openLimitDialog(row)"
          >
            调额
          </el-button>

          <!-- 锁定与激活切换按钮 -->
          <el-button
            :type="row.status === 0 ? 'danger' : 'success'"
            link
            size="small"
            @click="toggleStatus(row)"
          >
            {{ row.status === 0 ? '锁定' : '激活' }}
          </el-button>
        </div>
      </template>
    </Grid>

    <!-- 信用额度调整模态框 -->
    <el-dialog
      v-model="limitDialogVisible"
      title="修改信用透支额度"
      width="460px"
      destroy-on-close
    >
      <el-form v-if="currentCustomer" label-width="100px" class="pr-4">
        <el-form-item label="客户账户">
          <el-input :model-value="currentCustomer.account" disabled />
        </el-form-item>
        <el-form-item label="当前余额">
          <el-input :model-value="formatMoney(currentCustomer.money) + ' 元'" disabled />
        </el-form-item>
        <el-form-item label="透支额度">
          <el-input-number
            v-model="newLimitMoney"
            :precision="4"
            :step="100"
            style="width: 100%;"
          />
          <div class="text-[12px] text-slate-400 dark:text-zinc-500 mt-1">
            说明：负数代表信用透支额度（例如 -1000 元表示允许欠费 1000 元）。正数代表限制额度。调额范围 [-100000, 100000]。
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="flex justify-end gap-2">
          <el-button @click="limitDialogVisible = false">取消</el-button>
          <el-button
            type="primary"
            :loading="limitLoading"
            @click="submitLimit"
          >
            下发控制
          </el-button>
        </div>
      </template>
    </el-dialog>
  </Page>
</template>

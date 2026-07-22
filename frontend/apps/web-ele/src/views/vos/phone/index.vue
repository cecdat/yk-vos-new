<script lang="ts" setup>
import type { VxeTableGridOptions } from '#/adapter/vxe-table';

import { onMounted, ref } from 'vue';

import { Page } from '@vben/common-ui';

import { ElMessage, ElMessageBox } from 'element-plus';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { getPhonePage, getVosInstanceList, recyclePhone } from '#/api/vos';

const searchInstanceId = ref<number | null>(null);
const searchE164 = ref('');

const vosInstances = ref<any[]>([]);

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

/** 重置搜索条件 */
function handleReset() {
  if (vosInstances.value.length > 0) {
    searchInstanceId.value = vosInstances.value[0].id;
  } else {
    searchInstanceId.value = null;
  }
  searchE164.value = '';
  handleRefresh();
}

/** 单个号码回收 */
function handleSingleRecycle(row: any) {
  if (!searchInstanceId.value) return;
  ElMessageBox.confirm(
    `确定要回收电话号码 [${row.e164}] 吗？中台将下发控制指令，VOS Agent 消费后会联动卸载路由映射并挂断占用信道！`,
    '系统回收警告',
    {
      confirmButtonText: '确认回收',
      cancelButtonText: '取消',
      type: 'warning',
    },
  )
    .then(async () => {
      try {
        await recyclePhone({
          instanceId: searchInstanceId.value!,
          e164s: [row.e164],
        });
        ElMessage.success(`号码 [${row.e164}] 回收指令下发成功，本地缓存已清退！`);
        handleRefresh();
      } catch (e: any) {
        ElMessage.error(`回收失败: ${e.message || e}`);
      }
    })
    .catch(() => {});
}

/** 批量号码回收 */
function handleBatchRecycle() {
  const selectedRows = gridApi.grid.getCheckboxRecords();
  if (selectedRows.length === 0) {
    ElMessage.warning('请先勾选需要回收的号码！');
    return;
  }
  if (!searchInstanceId.value) {
    ElMessage.warning('获取 VOS 实例 ID 失败！');
    return;
  }

  const e164s = selectedRows.map((row: any) => row.e164);

  ElMessageBox.confirm(
    `确定要批量回收/删除选中的 ${e164s.length} 个电话号码吗？此操作会通知 Agent 联动卸载挂载并释放并发信道！`,
    '安全批量回收告警',
    {
      confirmButtonText: '确认批量回收',
      cancelButtonText: '取消',
      type: 'warning',
    },
  )
    .then(async () => {
      try {
        await recyclePhone({
          instanceId: searchInstanceId.value!,
          e164s: e164s,
        });
        ElMessage.success(`批量回收 ${e164s.length} 个号码指令已成功投递！`);
        handleRefresh();
      } catch (e: any) {
        ElMessage.error(`批量回收失败: ${e.message || e}`);
      }
    })
    .catch(() => {});
}

const [Grid, gridApi] = useVbenVxeGrid({
  gridOptions: {
    columns: [
      { type: 'checkbox', width: 60 },
      { field: 'id', title: '号码编号', width: 120 },
      { field: 'e164', title: '电话号码 (E.164)', minWidth: 240 },
      { field: 'feerategroupId', title: '计费费率组 ID', minWidth: 200 },
      {
        title: '操作',
        width: 140,
        fixed: 'right',
        slots: { default: 'actions' },
      },
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
          if (!searchInstanceId.value) {
            return { items: [], total: 0 };
          }
          try {
            const res = await getPhonePage({
              pageNo: page.currentPage,
              pageSize: page.pageSize,
              instanceId: searchInstanceId.value,
              e164: searchE164.value.trim() || undefined,
            });
            return {
              items: res.list || [],
              total: res.total || 0,
            };
          } catch (e: any) {
            ElMessage.error(`查询号码列表失败: ${e.message || e}`);
            return { items: [], total: 0 };
          }
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
    <Grid table-title="VOS 号码资产管理 (API 联动)">
      <template #toolbar-tools>
        <div class="flex items-center gap-2">
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

          <!-- 号码过滤 -->
          <el-input
            v-model="searchE164"
            placeholder="电话号码模糊检索"
            clearable
            class="w-44"
            @keyup.enter="handleSearch"
          />

          <el-button type="primary" @click="handleSearch"> 搜索 </el-button>
          <el-button @click="handleReset"> 重置 </el-button>

          <el-button type="danger" @click="handleBatchRecycle">
            批量回收
          </el-button>
        </div>
      </template>

      <!-- 操作按钮插槽 -->
      <template #actions="{ row }">
        <el-button type="danger" link size="small" @click="handleSingleRecycle(row)">
          回收号码
        </el-button>
      </template>
    </Grid>
  </Page>
</template>

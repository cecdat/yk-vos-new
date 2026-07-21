<script lang="ts" setup>
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { VosInstanceApi } from '#/api/vos';

import { ref } from 'vue';

import { Page, useVbenModal } from '@vben/common-ui';

import { ElMessage } from 'element-plus';

import { ACTION_ICON, TableAction, useVbenVxeGrid } from '#/adapter/vxe-table';
import { deleteVosInstance, getVosInstanceList } from '#/api/vos';
import { $t } from '#/locales';

import { extractHost, useGridColumns } from './data';
import Form from './modules/form.vue';

const [FormModal, formModalApi] = useVbenModal({
  connectedComponent: Form,
  destroyOnClose: true,
});

const searchName = ref('');
const searchIp = ref('');

/** 列表查询（GET /vos/instances 返回全量，前端按名称 / IP 模糊过滤） */
async function queryVosList() {
  const list = await getVosInstanceList();
  const name = searchName.value.trim().toLowerCase();
  const ip = searchIp.value.trim().toLowerCase();
  return list.filter((item) => {
    const matchName = name
      ? (item.name || '').toLowerCase().includes(name)
      : true;
    const matchIp = ip
      ? (item.base_url || '').toLowerCase().includes(ip)
      : true;
    return matchName && matchIp;
  });
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
  searchName.value = '';
  searchIp.value = '';
  handleRefresh();
}

/** 创建 VOS 实例 */
function handleCreate() {
  formModalApi.setData(null).open();
}

/** 编辑 VOS 实例 */
function handleEdit(row: VosInstanceApi.VosInstance) {
  formModalApi.setData(row).open();
}

/** 删除 VOS 实例 */
async function handleDelete(row: VosInstanceApi.VosInstance) {
  await deleteVosInstance(row.id!);
  ElMessage.success($t('ui.actionMessage.deleteSuccess', [row.name]));
  handleRefresh();
}

const [Grid, gridApi] = useVbenVxeGrid({
  gridOptions: {
    columns: useGridColumns(),
    height: 'auto',
    keepSource: true,
    rowConfig: {
      keyField: 'id',
      isHover: true,
    },
    pagerConfig: {
      enabled: false,
    },
    proxyConfig: {
      ajax: {
        query: queryVosList,
      },
    },
  } as VxeTableGridOptions<VosInstanceApi.VosInstance>,
});
</script>

<template>
  <Page auto-content-height>
    <FormModal @success="handleRefresh" />
    <Grid table-title="VOS 实例列表">
      <template #toolbar-tools>
        <div class="flex items-center gap-2">
          <el-input
            v-model="searchName"
            placeholder="名称（模糊）"
            clearable
            class="w-44"
            @keyup.enter="handleSearch"
          />
          <el-input
            v-model="searchIp"
            placeholder="IP / 地址（模糊）"
            clearable
            class="w-52"
            @keyup.enter="handleSearch"
          />
          <el-button type="primary" @click="handleSearch">
            搜索
          </el-button>
          <el-button @click="handleReset">
            重置
          </el-button>
          <TableAction
            :actions="[
              {
                label: $t('ui.actionTitle.create', ['VOS 实例']),
                type: 'primary',
                icon: ACTION_ICON.ADD,
                onClick: handleCreate,
              },
            ]"
          />
        </div>
      </template>
      <template #base_url="{ row }">
        <el-tooltip :content="row.base_url" placement="top">
          <span>{{ extractHost(row.base_url) }}</span>
        </el-tooltip>
      </template>
      <template #enabled="{ row }">
        <el-tag :type="row.enabled ? 'success' : 'info'">
          {{ row.enabled ? '启用' : '禁用' }}
        </el-tag>
      </template>
      <template #health_status="{ row }">
        <el-tag
          :type="
            row.health_status === 'healthy'
              ? 'success'
              : row.health_status === 'unhealthy'
                ? 'danger'
                : 'info'
          "
        >
          {{ row.health_status || 'unknown' }}
        </el-tag>
      </template>
      <template #actions="{ row }">
        <TableAction
          :actions="[
            {
              label: $t('common.edit'),
              type: 'primary',
              link: true,
              icon: ACTION_ICON.EDIT,
              onClick: handleEdit.bind(null, row),
            },
            {
              label: $t('common.delete'),
              type: 'danger',
              link: true,
              icon: ACTION_ICON.DELETE,
              popConfirm: {
                title: $t('ui.actionMessage.deleteConfirm', [row.name]),
                confirm: handleDelete.bind(null, row),
              },
            },
          ]"
        />
      </template>
    </Grid>
  </Page>
</template>

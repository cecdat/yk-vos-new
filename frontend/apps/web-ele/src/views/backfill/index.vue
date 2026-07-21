<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue';
import {
  ElCard,
  ElTable,
  ElTableColumn,
  ElButton,
  ElSelect,
  ElOption,
  ElProgress,
  ElTag,
  ElDialog,
  ElForm,
  ElFormItem,
  ElInput,
  ElInputNumber,
  ElMessageBox,
  ElMessage,
  ElRow,
  ElCol,
  ElStatistic,
  ElDropdown,
  ElDropdownMenu,
  ElDropdownItem,
} from 'element-plus';
import {
  getVosInstanceList,
  getAvailabilityList,
  getTaskList,
  startBackfill,
  pauseBackfill,
  resumeBackfill,
  cancelBackfill,
  setThrottle,
  dispatchBackfill,
  triggerPreciseCount,
  triggerRescan,
  type VosInstanceApi,
} from '#/api/vos';

// 实例下拉
const instances = ref<VosInstanceApi.VosInstance[]>([]);
const selectedVosId = ref<string>('');

// 可用历史表列表
const availabilities = ref<VosInstanceApi.VosAgentBackfill[]>([]);
const tableLoading = ref(false);
const selectedTables = ref<VosInstanceApi.VosAgentBackfill[]>([]);

// 控制日志/任务列表
const tasks = ref<VosInstanceApi.VosBackfillTask[]>([]);
const logLoading = ref(false);

// 统计大屏看板数据
const totalEstimatedRows = ref(0);
const totalPushedRows = ref(0);
const syncingTasksCount = ref(0);

// 回填弹窗控制
const startDialogVisible = ref(false);
const startForm = ref({
  mode: 'immediate',
  cron: '',
  speedLimit: 10000,
});

// 限速弹窗控制
const throttleDialogVisible = ref(false);
const throttleForm = ref({
  commandId: '',
  speedLimit: 5000,
});

let timer: any = null;

// 获取实例列表
const fetchInstances = async () => {
  try {
    const res = await getVosInstanceList();
    instances.value = res || [];
    if (instances.value.length > 0) {
      selectedVosId.value = instances.value[0].vos_id || '';
    }
  } catch (err: any) {
    ElMessage.error('获取 VOS 实例列表失败: ' + (err.message || err));
  }
};

// 获取历史表可用性及任务
// showLoading=true 用于首次/手动刷新（带 loading 遮罩）；false 用于 2s 轮询（不闪）
const fetchData = async (showLoading = true) => {
  if (!selectedVosId.value) return;

  if (showLoading) {
    tableLoading.value = true;
    logLoading.value = true;
  }
  try {
    // 1. 可用表列表
    const availRes = await getAvailabilityList(selectedVosId.value);
    availabilities.value = availRes || [];

    // 2. 任务日志列表
    const taskRes = await getTaskList(selectedVosId.value);
    tasks.value = taskRes || [];

    // 3. 计算大屏统计数据
    let est = 0;
    let push = 0;
    availabilities.value.forEach((t) => {
      est += t.estimatedRows;
      push += t.alreadyPushed;
    });
    totalEstimatedRows.value = est;
    totalPushedRows.value = push;

    syncingTasksCount.value = tasks.value.filter(
      (t) => t.status === 'syncing' || t.status === 'dispatched'
    ).length;

  } catch (err: any) {
    if (showLoading) ElMessage.error('加载回填元数据失败: ' + (err.message || err));
  } finally {
    if (showLoading) {
      tableLoading.value = false;
      logLoading.value = false;
    }
  }
};
// 选定 VOS ID 改变时加载数据
watch(selectedVosId, () => {
  fetchData();
});

// 定时轮询 (2秒，不切换 loading，避免页面闪烁)
onMounted(async () => {
  await fetchInstances();
  timer = setInterval(() => {
    fetchData(false);
  }, 2000);
});

onUnmounted(() => {
  if (timer) clearInterval(timer);
});

// 表格多选改变
const handleSelectionChange = (val: any) => {
  selectedTables.value = val;
};

// 重新扫描日表
const handleRescan = async () => {
  if (!selectedVosId.value) return;
  try {
    await triggerRescan(selectedVosId.value);
    ElMessage.success('已下发重新扫描指令，等待 Agent 响应');
    fetchData();
  } catch (err: any) {
    ElMessage.error('下发扫描指令失败: ' + err.message);
  }
};

// 发起精确统计 COUNT(*)
const handlePreciseCount = async (tableName: string) => {
  if (!selectedVosId.value) return;
  try {
    await triggerPreciseCount(selectedVosId.value, tableName);
    ElMessage.success(`已下发表 [${tableName}] 精确 COUNT(*) 指令，稍后自动同步`);
  } catch (err: any) {
    ElMessage.error('下发精确统计指令失败: ' + err.message);
  }
};

// 打开启动回填弹窗
const openStartDialog = () => {
  if (selectedTables.value.length === 0) {
    ElMessage.warning('请勾选左侧表格要回填的历史日表！');
    return;
  }
  startDialogVisible.value = true;
};

// 确认提交启动任务
const submitStartBackfill = async () => {
  const tables = selectedTables.value.map((t) => t.tableName);
  try {
    const status = await startBackfill({
      vosId: selectedVosId.value,
      tables,
      mode: startForm.value.mode,
      cron: startForm.value.mode === 'scheduled' ? startForm.value.cron : undefined,
      speedLimit: startForm.value.speedLimit,
    });

    if (status === 'queued') {
      ElMessage.warning('系统当前同步并发数已满（最大 3），回填任务已进入排队序列。');
    } else {
      ElMessage.success('回填控制指令下发成功！');
    }
    startDialogVisible.value = false;
    fetchData();
  } catch (err: any) {
    ElMessage.error('启动回填任务失败: ' + err.message);
  }
};

// 控制动作 (pause, resume, cancel) —— 由下拉菜单调用
const handleControl = async (action: 'pause' | 'resume' | 'cancel', commandId: string) => {
  const labels = { pause: '暂停', resume: '继续', cancel: '取消中止' };
  try {
    await ElMessageBox.confirm(`确定要对当前任务下发 [${labels[action]}] 指令吗？`, '提示', {
      type: 'warning',
    });

    if (action === 'pause') {
      await pauseBackfill(commandId);
    } else if (action === 'resume') {
      await resumeBackfill(commandId);
    } else {
      await cancelBackfill(commandId);
    }
    ElMessage.success(`[${labels[action]}] 控制指令发送成功`);
    fetchData();
  } catch (err: any) {
    if (err !== 'cancel') {
      ElMessage.error('下发控制指令失败: ' + err.message);
    }
  }
};

// 手动下发（启动下发）待下发/排队的任务
const handleDispatch = async (id: number) => {
  try {
    await dispatchBackfill(id);
    ElMessage.success('已下发启动指令，等待 Agent 执行...');
    fetchData();
  } catch (err: any) {
    ElMessage.error('启动下发失败: ' + (err.message || err));
  }
};

// 下拉指令分发
const onTaskCommand = (cmd: string, row: any) => {
  if (cmd === 'dispatch') {
    handleDispatch(row.id);
  } else if (cmd === 'throttle') {
    openThrottleDialog(row.commandId, row.params?.speed_limit);
  } else {
    handleControl(cmd as 'pause' | 'resume' | 'cancel', row.commandId);
  }
};

// 打开限流调节弹窗
const openThrottleDialog = (commandId: string, currentLimit?: number) => {
  throttleForm.value.commandId = commandId;
  throttleForm.value.speedLimit = currentLimit || 10000;
  throttleDialogVisible.value = true;
};

// 提交限流参数
const submitThrottle = async () => {
  try {
    await setThrottle(throttleForm.value.commandId, throttleForm.value.speedLimit);
    ElMessage.success('限流调整参数发送成功！');
    throttleDialogVisible.value = false;
    fetchData();
  } catch (err: any) {
    ElMessage.error('调整限速失败: ' + err.message);
  }
};

// 计算单个日表的百分比进度
const getProgressPercent = (row: VosInstanceApi.VosAgentBackfill) => {
  if (!row.estimatedRows) return 0;
  const pct = Math.floor((row.alreadyPushed / row.estimatedRows) * 100);
  return pct > 100 ? 100 : pct;
};

// 映射任务状态颜色
const getTaskStatusType = (status: string): "primary" | "success" | "warning" | "info" | "danger" | undefined => {
  switch (status) {
    case 'syncing':
      return 'primary';
    case 'done':
      return 'success';
    case 'paused':
      return 'warning';
    case 'cancelled':
      return 'info';
    case 'failed':
      return 'danger';
    case 'queued':
      return 'warning';
    default:
      return 'info';
  }
};

// 映射可用性表同步状态颜色
const getBackfillStatusType = (status: string): "primary" | "success" | "warning" | "info" | "danger" | undefined => {
  switch (status) {
    case 'syncing':
      return 'warning';
    case 'done':
      return 'success';
    case 'pending':
      return 'info';
    default:
      return 'info';
  }
};

// 日表列悬浮显示字符串
const tableNames = (row: VosInstanceApi.VosBackfillTask) => {
  return row.tables && row.tables.length ? row.tables.join(', ') : '-';
};
</script>

<template>
  <div class="p-6 space-y-6">
    <!-- 头部选择器 & 统计大屏看板 -->
    <ElCard shadow="hover" class="border-none rounded-xl" style="background: linear-gradient(135deg, #1f2d3d 0%, #111a24 100%); color: #fff;">
      <div class="flex justify-between items-center mb-6">
        <div class="flex items-center space-x-4">
          <span class="text-lg font-semibold text-white">VOS 实例选择：</span>
          <ElSelect v-model="selectedVosId" placeholder="选择 VOS 实例" style="width: 240px">
            <ElOption
              v-for="item in instances"
              :key="item.vos_id"
              :label="`${item.name} (${item.vos_id})`"
              :value="item.vos_id || ''"
            />
          </ElSelect>
          <ElButton type="primary" plain @click="handleRescan" :disabled="!selectedVosId">重新扫描可用日表</ElButton>
          <ElButton type="success" @click="openStartDialog" :disabled="selectedTables.length === 0">启动批量回填</ElButton>
        </div>
        <div class="text-sm text-gray-400">
          * 2秒智能自动轮询，实时展现话单行级推送进度与心跳硬件监控
        </div>
      </div>

      <!-- 统计大屏指标 -->
      <ElRow :gutter="20" class="text-center">
        <ElCol :span="8">
          <div class="bg-opacity-10 bg-white p-4 rounded-xl">
            <div class="text-gray-400 text-sm mb-1">已检测历史话单总行数 (估算)</div>
            <div class="text-3xl font-bold text-blue-400">{{ totalEstimatedRows.toLocaleString() }} 行</div>
          </div>
        </ElCol>
        <ElCol :span="8">
          <div class="bg-opacity-10 bg-white p-4 rounded-xl">
            <div class="text-gray-400 text-sm mb-1">中台 ClickHouse 已入库总行数</div>
            <div class="text-3xl font-bold text-green-400">{{ totalPushedRows.toLocaleString() }} 行</div>
          </div>
        </ElCol>
        <ElCol :span="8">
          <div class="bg-opacity-10 bg-white p-4 rounded-xl">
            <div class="text-gray-400 text-sm mb-1">正在活动的同步任务</div>
            <div class="text-3xl font-bold text-yellow-400">{{ syncingTasksCount }} / 3 <span class="text-sm font-normal text-gray-400">(全局流控)</span></div>
          </div>
        </ElCol>
      </ElRow>
    </ElCard>

    <ElRow :gutter="20">
      <!-- 左侧：历史话单日表列表 -->
      <ElCol :span="12">
        <ElCard header="📅 历史日表清单及行数进度" shadow="hover" class="rounded-xl border-none">
          <ElTable
            :data="availabilities"
            v-loading="tableLoading"
            row-key="id"
            style="width: 100%"
            height="550"
            @selection-change="handleSelectionChange"
          >
            <ElTableColumn type="selection" width="55" />
            <ElTableColumn prop="tableName" label="历史日表" min-width="160" />
            <ElTableColumn label="物理估算行" min-width="120">
              <template #default="{ row }">
                {{ row.estimatedRows.toLocaleString() }}
              </template>
            </ElTableColumn>
            <ElTableColumn label="已推行数" min-width="120">
              <template #default="{ row }">
                {{ row.alreadyPushed.toLocaleString() }}
              </template>
            </ElTableColumn>
            <ElTableColumn label="同步进度" min-width="150">
              <template #default="{ row }">
                <ElProgress
                  :percentage="getProgressPercent(row)"
                  :status="row.status === 'done' ? 'success' : row.status === 'syncing' ? 'warning' : ''"
                  :stroke-width="12"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn prop="status" label="状态" width="100">
              <template #default="{ row }">
                <ElTag :type="getBackfillStatusType(row.status)">
                  {{
                    row.status === 'pending'
                      ? '待回填'
                      : row.status === 'syncing'
                      ? '回填中'
                      : row.status === 'done'
                      ? '已完成'
                      : row.status
                  }}
                </ElTag>
              </template>
            </ElTableColumn>
            <ElTableColumn label="精确校验" width="100" fixed="right">
              <template #default="{ row }">
                <ElButton
                  size="small"
                  type="info"
                  plain
                  @click="handlePreciseCount(row.tableName)"
                  :title="row.preciseRows ? `精确COUNT(*)结果: ${row.preciseRows}` : '下发 COUNT(*) 精确统计'"
                >
                  {{ row.preciseRows ? row.preciseRows.toLocaleString() : '精确统计' }}
                </ElButton>
              </template>
            </ElTableColumn>
          </ElTable>
        </ElCard>
      </ElCol>

      <!-- 右侧：回填指令任务及控制台 -->
      <ElCol :span="12">
        <ElCard header="⚙️ 任务队列及指令控制中心" shadow="hover" class="rounded-xl border-none">
          <ElTable :data="tasks" row-key="id" v-loading="logLoading" style="width: 100%" height="550">
            <ElTableColumn prop="taskCode" label="任务编号" width="160" />
            <ElTableColumn label="包含日表" min-width="160" show-overflow-tooltip>
              <template #default="{ row }">
                {{ tableNames(row) }}
              </template>
            </ElTableColumn>
            <ElTableColumn label="推送量" width="110">
              <template #default="{ row }">
                {{ (row.progressPushed || 0).toLocaleString() }}
              </template>
            </ElTableColumn>
            <ElTableColumn prop="status" label="任务状态" width="110">
              <template #default="{ row }">
                <ElTag :type="getTaskStatusType(row.status)">
                  {{
                    row.status === 'dispatched'
                      ? '下发中'
                      : row.status === 'syncing'
                      ? '回填中'
                      : row.status === 'done'
                      ? '已完成'
                      : row.status === 'paused'
                      ? '已暂停'
                      : row.status === 'cancelled'
                      ? '已取消'
                      : row.status === 'failed'
                      ? '失败'
                      : row.status === 'queued'
                      ? '排队中'
                      : row.status === 'pending'
                      ? '待下发'
                      : row.status
                  }}
                </ElTag>
              </template>
            </ElTableColumn>
            <ElTableColumn label="指令操作" width="100" fixed="right">
              <template #default="{ row }">
                <ElDropdown trigger="click" @command="(cmd) => onTaskCommand(cmd, row)">
                  <ElButton size="small" type="primary" plain>操作 ▾</ElButton>
                  <template #dropdown>
                    <ElDropdownMenu>
                      <ElDropdownItem
                        v-if="['pending','queued','cancelled','failed'].includes(row.status)"
                        :command="'dispatch'"
                      >启动下发</ElDropdownItem>
                      <ElDropdownItem
                        v-if="['syncing','dispatched','queued'].includes(row.status)"
                        :command="'pause'"
                        divided
                      >暂停</ElDropdownItem>
                      <ElDropdownItem
                        v-if="row.status === 'paused'"
                        :command="'resume'"
                      >继续</ElDropdownItem>
                      <ElDropdownItem
                        v-if="['syncing','dispatched','paused','queued'].includes(row.status)"
                        :command="'cancel'"
                        divided
                      >取消</ElDropdownItem>
                      <ElDropdownItem
                        v-if="['syncing','dispatched'].includes(row.status)"
                        :command="'throttle'"
                      >限速</ElDropdownItem>
                    </ElDropdownMenu>
                  </template>
                </ElDropdown>
              </template>
            </ElTableColumn>
          </ElTable>
        </ElCard>
      </ElCol>
    </ElRow>

    <!-- 弹窗：启动回填配置 -->
    <ElDialog v-model="startDialogVisible" title="🚀 启动历史话单回填任务" width="500px">
      <ElForm :model="startForm" label-width="120px">
        <ElFormItem label="已选表数量">
          <div class="font-semibold text-blue-500">{{ selectedTables.length }} 张日表</div>
        </ElFormItem>
        <ElFormItem label="执行模式">
          <ElSelect v-model="startForm.mode" placeholder="请选择执行模式">
            <ElOption label="立即执行 (Immediate)" value="immediate" />
            <ElOption label="定时执行 (Scheduled)" value="scheduled" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem v-if="startForm.mode === 'scheduled'" label="Cron 表达式" required>
          <ElInput v-model="startForm.cron" placeholder="例如 0 0 1 * * ? (每日凌晨一点)" />
        </ElFormItem>
        <ElFormItem label="每秒限速行数" required>
          <ElInputNumber v-model="startForm.speedLimit" :min="1000" :max="100000" :step="1000" />
          <div class="text-xs text-gray-400 mt-1">控制 Agent 单实例推送速度上限，保护 VOS MySQL IO。</div>
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="startDialogVisible = false">取消</ElButton>
        <ElButton type="success" @click="submitStartBackfill">下发指令</ElButton>
      </template>
    </ElDialog>

    <!-- 弹窗：限速调节 -->
    <ElDialog v-model="throttleDialogVisible" title="⚡ 动态调整回填限流速上限" width="400px">
      <ElForm :model="throttleForm" label-width="100px">
        <ElFormItem label="每秒最大行数" required>
          <ElInputNumber v-model="throttleForm.speedLimit" :min="500" :max="100000" :step="500" />
          <div class="text-xs text-gray-400 mt-2">指令将实时送达 VOS 运行中的 Agent 协程，限速秒级生效。</div>
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="throttleDialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="submitThrottle">应用参数</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<style scoped>
.p-6 {
  padding: 1.5rem;
}
.space-y-6 > * + * {
  margin-top: 1.5rem;
}
.rounded-xl {
  border-radius: 0.75rem;
}
.border-none {
  border-style: none;
}
</style>

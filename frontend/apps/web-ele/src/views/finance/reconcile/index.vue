<script setup lang="ts">
// 占位页：对账（菜单 5042，visible=0 暂未开放）
// component: views/finance/reconcile/index.vue
// 注意：菜单 permission 串为 finance:reconcile:list（reconcile 拼写与菜单种子保持一致）
</script>

<template>
  <div class="p-6">
    <ElCard header="对账" shadow="hover" class="rounded-xl border-none">
      <ElEmpty description="本模块建设中（财务管理 · 对账）">
        <template #description>
          <div class="text-center">
            <p class="text-gray-500">该页面用于核对中台 ClickHouse 入库行数与 VOS 源端话单一致性。</p>
            <p class="text-gray-400 text-xs mt-2">权限串：<code>finance:reconcile:list</code></p>
          </div>
        </template>
      </ElEmpty>
    </ElCard>
  </div>
</template>

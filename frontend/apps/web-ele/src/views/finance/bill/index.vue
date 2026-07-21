<script setup lang="ts">
// 占位页：账单计费（菜单 5041，visible=0 暂未开放）
// component: views/finance/bill/index.vue
</script>

<template>
  <div class="p-6">
    <ElCard header="账单计费" shadow="hover" class="rounded-xl border-none">
      <ElEmpty description="本模块建设中（财务管理 · 账单计费）">
        <template #description>
          <div class="text-center">
            <p class="text-gray-500">该页面用于按租户 / VOS 实例维度展示话单同步与资源用量账单。</p>
            <p class="text-gray-400 text-xs mt-2">权限串：<code>finance:bill:list</code></p>
          </div>
        </template>
      </ElEmpty>
    </ElCard>
  </div>
</template>

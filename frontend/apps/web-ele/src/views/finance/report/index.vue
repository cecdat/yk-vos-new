<script setup lang="ts">
// 占位页：报表（菜单 5043，visible=0 暂未开放）
// component: views/finance/report/index.vue
</script>

<template>
  <div class="p-6">
    <ElCard header="报表" shadow="hover" class="rounded-xl border-none">
      <ElEmpty description="本模块建设中（财务管理 · 报表）">
        <template #description>
          <div class="text-center">
            <p class="text-gray-500">该页面用于生成与导出财务 / 运营维度的话单统计报表。</p>
            <p class="text-gray-400 text-xs mt-2">权限串：<code>finance:report:list</code></p>
          </div>
        </template>
      </ElEmpty>
    </ElCard>
  </div>
</template>

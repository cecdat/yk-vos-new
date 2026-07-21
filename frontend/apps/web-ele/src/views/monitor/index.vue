<script setup lang="ts">
// 占位页：监控大屏（菜单 5032，visible=0 暂未开放）
// component: views/monitor/index.vue
</script>

<template>
  <div class="p-6">
    <ElCard header="监控大屏" shadow="hover" class="rounded-xl border-none">
      <ElEmpty description="本模块建设中（监控运维 · 监控大屏）">
        <template #description>
          <div class="text-center">
            <p class="text-gray-500">该页面用于聚合展示全平台 VOS 节点与话单同步的全局态势。</p>
            <p class="text-gray-400 text-xs mt-2">
              跨租户聚合场景需走 <code>TenantUtils.executeIgnore(...)</code> 查询（见 SaaS 权限设计 §5）。
            </p>
          </div>
        </template>
      </ElEmpty>
    </ElCard>
  </div>
</template>

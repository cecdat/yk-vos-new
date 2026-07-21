import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/vos',
    name: 'VOS',
    meta: {
      title: '对接管理',
      icon: 'ant-design:api-outlined',
      keepAlive: false,
      // 菜单统一由后端 system_menu 下发（vos_menu.sql 5000-5043），
      // 此静态路由仅作组件/直达兜底，隐藏于侧边栏避免与后端菜单重复。
      hideInMenu: true,
    },
    redirect: '/vos/instance',
    children: [
      {
        path: 'instance',
        name: 'VOSInstance',
        component: () => import('#/views/vos/index.vue'),
        meta: {
          title: 'VOS 管理',
          icon: 'ant-design:cloud-server-outlined',
          activePath: '/vos',
          permissions: ['vos:instance:list'],
        },
      },
      {
        path: 'backfill',
        name: 'VOSBackfill',
        component: () => import('#/views/backfill/index.vue'),
        meta: {
          title: '受控历史回填',
          icon: 'ant-design:history-outlined',
          permissions: ['vos:backfill:list'],
        },
      },
      {
        path: 'agent-health',
        name: 'VOSAgentHealth',
        component: () => import('#/views/vos/agent-health/index.vue'),
        meta: {
          title: 'Agent 健康看板',
          icon: 'ant-design:heart-outlined',
          activePath: '/vos',
          permissions: ['vos:agent:health'],
        },
      },
      {
        path: 'monitor',
        name: 'VOSMonitor',
        component: () => import('#/views/monitor/index.vue'),
        meta: {
          title: '监控大屏',
          icon: 'ant-design:dashboard-outlined',
          activePath: '/vos',
          permissions: ['vos:monitor:screen'],
        },
      },
    ],
  },
];

export default routes;

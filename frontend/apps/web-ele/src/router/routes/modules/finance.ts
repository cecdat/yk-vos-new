import type { RouteRecordRaw } from 'vue-router';

// 财务管理模块路由（占位，菜单 visible=0 暂未开放）
// 菜单 component 路径：views/finance/{bill,reconcile,report}/index.vue
const routes: RouteRecordRaw[] = [
  {
    path: '/finance',
    name: 'Finance',
    meta: {
      title: '财务管理',
      icon: 'ant-design:accountbook-outlined',
      keepAlive: false,
    },
    redirect: '/finance/bill',
    children: [
      {
        path: 'bill',
        name: 'FinanceBill',
        component: () => import('#/views/finance/bill/index.vue'),
        meta: {
          title: '账单计费',
          icon: 'ant-design:money-collected-outlined',
          activePath: '/finance',
          permissions: ['finance:bill:list'],
        },
      },
      {
        path: 'reconcile',
        name: 'FinanceReconcile',
        component: () => import('#/views/finance/reconcile/index.vue'),
        meta: {
          title: '对账',
          icon: 'ant-design:swap-outlined',
          activePath: '/finance',
          permissions: ['finance:reconcile:list'],
        },
      },
      {
        path: 'report',
        name: 'FinanceReport',
        component: () => import('#/views/finance/report/index.vue'),
        meta: {
          title: '报表',
          icon: 'ant-design:file-text-outlined',
          activePath: '/finance',
          permissions: ['finance:report:list'],
        },
      },
    ],
  },
];

export default routes;

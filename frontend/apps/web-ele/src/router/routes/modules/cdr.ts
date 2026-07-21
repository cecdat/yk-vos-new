import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/cdr',
    name: 'CDR',
    meta: {
      title: '话单管理',
      icon: 'ant-design:file-search-outlined',
      keepAlive: false,
      // 菜单统一由后端 system_menu 下发（vos_menu.sql 5050/5051），
      // 此静态路由仅作组件/直达兜底，隐藏于侧边栏避免与后端菜单重复。
      hideInMenu: true,
    },
    redirect: '/cdr/query',
    children: [
      {
        path: 'query',
        name: 'CDRQuery',
        component: () => import('#/views/cdr/index.vue'),
        meta: {
          title: '话单查询',
          icon: 'ant-design:search-outlined',
          activePath: '/cdr',
        },
      },
    ],
  },
];

export default routes;

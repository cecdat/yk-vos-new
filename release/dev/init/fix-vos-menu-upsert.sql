-- ============================================================
-- 修正「VOS 菜单看不到」：upsert 覆盖旧库残骸行
-- 适用：同机多次部署遗留的旧 system_menu 行（乱码名 / status=0 /
--       parent_id 错），原 INSERT IGNORE 不会覆盖，导致整棵 VOS
--       子树被隐藏。本文件用 ON DUPLICATE KEY UPDATE 强制修正。
-- 用法（在 /data/vos-dev 下）：
--   docker compose exec -T mysql mysql -uroot -p123456 ykvos < release/dev/init/fix-vos-menu-upsert.sql
-- 跑完 admin 重新登录即可见「VOS 数据中台 / 话单管理」。
-- 幂等，可反复执行。
-- ============================================================
INSERT INTO `system_menu`
  (`id`, `name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
VALUES
(5000, 'VOS 数据中台', '', 1, 5000, 0, '', 'ant-design:cloud-server-outlined', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5010, '对接管理', '', 1, 5010, 5000, '/vos', 'ant-design:api-outlined', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5011, 'VOS 管理', 'vos:instance:list', 2, 5011, 5010, '/vos/instance', 'ant-design:cloud-outlined', 'views/vos/index.vue', 'VOSInstance', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5012, '新增', 'vos:instance:create', 3, 5012, 5011, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5013, '编辑', 'vos:instance:update', 3, 5013, 5011, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5014, '删除', 'vos:instance:delete', 3, 5014, 5011, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5020, '历史话单回填', 'vos:backfill:list', 2, 5020, 5010, '/vos/backfill', 'ant-design:history-outlined', 'views/backfill/index.vue', 'VOSBackfill', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5021, '立即/定时接收', 'vos:backfill:start', 3, 5021, 5020, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5022, '暂停', 'vos:backfill:pause', 3, 5022, 5020, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5023, '恢复', 'vos:backfill:resume', 3, 5023, 5020, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5024, '取消', 'vos:backfill:cancel', 3, 5024, 5020, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5025, '重新扫描', 'vos:backfill:rescan', 3, 5025, 5020, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5026, '精确计数', 'vos:backfill:precise-count', 3, 5026, 5020, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5027, '调速', 'vos:backfill:throttle', 3, 5027, 5020, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5028, '号码管理', 'vos:phone:list', 2, 5028, 5010, '/vos/phone', 'ant-design:phone-outlined', 'views/vos/phone/index.vue', 'VOSPhone', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5029, '号码删除', 'vos:phone:delete', 3, 5029, 5028, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5030, '监控运维', '', 1, 5030, 5000, '', 'ant-design:monitor-outlined', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5031, 'Agent 健康看板', 'vos:agent:health', 2, 5031, 5030, '/vos/agent-health', 'ant-design:heart-outlined', 'views/vos/agent-health/index.vue', 'VOSAgentHealth', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5033, '网关监控', 'vos:gateway:list', 2, 5033, 5030, '/vos/gateway', 'ant-design:partition-outlined', 'views/vos/gateway/index.vue', 'VOSGateway', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5040, '财务管理', '', 1, 5040, 5000, '/finance', 'ant-design:accountbook-outlined', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5041, '账单计费', 'finance:bill:list', 2, 5041, 5040, '/finance/bill', 'ant-design:money-collected-outlined', 'views/finance/bill/index.vue', 'FinanceBill', 0, 0, 0, 0, '1', NOW(), '1', NOW(), 0),
(5042, '对账', 'finance:reconcile:list', 2, 5042, 5040, '/finance/reconcile', 'ant-design:swap-outlined', 'views/finance/reconcile/index.vue', 'FinanceReconcile', 0, 0, 0, 0, '1', NOW(), '1', NOW(), 0),
(5043, '对账报表', 'finance:report:list', 2, 5043, 5040, '/finance/report', 'ant-design:file-text-outlined', 'views/vos/report/index.vue', 'VOSReport', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5044, '客户管理', 'vos:customer:list', 2, 5044, 5040, '/finance/customer', 'ant-design:user-outlined', 'views/vos/customer/index.vue', 'VOSCustomer', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5045, '限额调整', 'vos:customer:write', 3, 5045, 5044, '', '', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5050, '话单管理', '', 1, 5050, 5000, '/cdr', 'ant-design:file-search-outlined', '', '', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0),
(5051, '话单查询', 'cdr:query:list', 2, 5051, 5050, '/cdr/query', 'ant-design:search-outlined', 'views/cdr/index.vue', 'CDRQuery', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0)
ON DUPLICATE KEY UPDATE
  `name`=VALUES(`name`), `permission`=VALUES(`permission`), `type`=VALUES(`type`),
  `sort`=VALUES(`sort`), `parent_id`=VALUES(`parent_id`), `path`=VALUES(`path`),
  `icon`=VALUES(`icon`), `component`=VALUES(`component`), `component_name`=VALUES(`component_name`),
  `status`=VALUES(`status`), `visible`=VALUES(`visible`), `keep_alive`=VALUES(`keep_alive`),
  `always_show`=VALUES(`always_show`), `updater`=VALUES(`updater`), `update_time`=NOW();

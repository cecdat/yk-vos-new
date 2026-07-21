-- ============================================================
-- yk-vos-new · 把已部署库的 VOS 菜单【层级】迁移到新分组结构
-- ============================================================
-- 适用：之前用「旧版 vos_menu.sql（扁平结构）」初始化过、且不想重新建库重装的测试环境。
-- 旧结构：5011/5051 是 MENU 叶节点，5020 历史话单回填、5031 Agent 健康看板
--          直接挂在 5000 / 5050 顶级 DIR 下。
-- 新结构：5011 VOS 管理、5051 话单查询 变为【分组 DIR】，其下分别挂
--          【VOS 节点管理 + Agent 健康看板】、【历史话单 + 历史话单回填】。
-- 执行：docker compose exec -T mysql mysql -uroot -p123456 ykvos \
--          < release/dev/init/fix-vos-menu-routes.sql
--       然后 admin 重新登录即可（无需重启后端）。
-- 说明：本脚本对全新部署无效也不需执行（全新部署直接由 vos_menu.sql 初始化）。
-- ============================================================

-- 1) 5011 变为分组 DIR（原节点页内容交给新 id 5015）
UPDATE `system_menu` SET `type`=1, `component`='', `component_name`='', `path`='vos-mgr' WHERE `id`=5011;

-- 2) 新增 5015 VOS 节点管理（即原 5011 的页面）
INSERT IGNORE INTO `system_menu`
  (`id`, `name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
VALUES
  (5015, 'VOS 节点管理', 'vos:instance:list', 2, 5012, 5011, 'node', 'ant-design:cloud-outlined', 'vos/index', 'VOSInstance', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0);

-- 3) 原 5011 下的按钮（新增/编辑/删除）改挂到 5015 下
UPDATE `system_menu` SET `parent_id`=5015 WHERE `parent_id`=5011 AND `type`=3;

-- 4) 5031 Agent 健康看板 挂到 5011 下，并设为可见
UPDATE `system_menu` SET `parent_id`=5011, `visible`=1, `path`='agent-health',
  `component`='vos/agent-health/index', `component_name`='VOSAgentHealth' WHERE `id`=5031;

-- 5) 5051 变为分组 DIR（原历史话单页内容交给新 id 5055）
UPDATE `system_menu` SET `type`=1, `component`='', `component_name`='', `path`='cdr-query' WHERE `id`=5051;

-- 6) 新增 5055 历史话单（即原 5051 的页面）
INSERT IGNORE INTO `system_menu`
  (`id`, `name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
VALUES
  (5055, '历史话单', 'cdr:query:list', 2, 5052, 5051, 'history', 'ant-design:history-outlined', 'cdr/index', 'CDRQuery', 0, 1, 0, 0, '1', NOW(), '1', NOW(), 0);

-- 7) 5020 历史话单回填 从 5000 改挂到 5051 下，并设为可见
UPDATE `system_menu` SET `parent_id`=5051, `visible`=1, `path`='backfill',
  `component`='backfill/index', `component_name`='VOSBackfill' WHERE `id`=5020;

-- 8) 顶级 DIR / 监控大屏 / 财务子页 与全量包保持一致
UPDATE `system_menu` SET `path`='/vos', `component`='', `component_name`='' WHERE `id`=5000;
UPDATE `system_menu` SET `path`='monitor', `component`='monitor/index', `component_name`='VOSMonitor', `visible`=0 WHERE `id`=5032;
UPDATE `system_menu` SET `path`='/finance', `component`='', `component_name`='' WHERE `id`=5040;
UPDATE `system_menu` SET `path`='bill', `component`='finance/bill/index', `component_name`='FinanceBill' WHERE `id`=5041;
UPDATE `system_menu` SET `path`='reconcile', `component`='finance/reconcile/index', `component_name`='FinanceReconcile' WHERE `id`=5042;
UPDATE `system_menu` SET `path`='report', `component`='finance/report/index', `component_name`='FinanceReport' WHERE `id`=5043;
UPDATE `system_menu` SET `path`='/cdr', `component`='', `component_name`='' WHERE `id`=5050;

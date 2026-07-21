-- ============================================================
-- 即时修复「VOS 菜单看不到」根因：菜单 status 写反了
--   yudao：status=0 启用(开启) / status=1 禁用(关闭)
--   原 vos_menu.sql 把整棵 VOS 子树写成 status=1=禁用，
--   getRouters 递归判定禁用 → 侧边栏整棵不显示。
-- 本文件把 VOS 全部菜单（含可见与预留隐藏项）status 改回 0。
-- 用法（在 /data/vos-dev 下）：
--   docker compose exec -T mysql mysql -uroot -p123456 ykvos \
--     < release/dev/init/fix-vos-menu-status.sql
-- 跑完 admin 重新登录即可见「VOS 数据中台 / 话单管理」。
-- 幂等，可反复执行。
-- ============================================================
UPDATE `system_menu`
SET `status` = 0, `updater` = '1', `update_time` = NOW()
WHERE `id` IN (
    5000, 5010, 5011, 5012, 5013, 5014,
    5020, 5021, 5022, 5023, 5024, 5025, 5026, 5027,
    5030, 5031, 5032,
    5040, 5041, 5042, 5043,
    5050, 5051
);

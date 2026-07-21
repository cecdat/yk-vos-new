import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';

/** 从 base_url 中提取 host 部分（如 http://1.2.3.4:8080 -> 1.2.3.4:8080） */
export function extractHost(baseUrl?: string): string {
  if (!baseUrl) {
    return '';
  }
  try {
    return new URL(baseUrl).host;
  } catch {
    return baseUrl;
  }
}

/** 新增/修改的表单 */
export function useFormSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      fieldName: 'id',
      dependencies: {
        triggerFields: [''],
        show: () => false,
      },
    },
    {
      fieldName: 'vos_id',
      label: 'Agent ID',
      component: 'Input',
      componentProps: {
        placeholder: '请输入 Agent 实例 ID (例如 vos1)',
      },
      rules: 'required',
    },
    {
      fieldName: 'name',
      label: '名称',
      component: 'Input',
      componentProps: {
        placeholder: '请输入 VOS 实例名称',
      },
      rules: 'required',
    },
    {
      fieldName: 'base_url',
      label: 'IP / 地址',
      component: 'Input',
      componentProps: {
        placeholder: '请输入地址，例如 http://1.2.3.4:8080',
      },
      rules: 'required',
    },
    {
      fieldName: 'description',
      label: '备注',
      component: 'Textarea',
      componentProps: {
        placeholder: '请输入备注',
        rows: 3,
      },
    },
    {
      fieldName: 'enabled',
      label: '启用',
      component: 'Switch',
      componentProps: {
        activeValue: true,
        inactiveValue: false,
      },
    },
  ];
}

/** 列表的字段 */
export function useGridColumns(): VxeTableGridOptions['columns'] {
  return [
    {
      field: 'id',
      title: '编号',
      minWidth: 80,
    },
    {
      field: 'vos_id',
      title: 'Agent ID',
      minWidth: 120,
    },
    {
      field: 'name',
      title: '名称',
      minWidth: 160,
    },
    {
      field: 'base_url',
      title: 'IP / 地址',
      minWidth: 220,
      slots: { default: 'base_url' },
    },
    {
      field: 'enabled',
      title: '状态',
      minWidth: 100,
      slots: { default: 'enabled' },
    },
    {
      field: 'health_status',
      title: '健康',
      minWidth: 120,
      slots: { default: 'health_status' },
    },
    {
      field: 'description',
      title: '备注',
      minWidth: 200,
    },
    {
      field: 'health_last_check',
      title: '最近检查',
      minWidth: 180,
      formatter: 'formatDateTime',
    },
    {
      title: '操作',
      width: 160,
      fixed: 'right',
      slots: { default: 'actions' },
    },
  ];
}

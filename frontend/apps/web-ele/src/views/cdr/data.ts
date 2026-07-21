import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { CdrApi } from '#/api/cdr';

/** 毫秒时间戳 -> yyyy-MM-dd HH:mm:ss，失败返回空串 */
export function formatTs(ts?: number | null): string {
  if (ts == null || Number.isNaN(ts)) {
    return '';
  }
  const d = new Date(ts);
  if (Number.isNaN(d.getTime())) {
    return '';
  }
  const p = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`;
}

/** 挂断方数值 -> 文案 */
const endDirectionMap: Record<number, string> = {
  0: '主叫',
  1: '被叫',
  2: '服务器',
};
export function formatEndDirection(v?: number | null): string {
  if (v == null) {
    return '-';
  }
  return endDirectionMap[v] ?? '-';
}

/** yyyy-MM-dd -> yyyyMMdd（接口要求格式） */
export function formatYmd(date?: string): string {
  if (!date) {
    return '';
  }
  return date.replace(/[-/]/g, '');
}

/** 话单列表的列定义 */
export function useGridColumns(): VxeTableGridOptions['columns'] {
  return [
    {
      field: 'flowNo',
      title: '话单ID',
      minWidth: 160,
    },
    {
      field: 'account',
      title: '账号',
      minWidth: 140,
    },
    {
      field: 'accountName',
      title: '账户名称',
      minWidth: 140,
    },
    {
      field: 'callerAccessE164',
      title: '主叫号码',
      minWidth: 140,
    },
    {
      field: 'calleeAccessE164',
      title: '被叫号码',
      minWidth: 140,
    },
    {
      field: 'calleeGateway',
      title: '网关',
      minWidth: 120,
    },
    {
      field: 'start',
      title: '开始时间',
      minWidth: 180,
      slots: { default: 'start' },
    },
    {
      field: 'stop',
      title: '结束时间',
      minWidth: 180,
      slots: { default: 'stop' },
    },
    {
      field: 'holdTime',
      title: '通话时长(秒)',
      minWidth: 120,
    },
    {
      field: 'feeTime',
      title: '计费时长(秒)',
      minWidth: 120,
    },
    {
      field: 'fee',
      title: '费用(元)',
      minWidth: 100,
    },
    {
      field: 'endDirection',
      title: '挂断方',
      minWidth: 100,
      slots: { default: 'endDirection' },
    },
    {
      field: 'endReason',
      title: '终止原因',
      minWidth: 160,
    },
  ];
}

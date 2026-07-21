import re
txt = open(r'D:/github/yk-vos/vos3000_structure.sql', encoding='utf-8', errors='ignore').read()
blocks = re.findall(r'CREATE TABLE\s+`?(\w+)`?\s*\((.*?)\)\s*ENGINE=(\w+)', txt, re.S)
print('建表块数:', len(blocks))
from collections import Counter
print('引擎分布:', dict(Counter(e for _, _, e in blocks)))
cdr = [n for n, _, _ in blocks if n.startswith('e_cdr')]
print('e_cdr 系列数量:', len(cdr))
print()
print('=== 全部表名 + 引擎 + 列数（按出现序）===')
for n, body, e in blocks:
    cols = len(re.findall(r'`\w+`', body))
    print(f'{n:34s} {e:9s} cols={cols}')

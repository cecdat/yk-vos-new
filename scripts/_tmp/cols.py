import re
txt = open(r'D:/github/yk-vos/vos3000_structure.sql', encoding='utf-8', errors='ignore').read()

def cols(name):
    m = re.search(r'CREATE TABLE\s+`?' + re.escape(name) + r'`?\s*\((.*?)\)\s*ENGINE=', txt, re.S)
    if not m:
        return None
    body = m.group(1)
    # 仅取列定义（跳过 KEY/INDEX 行）：列以 `name` type 开头
    out = []
    for line in body.split(',\n'):
        line = line.strip()
        cm = re.match(r'`(\w+)`\s+(\w+)', line)
        if cm:
            out.append(cm.group(1))
    return out

tables = ['e_customer','e_customerdetail','e_gatewaymapping','e_gatewaymappingsetting',
'e_gatewaygroup','e_gatewayrouting','e_gatewayroutingsetting','e_feerate','e_feerategroup',
'e_feeratesection','e_feeratebytime','e_phone','e_phonecard','e_axb_cdr','e_ivr_cdr',
'e_aas_cdr','e_payhistory','e_consumption','e_suite','e_suiteorder','e_limit_e164',
'e_limit_e164_group','e_terminal_black_list_policy','e_system_limit_e164','e_ip_limit',
'e_web_access_control','e_alarm_current','e_alarm_history','e_alarm_setting',
'e_reportcustomerfee','e_reportcustomerclearingfee','e_reportgatewaymappingfee',
'e_reportagentincome','e_areacode','e_citycode','e_mobilearea','e_user','e_userlogin',
'e_syslog','e_bindede164','e_groupe164','e_privatephonebook','e_publicphonebook',
'e_currentsuite','e_reportmanagement','e_black_list']

for t in tables:
    c = cols(t)
    if c is None:
        print(f'{t:32s} >> 未找到')
    else:
        print(f'{t:32s} [{len(c)}]: {",".join(c)}')

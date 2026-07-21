package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import lombok.Data;

import java.util.List;

/**
 * 话单查询请求 VO（对应前端 CdrApi.CdrQueryParams）
 * <p>begin_time / end_time 格式为 yyyyMMdd，对应 CH 表 recordstarttime 的日期范围。</p>
 *
 * @author ykxx
 */
@Data
public class VosCdrQueryReqVO {

    /**
     * 开始时间，yyyyMMdd 格式
     */
    private String beginTime;

    /**
     * 结束时间，yyyyMMdd 格式
     */
    private String endTime;

    /**
     * 页码，从 1 开始
     */
    private Integer page = 1;

    /**
     * 每页数量，默认 20，最大 1000
     */
    private Integer pageSize = 20;

    /**
     * 客户账号（逗号分隔，可选）
     */
    private String accounts;

    /**
     * 主叫号码（可选）
     */
    private String callerE164;

    /**
     * 被叫号码（可选）
     */
    private String calleeE164;

    /**
     * 被叫网关（可选）
     */
    private String calleeGateway;

    /**
     * 是否排除零费用话单
     */
    private Boolean excludeZeroFee;

    public List<String> getAccountList() {
        if (accounts == null || accounts.isBlank()) {
            return java.util.Collections.emptyList();
        }
        java.util.List<String> list = new java.util.ArrayList<>();
        for (String s : accounts.split(",")) {
            String t = s.trim();
            if (!t.isEmpty()) {
                list.add(t);
            }
        }
        return list;
    }
}

package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

/**
 * VOS 实例分页 Request VO
 *
 * @author yk-vos-new
 */
@Schema(description = "管理后台 - VOS 实例分页 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class VosInstancePageReqVO extends PageParam {

    @Schema(description = "名称", example = "北京节点")
    private String name;

    @Schema(description = "Agent ID", example = "vos1")
    @JsonProperty("vos_id")
    private String vosId;

}

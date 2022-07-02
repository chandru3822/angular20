package com.albatross.api.v1.flow.model.workQueue;

import com.albatross.api.v1.flow.model.WhiteListedPosition;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueCategory {
    private Long id, companyId, displayOrder;
    private String workQueueCategory, color;
    private Boolean archived, hidden;
    private List<WhiteListedPosition> hiddenWhiteListedPositions;
}

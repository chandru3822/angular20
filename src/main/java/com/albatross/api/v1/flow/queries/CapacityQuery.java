package com.albatross.api.v1.flow.queries;

public class CapacityQuery {

    //language=PostgreSQL
    public final static String getForRange = """
            SELECT
              vrsc.id,
              vrsc.max_capacity,
              vrsc.start_time,
              vrsc.end_time
            FROM flow.virtual_resource_slot_capacity vrsc
            WHERE vrsc.start_time > :rangeStart and
            	      vrsc.start_time < :rangeEnd and
            	      vrsc.org_id = :orgId and
            	      vrsc.archived = false
            """;
}

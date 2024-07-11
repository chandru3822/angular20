package com.albatross.api.v1.company.blueraven.controllers.apiManagement;

public record ApiManagementQuery() {
    //language=PostgreSQL
    public final static String getPartners = """
        select
            id,
            partner_code as code,
            partner_name as name,
            coalesce((select to_jsonb(array_agg(row_to_json(rows))) from (
                select
                    id,
                    partner_id as "partnerId",
                    external_key as key,
                    description,
                    valid_until as "validUntil",
                    date_created as "dateCreated",
                    date_modified as "dateModified",
                    created_by as "createdBy",
                    modified_by as "modifiedBy",
                    is_admin as "isAdmin"
                from api.api_key ak
                where ak.partner_id = p.id
                order by ak.description
            ) rows), '[]') as keys
        from api.partner p
        order by p.partner_name
    """;

    //langeuate=PostreSQL
    public final static String addPartner = """
        insert into api.partner (partner_code, partner_name, created_by, modified_by)
        values (:code, :name, :userId, :userId)
        returning
            id,
            partner_code as code,
            partner_name as name,
            '[]'::jsonb as keys
    """;

    //language=PostgreSQL
    public final static String updatePartner = """
        update api.partner
        set
            partner_name = :name,
            date_modified = now(),
            modified_by = :userId
        where id = :id
    """;

    //language=PostgreSQL
    public final static String addKey = """
        insert into api.api_key (description, created_by, modified_by, is_admin, partner_id)
        values (:description, :userId, :userId, :isAdmin, :partnerId)
        returning
            id,
            partner_id,
            external_key as key,
            description,
            valid_until,
            date_created,
            date_modified,
            created_by,
            modified_by,
            is_admin
    """;

    //language=PostgreSQL
    public final static String updateKey = """
        update api.api_key
        set
            description = :description,
            valid_until = :validUntil,
            is_admin = :isAdmin,
            date_modified = now(),
            modified_by = :userId
        where id = :id
    """;
}

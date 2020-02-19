ALTER TABLE flow.work_queue_type
    DROP CONSTRAINT if exists flow_wqt_work_queue_category_id_fk;

ALTER TABLE flow.work_queue_type
    ADD CONSTRAINT flow_wqt_work_queue_category_id_fk FOREIGN KEY (work_queue_category_id)
        REFERENCES flow.work_queue_category (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT;


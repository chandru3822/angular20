alter table if exists flow.work_queue_type
add column if not exists column_sorting_order jsonb default null;

update flow.work_queue_type
SET column_sorting_order = json('[' ||
                                '{"columnSortingOrder": "Primary", "sortDesc": false, "value": null},' ||
                                '{"columnSortingOrder": "Secondary", "sortDesc": false, "value": null},' ||
                                '{"columnSortingOrder": "Tertiary", "sortDesc": false, "value": null}]');



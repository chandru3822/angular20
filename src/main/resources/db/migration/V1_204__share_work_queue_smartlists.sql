-- make public the smartlists that were just created for work queues
update flow.smartlist
set shared = true
where owner_id = 99999999;
CREATE index if not exists emails_sent_user_id_idx
    on flow.emails_sent (user_id);

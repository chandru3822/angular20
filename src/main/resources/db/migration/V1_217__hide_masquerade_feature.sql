--oops forgot to set masquerade as system so that it doesn't show in company tools
update flow.feature
set is_system = true
where feature_code = 'MASQUERADE';

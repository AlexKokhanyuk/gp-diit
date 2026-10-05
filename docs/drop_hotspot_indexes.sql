-- Optional experiment: remove indexes that usually protect DELETE subqueries from full scans.
-- Run only on the lab database, never on production.
DROP INDEX xie_user_ledgers_user_id;
DROP INDEX xie_key_events_key_id;
DROP INDEX xie_ledger_accounts_subject_id;
DROP INDEX xie_loan_contracts_subject_id;
DROP INDEX xie_agent_cards_agent_id;










